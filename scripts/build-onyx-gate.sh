#!/bin/bash
# ============================================================================
# ONYX-GATE Pre-Boot Authentication (PBA) - Clean Build Script
# ============================================================================
#
# Умная система сборки использующая существующие файлы проекта:
# - Все конфигурации хранятся в git-репозитории
# - Умная пересборка только измененных компонентов
# - Правильная структура проекта с board/ директорией
# - Совместимость с CI/CD
#
# Файлы проекта:
# - configs/buildroot/onyx_gate_defconfig - Buildroot конфигурация
# - board/onyx-gate/rootfs-overlay/ - Overlay файловой системы
# - board/onyx-gate/grub.cfg - GRUB конфигурация
#
# ============================================================================

set -e  # Exit immediately if any command fails

echo "🖤 ONYX-GATE Clean Build System"
echo "==============================="

# ----------------------------------------------------------------------------
# BUILD ENVIRONMENT SETUP
# ----------------------------------------------------------------------------
VERSION=$(git describe --tags --always --dirty 2>/dev/null || echo "dev")
BUILD_DATE=$(date -u)
BUILD_HOST=$(hostname)
CI_BUILD=${CI:-false}

echo "📋 Build Environment:"
echo "   Version: $VERSION"
echo "   Date: $BUILD_DATE"
echo "   Host: $BUILD_HOST"
echo "   CPU Cores: $(nproc)"
echo "   CI Build: $CI_BUILD"
echo ""

# ============================================================================
# STEP 1: VALIDATE PROJECT STRUCTURE
# ============================================================================
echo "🔍 Step 1: Validating project structure..."

# Check required files exist
REQUIRED_FILES=(
    "configs/buildroot/onyx_gate_defconfig"
    "board/onyx-gate/rootfs-overlay/etc/init.d/S99onyx-pba"
    "board/onyx-gate/grub.cfg"
    "src/main.c"
    "src/logger.c"
)

echo "   → Checking required files..."
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "   ❌ Missing required file: $file"
        echo ""
        echo "Please create the missing files. Run:"
        echo "mkdir -p board/onyx-gate/rootfs-overlay/etc/init.d"
        echo "mkdir -p configs/buildroot"
        exit 1
    fi
    echo "   ✓ $file"
done

# Ensure directories exist
mkdir -p board/onyx-gate/rootfs-overlay/usr/bin
mkdir -p images/{img,checksums}

echo "✅ Project structure validated"

# ============================================================================
# STEP 2: C APPLICATION BUILD & TESTING
# ============================================================================
echo ""
echo "🔧 Step 2: Building C application..."

# Clean previous build
rm -rf build

# Configure and build
cmake -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_TESTING=ON \
    -DCMAKE_BUILD_DATE="$BUILD_DATE"

echo "   → Compiling with $(nproc) parallel jobs..."
cmake --build build --parallel $(nproc)

echo "   → Running unit tests..."
cd build && ctest --output-on-failure && cd ..

echo "   → Testing PBA binary..."
./build/src/onyx-gate-pba --test

echo "✅ C application built and tested successfully"
echo "   Binary size: $(du -h build/src/onyx-gate-pba | cut -f1)"

# ============================================================================
# STEP 3: UPDATE OVERLAY WITH LATEST BINARY
# ============================================================================
echo ""
echo "📦 Step 3: Updating filesystem overlay..."

echo "   → Installing PBA binary to overlay..."
cp build/src/onyx-gate-pba board/onyx-gate/rootfs-overlay/usr/bin/
chmod +x board/onyx-gate/rootfs-overlay/usr/bin/onyx-gate-pba

echo "   → Verifying overlay structure..."
echo "   Files in overlay: $(find board/onyx-gate/rootfs-overlay -type f | wc -l)"
find board/onyx-gate/rootfs-overlay -type f | while read file; do
    echo "     $(ls -la "$file" | awk '{print $1, $9}')"
done

echo "✅ Overlay updated successfully"

# ============================================================================
# STEP 4: SMART BUILD ANALYSIS
# ============================================================================
echo ""
echo "🧠 Step 4: Smart build analysis..."

# Build strategy detection functions
needs_full_rebuild() {
    # Always full rebuild in CI
    if [ "$CI_BUILD" = "true" ]; then
        echo "CI environment detected"
        return 0
    fi

    # Full rebuild if no previous build
    if [ ! -d "buildroot-output" ] || [ ! -f "buildroot-output/.config" ]; then
        echo "No previous build found"
        return 0
    fi

    # Full rebuild if defconfig changed
    if [ configs/buildroot/onyx_gate_defconfig -nt buildroot-output/.config ]; then
        echo "Buildroot configuration changed"
        return 0
    fi

    # Full rebuild if build script changed
    if [ "$0" -nt buildroot-output/.config ]; then
        echo "Build script updated"
        return 0
    fi

    return 1
}

needs_image_rebuild() {
    # Check if any output images exist
    if [ ! -f "buildroot-output/images/rootfs.cpio.gz" ]; then
        echo "No images found"
        return 0
    fi

    # Image rebuild if PBA binary changed
    if [ build/src/onyx-gate-pba -nt buildroot-output/images/rootfs.cpio.gz ]; then
        echo "PBA binary updated"
        return 0
    fi

    # Image rebuild if overlay files changed
    if find board/onyx-gate/rootfs-overlay -newer buildroot-output/images/rootfs.cpio.gz 2>/dev/null | grep -q .; then
        echo "Overlay files updated"
        return 0
    fi

    return 1
}

# Determine build strategy
BUILD_STRATEGY="none"
BUILD_REASON=""

if needs_full_rebuild; then
    BUILD_STRATEGY="full"
    BUILD_REASON=$(needs_full_rebuild 2>&1 | head -1)
elif needs_image_rebuild; then
    BUILD_STRATEGY="images"
    BUILD_REASON=$(needs_image_rebuild 2>&1 | head -1)
fi

echo "   Build strategy: $BUILD_STRATEGY"
echo "   Reason: $BUILD_REASON"

# ============================================================================
# STEP 5: EXECUTE BUILD STRATEGY
# ============================================================================
echo ""
echo "🔨 Step 5: Executing build strategy ($BUILD_STRATEGY)..."

cd external/buildroot

case "$BUILD_STRATEGY" in
    "full")
        echo "   → Full system rebuild (~10-15 minutes)"
        echo "     - Cleaning previous artifacts"
        echo "     - Loading ONYX-GATE defconfig"
        echo "     - Compiling Linux kernel and packages"
        echo "     - Creating filesystem images"

        # Clean and reconfigure
        make O=../../buildroot-output clean
        make O=../../buildroot-output BR2_DEFCONFIG=../../configs/buildroot/onyx_gate_defconfig defconfig

        # Full build
        make O=../../buildroot-output -j$(($(nproc) - 1))
        ;;

    "images")
        echo "   → Quick image rebuild (~1-2 minutes)"
        echo "     - Using existing compiled packages"
        echo "     - Updating overlay integration"
        echo "     - Regenerating filesystem images"

        # Force rebuild of target filesystem and images
        rm -rf buildroot-output/target/usr/bin/onyx-gate-pba
        rm -f buildroot-output/images/rootfs.*

        # Rebuild only images (much faster)
        make O=../../buildroot-output target-finalize
        make O=../../buildroot-output rootfs-cpio-gzip rootfs-ext2
        ;;

    "none")
        echo "   → No rebuild needed, using cached artifacts"
        if [ ! -f "../../buildroot-output/images/rootfs.cpio.gz" ]; then
            echo "   ⚠️  Warning: No images found despite analysis, forcing full rebuild"
            BUILD_STRATEGY="full"
            make O=../../buildroot-output clean
            make O=../../buildroot-output BR2_DEFCONFIG=../../configs/buildroot/onyx_gate_defconfig defconfig
            make O=../../buildroot-output -j$(($(nproc) - 1))
        fi
        ;;
esac

cd ../..

# Verify build results
if [ ! -f "buildroot-output/images/bzImage" ]; then
    echo "❌ Build failed: kernel image not found"
    exit 1
fi

if [ ! -f "buildroot-output/images/rootfs.cpio.gz" ]; then
    echo "❌ Build failed: root filesystem not found"
    exit 1
fi

echo "✅ Build completed successfully"
echo "   Strategy used: $BUILD_STRATEGY ($BUILD_REASON)"
echo "   Kernel: ✓ Present ($(du -h buildroot-output/images/bzImage | cut -f1))"
echo "   Root FS: ✓ Present ($(du -h buildroot-output/images/rootfs.cpio.gz | cut -f1))"

# ============================================================================
# STEP 6: DEPLOYABLE IMAGE CREATION
# ============================================================================
echo ""
echo "📀 Step 6: Creating deployable images..."

echo "   → Copying files for direct testing..."
cp buildroot-output/images/bzImage "images/bzImage"
cp buildroot-output/images/rootfs.cpio.gz "images/rootfs.cpio.gz"

echo "   → Creating bootable IMG for production deployment..."
# Create bootable disk image with proper structure
dd if=/dev/zero of="images/img/onyx-gate-pba-$VERSION.img" bs=1M count=32 2>/dev/null

# Create MBR partition table
fdisk "images/img/onyx-gate-pba-$VERSION.img" >/dev/null 2>&1 << FDISK_EOF
n
p
1


a
1
w
FDISK_EOF

# Setup loop device and format
LOOP_DEVICE=$(sudo losetup -f --show "images/img/onyx-gate-pba-$VERSION.img")
sudo partprobe $LOOP_DEVICE
sudo mkfs.ext2 -F "${LOOP_DEVICE}p1" >/dev/null 2>&1

# Mount and populate IMG
IMG_MOUNT="/tmp/onyx-img-mount"
sudo mkdir -p $IMG_MOUNT
sudo mount "${LOOP_DEVICE}p1" $IMG_MOUNT

# Copy kernel and initrd
sudo mkdir -p $IMG_MOUNT/boot
sudo cp buildroot-output/images/bzImage $IMG_MOUNT/boot/
sudo cp buildroot-output/images/rootfs.cpio.gz $IMG_MOUNT/boot/initrd

# Install GRUB configuration
sudo mkdir -p $IMG_MOUNT/boot/grub
sudo cp board/onyx-gate/grub.cfg $IMG_MOUNT/boot/grub/

# Install GRUB bootloader
echo "   → Installing GRUB bootloader..."
sudo grub-install --target=i386-pc --boot-directory=$IMG_MOUNT/boot --force --no-floppy $LOOP_DEVICE >/dev/null 2>&1

# Cleanup
sudo umount $IMG_MOUNT
sudo rmdir $IMG_MOUNT
sudo losetup -d $LOOP_DEVICE

echo "   → Creating compressed image..."
gzip -k "images/img/onyx-gate-pba-$VERSION.img"

echo "   → Generating checksums and manifest..."
cd images
find . -name "bzImage" -o -name "*.cpio.gz" -o -name "*.img" -o -name "*.gz" | sort | xargs sha256sum > checksums/sha256sums.txt

# Create detailed build manifest
cat > checksums/build-manifest.txt << MANIFEST_EOF
ONYX-GATE PBA Build Manifest
============================

Build Information:
- Version: $VERSION
- Build Date: $BUILD_DATE
- Build Host: $BUILD_HOST
- Build Strategy: $BUILD_STRATEGY
- Build Reason: $BUILD_REASON
- Git Commit: $(git rev-parse HEAD 2>/dev/null | cut -c1-8)

Project Structure:
- Buildroot Config: configs/buildroot/onyx_gate_defconfig
- Board Files: board/onyx-gate/
- Overlay System: board/onyx-gate/rootfs-overlay/
- GRUB Config: board/onyx-gate/grub.cfg

Generated Files:
$(find . -name "bzImage" -o -name "*.cpio.gz" -o -name "*.img" -o -name "*.gz" | sort | while read file; do
    size=$(du -h "$file" | cut -f1)
    echo "- $file ($size)"
done)

Testing Instructions:
1. Direct Kernel Boot (Development):
   qemu-system-x86_64 -m 512M -kernel bzImage -initrd rootfs.cpio.gz -append "root=/dev/ram0 rw init=/sbin/init console=ttyS0,115200" -nographic

2. IMG Boot (Production Testing):
   qemu-system-x86_64 -m 512M -hda img/onyx-gate-pba-$VERSION.img -nographic

3. Shadow MBR Deployment:
   sedutil-cli --loadPBAimage img/onyx-gate-pba-$VERSION.img /dev/nvme0n1

Development Workflow:
- Edit source files in src/
- Run: ./scripts/build-onyx-gate.sh
- Expected time: 30-60 seconds (incremental build)
- Test: Use QEMU commands above

Project Files (version controlled):
- All configuration files are in git
- No generated files in build script
- Clean separation of concerns
MANIFEST_EOF

cd ..

echo "✅ Images created successfully"

# ============================================================================
# BUILD COMPLETION SUMMARY
# ============================================================================
echo ""
echo "🎉 BUILD COMPLETED SUCCESSFULLY!"
echo "================================="
echo ""
echo "📊 Build Statistics:"
echo "   Strategy: $BUILD_STRATEGY ($BUILD_REASON)"
echo "   Version: $VERSION"
echo "   Host: $BUILD_HOST"
echo ""
echo "📦 Generated Files:"
find images/ -name "bzImage" -o -name "*.cpio.gz" -o -name "*.img" -o -name "*.gz" | sort | while read file; do
    size=$(du -h "$file" | cut -f1)
    echo "   $file: $size"
done
echo ""
echo "🚀 Development Optimization:"
if [ "$BUILD_STRATEGY" = "full" ]; then
    echo "   ✓ Full build completed - next changes will be incremental"
    echo "   ✓ Estimated time for PBA changes: 30-60 seconds"
else
    echo "   ✓ Incremental build used - significant time saved!"
    echo "   ✓ Build optimization working correctly"
fi
echo ""
echo "🧪 Testing Commands:"
echo "   Direct Boot:  qemu-system-x86_64 -m 512M -kernel images/bzImage -initrd images/rootfs.cpio.gz -append \"root=/dev/ram0 rw init=/sbin/init console=ttyS0,115200\" -nographic"
echo "   IMG Boot:     qemu-system-x86_64 -m 512M -hda images/img/onyx-gate-pba-$VERSION.img -nographic"
echo ""
echo "📁 Project Structure:"
echo "   configs/buildroot/        - Build configurations (version controlled)"
echo "   board/onyx-gate/          - ONYX-GATE specific files (version controlled)"
echo "   images/                   - Generated deployable files (not in git)"
echo ""
echo "💡 All configuration files are now in git - no generated files!"
echo ""

exit 0
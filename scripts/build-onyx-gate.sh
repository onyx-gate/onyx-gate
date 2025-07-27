#!/bin/bash
# ============================================================================
# ONYX-GATE Pre-Boot Authentication (PBA) - Complete Build Script
# ============================================================================
#
# This script builds the complete ONYX-GATE PBA system from source code to
# deployable images. It creates bootable IMG files for Shadow MBR deployment
# on TCG OPAL self-encrypting drives and individual files for testing.
#
# Build Process Overview:
#   1. Compile C application (PBA binary)
#   2. Run unit tests to verify functionality
#   3. Create Linux overlay with PBA integration
#   4. Build minimal Linux system via Buildroot
#   5. Generate bootable IMG + testing files
#   6. Create checksums for verification
#
# Build Time: ~10-15 minutes (depends on system specs)
# Output: bzImage, rootfs.cpio.gz, bootable IMG, checksums
# Target: x86_64 systems with TCG OPAL 2.0 drives
#
# Usage: ./scripts/build-onyx-gate.sh
# Prerequisites: cmake, make, gcc, git, buildroot submodules
#
# ============================================================================

set -e  # Exit immediately if any command fails

echo "🖤 ONYX-GATE Complete Build Process"
echo "======================================"

# ----------------------------------------------------------------------------
# BUILD ENVIRONMENT SETUP
# ----------------------------------------------------------------------------
# Extract version information from git for build traceability
# This appears in the PBA interface and build artifacts
VERSION=$(git describe --tags --always --dirty 2>/dev/null || echo "dev")
BUILD_DATE=$(date -u)
BUILD_HOST=$(hostname)

echo "📋 Build Environment:"
echo "   Version: $VERSION"
echo "   Date: $BUILD_DATE"
echo "   Host: $BUILD_HOST"
echo "   CPU Cores: $(nproc)"
echo ""

# ============================================================================
# STEP 1: C APPLICATION BUILD & TESTING
# ============================================================================
echo "🔧 Step 1: Building C application..."
echo "   Purpose: Compile the core PBA binary that handles user authentication"
echo "   Components: main.c (UI logic) + logger.c (logging system)"
echo "   Output: build/src/onyx-gate-pba (~16KB executable)"

# Clean any previous build artifacts to ensure fresh compilation
# This prevents issues with cached CMake configurations or stale objects
rm -rf build

# Configure CMake build system with optimized release settings
# -DCMAKE_BUILD_TYPE=Release: Optimized binary for production deployment
# -DBUILD_TESTING=ON: Enable unit tests to verify functionality
cmake -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_TESTING=ON \
    -DCMAKE_BUILD_DATE="$BUILD_DATE"

echo "   → Compiling with $(nproc) parallel jobs..."
cmake --build build --parallel $(nproc)

# Run comprehensive test suite to verify PBA functionality
# This catches regressions and ensures the PBA works correctly
echo "   → Running unit tests..."
cd build && ctest --output-on-failure && cd ..

# Test the actual PBA binary in test mode (non-interactive)
# This verifies the binary can start, display interface, and exit cleanly
echo "   → Testing PBA binary..."
./build/src/onyx-gate-pba --test

echo "✅ C application built and tested successfully"
echo "   Binary size: $(du -h build/src/onyx-gate-pba | cut -f1)"

# ============================================================================
# STEP 2: PBA INTEGRATION ENVIRONMENT
# ============================================================================
echo ""
echo "📦 Step 2: Preparing PBA integration environment..."
echo "   Purpose: Create overlay filesystem that integrates PBA into Linux"
echo "   Method: Buildroot overlay system for clean integration"

# Clean any previous overlay to ensure fresh integration
# The overlay contains files that get copied into the Linux root filesystem
rm -rf buildroot-output/target-overlay
mkdir -p buildroot-output/target-overlay/{usr/bin,etc/init.d}

echo "   → Installing PBA binary to overlay..."
# Copy the compiled PBA binary to the overlay's /usr/bin directory
# This makes it available as a system command in the final Linux image
cp build/src/onyx-gate-pba buildroot-output/target-overlay/usr/bin/
chmod +x buildroot-output/target-overlay/usr/bin/onyx-gate-pba

echo "   → Creating PBA auto-start service..."
# Create SysV init script that automatically starts the PBA on boot
# S99 = starts last in boot sequence, after all system services
cat > buildroot-output/target-overlay/etc/init.d/S99onyx-pba << 'INIT_EOF'
#!/bin/sh
# ONYX-GATE PBA Auto-Start Service
# This script runs automatically when the PBA system boots
# It provides the main user interface for pre-boot authentication

case "$1" in
    start)
        echo "🖤 Starting ONYX-GATE PBA..."
        clear
        echo ""
        echo "🖤 ONYX-GATE Pre-Boot Authentication"
        echo "   The elegant gateway to unbreakable security"
        echo ""
        echo "   System Version: 65165d9-dirty"
        echo "   Build Date: $(date -u)"
        echo ""

        # Execute the main PBA application
        # In production, this handles user authentication and drive unlocking
        /usr/bin/onyx-gate-pba

        echo ""
        echo "🎉 PBA Authentication Complete"
        echo "   In production: Drive would be unlocked and system rebooted"
        echo ""
        echo "   Press Ctrl+Alt+Del to restart system"
        ;;
    stop)
        echo "Stopping ONYX-GATE PBA..."
        # Graceful shutdown (currently no cleanup needed)
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac
exit 0
INIT_EOF

chmod +x buildroot-output/target-overlay/etc/init.d/S99onyx-pba

echo "✅ PBA integration environment prepared"
echo "   Overlay files: $(find buildroot-output/target-overlay -type f | wc -l)"

# ============================================================================
# STEP 3: LINUX SYSTEM BUILD
# ============================================================================
echo ""
echo "🔨 Step 3: Building minimal Linux system..."
echo "   Purpose: Create bootable Linux environment for PBA execution"
echo "   Method: Buildroot cross-compilation system"
echo "   Duration: ~10-15 minutes (depending on system performance)"

# Clean previous Buildroot artifacts to ensure consistent builds
# This removes compiled packages, kernel, and filesystem images
echo "   → Cleaning previous Linux build artifacts..."
rm -rf buildroot-output/build buildroot-output/images buildroot-output/target
rm -f buildroot-output/.config* buildroot-output/Makefile

echo "   → Configuring Linux build system..."
cd external/buildroot

# Load ONYX-GATE specific Buildroot configuration
# This defines what packages, kernel version, and settings to use
make O=../../buildroot-output BR2_DEFCONFIG=../../configs/buildroot/onyx_defconfig defconfig

# Configure the overlay system to include our PBA files
# This tells Buildroot to copy our overlay files into the root filesystem
echo 'BR2_ROOTFS_OVERLAY="../../buildroot-output/target-overlay"' >> ../../buildroot-output/.config

echo "   → Starting Linux compilation (this takes ~10-15 minutes)..."
echo "     - Downloading and compiling Linux kernel"
echo "     - Building BusyBox utilities"
echo "     - Creating root filesystem"
echo "     - Integrating PBA overlay"
echo "     - Generating bootable images"

# Build the complete Linux system with parallel compilation
# Uses (cores-1) to leave one CPU core available for system responsiveness
make O=../../buildroot-output -j$(($(nproc) - 1))

cd ../..

echo "✅ Linux system built successfully"
echo "   Kernel: $(ls buildroot-output/images/bzImage 2>/dev/null && echo "✓ Present" || echo "✗ Missing")"
echo "   Root FS: $(ls buildroot-output/images/rootfs.* 2>/dev/null | wc -l) filesystem images"

# ============================================================================
# STEP 4: DEPLOYABLE IMAGE CREATION
# ============================================================================
echo ""
echo "📀 Step 4: Creating deployable images..."
echo "   Purpose: Generate images for testing and production deployment"

# Create output directory structure for organized image storage
mkdir -p images/{img,checksums}

echo "   → Copying kernel and rootfs for direct testing..."
# Copy kernel and rootfs for direct QEMU testing
# These files allow direct kernel boot for development and testing
cp buildroot-output/images/bzImage "images/bzImage"
cp buildroot-output/images/rootfs.cpio.gz "images/rootfs.cpio.gz"

echo "   → Creating bootable IMG for production deployment..."
# Create proper bootable disk image suitable for Shadow MBR deployment
# This creates a 32MB disk image with MBR partition table and ext2 filesystem

# Step 1: Create empty disk image
dd if=/dev/zero of="images/img/onyx-gate-pba-$VERSION.img" bs=1M count=32 2>/dev/null

# Step 2: Create partition table (MBR with single Linux partition)
echo "   → Setting up IMG partition table..."
fdisk "images/img/onyx-gate-pba-$VERSION.img" >/dev/null 2>&1 << FDISK_EOF
n
p
1


a
1
w
FDISK_EOF

# Step 3: Setup loop device for partition access
LOOP_DEVICE=$(sudo losetup -f --show "images/img/onyx-gate-pba-$VERSION.img")
sudo partprobe $LOOP_DEVICE

# Step 4: Format the partition as ext2
echo "   → Creating ext2 filesystem on IMG..."
sudo mkfs.ext2 -F "${LOOP_DEVICE}p1" >/dev/null 2>&1

# Step 5: Mount partition and copy files
echo "   → Installing files to IMG..."
IMG_MOUNT="/tmp/onyx-img-mount"
sudo mkdir -p $IMG_MOUNT
sudo mount "${LOOP_DEVICE}p1" $IMG_MOUNT

# Copy kernel and initrd to the IMG
sudo mkdir -p $IMG_MOUNT/boot
sudo cp buildroot-output/images/bzImage $IMG_MOUNT/boot/
sudo cp buildroot-output/images/rootfs.cpio.gz $IMG_MOUNT/boot/initrd

# Create basic GRUB configuration for the IMG
sudo mkdir -p $IMG_MOUNT/boot/grub
sudo tee $IMG_MOUNT/boot/grub/grub.cfg >/dev/null << GRUB_EOF
set timeout=5
set default=0

menuentry "🖤 ONYX-GATE PBA" {
    linux /boot/bzImage root=/dev/ram0 rw init=/sbin/init console=tty1 console=ttyS0,115200 quiet splash
    initrd /boot/initrd
}

menuentry "ONYX-GATE PBA (Recovery Mode)" {
    linux /boot/bzImage root=/dev/ram0 rw init=/bin/sh console=tty1 console=ttyS0,115200
    initrd /boot/initrd
}

menuentry "ONYX-GATE PBA (Debug Mode)" {
    linux /boot/bzImage root=/dev/ram0 rw init=/sbin/init console=tty1 console=ttyS0,115200 debug
    initrd /boot/initrd
}
GRUB_EOF

# Install GRUB bootloader to the IMG
echo "   → Installing GRUB bootloader to IMG..."
sudo grub-install --target=i386-pc --boot-directory=$IMG_MOUNT/boot --force --no-floppy $LOOP_DEVICE >/dev/null 2>&1

# Cleanup mounts and loop device
sudo umount $IMG_MOUNT
sudo rmdir $IMG_MOUNT
sudo losetup -d $LOOP_DEVICE

echo "   → Creating compressed image for distribution..."
# Create compressed version for easier network distribution and storage
gzip -k "images/img/onyx-gate-pba-$VERSION.img"

echo "   → Generating integrity checksums..."
# Create SHA256 checksums for image verification and integrity checking
# This allows users to verify their downloads haven't been corrupted
cd images
find . -name "bzImage" -o -name "*.cpio.gz" -o -name "*.img" -o -name "*.gz" | sort | xargs sha256sum > checksums/sha256sums.txt

# Create build manifest with detailed information
cat > checksums/build-manifest.txt << MANIFEST_EOF
ONYX-GATE PBA Build Manifest
============================

Build Information:
- Version: $VERSION
- Build Date: $BUILD_DATE
- Build Host: $BUILD_HOST
- Git Commit: $(git rev-parse HEAD 2>/dev/null | cut -c1-8)
- Builder: ONYX-GATE Build System v2.0

Generated Files:
$(find . -name "bzImage" -o -name "*.cpio.gz" -o -name "*.img" -o -name "*.gz" | sort | while read file; do
    size=$(du -h "$file" | cut -f1)
    echo "- $file ($size)"
done)

System Specifications:
- Target Architecture: x86_64 (Intel/AMD 64-bit)
- Linux Kernel: Latest stable via Buildroot
- Root Filesystem: Compressed initrd (~3MB)
- Bootloader: GRUB2 (BIOS compatible)
- Init System: BusyBox
- PBA Application: Integrated via overlay

Testing Instructions:
1. Direct Kernel Boot (Development):
   qemu-system-x86_64 -m 512M -kernel bzImage -initrd rootfs.cpio.gz -append "root=/dev/ram0 rw init=/sbin/init console=ttyS0,115200" -nographic

2. IMG Boot (Production Testing):
   qemu-system-x86_64 -m 512M -hda img/onyx-gate-pba-$VERSION.img -nographic

3. Shadow MBR Deployment:
   sedutil-cli --loadPBAimage img/onyx-gate-pba-$VERSION.img /dev/nvme0n1

Expected Behavior:
- System boots to ONYX-GATE PBA interface
- Displays authentication prompt
- Currently: Shows "Hello World" and waits for input
- Future: FIDO2 authentication + drive unlocking
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
echo "   Duration: Started at $(date -u)"
echo "   Version: $VERSION"
echo "   Host: $BUILD_HOST"
echo ""
echo "📦 Generated Files:"
ls -la images/ images/img/ images/checksums/ 2>/dev/null | grep -v "^total" | while read -r line; do
    echo "   $line"
done
echo ""
echo "🔍 File Sizes:"
find images/ -name "bzImage" -o -name "*.cpio.gz" -o -name "*.img" -o -name "*.gz" | sort | while read file; do
    size=$(du -h "$file" | cut -f1)
    echo "   $file: $size"
done
echo ""
echo "🧪 Testing Instructions:"
echo "   Direct Boot:  qemu-system-x86_64 -m 512M -kernel images/bzImage -initrd images/rootfs.cpio.gz -append \"root=/dev/ram0 rw init=/sbin/init console=ttyS0,115200\" -nographic"
echo "   IMG Boot:     qemu-system-x86_64 -m 512M -hda images/img/onyx-gate-pba-$VERSION.img -nographic"
echo "   Production:   Deploy images/img/onyx-gate-pba-$VERSION.img to Shadow MBR"
echo ""
echo "📋 Verification:"
echo "   Checksums:    cat images/checksums/sha256sums.txt"
echo "   Manifest:     cat images/checksums/build-manifest.txt"
echo ""
echo "🚀 Your ONYX-GATE PBA system is ready for deployment!"
echo ""

exit 0
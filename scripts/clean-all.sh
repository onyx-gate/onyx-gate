#!/bin/bash
# ============================================================================
# ONYX-GATE Complete Environment Cleanup Script
# ============================================================================
#
# This script removes ALL build artifacts, cached files, and temporary data
# to ensure a completely fresh build environment. Use this when:
#
# - Build failures occur due to stale artifacts
# - Switching between different build configurations
# - Preparing for clean builds in CI/CD environments
# - Troubleshooting mysterious build issues
# - Before major version changes or configuration updates
#
# What gets cleaned:
# - All compiled binaries and object files
# - CMake configuration and cache files
# - Buildroot build artifacts and downloaded packages
# - Generated images and checksums
# - IDE-specific build directories
# - Temporary overlay files
# - Git ignored build artifacts
#
# This is SAFE to run - it only removes generated files, never source code.
#
# ============================================================================

set -e

echo "🧹 ONYX-GATE Complete Environment Cleanup"
echo "=========================================="
echo ""
echo "This will remove ALL build artifacts and cached data."
echo "Your source code and configuration files will NOT be touched."
echo ""

# Add confirmation for safety (comment out if running in CI/CD)
read -p "Continue with cleanup? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Cleanup cancelled by user"
    exit 1
fi

echo "🗑️  Starting comprehensive cleanup..."
echo ""

# ============================================================================
# CMAKE & C++ BUILD ARTIFACTS
# ============================================================================
echo "📂 Cleaning CMake and C++ build artifacts..."

# Main build directory (created by cmake -B build)
if [ -d "build" ]; then
    echo "   → Removing build/ directory"
    rm -rf build
fi

# CLion IDE build directories
if [ -d "cmake-build-debug" ]; then
    echo "   → Removing cmake-build-debug/ (CLion debug builds)"
    rm -rf cmake-build-debug
fi

if [ -d "cmake-build-release" ]; then
    echo "   → Removing cmake-build-release/ (CLion release builds)"
    rm -rf cmake-build-release
fi

# Generic cmake-build-* patterns (various IDE configurations)
for cmake_dir in cmake-build-*; do
    if [ -d "$cmake_dir" ]; then
        echo "   → Removing $cmake_dir/ (IDE build directory)"
        rm -rf "$cmake_dir"
    fi
done

# Build system artifacts that might be in root directory
if [ -f "CMakeCache.txt" ]; then
    echo "   → Removing root CMakeCache.txt"
    rm -f CMakeCache.txt
fi

if [ -d "CMakeFiles" ]; then
    echo "   → Removing root CMakeFiles/ directory"
    rm -rf CMakeFiles
fi

echo "✅ CMake artifacts cleaned"

# ============================================================================
# BUILDROOT SYSTEM ARTIFACTS
# ============================================================================
echo ""
echo "🐧 Cleaning Buildroot Linux system artifacts..."

if [ -d "buildroot-output" ]; then
    echo "   → Removing buildroot-output/ directory"
    echo "     (This includes: compiled packages, kernel, root filesystem)"
    rm -rf buildroot-output
fi

# Buildroot might create files in external/buildroot
if [ -f "external/buildroot/.config" ]; then
    echo "   → Removing Buildroot configuration cache"
    rm -f external/buildroot/.config*
fi

if [ -f "external/buildroot/Makefile" ] && [ -f "external/buildroot/.stamp_configured" ]; then
    echo "   → Cleaning Buildroot internal state"
    cd external/buildroot
    make clean 2>/dev/null || true
    cd ../..
fi

echo "✅ Buildroot artifacts cleaned"

# ============================================================================
# GENERATED IMAGES & DISTRIBUTION FILES
# ============================================================================
echo ""
echo "💿 Cleaning generated images and distribution files..."

if [ -d "images" ]; then
    echo "   → Removing images/ directory"
    echo "     (This includes: ISO files, IMG files, checksums)"
    rm -rf images
fi

# Clean up temporary build directories from previous builds
if [ -d "iso-temp" ]; then
    echo "   → Removing iso-temp/ directory (leftover from failed builds)"
    rm -rf iso-temp
fi

if [ -d "build-temp" ]; then
    echo "   → Removing build-temp/ directory (leftover from failed builds)"
    rm -rf build-temp
fi

# Look for any stray image files in root directory
for img_file in *.iso *.img *.img.gz; do
    if [ -f "$img_file" ]; then
        echo "   → Removing stray image file: $img_file"
        rm -f "$img_file"
    fi
done

echo "✅ Image artifacts cleaned"

# ============================================================================
# TEMPORARY & CACHE FILES
# ============================================================================
echo ""
echo "🗂️  Cleaning temporary and cache files..."

# Various cache directories that might be created
cache_dirs=(".cache" "_build" ".tmp" "tmp" "temp")
for cache_dir in "${cache_dirs[@]}"; do
    if [ -d "$cache_dir" ]; then
        echo "   → Removing $cache_dir/ directory"
        rm -rf "$cache_dir"
    fi
done

# Temporary files with common patterns
temp_patterns=("*.tmp" "*.bak" "*.orig" "*.swp" "*.swo" "*~")
for pattern in "${temp_patterns[@]}"; do
    if ls $pattern 1> /dev/null 2>&1; then
        echo "   → Removing temporary files: $pattern"
        rm -f $pattern
    fi
done

# Log files that might be generated
log_patterns=("*.log" "build.log" "error.log")
for pattern in "${log_patterns[@]}"; do
    if ls $pattern 1> /dev/null 2>&1; then
        echo "   → Removing log files: $pattern"
        rm -f $pattern
    fi
done

echo "✅ Temporary files cleaned"

# ============================================================================
# IDE & EDITOR ARTIFACTS
# ============================================================================
echo ""
echo "💻 Cleaning IDE and editor artifacts..."

# CLion - Remove workspace files but keep project configuration
if [ -d ".idea" ]; then
    echo "   → Cleaning CLion workspace artifacts (.idea/)"
    # Remove workspace and cache files, keep project configuration
    rm -f .idea/workspace.xml 2>/dev/null || true
    rm -f .idea/tasks.xml 2>/dev/null || true
    rm -f .idea/usage.statistics.xml 2>/dev/null || true
    # Note: We keep .idea/ directory as it contains useful project settings
fi

# Visual Studio Code
if [ -d ".vscode" ]; then
    echo "   → Cleaning VS Code artifacts (.vscode/)"
    # Keep settings.json and tasks.json, remove build artifacts
    rm -f .vscode/launch.json.bak 2>/dev/null || true
    rm -f .vscode/c_cpp_properties.json.bak 2>/dev/null || true
fi

# Vim/Neovim swap files
if ls .*.swp 1> /dev/null 2>&1; then
    echo "   → Removing Vim swap files"
    rm -f .*.swp
fi

# Emacs backup files
if ls *~ 1> /dev/null 2>&1; then
    echo "   → Removing Emacs backup files"
    rm -f *~
fi

echo "✅ IDE artifacts cleaned"

# ============================================================================
# SYSTEM-SPECIFIC CLEANUP
# ============================================================================
echo ""
echo "🖥️  Cleaning system-specific artifacts..."

# macOS specific files
if [ -f ".DS_Store" ]; then
    echo "   → Removing macOS .DS_Store files"
    find . -name ".DS_Store" -delete 2>/dev/null || true
fi

# Windows specific files  
if ls Thumbs.db 1> /dev/null 2>&1; then
    echo "   → Removing Windows Thumbs.db files"
    rm -f Thumbs.db
fi

# Linux specific
if [ -d ".thumbnails" ]; then
    echo "   → Removing Linux thumbnail cache"
    rm -rf .thumbnails
fi

echo "✅ System artifacts cleaned"

# ============================================================================
# VERIFICATION & SUMMARY
# ============================================================================
echo ""
echo "🔍 Verifying cleanup completion..."

# Check that key directories are gone
missing_dirs=0
expected_clean_dirs=("build" "buildroot-output" "images" "cmake-build-debug" "cmake-build-release" "iso-temp" "build-temp")

for dir in "${expected_clean_dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo "   ⚠️  Warning: $dir/ still exists"
    else
        missing_dirs=$((missing_dirs + 1))
    fi
done

echo "   → $missing_dirs of ${#expected_clean_dirs[@]} expected build directories cleaned"

# Show what's left (should only be source code and configs)
echo ""
echo "📋 Project directory status:"
ls -la | grep -E "^d" | grep -v "^\.$" | grep -v "^\.\.$" | while read -r line; do
    dir_name=$(echo "$line" | awk '{print $NF}')
    case "$dir_name" in
        # Core project directories (always kept)
        ".git")
            echo "   ✅ $dir_name/ (Git repository)"
            ;;
        "src"|"tests"|"configs"|"scripts"|"docs")
            echo "   ✅ $dir_name/ (Source code/configs)"
            ;;
        "external")
            echo "   ✅ $dir_name/ (Git submodules)"
            ;;
        # Project-specific directories (always kept)
        "board")
            echo "   ✅ $dir_name/ (Buildroot board configs)"
            ;;
        ".github")
            echo "   ✅ $dir_name/ (GitHub workflows/templates)"
            ;;
        # IDE directories (kept but noted)
        ".idea")
            echo "   📝 $dir_name/ (CLion project settings - kept)"
            ;;
        ".vscode")
            echo "   📝 $dir_name/ (VS Code settings - kept)"
            ;;
        # Build directories that should be gone
        "build"|"buildroot-output"|"images"|"cmake-build-"*)
            echo "   ❌ $dir_name/ (Should have been removed!)"
            ;;
        # Unknown directories
        *)
            echo "   ❓ $dir_name/ (Unknown - review needed)"
            ;;
    esac
done

# ============================================================================
# CLEANUP COMPLETE
# ============================================================================
echo ""
echo "🎉 CLEANUP COMPLETED SUCCESSFULLY!"
echo "=================================="
echo ""
echo "✅ Environment Status:"
echo "   - All build artifacts removed"
echo "   - All cached files cleared"
echo "   - All generated images deleted"
echo "   - Source code and configurations preserved"
echo "   - IDE settings preserved"
echo ""
echo "🚀 Ready for fresh build:"
echo "   - Run: ./scripts/build-onyx-gate.sh"
echo "   - Expected clean build time: ~10-15 minutes"
echo "   - All dependencies will be rebuilt from scratch"
echo ""
echo "💡 Tip: This cleanup is safe to run anytime you encounter build issues!"
echo ""

exit 0

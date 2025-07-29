#!/bin/bash
# ONYX-GATE Post-build script
# Ensures correct permissions for PBA files

set -e

TARGET_DIR="$1"

echo "🔧 ONYX-GATE post-build: Setting correct permissions..."

# Ensure init script has execute permissions
if [ -f "$TARGET_DIR/etc/init.d/S99onyx-pba" ]; then
    chmod +x "$TARGET_DIR/etc/init.d/S99onyx-pba"
    echo "   ✓ Set execute permission on S99onyx-pba"
else
    echo "   ⚠️  S99onyx-pba not found in target"
fi

# Ensure PBA binary has execute permissions
if [ -f "$TARGET_DIR/usr/bin/onyx-gate-pba" ]; then
    chmod +x "$TARGET_DIR/usr/bin/onyx-gate-pba"
    echo "   ✓ Set execute permission on onyx-gate-pba"
else
    echo "   ⚠️  onyx-gate-pba not found in target"
fi

echo "🎉 ONYX-GATE post-build completed"
---
layout: page
title: Download
permalink: /download/
---

# Download ONYX-GATE

**Current Release**: 2025.7.1-alpha - Foundation Complete ✅

## 🎉 Alpha Release Available

ONYX-GATE now has a **working foundation** with complete build system, CI/CD pipeline, and bootable PBA environment. Ready for testing and development!

### **Quick Test (Recommended)**
```bash
# Download pre-built alpha image
wget https://github.com/onyx-gate/onyx-gate/releases/download/2025.7.1-alpha/onyx-gate-pba-2025.7.1-alpha.img.gz

# Extract and test in QEMU
gunzip onyx-gate-pba-2025.7.1-alpha.img.gz
qemu-system-x86_64 -m 512M -hda onyx-gate-pba-2025.7.1-alpha.img -nographic
```

## 📦 Available Downloads

### **Alpha Release (2025.7.1-alpha)**
| File | Size | Description |
|------|------|-------------|
| `onyx-gate-pba-2025.7.1-alpha.img.gz` | ~18MB | Compressed bootable disk image |
| `onyx-gate-source-2025.7.1-alpha.tar.gz` | ~2MB | Source code archive |
| `checksums-2025.7.1-alpha.txt` | ~1KB | SHA256 verification checksums |

[**🔗 Download from GitHub Releases**](https://github.com/onyx-gate/onyx-gate/releases/latest)

## 🏗️ Build from Source

### **Prerequisites**
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y build-essential cmake git \
    libelf-dev libssl-dev bc flex bison rsync \
    qemu-system-x86 grub-pc-bin grub2-common

# Fedora/RHEL  
sudo dnf install -y gcc gcc-c++ cmake git \
    elfutils-libelf-devel openssl-devel bc flex bison rsync \
    qemu-system-x86 grub2-tools-pc grub2-common
```

### **Build Process**
```bash
# Clone repository
git clone https://github.com/onyx-gate/onyx-gate.git
cd onyx-gate

# Checkout specific release (optional)
git checkout 2025.7.1-alpha

# Initialize submodules
git submodule update --init --recursive

# Build (first build: ~25 minutes, subsequent: 30-60 seconds)
./scripts/build-onyx-gate.sh

# Test your build
qemu-system-x86_64 -m 512M -kernel images/bzImage -initrd images/rootfs.cpio.gz \
  -append "root=/dev/ram0 rw init=/sbin/init console=ttyS0,115200" -nographic
```

## 🎯 Current Status

### **✅ Working (2025.7.1-alpha)**
- **Complete Build System**: Buildroot integration with smart rebuilds
- **CI/CD Pipeline**: Automated builds and testing
- **PBA Environment**: Minimal Linux with working init system
- **Image Generation**: Both development and production formats
- **Testing Framework**: Unit tests + QEMU integration
- **Development Workflow**: Fast incremental builds

### **🔄 In Development (2025.8.1-alpha)**
- **Virtual Keyboard**: Randomized layout with arrow navigation
- **FIDO2 Detection**: USB enumeration and YubiKey identification
- **Enhanced UI**: Improved boot screen and user feedback

### **⏳ Planned (Future Releases)**
- **FIDO2 Authentication**: Complete challenge-response (2025.9.1-alpha)
- **TCG OPAL Integration**: Drive unlock and Shadow MBR (2025.10.1-beta)
- **FIPS Cryptography**: Validated crypto modules (2025.11.1-beta)

## 🧪 Testing Instructions

### **QEMU Testing (Safe)**
```bash
# Direct kernel boot (development testing)
qemu-system-x86_64 -m 512M -kernel images/bzImage -initrd images/rootfs.cpio.gz \
  -append "root=/dev/ram0 rw init=/sbin/init console=ttyS0,115200" -nographic

# Bootable image (production-like testing)
qemu-system-x86_64 -m 512M -hda images/img/onyx-gate-pba-*.img -nographic
```

### **USB/SD Card Testing (Advanced)**
```bash
# Create bootable USB/SD card for hardware testing
# ⚠️ WARNING: This will destroy all data on the target device
sudo dd if=images/img/onyx-gate-pba-*.img of=/dev/sdX bs=1M status=progress
```

### **Hardware Requirements (Future)**
- TCG OPAL 2.0 compatible SSD (Samsung, Intel, WD, Seagate, Micron, etc.)
- FIDO2 device (YubiKey 5 series recommended)
- UEFI system with Secure Boot support
- TPM 2.0 (optional but recommended)

## ⚠️ Important Warnings

### **Alpha Software Notice**
- **Development Only**: Not suitable for production use
- **No Security Features**: Core authentication not yet implemented
- **Data Loss Risk**: Do not test on systems with important data
- **Hardware Testing**: Only test on disposable/test systems

### **Security Status**
- **No Encryption**: Drive encryption features not implemented
- **No Authentication**: FIDO2 authentication not functional
- **Foundation Only**: This release establishes architecture only

## 🔄 Update Notifications

### **Stay Updated**
- **GitHub Releases**: [Watch repository](https://github.com/onyx-gate/onyx-gate) for release notifications
- **GitHub Discussions**: Join discussions about development progress
- **Issue Tracker**: Report bugs and feature requests

### **Release Schedule**
- **2025.8.1-alpha**: Virtual keyboard + FIDO2 detection (August 2025)
- **2025.9.1-alpha**: Complete FIDO2 authentication (September 2025)
- **2025.10.1-beta**: TCG OPAL integration (October 2025)
- **2025.12.1**: First stable release (December 2025)

## 🤝 Contributing

Ready to help build the future of Pre-Boot Authentication?

- **High Priority**: Virtual keyboard implementation
- **Next Priority**: FIDO2 device detection
- **Always Welcome**: Documentation, testing, security analysis

See [CONTRIBUTING.md](https://github.com/onyx-gate/onyx-gate/blob/main/CONTRIBUTING.md) for development setup and guidelines.

---

**Ready to test?** [Download the latest alpha](https://github.com/onyx-gate/onyx-gate/releases/latest) and help shape ONYX-GATE! 🖤
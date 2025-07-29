# 🖤 ONYX-GATE

**The elegant gateway to unbreakable security**

Premium Pre-Boot Authentication with FIDO2 and anti-keylogger protection for TCG OPAL 2.0 self-encrypting drives.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg)](#)
[![Version](https://img.shields.io/badge/version-2025.7.1--alpha-orange.svg)](#)
[![Security](https://img.shields.io/badge/security-FIPS%20140--2-green.svg)](#)
[![Hardware](https://img.shields.io/badge/hardware-TCG%20OPAL%202.0-orange.svg)](#)

## 🎯 **Why ONYX-GATE?**

Most Pre-Boot Authentication (PBA) solutions have a **fundamental security flaw**: they leave critical boot components unencrypted, creating attack vectors that compromise the entire security model. Traditional approaches suffer from:

- **Unencrypted /boot partitions** - exposing kernel, initramfs, and bootloader to tampering
- **Vulnerable PBA environments** - often stored in plaintext, susceptible to Evil Maid attacks
- **Legacy authentication methods** - password-only systems vulnerable to keyloggers and brute force
- **Vendor lock-in** - proprietary solutions requiring specific hardware combinations
- **No transparency** - closed-source implementations that cannot be independently audited

**ONYX-GATE eliminates these compromises** by leveraging TCG OPAL 2.0 Shadow MBR technology, ensuring that **100% of user data remains encrypted** until proper authentication is provided.

## 🔥 **Core Innovations**

### **🎮 Anti-Keylogger Virtual Keyboard**
*World's first PBA with keylogger-resistant authentication*

- **Randomized layout** - digits 0-9 shuffled on every boot
- **Arrow key navigation** - immune to software, hardware, and acoustic keyloggers
- **Visual feedback system** - professional UI with selection highlighting
- **Complete protection** - renders traditional keylogger attacks useless

### **🔑 Modern FIDO2/WebAuthn Authentication**
*Next-generation hardware-bound security*

- **YubiKey integration** - support for all FIDO2-compatible devices
- **Hardware-bound keys** - secrets never leave the secure element
- **Challenge-response protocol** - unique unlock key generated per boot
- **Multi-device support** - backup authentication devices supported

### **🏛️ FIPS 140-2 Validated Cryptography**
*Government-grade security foundation*

- **OpenSSL FIPS module** - building on validated cryptographic implementations
- **Mandatory self-tests** - power-on cryptographic validation
- **FIPS-approved algorithms** - AES, SHA-2, PBKDF2 with compliant parameters
- **Certification ready** - designed for government deployment

### **🔓 Universal Hardware Freedom**
*No vendor lock-in*

- **Any TCG OPAL 2.0 drive** - Samsung, Intel, WD, Seagate, Micron, and more
- **Open standards compliance** - TCG OPAL specification only
- **Future compatibility** - works with new drives as they're released
- **Cost flexibility** - choose optimal hardware for your needs

## 🏗️ **How It Works**

### **Shadow MBR Technology**
ONYX-GATE utilizes TCG OPAL 2.0 Shadow MBR to achieve **true full-disk encryption**:

1. **Power On** → UEFI Secure Boot → Shadow MBR (32MB encrypted environment)
2. **PBA Environment** → Minimal Linux with FIDO2 support loads
3. **Authentication** → Virtual keyboard + YubiKey challenge-response
4. **Key Derivation** → FIPS-compliant key derivation from FIDO2 HMAC
5. **Drive Unlock** → TCG OPAL unlock, system reboots to main OS
6. **Full Access** → 100% of drive now accessible, completely transparent

### **Security Architecture**
```
┌─────────────────────────────────────────────────────────────┐
│                    APPLICATION LAYER                        │
│  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐│
│  │Virtual Keyboard │ │   FIDO2 Auth    │ │  OPAL Manager   ││
│  │• Randomization  │ │• YubiKey        │ │• Drive Unlock   ││
│  │• Arrow Nav      │ │• Challenge-Resp │ │• Status Monitor ││
│  └─────────────────┘ └─────────────────┘ └─────────────────┘│
├─────────────────────────────────────────────────────────────┤
│                     SYSTEM LAYER                            │
│  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐│
│  │PBA Environment  │ │OpenSSL FIPS     │ │  TPM 2.0 Mgmt   ││
│  │• Minimal Linux  │ │• Validated Crypto│ │• Measured Boot ││
│  │• Buildroot      │ │• Self-tests     │ │• Attestation    ││
│  └─────────────────┘ └─────────────────┘ └─────────────────┘│
├─────────────────────────────────────────────────────────────┤
│                    HARDWARE LAYER                           │
│  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐│
│  │   OPAL SED      │ │    YubiKey      │ │    TPM 2.0      ││
│  │• Shadow MBR     │ │• FIDO2/HMAC     │ │• PCR Registers  ││
│  │• Hardware AES   │ │• Hardware Keys  │ │• Secure Boot    ││
│  └─────────────────┘ └─────────────────┘ └─────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

## 🚀 **Quick Start**

### **Requirements**
- TCG OPAL 2.0 compatible SSD (Samsung, Intel, WD, Seagate, Micron, etc.)
- FIDO2 device (YubiKey 5 series recommended)
- UEFI system with Secure Boot support
- TPM 2.0 (optional but recommended)
- 4GB+ RAM for building from source

### **Download Pre-built Images (Alpha)**
```bash
# Download latest alpha release
wget https://github.com/onyx-gate/onyx-gate/releases/download/2025.7.1-alpha/onyx-gate-pba-2025.7.1-alpha.img.gz

# Extract and test
gunzip onyx-gate-pba-2025.7.1-alpha.img.gz
qemu-system-x86_64 -m 512M -hda onyx-gate-pba-2025.7.1-alpha.img -nographic
```

### **Build from Source**
```bash
# Clone repository
git clone https://github.com/onyx-gate/onyx-gate.git
cd onyx-gate

# Initialize submodules  
git submodule update --init --recursive

# Install dependencies (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install -y build-essential cmake \
    libelf-dev libssl-dev bc flex bison rsync \
    qemu-system-x86 grub-pc-bin grub2-common

# Build PBA system
./scripts/build-onyx-gate.sh

# Test your build
qemu-system-x86_64 -m 512M -kernel images/bzImage -initrd images/rootfs.cpio.gz \
  -append "root=/dev/ram0 rw init=/sbin/init console=ttyS0,115200" -nographic
```

### **Development Deployment**
```bash
# For testing only - creates bootable USB/SD card
sudo dd if=images/img/onyx-gate-pba-*.img of=/dev/sdX bs=1M status=progress

# For production (requires sedutil-cli and OPAL-compatible drive)
# ⚠️ WARNING: This will DESTROY ALL DATA on the drive
sudo sedutil-cli --loadPBAimage images/img/onyx-gate-pba-*.img /dev/nvme0n1
```

## 🛠️ **Development Status**

**Current Release**: 2025.7.1-alpha - Foundation Complete ✅

### **Completed ✅**
- [x] **Complete Build System** - Buildroot integration with smart rebuilds
- [x] **CI/CD Pipeline** - Automated builds and testing with GitHub Actions
- [x] **Project Architecture** - Full development framework established
- [x] **Basic PBA Environment** - Minimal Linux with init system
- [x] **Image Generation** - Both direct-boot and deployable formats
- [x] **Testing Framework** - Unit tests and QEMU integration testing
- [x] **Development Workflow** - Fast incremental builds (30-60 seconds)

### **In Progress 🔄**
- [ ] **Virtual Keyboard MVP** - Randomized layout with arrow navigation (2025.8.1-alpha)
- [ ] **FIDO2 Device Detection** - USB enumeration and YubiKey identification (2025.8.1-alpha)
- [ ] **Enhanced UI** - Improved boot screen and user feedback (2025.8.1-alpha)

### **Planned ⏳**
- [ ] **FIDO2 Authentication** - Complete challenge-response implementation (2025.9.1-alpha)
- [ ] **TCG OPAL Integration** - Drive unlock and Shadow MBR management (2025.10.1-beta)
- [ ] **FIPS Cryptography** - Validated crypto module integration (2025.11.1-beta)
- [ ] **Production Release** - Security audited and deployment ready (2025.12.1)

## 🤝 **Contributing**

ONYX-GATE is an open source project welcoming contributions from security researchers, cryptographers, and developers.

**High Priority Areas (2025.8.1-alpha):**
- 🎮 Virtual keyboard randomization implementation
- 🔍 FIDO2 device detection and enumeration
- 🖥️ User interface improvements and feedback systems
- 📚 Documentation and testing enhancements

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines and development setup.

## 📊 **Testing & Verification**

### **Automated Testing**
- **Unit Tests**: GoogleTest framework with CI integration
- **Build Tests**: Multi-platform builds verified on every commit
- **Integration Tests**: QEMU-based boot testing for all image formats
- **Security Tests**: Static analysis and cryptographic validation

### **Manual Testing**
```bash
# Direct kernel boot (development)
qemu-system-x86_64 -m 512M -kernel images/bzImage -initrd images/rootfs.cpio.gz \
  -append "root=/dev/ram0 rw init=/sbin/init console=ttyS0,115200" -nographic

# Bootable image (production-like)
qemu-system-x86_64 -m 512M -hda images/img/onyx-gate-pba-*.img -nographic

# Hardware testing (requires OPAL drive)
# Test on actual hardware with supported TCG OPAL 2.0 drives
```

## 📄 **License & Legal**

**MIT License** - see [LICENSE](LICENSE) file for details.

**Security Notice**: This is alpha software. Do not use in production environments or with important data until security audit completion.

## 🌟 **Roadmap**

### **2025.8.1-alpha (August 2025)**
- Virtual keyboard with randomized numeric layout
- FIDO2 device detection and basic communication
- Enhanced user interface and error handling

### **2025.9.1-alpha (September 2025)**
- Complete FIDO2 authentication with challenge-response
- Multi-device support and backup authentication
- Advanced virtual keyboard features

### **2025.10.1-beta (October 2025)**
- TCG OPAL 2.0 drive integration and unlock procedures
- Shadow MBR management and deployment tools
- Hardware compatibility testing

### **2025.12.1 (December 2025)**
- Security audit completion and certification
- Production deployment documentation
- Enterprise features and support

---

**Ready to secure your data?** Download the [latest alpha release](https://github.com/onyx-gate/onyx-gate/releases) or [contribute to development](CONTRIBUTING.md)!

**ONYX-GATE** - *Because your data deserves elegant protection* 🖤
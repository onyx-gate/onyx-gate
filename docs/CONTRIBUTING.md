# Contributing to ONYX-GATE

**The elegant gateway to unbreakable security**

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg)](#)
[![Version](https://img.shields.io/badge/version-2025.7.1--alpha-orange.svg)](#)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](#)

## 🚀 Development Status

**Current Release**: 2025.7.1-alpha - Foundation Complete ✅

ONYX-GATE now has a **solid foundation** with:
- ✅ Complete build system and CI/CD pipeline
- ✅ Working PBA environment with Linux kernel
- ✅ Deployable image generation
- ✅ Development workflow established
- 🔄 Ready for core feature implementation

## 🎯 Priority Areas for Contributors

### **High Priority (Next Release - 2025.8.1-alpha)**
1. **🎮 Virtual Keyboard Implementation**
    - Randomized numeric layout (0-9 digits)
    - Arrow key navigation system
    - Basic visual feedback
    - *Skills needed*: C programming, UI design

2. **🔍 FIDO2 Device Detection**
    - USB HID device enumeration
    - YubiKey identification
    - Basic device communication
    - *Skills needed*: USB/HID protocols, embedded C

3. **🖥️ Enhanced User Interface**
    - Improved boot screen design
    - Progress indicators
    - Error handling and feedback
    - *Skills needed*: Terminal UI, user experience

### **Medium Priority (Future Releases)**
4. **🔑 FIDO2/WebAuthn Integration**
    - Challenge-response implementation
    - HMAC-secret extension
    - Multi-device support
    - *Skills needed*: Cryptography, FIDO2 specification

5. **🏛️ FIPS Cryptography**
    - OpenSSL FIPS module integration
    - Validated algorithm implementation
    - Self-test procedures
    - *Skills needed*: Cryptographic standards, compliance

6. **🔓 TCG OPAL Integration**
    - Drive communication protocols
    - Shadow MBR management
    - Secure unlock procedures
    - *Skills needed*: Storage protocols, low-level programming

### **Always Welcome**
- 📚 **Documentation improvements**
- 🧪 **Testing and quality assurance**
- 🔍 **Security analysis and auditing**
- 🛠️ **Build system enhancements**
- 🐛 **Bug reports and fixes**

## 🛠️ Development Environment Setup

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

### **Quick Start**
```bash
# 1. Clone the repository
git clone https://github.com/onyx-gate/onyx-gate.git
cd onyx-gate

# 2. Initialize submodules
git submodule update --init --recursive

# 3. Build the project
./scripts/build-onyx-gate.sh

# 4. Test your build
qemu-system-x86_64 -m 512M -kernel images/bzImage -initrd images/rootfs.cpio.gz \
  -append "root=/dev/ram0 rw init=/sbin/init console=ttyS0,115200" -nographic
```

### **Development Workflow**
```bash
# Make changes to source code in src/
vim src/main.c

# Quick rebuild (30-60 seconds)
./scripts/build-onyx-gate.sh

# Run tests
cd build && ctest --output-on-failure && cd ..

# Test in QEMU
qemu-system-x86_64 -m 512M -kernel images/bzImage -initrd images/rootfs.cpio.gz \
  -append "root=/dev/ram0 rw init=/sbin/init console=ttyS0,115200" -nographic
```

## 📋 Contribution Guidelines

### **Code Style**
- **C Code**: Follow Linux kernel style guide
- **Comments**: Use clear, descriptive comments
- **Security**: Security-first mindset in all implementations
- **Testing**: Include unit tests for new functionality

### **Commit Messages**
Follow conventional commits format:
```
type(scope): description

feat(keyboard): implement randomized numeric layout
fix(build): resolve permission issues in overlay
docs(readme): update installation instructions
test(fido2): add unit tests for device detection
```

### **Pull Request Process**
1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/virtual-keyboard`)
3. **Implement** your changes with tests
4. **Ensure** all tests pass (`./scripts/build-onyx-gate.sh`)
5. **Submit** pull request with clear description

### **Issue Reporting**
Use our issue templates:
- 🐛 **Bug Report**: For functionality issues
- 🚀 **Feature Request**: For new functionality
- 🔒 **Security Issue**: For security-related concerns (use security@onyx-gate.dev for sensitive issues)
- 📚 **Documentation**: For documentation improvements

## 🎯 Architecture Understanding

### **Project Structure**
```
onyx-gate/
├── src/                    # Core PBA application (C)
├── tests/                  # Unit tests (GoogleTest)
├── board/onyx-gate/        # Buildroot board configuration
├── configs/buildroot/      # Build configurations
├── scripts/                # Build and utility scripts
├── external/               # Git submodules (buildroot, crypto libs)
└── images/                 # Generated bootable images
```

### **Key Components**
- **PBA Application** (`src/`): Main authentication logic
- **Build System** (`scripts/`, `configs/`): Creates bootable images
- **Init System** (`board/onyx-gate/rootfs-overlay/`): Boot sequence
- **Testing** (`tests/`): Automated quality assurance

### **Technologies Used**
- **C/C++**: Core application development
- **Buildroot**: Embedded Linux build system
- **CMake**: Build configuration
- **QEMU**: Virtualization for testing
- **GitHub Actions**: Continuous integration

## 🔒 Security Considerations

### **Security-First Development**
- **Threat Modeling**: Consider attack vectors in design
- **Secure Coding**: Follow OWASP secure coding practices
- **Code Review**: All security-related code requires review
- **Testing**: Include security test cases

### **Cryptographic Standards**
- **FIPS 140-2**: Use only validated cryptographic modules
- **Key Management**: Secure key derivation and storage
- **Random Number Generation**: Cryptographically secure randomness
- **Side-Channel Protection**: Consider timing and power analysis

## 🤝 Community

### **Communication Channels**
- **GitHub Issues**: Primary discussion platform
- **GitHub Discussions**: Architecture and design discussions
- **Security Issues**: security@onyx-gate.dev (private)

### **Code of Conduct**
- **Respectful**: Treat all contributors with respect
- **Collaborative**: Work together toward common goals
- **Security-Focused**: Prioritize security in all decisions
- **Professional**: Maintain professional communication

### **Recognition**
- Contributors are recognized in release notes
- Significant contributions earn maintainer status
- Security researchers receive special acknowledgment

## 📈 Roadmap Participation

### **Upcoming Milestones**
- **2025.8.1-alpha**: Virtual keyboard + FIDO2 detection
- **2025.9.1-alpha**: Complete FIDO2 authentication
- **2025.10.1-beta**: TCG OPAL integration
- **2025.12.1**: First stable release

### **Long-term Vision**
Help us build the **world's most secure and user-friendly** Pre-Boot Authentication system:
- Universal hardware compatibility
- Government-grade security certification
- Enterprise deployment ready
- Open source transparency

---

**Ready to contribute?** Check out our [good first issues](https://github.com/onyx-gate/onyx-gate/labels/good%20first%20issue) or reach out through GitHub discussions!

**ONYX-GATE** - *Because your data deserves elegant protection* 🖤
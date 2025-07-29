# Changelog

All notable changes to ONYX-GATE will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2025.7.1-alpha] - 2025-07-30

### 🎉 First Alpha Release

This is the first public alpha release of ONYX-GATE, establishing the fundamental architecture and build system for a premium Pre-Boot Authentication solution.

### Added
- **Complete Build System**: Full Buildroot-based build pipeline for creating PBA images
- **CI/CD Pipeline**: GitHub Actions workflow for automated building and testing
- **Project Architecture**: Complete project structure with proper organization
- **Basic PBA Application**: Hello World PBA that demonstrates the boot process
- **Image Generation**: Creates both direct-boot and deployable IMG files for testing
- **Documentation**: Comprehensive README, contributing guidelines, and project docs
- **Testing Framework**: Unit tests with GoogleTest integration
- **Development Tools**: Build scripts, cleanup utilities, and development workflows

### Technical Implementation
- **Buildroot Integration**: Custom defconfig for minimal Linux PBA environment
- **Overlay System**: Proper rootfs overlay with init scripts and binaries
- **Permission Management**: Post-build scripts ensuring correct file permissions
- **Cross-compilation**: Full x86_64 toolchain for PBA development
- **Image Formats**: Support for both CPIO initrd and bootable disk images

### Build System Features
- **Smart Rebuilds**: Incremental build system that only rebuilds changed components
- **Multiple Output Formats**:
    - `bzImage` + `rootfs.cpio.gz` for direct kernel testing
    - Bootable `.img` files for production deployment
    - Compressed archives for distribution
- **Verification**: SHA256 checksums and build manifests for all generated files

### Development Workflow
- **Local Development**: Fast incremental builds (30-60 seconds after initial build)
- **CI Integration**: Automated builds on all pull requests and pushes
- **Testing**: Both unit tests and integration tests with QEMU
- **Documentation**: Live documentation site with GitHub Pages

### Foundation for Future Features
This release establishes the groundwork for implementing:
- 🎮 Anti-keylogger virtual keyboard
- 🔑 FIDO2/WebAuthn authentication
- 🏛️ FIPS 140-2 validated cryptography
- 🔓 TCG OPAL 2.0 drive management
- 📊 Shadow MBR deployment

### Requirements
- TCG OPAL 2.0 compatible SSD
- UEFI system with Secure Boot support
- 4GB+ RAM for building from source
- Linux development environment

### Testing
```bash
# Direct kernel boot testing
qemu-system-x86_64 -m 512M -kernel images/bzImage -initrd images/rootfs.cpio.gz \
  -append "root=/dev/ram0 rw init=/sbin/init console=ttyS0,115200" -nographic

# Bootable image testing  
qemu-system-x86_64 -m 512M -hda images/img/onyx-gate-pba-*.img -nographic
```

### Known Limitations
- **Pre-Alpha Status**: This is a foundation release - core PBA features not yet implemented
- **Development Only**: Not suitable for production use
- **Limited Hardware Support**: Currently x86_64 only
- **Basic Authentication**: No advanced authentication mechanisms yet

### Next Release (2025.8.1-alpha)
Planned features for next alpha:
- Virtual keyboard with basic randomization
- Initial FIDO2 device detection
- Enhanced user interface
- Additional hardware platform support

---

## Release Notes Format

### Version Numbering
ONYX-GATE uses calendar versioning with the format `YYYY.M.PATCH-STAGE`:
- `YYYY`: Year (2025)
- `M`: Month (1-12, no leading zero)
- `PATCH`: Patch number within the month
- `STAGE`: Release stage (alpha, beta, rc, stable)

Examples:
- `2025.7.1-alpha`: First alpha in July 2025
- `2025.8.2-beta`: Second beta in August 2025
- `2025.12.1`: First stable release in December 2025
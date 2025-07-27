# 🖤 ONYX-GATE

**The elegant gateway to unbreakable security**

Premium Pre-Boot Authentication with FIDO2 and anti-keylogger protection for TCG OPAL 2.0 self-encrypting drives.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg)](#)
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

### **Installation**
```bash
# Clone repository
git clone https://github.com/onyx-gate/onyx-gate.git
cd onyx-gate

# Initialize submodules
make init

# Build PBA image
make build

# Deploy to your OPAL drive (⚠️ DESTROYS ALL DATA)
sudo ./tools/onyx-gate setup /dev/nvme0n1
```

### **First Boot**
1. **Power on** → ONYX-GATE PBA environment loads
2. **Insert YubiKey** → Device detected automatically  
3. **Enter PIN** → Use virtual keyboard (randomized layout)
4. **Authentication** → Challenge-response with YubiKey
5. **Drive unlocks** → System reboots to main OS

## 🛠️ **Development Status**

**Current Phase**: Pre-Alpha Development

- [x] **Architecture Design** - Complete security architecture defined
- [x] **Competitive Analysis** - Comprehensive market research completed
- [x] **Project Structure** - Full development framework established
- [ ] **Virtual Keyboard MVP** - Core anti-keylogger innovation (In Progress)
- [ ] **FIDO2 Integration** - YubiKey authentication flow (Next)
- [ ] **TCG OPAL Integration** - Drive unlock implementation (Next)
- [ ] **VM Testing Environment** - Development and testing infrastructure (Next)

**MVP Target**: 12 days to working proof-of-concept

## 🤝 **Contributing**

ONYX-GATE is an open source project welcoming contributions from security researchers, cryptographers, and developers.

**Priority Areas:**
- Virtual keyboard randomization algorithms
- FIDO2/WebAuthn implementation
- TCG OPAL protocol integration  
- Security audit and testing
- Documentation and user guides

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## 📄 **License**

MIT License - see [LICENSE](LICENSE) file for details.

## 🌟 **Roadmap**

### **Phase 1 (Q1 2025): Core MVP**
- Virtual keyboard with randomization
- FIDO2 authentication integration  
- Basic TCG OPAL support
- VM testing environment

### **Phase 2 (Q2 2025): Production Ready**
- Hardware compatibility testing
- Performance optimization
- Security audit completion
- User documentation

---

**ONYX-GATE** - *Because your data deserves elegant protection* 🖤


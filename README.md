# ESPHome Device Configuration Framework

This repository contains a structured, reusable ESPHome configuration and build system for managing multiple embedded devices with professional-grade---

## 🔧 Hardware Configuration & Development Workflow

### **Current GPIO Configuration**
```text
ESP32-S3 DevKitC-1 (Freenove Board)
├── GPIO04: Pulse counter input (primary flow sensor)
├── GPIO05: Test output pin 
├── All pins tested: GPIO04, GPIO05, GPIO18, GPIO45, GPIO21
├── LED interference: Confirmed on all GPIO pins
└── PWM test signal: 4kHz, 50% duty cycle, 2.99V
```

### **Development Workflow Patterns**

#### **AI Assistant Workflow** (Non-blocking)
```bash
make build && make upload       # Verifiable steps with clear output
tail -10 logs/sysmon-ph.log    # Quick non-blocking log check
# Use separate terminals for commands to avoid blocking
```

#### **Human Developer Workflow** (Interactive)
```bash
make run                       # Interactive: build + upload + live logs
make logs-follow              # Dedicated log following terminal
make logs-stop               # Stop background log processes
```

> **Key Insight**: `make run` is optimized for human interaction, not AI assistance

### **Component Architecture Evolution**

#### **Modular Component System**
- **Created**: `../common/watchdog.yaml` reusable component
- **Pin assignments**: Via substitutions in `main.yaml`
- **Component includes**: Via packages section for clean modularity

#### **Professional Standards Established**
- **Consistent GPL v3.0 headers** across all files
- **Documentation style**: `@brief`/`@details`/`@author` format
- **Component startup logging** with tags and severity levels
- **Configurable pins** via substitutions pattern

#### **Component Benefits**
- **Hardware portability**: Change pins in main.yaml only
- **Component reusability**: Across different projects
- **Independent control**: Enable/disable components individually  
- **Team development**: Different developers, different components
- **Professional logging**: Tagged output for debugging

---

## ✅ Quality Assurancetomation and comprehensive development workflow.

---

## 📁 Project Layout

```text
.
├── Makefile               # Professional build system (24 targets)
├── README.md
├── VERSION                # Project version (0.3.0)
├── Doxyfile
├── configure.sh           # Interactive configuration generator
├── main.yaml              # Device template with variable substitution
├── common/
│   ├── display.yaml
│   ├── logging.yaml
│   ├── ota.yaml
│   ├── secrets.yaml       # Not tracked (gitignored)
│   ├── web_server.yaml
│   └── wifi.yaml
├── docs/                  # Generated documentation
│   ├── esphome/          # ESPHome component documentation
│   ├── html/             # Doxygen HTML documentation
│   └── latex/            # Doxygen PDF documentation
├── .gitignore
├── .makefile              # Auto-generated per-device configuration
└── <DEVICE_NAME>/
    └── <DEVICE_NAME>.yaml # Generated device configuration

```

---

## 🚀 Features

### **Professional Build System**
- **24 Makefile targets** with comprehensive functionality
- **Auto-detected Python** with sophisticated esptool integration
- **Safety mechanisms** with PROTECTED_DIRS and error handling
- **Dependency composition** for clean, maintainable target relationships

### **Advanced Development Workflow**
- **Interactive configuration** via `configure.sh` script
- **Template substitution** from main.yaml with variable interpolation
- **Comprehensive cleanup system** (clean, clobber, distclean)
- **Professional documentation generation** (ESPHome + Doxygen)

### **Flash Operations & Hardware Integration**
- **Complete esptool integration** for ESP32-S3 devices
- **Flash memory operations** (erase, info, verify)
- **Chip information** and capabilities detection
- **Firmware verification** against built binaries

### **Documentation & Quality**
- **Organized documentation structure** with multiple output formats
- **Professional header standards** with version tracking
- **Consistent code quality** with systematic formatting
- **Session continuity** with comprehensive development context

---

## 🛠️ Getting Started

1. **Clone and configure:**

```bash
git clone <repository-url>
cd esphome
make configure  # Interactive setup
```

2. **Build and deploy:**

```bash
make run        # Complete pipeline: build + upload + logs
```

3. **The configuration process defines:**

- `DEVICE_NAME` (e.g. `sysmon-ph`)
- `NODE_NAME` (used for mDNS)
- `FRIENDLY_NAME` (display name for Home Assistant)
- `UPLOAD_PATH` (USB port or IP address)
- Optional: Static IP, Gateway, Subnet, DNS configuration

---

## 🎯 Professional Make Targets

### **Build Pipeline**
```bash
make configure      # Interactive setup (.makefile generation)
make build          # Compile firmware (output to build.log)
make upload         # Upload firmware to device
make logs           # Stream live device logs
make run            # Complete pipeline: build + upload + logs
```

### **Platform Operations**
```bash
make flash-erase    # Erase ESP32-S3 flash (WARNING: destructive!)
make chip-info      # Display chip information and capabilities
make flash-info     # Display flash memory layout
make flash-verify   # Verify flash contents against firmware
```

### **Documentation Generation**
```bash
make docs           # Generate all documentation (ESPHome + Doxygen)
make docs-esphome   # Generate ESPHome component documentation
make docs-doxygen   # Generate Doxygen HTML/PDF documentation
```

### **Comprehensive Cleanup**
```bash
make clean          # Remove temporary build artifacts
make clean-cache    # Remove ESPHome build cache
make clean-docs     # Remove all generated documentation
make clobber        # Remove entire device directory
make distclean      # Complete cleanup for archive/export
```

### **Utilities**
```bash
make version        # Show platform and ESPHome versions
make buildvars      # Show current build configuration
make help           # Display professional help banner
```

---

## 🧾 Documentation System

### **Generate Documentation**
```bash
make docs           # Generate all documentation
make docs-esphome   # ESPHome component docs → docs/esphome/
make docs-doxygen   # Doxygen HTML/PDF → docs/html/, docs/latex/
```

### **Documentation Features**
- **ESPHome Component Documentation**: Device-specific configuration analysis
- **Doxygen Integration**: Professional HTML and PDF generation
- **Organized Structure**: Separate directories for different documentation types
- **Automatic Timestamps**: Generated documentation includes creation dates

---

## ⚡ Advanced Features

### **Auto-detected Python Integration**
- **Sophisticated fallback chain** for esptool availability
- **Cross-platform compatibility** (Windows/Cygwin/Linux)
- **Automatic detection** of Python installations with esptool module

### **Safety Systems**
- **PROTECTED_DIRS**: Prevents accidental deletion of critical directories
- **Error handling**: Comprehensive error messages with recovery suggestions
- **Dependency composition**: Clean, maintainable target relationships

### **Professional Development Environment**
- **VS Code integration**: Complete tasks.json with 9 ESPHome targets
- **Terminal compatibility**: Optimized for zsh/bash with proper command suppression
- **Session continuity**: GIT-COPILOT.md system for seamless restart capability

---

## ⚠️ Security & Secrets

- **Secrets management**: Stored in `common/secrets.yaml` (gitignored)
- **Template references**: Use `!secret` in YAML files
- **Version control**: Secrets automatically excluded from repository

---

## 🔧 Professional Standards

### **Code Quality**
- **Consistent formatting**: Professional commenting and spacing
- **Version tracking**: Synchronized versioning across all components
- **Documentation headers**: Doxygen-style with GPL v3.0 licensing

### **Development Workflow**
- **Professional Makefile**: 24 targets with enterprise-grade functionality
- **Comprehensive testing**: Flash verification and hardware validation
- **Quality assurance**: Systematic code review and formatting standards
- **Check-in process**: Structured validation via `CHECKIN-CHECKLIST.md`

---

## 🔍 Quality Assurance

### **Check-in Process**
Follow the comprehensive validation checklist in `CHECKIN-CHECKLIST.md`:
- **Pre-commit validation**: Build verification, code standards, documentation
- **Version management**: Consistent versioning across all components  
- **Repository hygiene**: Clean commits, proper file permissions
- **Archive readiness**: `make distclean` validation for clean workspace

### **Quick Validation Commands**
```bash
# Pre-commit validation
make clean && make build    # Clean build test
make help                   # Verify target documentation
make docs                   # Documentation generation test

# Post-commit validation  
make distclean && git status # Archive readiness test
make configure && make build # Fresh build validation
```

---

## 🙏 Co-Authorship

This project was co-developed by:

- **Roland Tembo Hendel** (author, architect)
- **GitHub Copilot by OpenAI** (co-author, automation + documentation)

All code, automation, and documentation were designed through conversational collaboration with professional development standards.

---

## 📜 License

Licensed under the GNU General Public License v3.0  
SPDX-License-Identifier: GPL-3.0-or-later

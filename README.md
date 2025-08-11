# PumpHouseBoss: ESPHome Pumphouse Monitor

> **Scope & Purpose:**
> This document provides a high-level overview, features, and onboarding information for the PumpHouseBoss project. It is the starting point for new contributors and users, describing the system, its capabilities, and how to get started.

An ESPHome-based system for monitoring and managing commercial or residential pumphouse or water distribution/filtration systems.

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Version](https://img.shields.io/badge/version-$(cat%20VERSION)-orange)](#)
[![Last Commit](https://img.shields.io/github/last-commit/hucklesberries/PumpHouseBoss?color=blue)](https://github.com/hucklesberries/PumpHouseBoss/commits/main)
[![Platform](https://img.shields.io/badge/platform-ESP32%20%7C%20ESP32S3-lightgrey)](#)
[![Release](https://img.shields.io/github/v/release/hucklesberries/PumpHouseBoss?include_prereleases&label=release)](https://github.com/hucklesberries/PumpHouseBoss/releases)
[![Docs](https://img.shields.io/badge/docs-wiki-blue)](#)
[![Maintenance](https://img.shields.io/maintenance/yes/2025)](#)

> **⚠️ _This project is currently under active development and is _not_ ready for practical deployment. Use at your own risk!_ ⚠️**


## Table of Contents

## Table of Contents
- [Product Features](#product-features)
- [Authorship](#authorship)
- [License](#license)
- [Available Variants](#available-variants)
- [Firmware Features](#firmware-features)
- [Getting Started](#getting-started)
- [Collaboration](#collaboration)
- [Automations](#automations)
- [FAQ / Common Issues](#faq-and-common-issues)
- [Contact & Support](#contact-and-support)


## Product Features
- Over/under flow-rate detection, alerts and alarms
- Automated solenoid control for emergency water-shutoff or water-flow management/control
- Manual emergency override (button) to shut-off water-flow
- Historical flow-rate/usage graphing
- Home Assistant integration via ESPHome
- LED System Status indications
- 4 Line LCD Display
- Support for up to 8 MMUs (Monitor/Management Units) to monitor and manage up to 8 water-lines
- Extensible to other flow-monitoring and and management operations and fluid-types

## Authorship
Project developed and maintained by:
- Roland Tembo Hendel (author, architect)
- GitHub Copilot (AI automation and documentation support)

## License
GNU General Public License v3.0
SPDX-License-Identifier: GPL-3.0-or-later

## Available Variants
The PumpHouseBoss project supports three hardware variants:

### PumpHouseBoss Standard
- **Platform:** Espressif ESP32 (30 pin)
- **MMUs:** 1
- **Indications:** 4 LED status outputs
- **Controls:**  3 button; System Reset, Manual MMU Control (shut-off)
- **Display:** 4 line by 20 character display (lcd_pcf8574 I2C interface)
- **Other:** USB programming/debugging port
- **Reference:**
    - [PHB Standard Functional Overview](phb-std-overview.md)
    - [PHB Standard Hardware Guide](phb-std-hardware.md)

### PumpHouseBoss Professional
- **Platform:** Espressif ESP32-S3 (44 pin)
- **MMUs:** 8
- **Indications:** 4 LED status outputs
- **Controls:**  4 button; Display Control, System Reset, Manual MMU Control (shut-off)
- **Display:** 4 line by 20 character display (lcd_pcf8574 I2C interface)
- **Other:** USB programming/debugging port
- **Reference:**
    - [PHB Professional Functional Overview](phb-pro-overview.md)
    - [PHB Professional Hardware Guide](phb-pro-hardware.md)

### PumpHouseBoss Test Harness
- **Platform:** Espressif ESP32/ESP32S3
- **Purpose:** Hardware and firmware test fixture for regression and integration testing
- **Features:** 8 PWM outputs, 4 line LCD, menu-driven output control
- **Reference:** [PHB Test Harness Overview](phb-test-overview.md)

See the `variants/` directory for detailed configuration and hardware mapping for each variant.

## Firmware Features
- Modular YAML configuration for all hardware components and variants
- Pinout maps and modular includes for ESP32/ESP32S3, PCF8574 display, and all I/O
- Comprehensive Makefile build, upload, logging, cleaning, documentation, and more
- Secure secrets management using `secrets.template.yaml` (never check in real secrets)
- Automated documentation generation (ESPHome, MkDocs)
- Automated version management and consistency checks
- Safety mechanisms to protect critical files and prevent destructive actions
- VS Code integration with pre-defined tasks for build and test
- Quality assurance via automated regression tests, checklists, and session continuity


## Getting Started

### 1. Clone the Repository

```sh
git clone https://github.com/hucklesberries/PumpHouseBoss.git
cd PumpHouseBoss
```

```
├── CHANGELOG.md                           # Project changelog
├── common/                                # Shared YAML configs and hardware includes
│   ├── api.yaml                           # API config
│   ├── display_pcf8574.yaml               # PCF8574 display config
│   ├── esp32.yaml                         # ESP32 base config
│   ├── esp32s3.yaml                       # ESP32-S3 base config
│   ├── indications.yaml                   # Indications config
│   ├── logging.yaml                       # Logging config
│   ├── mmu.yaml                           # MMU config
│   ├── ota.yaml                           # OTA update config
│   ├── secrets.template.yaml              # Template for secrets file
│   ├── secrets.yaml                       # Actual secrets (not in repo)
│   ├── web_server.yaml                    # Web server config
│   └── wifi.yaml                          # WiFi config
├── config/                                # Build and variant configuration
│   ├── config.mk                          # Main build config
│   ├── phb-pro.mk                         # Pro variant build config
│   ├── phb-std.mk                         # Standard variant build config
│   ├── phb-test.mk                        # Test harness build config
│   └── template.mk                        # Template for new configs
├── CONTRIBUTING.md                        # Contributor/developer guide
├── docs/                                  # Documentation and MkDocs config
│   ├── common-md/                         # Common markdown docs
│   │   ├── Contact-and-Support.md         # Contact/support info
│   │   ├── Developer-Guide.md             # Developer guide
│   │   ├── FAQ.md                         # Frequently asked questions
│   │   ├── Firmware-and-Configuration.md  # Firmware/configuration guide
│   │   ├── Getting-Started.md             # Getting started guide
│   │   ├── Hardware-Overview.md           # Hardware overview
│   │   ├── Overview.md                    # Project overview
│   │   └── Usage-and-Troubleshooting.md   # Usage/troubleshooting
│   ├── mkdocs.yml                         # MkDocs site config
│   ├── README-DOCS.md                     # Additional documentation
│   ├── site-md/                           # Site markdown docs
│   │   └── Home.md                        # Site home page
│   └── wiki-md/                           # Wiki markdown docs
│       └── Home.md                        # Wiki home page
├── LICENSE                                # Project license (GPLv3)
├── logs/                                  # Build and regression logs
│   ├── pre-commit.log                     # Pre-commit log
│   └── regression-test.log                # Regression test log
├── Makefile                               # Main project Makefile
├── makefile.mk                            # Makefile macros and helpers
├── README.md                              # Project overview and documentation
├── RELEASE.md                             # Release notes and instructions
├── RELEASE-CHECKLIST.md                   # Release checklist
├── scripts/                               # Project scripts and automation
│   ├── pco_common.py                      # Shared Python utilities
│   ├── pco-header.py                      # Header validation script
│   ├── pco-version.py                     # Version check script
│   ├── pre-commit.py                      # Pre-commit checks
│   ├── regression-test.py                 # Regression test automation
│   └── safe_rm.sh                         # Safe file removal script
├── STANDARDS.md                           # Coding standards and conventions
├── TODO.md                                # Project TODOs and future plans
├── variants/                              # Device variant definitions
│   ├── phb-pro/                           # Pro variant files
│   │   ├── phb-pro.mk                     # Pro build config
│   │   ├── phb-pro.yaml                   # Pro YAML config
│   │   ├── phb-pro-hardware.md            # Pro hardware guide
│   │   └── phb-pro-overview.md            # Pro functional overview
│   ├── phb-std/                           # Standard variant files
│   │   ├── phb-std.mk                     # Standard build config
│   │   ├── phb-std.yaml                   # Standard YAML config
│   │   ├── phb-std-hardware.md            # Standard hardware guide
│   │   └── phb-std-overview.md            # Standard functional overview
│   └── phb-test/                          # Test harness variant files
│       ├── indications.yaml               # Test harness indications config
│       ├── phb-test.mk                    # Test harness build config
│       ├── phb-test.yaml                  # Test harness YAML config
│       ├── phb-test-hardware.md           # Test harness hardware guide
│       └── phb-test-overview.md           # Test harness functional overview
└── VERSION                                # Project version string
```

### 2. Review Documentation
Read all Markdown files in the project root for standards, changelogs, and workflow:

### Wiki
The project wiki is maintained in `docs/src/` for easy editing and backup. Key pages:

- **Wiki Home**: docs/src/Home.md
- **Overview**: docs/src/Overview.md
- **Getting Started**: docs/src/Getting-Started.md
- **Hardware Overview**: docs/src/Hardware-Overview.md
- **Firmware & Configuration**: docs/src/Firmware-and-Configuration.md
- **Usage and Troubleshooting**: docs/src/Usage-and-Troubleshooting.md
- **Developer Guide**: docs/src/Developer-Guide.md
- **FAQ**: docs/src/FAQ.md
- **Contact & Support**: docs/src/Contact-and-Support.md

| Document Title | Description |
|---|---|
| [README.md](README.md) | Main project overview, setup, and documentation (this file) |
| [STANDARDS.md](STANDARDS.md) | Coding standards, conventions, and check-in procedures |
| [RELEASE.md](RELEASE.md) | Release notes and instructions for new versions |
| [CHANGELOG.md](CHANGELOG.md) | Project changelog; documents all major changes and releases |
| [RELEASE-CHECKLIST.md](RELEASE-CHECKLIST.md) | (If present) Record of previous check-in status |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Contributor/developer guide, session context, and Copilot usage |
| [TODO.md](TODO.md) | Project TODOs and possible future enhancements |

### 3. Configure Your Build
Copy the secrets template and edit your secrets:
  ```sh
  cp common/secrets.template.yaml common/secrets.yaml
  # Edit common/secrets.yaml with your actual secrets
  ```
Create and edit your build configuration:
  ```sh
  
  # Edit config/config.mk to match your hardware and preferences
  ```

### 4. Build, Flash, and Test
Use the following Makefile targets for common tasks:

**Build Targets:**
- `make build`               Build (compile) firmware for the selected device variant

**Platform Targets:**
- `make upload`              Upload compiled firmware to the device (via COMM_PATH)
- `make flash-verify`        Verify device flash contents against current firmware build
- `make run`                 Build, upload, and stream logs (combo pipeline)
- `make flash-erase`         Erase entire device flash memory (CAREFUL: destructive!)
- `make flash-info`          Show flash memory information and layout
- `make chip-info`           Show device chipset information and capabilities

**Logging Targets:**
- `make logs`                Stream logs in the foreground (interactive, blocks terminal)
- `make logs-start-bg`       Start background logging to file (creates logs/DEVICE.log symlink)
- `make logs-stop-bg`        Stop background logging processes for this device
- `make logs-follow`         Follow logs in real-time from the background log file
- `make logs-follow-new`     Start new background logging and follow its output

**Documentation Targets:**
- `make docs`                Generate project documentation
- `make docs-deploy`         Generate and deploy documentation to GitHub Pages and GitHub Wiki repository

**Test Targets:**
- `make regression-test`     Run regression tests on all device YAMLs

**Cleanup Targets:**
- `make clean`               Remove temporary build artifacts and logs
- `make clean-cache`         Remove ESPHome build cache
- `make clean-docs`          Remove generated documentation
- `make clobber`             Remove entire device directory and documentation
- `make distclean`           Complete cleanup for archive/export

**Utility Targets:**
- `make version`             Show platform and ESPHome version
- `make buildvars`           Show current build configuration values
- `make help`                Show this message

#### Note on Communication Path (COMM_PATH)
The Makefile uses the `COMM_PATH` variable to control how the build host machine communicates with the target ESP32/ESP32s3 device-either via serial port or the network (OTA).
- If `COMM_PATH` is set to a device hostname (e.g., `some_device.local`), upload is performed over OTA (WiFi).
- If `COMM_PATH` is set to a serial port (e.g., `COM8` or `/dev/ttyUSB0`), upload is performed over serial.

**Examples:**
- `make upload COMM_PATH=phb-pro-00.local` (OTA upload)
- `make upload COMM_PATH=COM8` (Serial upload)


## Collaboration
Contributions, collaboration, suggestions, and critique are welcome.

For a comprehensive guide to the implementation standards applied to this project,
please refer to [PHB Implementation Standards](STANDARDS.md)


## Automations
The following automation scripts are included to streamline development. These can be run directly from the `scripts/` directory or integrated into your workflow:
- `pco-header.py`      – Validates file headers for standards conformance
- `pco-version.py`     – Checks and manages project version consistency
- `pco_common.py`      – Python module with shared utilities for PCO scripts
- `pre-commit.py`      – Runs pre-commit checks for code and documentation
- `regression-test.py` – Automates regression testing for the project
- `safe_rm.sh`         – Safely removes files and directories (used by Makefile)

Refer to each script for usage details and integration points. Most build, test, and clean operations are managed via Makefile targets.


## FAQ and Common Issues

**Q: Build fails due to missing secrets or configuration files.**
> Ensure you have copied the secrets template (`common/secrets.template.yaml`) to `common/secrets.yaml` and the configuration template (`configuration/template.mk`) to `configuration/config.mk`, then edited them for your environment.

**Q: Upload or flash fails.**
> Double-check your device is connected, the correct serial port is selected, and your user has permission to access the device.

**Q: Logging does not work or logs are empty.**
> Make sure the device is running, and you are using the correct log target. Try `make logs-fresh` for a clean session.

**Q: Wrong variant or hardware configuration.**
> Edit your configuration (`config/config.mk`) to select the correct variant and hardware options for your device.

For more troubleshooting, see the [project wiki](#) or open an issue.


## Contact and Support

For bug reports, questions, or contributions:
- Open an issue or pull request on [GitHub](https://github.com/hucklesberries/PumpHouseBoss)
- Contact the maintainer via the email listed in the repository profile
- See the [project wiki](#) for more documentation and help (coming soon)

# PumpHouseBoss: ESPHome Pumphouse Monitor

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
- [Product Features](#product-features)
- [Authorship](#authorship)
- [License](#license)
- [Available Variants](#available-variants)
- [Firmware Features](#firmware-features)
- [Getting Started](#getting-started)
- [Collaboration](#collaboration)
- [Automations](#automations)
- [FAQ / Common Issues](#faq--common-issues)
- [Contact & Support](#contact--support)


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
The PumpHouseBoss project supports two hardware variants:

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
- **Controls:**  4 button; Display Control, Systemm Reset, Manual MMU Control (shut-off)
- **Display:** 4 line by 20 character display (lcd_pcf8574 I2C interface)
- **Other:** USB programming/debugging port
- **Reference:**
    - [PHB Professional Functional Overview](phb-pro-overview.md)
    - [PHB Professional Hardware Guide](phb-pro-hardware.md)

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

│
├── CHANGELOG.md                    # Project changelog
├── common/                             # Shared YAML configs and hardware includes
│   ├── display_st7789.yaml             # ST7789 display config
│   ├── esp32.yaml                      # ESP32 base config
│   ├── esp32s3.yaml                    # ESP32-S3 base config
│   ├── logging.yaml                    # Logging config
│   ├── ota.yaml                        # OTA update config
│   ├── secrets.template.yaml           # Template for secrets file
│   ├── secrets.yaml                    # Actual secrets (not in repo)
│   ├── watchdog.yaml                   # Watchdog timer config
│   ├── web_server.yaml                 # Web server config
│   └── wifi.yaml                       # WiFi config
├── config/                         # Build and variant configuration
│   ├── config.mk                       # Main build config
│   ├── default.mk                      # Default build settings
│   ├── phb-pro-test.mk                 # Test config for Pro variant
│   ├── phb-std-test.mk                 # Test config for Standard variant
│   └── template.mk                     # Template for new configs
├── docs/                           # Documentation and MkDocs config
│   └── mkdocs.yml                      # MkDocs site config
├── GIT-COPILOT.md                  # Copilot session context and usage notes
├── icons/                          # Status and WiFi icon images
│   ├── status_error.png                # Error status icon
│   ├── status_ok.png                   # OK status icon
│   ├── status_warn.png                 # Warning status icon
│   ├── wifi-0.png                      # WiFi signal icon (0%)
│   ├── wifi-100.png                    # WiFi signal icon (100%)
│   ├── wifi_0.png                      # WiFi signal icon (0%)
│   ├── wifi_1.png                      # WiFi signal icon (25%)
│   ├── wifi_2.png                      # WiFi signal icon (50%)
│   ├── wifi_3.png                      # WiFi signal icon (75%)
│   └── wifi_4.png                      # WiFi signal icon (100%)
├── LICENSE                         # Project license (GPLv3)
├── logs/                           # Log files (created at runtime)
├── Makefile                        # Main project Makefile
├── makefile.mk                     # Makefile macros and helpers
├── README.md                       # Project overview and documentation
├── RELEASE-CHECKLIST.md            # Release checklist (if present)
├── RELEASE.md                      # Release notes and instructions
├── scripts/                        # Project scripts and automation
│   ├── .common.sh                      # Shared shell functions for scripts
│   └── regression-test.sh              # Regression test automation
├── STANDARDS.md                    # Coding standards and conventions
├── TODO.md                         # Project TODOs and future plans
├── variants/                       # Device variant definitions
│   ├── phb-pro/                        # Pro variant files
│   │   ├── phb-pro-hardware.md             # Pro hardware guide
│   │   ├── phb-pro-overview.md             # Pro functional overview
│   │   ├── phb-pro.mk                      # Pro variant Makefile config
│   │   └── phb-pro.yaml                    # Pro variant YAML config
│   └── phb-std/                        # Standard variant files
│       ├── phb-std-hardware.md             # Standard hardware guide
│       ├── phb-std-overview.md             # Standard functional overview
│       ├── phb-std.mk                      # Standard variant Makefile config
│       └── phb-std.yaml                    # Standard variant YAML config
└── VERSION                         # Project version string
```


### 2. Review Documentation
Read all Markdown files in the project root for standards, changelogs, and workflow:

| Document Title | Description |
|---|---|
| [README.md](README.md) | Main project overview, setup, and documentation (this file) |
| [STANDARDS.md](STANDARDS.md) | Coding standards, conventions, and check-in procedures |
| [RELEASE.md](RELEASE.md) | Release notes and instructions for new versions |
| [CHANGELOG.md](CHANGELOG.md) | Project changelog; documents all major changes and releases |
| [RELEASE-CHECKLIST.md](RELEASE-CHECKLIST.md) | (If present) Record of previous check-in status |
| [GIT-COPILOT.md](GIT-COPILOT.md) | Session context, developer notes, and Copilot usage |
| [TODO.md](TODO.md) | Project TODOs and possible future enhancements |

### 3. Configure Your Build
Copy the secrets template and edit your secrets:
  ```sh
  cp common/secrets.template.yaml common/secrets.yaml
  # Edit common/secrets.yaml with your actual secrets
  ```
Create and edit your build configuration:
  ```sh
  cp configuration/template.mk configuration/config.mk
  # Edit configuration/config.mk to match your hardware and preferences
  ```

### 4. Build, Flash, and Test
Use the following Makefile targets for common tasks:

  **Build & Flash:**
  - `make build` – Compile firmware for the selected device
  - `make upload` – Upload firmware to the device
  - `make run` – Build, upload, and start logging (all-in-one)

  **Logging:**
  - `make logs` – Start background logging to logs/DEVICE.log
  - `make logs-follow` – Follow logs in real-time
  - `make logs-stop` – Stop background logging processes
  - `make logs-interactive` – Stream logs interactively (blocks terminal)
  - `make logs-fresh` – Start fresh logging session and follow immediately

  **Device Info & Flash:**
  - `make chip-info` – Display platform chip information
  - `make flash-info` – Display flash memory information
  - `make flash-verify` – Verify flash contents against firmware build
  - `make flash-erase` – Erase entire platform flash memory (destructive!)

  **Documentation:**
  - `make docs` – Generate all documentation (ESPHome and MkDocs)
  - `make docs-esphome` – Generate ESPHome documentation
  - `make docs-mkdoc` – Generate MkDocs documentation

  **Cleanup:**
  - `make clean` – Remove build artifacts and logs
  - `make clean-cache` – Remove ESPHome build cache
  - `make clean-docs` – Remove all generated documentation
  - `make clobber` – Remove device directory and documentation
  - `make distclean` – Complete cleanup for archive/export

  **Test:**
  - `make regression-test` – Run regression tests for the project

  **Utility:**
  - `make version` – Show project and ESPHome version
  - `make buildvars` – Show current build configuration values
  - `make help` – Show help/target summary


## Collaboration
Contributions, collaboration, suggestions, and critique are welcome.

For a comprehensive guide to the implementation standards applied to this project,
please refer to [PHB Implementation Standards](STANDARDS.md)


## Automations
Several automations are included to streamline the development process. These automations can be exercised as make targets or run directly from the project 'scripts' directory.
1. sanitize.sh        - performs standards conformance validation on a project file [TBD]
2. regression-test.sh - performs build and basic regression testing across all makefile targets
3. pre-check-in.sh    - perfomes pre-checkin process per project standards [TBD]
4. check-in.sh        - perfomes checkin process per project standards [TBD]
5. post-check-in.sh   - perfomes checkin process per project standards [TBD]

## FAQ / Common Issues

**Q: Build fails due to missing secrets or configuration files.**
> Ensure you have copied the secrets template (`common/secrets.template.yaml`) to `common/secrets.yaml` and the configuration template (`configuration/template.mk`) to `configuration/config.mk`, then edited them for your environment.

**Q: Upload or flash fails.**
> Double-check your device is connected, the correct serial port is selected, and your user has permission to access the device.

**Q: Logging does not work or logs are empty.**
> Make sure the device is running, and you are using the correct log target. Try `make logs-fresh` for a clean session.

**Q: Wrong variant or hardware configuration.**
> Edit your configuration (`config/config.mk`) to select the correct variant and hardware options for your device.

For more troubleshooting, see the [project wiki](#) or open an issue.


## Contact & Support

For bug reports, questions, or contributions:
- Open an issue or pull request on [GitHub](https://github.com/hucklesberries/PumpHouseBoss)
- Contact the maintainer via the email listed in the repository profile
- See the [project wiki](#) for more documentation and help (coming soon)

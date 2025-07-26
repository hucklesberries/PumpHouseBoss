# PumpHouseBoss: ESPHome Pumphouse Monitor

  A professional ESPHome-based system for monitoring and managing a commercial or residential pumphouse or water distribution/filtration system.

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Docs](https://img.shields.io/badge/docs-wiki-blue)](#)

> **⚠️ _This project is currently under active development and is _not_ ready for practical deployment. Use at your own risk!_ ⚠️**


## Product Features
- Monitors water flow and detects anomalies
- Controls solenoids to manage water flow and prevent water loss from water-line breaks and leaks
- Built-in integration with ESPHome Applications (i.e. Home Assistant)
- Can send alerts through integrated software (i.e. Home Assistant)


## Authorship
Project developed and maintained by:
- Roland Tembo Hendel (author, architect)
- GitHub Copilot (AI automation and documentation support)


## License
GNU General Public License v3.0
SPDX-License-Identifier: GPL-3.0-or-later


## Firmware Features
- Modular YAML configuration for all hardware components and variants
- Pinout maps and modular includes for ESP32/ESP32S3, ST7789 display, Pico-LCD, and all supported hardware
- Comprehensive Makefile with 24+ targets for build, upload, logging, cleaning, documentation, and more
- Secure secrets management using `secrets.template.yaml` (never check in real secrets)
- Automated and manual documentation generation (ESPHome, MkDocs)
- Automated version management and consistency checks
- Safety mechanisms to protect critical files and prevent destructive actions
- VS Code integration with pre-defined tasks for build and test
- Quality assurance via automated regression tests, checklists, and session continuity


## Available Variants
The PumpHouseBoss system supports three hardware variants, each tailored for different use cases and hardware configurations:

### phb-pro-max
- **Platform:** Espressif ESP32-S3 (44 pin)
- **Ports:** Up to 8
- **Display:** Waveshare Pico LCD 1.3" 240x240
- **Controls:** Integrated menu and controls
- **Other:** USB programming/debugging port

### phb-pro
- **Platform:** Espressif ESP32-S3 (44 pin)
- **Ports:** Up to 6
- **Status:** 3 LED status outputs
- **Controls:** External reset and emergency shut-off buttons
- **Other:** USB programming/debugging port

### phb-std
- **Platform:** Espressif ESP32 (30 pin)
- **Ports:** Up to 6 (default is 1)
- **Status:** 3 LED status outputs
- **Controls:** External reset and emergency shut-off buttons
- **Other:** USB programming/debugging port

See the `variants/` directory for detailed configuration and hardware mapping for each variant.


## Repository File Tree
```
│
├── CHANGELOG.md                  *Project changelog; documents all major changes and releases*
├── common/                       *Shared YAML modules for hardware, logging, OTA, wifi, etc.*
│   ├── display_st7789.yaml            *ST7789 display configuration*
│   ├── esp32.yaml                     *ESP32 base configuration*
│   ├── esp32s3.yaml                   *ESP32-S3 base configuration*
│   ├── logging.yaml                   *Logging configuration*
│   ├── ota.yaml                       *OTA update configuration*
│   ├── secrets.template.yaml          *Template for secrets.yaml*
│   ├── secrets.yaml                   *User secrets (gitignored)*
│   ├── watchdog.yaml                  *Watchdog timer configuration*
│   ├── web_server.yaml                *Web server configuration*
│   └── wifi.yaml                      *Wi-Fi configuration*
├── configuration/                *Input configuration templates and Makefile fragments*
│   ├── config.mk                        *Main configuration Makefile fragment*
│   ├── default.mk                       *Default configuration fragment*
│   ├── phb-pro-max-test.mk              *phb-pro-max test configuration*
│   ├── phb-pro-test.mk                  *phb-pro test configuration*
│   ├── phb-std-test.mk                  *phb-std test configuration*
│   └── template.mk                      *Secrets template Makefile fragment*
├── DISPOSITION.md                  *(If present) Disposition or project planning notes*
├── docs/                           *Project documentation, MkDocs config, and generated docs*
│   └── mkdocs.yml                        *MkDocs configuration file*
├── GIT-COPILOT.md                  *Session context, developer notes, and Copilot usage*
├── icons/                          *PNG icons for status and UI*
│   ├── status_error.png                 *Error status icon*
│   ├── status_ok.png                    *OK status icon*
│   ├── status_warn.png                  *Warning status icon*
│   ├── wifi_0.png                       *Wi-Fi signal icon 0*
│   ├── wifi_1.png                       *Wi-Fi signal icon 1*
│   ├── wifi_2.png                       *Wi-Fi signal icon 2*
│   ├── wifi_3.png                       *Wi-Fi signal icon 3*
│   ├── wifi_4.png                       *Wi-Fi signal icon 4*
│   ├── wifi-0.png                       *Wi-Fi signal icon alt 0*
│   └── wifi-100.png                     *Wi-Fi signal icon 100*
├── LICENSE                         *Project license (GPL v3.0 or later)*
├── Makefile                        *Main Makefile for build, upload, docs, and automation*
├── makefile.mk                     *(If present) Additional Makefile fragments*
├── README.md                       *Main project overview, setup, and documentation (this file)*
├── regression-test.sh              *Automated regression test script for Makefile/YAML*
├── RELEASE.md                      *Release notes and instructions for new versions*
├── STANDARDS.md                    *Coding standards, conventions, and check-in procedures*
├── TODO.md                         *Project TODOs and possible future enhancements*
├── variants/                       *Hardware variant directories (each with main.yaml and variant.mk)*
│   ├── phb-pro/
│   │   ├── main.yaml                    *phb-pro main configuration*
│   │   └── variant.mk                   *phb-pro Makefile fragment*
│   ├── phb-pro-max/
│   │   ├── main.yaml                    *phb-pro-max main configuration*
│   │   └── variant.mk                   *phb-pro-max Makefile fragment*
│   └── phb-std/
│       ├── main.yaml                    *phb-std main configuration*
│       └── variant.mk                   *phb-std Makefile fragment*
└── VERSION                         *Current project version string*
```


## Getting Started

### 1. Clone the Repository

```sh
git clone https://github.com/hucklesberries/PumpHouseBoss.git
cd PumpHouseBoss
```

### 2. Review Documentation

- Read all Markdown files in the project root for standards, changelogs, and workflow:
  - `README.md` – Main project overview, setup, and documentation (this file)
  - `STANDARDS.md` – Coding standards, conventions, and check-in procedures
  - `RELEASE.md` – Release notes and instructions for new versions
  - `CHANGELOG.md` – Project changelog; documents all major changes and releases
  - `DISPOSITION.md` – (If present) Record of previous check-in status
  - `GIT-COPILOT.md` – Session context, developer notes, and Copilot usage
  - `TODO.md` – Project TODOs and possible future enhancements
- (Coming Soon) Review the project wiki for additional details.


### 3. Configure Your Build

- Copy the secrets template and edit your secrets:
  ```sh
  cp common/secrets.template.yaml common/secrets.yaml
  # Edit common/secrets.yaml with your actual secrets
  ```
- Create and edit your build configuration:
  ```sh
  cp configuration/template.mk configuration/config.mk
  # Edit configuration/config.mk to match your hardware and preferences
  ```

### 4. Build, Flash, and Test

- Use the following Makefile targets for common tasks:

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

  **Testing:**
  - `make regression-test` – Run regression tests on all device YAMLs

  **Utility:**
  - `make version` – Show project and ESPHome version
  - `make buildvars` – Show current build configuration values
  - `make help` – Show help/target summary


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


# Changelog

> **Note:** For detailed release notes, see RELEASE.md. This changelog is a concise, developer-focused summary.

## [0.7.1] - 2025-07-28
### Changed
- Checked and fixed file permissions for scripts and assets (icons)
- Improved README.md: file tree now includes concise comments for every file
- Ensured all automation, Makefiles, and scripts are standards-compliant
- Added/updated documentation for check-in and release process
- General code and documentation cleanup for clarity and maintainability

## [0.7.0] - 2025-07-26
### Added
- Support for multiple hardware variants with modular configuration
- Table of Contents, FAQ, and Contact/Support sections in documentation
- Security best practices: secrets template, gitignore updates, onboarding guidance
### Changed
- Consistent terminology and improved documentation
- Enhanced Makefile automation and clarified targets
- Improved onboarding workflow and Getting Started instructions
- Cleaned up and organized project TODOs and release notes


## [0.6.8] - 2025-07-24
### Changed
- Repository name changed from sysmon-ph to PumpHouseBoss


## [0.6.7] - 2025-07-23
### Added
- Major UI improvements for ST7789 display
- Pinout maps for ESP32S3, ST7789, Pico-LCD
- `secrets.template.yaml` for onboarding
### Changed
- Improved Makefile automation, .gitignore, and documentation
- Refined check-in checklist and commit message standards


## [0.6.6] - 2025-07-22
### Added
- UI improvements for ST7789 display
- Pinout maps for ESP32S3, ST7789, Pico-LCD
- `secrets.template.yaml` for onboarding
### Changed
- Makefile automation, .gitignore, and documentation


## [0.6.1] - 2025-07-19
### Added
- ESP32 board and framework configuration
- Automated device configuration via `configure.sh`
- Modular includes: `wifi.yaml`, `ota.yaml`, `logging.yaml`, `web_server.yaml`
- Fully automated Makefile for build, upload, and logging
### Changed
- Migrated to independent sysmon-ph repository
- Improved check-in checklist, .gitignore, and documentation


## [baseline-makefile-auto] - 2025-07-18
- Snapshot before major Makefile automation overhaul


## [0.5.0] - 2025-07-10
- Migrated to independent sysmon-ph repository
- Quality assurance system added
- Improved documentation, workflow, and check-in checklist


## [0.3.0] - 2025-06-20
- Major refactor and cleanup
- Improved modularity, build scripts, and Makefile automation


## [0.1.0] - 2025-06-01
- First working version of ESPHome configuration
- Initial Makefile and YAML includes

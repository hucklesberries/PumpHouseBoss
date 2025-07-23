# Changelog

## [0.6.6] - 2025-07-22
**VERSION bump**: 0.6.5 → 0.6.6
- Major UI improvements: ST7789 display now shows Hostname, SSID, IP, and MAC address, with robust centering and fallback for missing values
- Font size and layout adjustments for better data fit and readability
- Fixed MAC address display and improved sensor value handling

- Provided pinout maps for ESP32S3, ST7789 display, and Pico-LCD hardware components
- Improved Makefile automation and .gitignore for secrets and generated files
- Updated `secrets.template.yaml` and documentation for secure workflow
- Refined check-in checklist and commit message standards
- General code cleanup, header consistency, and version reference updates

### Changed
- `common/display_st7789.yaml`: UI, font, and lambda logic for device info
- `main.yaml`, `common/*.yaml`: Documentation, linter, and modularization
- `Makefile`, `.gitignore`, `README.md`, `CHECKIN-CHECKLIST.md`, `GIT-COPILOT.md`, `RELEASE.md`: Workflow, automation, and documentation
- Restored detailed Makefile header (author, version, copyright)
- Removed user-specific Python path from Makefile; now portable
- Fixed shell syntax error in `check-secrets` target
- General Makefile polish and documentation improvements

### Added
- `secrets.template.yaml` for safe onboarding

### Removed
- Obsolete scripts and unused files (e.g., fix_bdf_encoding.py)

---

## [0.6.1] - 2025-07-19
 **VERSION bump**: 0.6.0 → 0.6.1
- Updated .gitignore, Makefile, and documentation for clean check-in
- Ensured all references to version number are consistent across codebase
- Added `common/esp32.yaml` for ESP32 board and framework configuration (modular hardware setup)
- Automated device configuration via `configure.sh` for interactive setup and .makefile generation

### Changed
- Migrated from AW-Toolbox/sysmon-ph-staging to independent sysmon-ph repository
- Updated all documentation and references for new repo context
- Improved check-in checklist and quickref for professional workflow
- Verified file permissions, .gitignore, and build system for clean check-in
- **Check-in checklist** (`CHECKIN-CHECKLIST.md`) for comprehensive pre-commit validation
- **Enhanced logging targets**: `logs-fresh`, `logs-follow`, `logs-stop` for session control
- **Log cleanup** in `distclean` target for archive preparation

- **Help system**: Updated with new logging workflow targets
- **README.md**: Added Quality Assurance section with validation commands
- **GIT-COPILOT.md**: Enhanced with check-in process documentation
- Initial ESPHome build system for `sysmon-ph` (ESP32-S3)
- Modular includes: `wifi.yaml`, `ota.yaml`, `logging.yaml`, `web_server.yaml`
- Secrets stored securely in `common/secrets.yaml`
- Fully automated `Makefile` for build, OTA/USB upload, and logging
- License: GNU GPLv3 with SPDX headers
- `README.md` with basic usage instructions

### Changed
- None

### Removed
- None


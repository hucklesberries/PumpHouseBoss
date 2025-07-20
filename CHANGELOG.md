# Changelog


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


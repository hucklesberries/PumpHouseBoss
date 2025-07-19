# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.6.0] - 2025-07-18
### Changed
- Migrated from AW-Toolbox/sysmon-ph-staging to independent sysmon-ph repository
- Updated all documentation and references for new repo context
- Improved check-in checklist and quickref for professional workflow
- Verified file permissions, .gitignore, and build system for clean check-in

### Added
- Post-check-in procedure and version bump workflow in CHECKIN-CHECKLIST.md

### Ready for next development cycle

## [0.4.0] - 2025-07-18
### Added
- **Session-based logging system** with timestamped log files and symlink management
- **Check-in checklist** (`CHECKIN-CHECKLIST.md`) for comprehensive pre-commit validation
- **Enhanced logging targets**: `logs-fresh`, `logs-follow`, `logs-stop` for session control
- **Modular component architecture** with substitution-based pin configuration
- **Watchdog component** (`common/watchdog.yaml`) with reset monitoring and health scoring
- **AI continuity system** (KIBO.md) for seamless development session restoration
- **Board transition notes** for hardware troubleshooting documentation
- **Professional file permissions** normalized across repository
- **Log cleanup** in `distclean` target for archive preparation

### Changed
- **VERSION bump**: 0.5.0 → 0.6.0
- **Makefile logging**: Background process management with automatic session cleanup
- **Help system**: Updated with new logging workflow targets
- **README.md**: Added Quality Assurance section with validation commands
- **GIT-COPILOT.md**: Enhanced with check-in process documentation

### Fixed
- **File permissions**: Consistent 644 permissions across repository
- **Log file accumulation**: Session-specific logs prevent "giant mash" of accumulated logs
- **Component architecture**: Clean separation between hardware config and functionality

## [0.1.0] - 2025-07-08
### Added
- Initial ESPHome build system for `sysmon-ph` (ESP32-S3)
- Modular includes: `wifi.yaml`, `ota.yaml`, `logging.yaml`, `web_server.yaml`
- Configurable `config.yaml` with substitution variables
- Secrets stored securely in `common/secrets.yaml`
- Fully automated `Makefile` for build, OTA/USB upload, and logging
- Git-aware build environment with standardized `.gitignore` rules
- License: GNU GPLv3 with SPDX headers
- `README.md` with basic usage instructions

### Changed
- None

### Removed
- None


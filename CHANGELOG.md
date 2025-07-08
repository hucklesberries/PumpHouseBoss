# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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


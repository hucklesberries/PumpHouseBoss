
# sysmon-ph: ESPHome Pumphouse Monitor

A professional ESPHome-based system for monitoring and managing a commerecial or residential pumphouse 
or water distribution/filtration system.

> **⚠️ _This project is currently under active development and is _not_ ready for practical deployment. Use at your own risk!_ ⚠️**

## Product Features
- Monitors water flow and detects anomalies
- Controls solenoids to manage water flow and prevent water loss from water-line breaks and leaks
- Built-in integration with ESPHome Applications (i.e. Home Assistant)
- Can sends alerts through integrated sofware (i.e. Home Assistant)

## Firmware Features
- Modular YAML for hardware components
- Pinout maps for ESP32S3, ST7789 display, and Pico-LCD hardware for easy wiring and troubleshooting
- 24-target Makefile for build, upload, logging, cleaning, docs
- Interactive setup via `configure.sh`
- Improved onboarding with `secrets.template.yaml` for secure secrets management
- ESPHome documentation
- Automated version management
- Safety mechanisms to protect critical files
- VS Code integration with pre-defined tasks
- Quality assurance via checklists and session continuity

## Supported Hardware
- Espressif ESP32 MCU platforms
- Espressif ESP32s3 MCU platforms
- Waveshare Pico-LCD-1.3 Display (st7789) [OPTIONAL]
- 4-button Control(ler) [OPTIONAL]
- Status LEDs x 3 [OPTIONAL]

## Repository File Tree
```
.
├── CHANGELOG.md
├── CHECKIN-CHECKLIST.md
├── LICENSE
├── Makefile
├── README.md
├── RELEASE.md
├── VERSION
├── configure.sh
├── main.yaml
├── secrets.template.yaml
├── regression-test.sh
├── GIT-COPILOT.md
├── common/
│   ├── display_st7789.yaml
│   ├── esp32.yaml
│   ├── esp32s3.yaml
│   ├── logging.yaml
│   ├── ota.yaml
│   ├── watchdog.yaml
│   ├── web_server.yaml
│   └── wifi.yaml
├── docs/
│   └── mkdocs.yml
├── icons/
│   ├── status_error.png
│   ├── status_ok.png
│   ├── status_warn.png
│   ├── wifi-0.png
│   ├── wifi-100.png
│   ├── wifi_0.png
│   ├── wifi_1.png
│   ├── wifi_2.png
│   ├── wifi_3.png
│   └── wifi_4.png
```


## Dependencies

To build, flash, and document this project, you need:

- **Python 3** (for ESPHome and build scripts)
- **ESPHome** (`pip install esphome`)
- **Make** (GNU Make, available via Cygwin on Windows)
- **Cygwin** (for Unix-like tools and shell on Windows)
- **MkDocs** (`pip install mkdocs mkdocs-material`) for documentation
- **YAML linter** (optional, e.g., `pip install yamllint`)
- **Git** (for version control)

You may also need:
- ESP32 toolchain (if building/flashing outside ESPHome)
- pip packages: `esphome`, `mkdocs`, `mkdocs-material`, `yamllint`

See the Makefile and docs for more details.

## Getting Started

### 1. Clone and configure:
```bash
git clone <repository-url>
cd esphome
make configure  # Interactive setup
```

### 2. Set up your secrets file:
Before building or flashing this project, you must:

  1. Copy `secrets.template.yaml` to `secrets.yaml` in the project root.
  2. Edit `secrets.yaml` and fill in your actual Wi-Fi and OTA credentials.

`secrets.yaml` is ignored by version control and should NOT be checked in. The template ensures onboarding is safe and repeatable.

### 3. Build and deploy:
```bash
make run        # Build, upload, and logs
```

### 4. Configuration defines:
  - DEVICE_NAME, NODE_NAME, FRIENDLY_NAME
  - UPLOAD_PATH (USB/IP)
  - Optional: Static IP, Gateway, Subnet, DNS

## Makefile Targets
- `make configure`      # Interactive setup
- `make build`          # Compile firmware
- `make upload`         # Upload firmware
- `make logs`           # Stream device logs
- `make run`            # Build, upload, logs
- `make flash-erase`    # Erase ESP32-S3 flash
- `make chip-info`      # Chip info
- `make flash-info`     # Flash memory info
- `make flash-verify`   # Verify flash contents
- `make docs`           # Generate all docs
- `make clean`          # Remove build artifacts
- `make clobber`        # Remove device directory
- `make distclean`      # Full cleanup
- `make version`        # Show versions
- `make buildvars`      # Show build config
- `make help`           # Help banner

## Documentation
- ESPHome component docs: `docs/esphome/`
<!-- Doxygen HTML/PDF directories removed -->
- Automatic timestamps and organized structure

## Advanced Features
- Auto-detected Python/esptool integration
- Cross-platform compatibility (Windows/Cygwin/Linux)
- PROTECTED_DIRS and error handling

## Security & Secrets
- Secrets in `common/secrets.yaml` (gitignored)
- Use `!secret` in YAML
- Secrets excluded from repository

## Code Quality & Workflow
- Consistent formatting and commenting
- Synchronized versioning
<!-- Doxygen headers reference removed -->
- Comprehensive testing and validation
- Check-in process via `CHECKIN-CHECKLIST.md`

## Quality Assurance
- Pre-commit: `make clean && make build`, `make docs`
- Post-commit: `make distclean && git status`, `make configure && make build`

## Co-Authorship
Developed by:
- GitHub Copilot (author, architect)
- GitHub Copilot by OpenAI (automation, documentation)

## License
GNU General Public License v3.0
SPDX-License-Identifier: GPL-3.0-or-later

# SysMon-PH Project

This project provides a robust, maintainable workflow for ESPHome-based device management and documentation.

## Key Features
- Modern Makefile for build, upload, and configuration
- Automated documentation generation (MkDocs, ESPHome docs)
- Clean, duplication-free workflow
- All canonical docs in the project root; generated docs in `docs/`
- Portable Python detection (no user-specific paths)
- Professional header and documentation for maintainability

## Recent Updates
- Makefile header restored to professional, detailed format
- Removed user-specific Python path; now uses only `python3` or `python`
- Fixed shell syntax in `check-secrets` target
- General polish and cleanup for maintainability

## Usage
- Run `make` for the default build/upload/log workflow
- See `make help` for all available targets

---
For more details, see the Makefile and project documentation.

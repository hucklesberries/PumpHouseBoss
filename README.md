
# sysmon-ph: ESPHome Pumphouse Monitor

A professional ESPHome-based system for monitoring and managing a pumphouse using ESP32-S3. Features modular configuration, robust automation, and comprehensive documentation for collaborative development.

## Features
- Monitors water flow and detects anomalies
- Controls solenoids to manage water flow
- Modular YAML for hardware components
- Pinout maps for ESP32S3, ST7789 display, and Pico-LCD hardware for easy wiring and troubleshooting
- 24-target Makefile for build, upload, logging, cleaning, docs
- Interactive setup via `configure.sh`
- Improved onboarding with `secrets.template.yaml` for secure secrets management
- Doxygen and ESPHome documentation
- Automated version management
- Safety mechanisms to protect critical files
- VS Code integration with pre-defined tasks
- Quality assurance via checklists and session continuity

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
├── Doxyfile
├── sysmon-ph.code-workspace
├── icons/
└── common/
    ├── display_st7789.yaml
    ├── esp32s3.yaml
    ├── logging.yaml
    ├── ota.yaml
    ├── secrets.yaml
    ├── watchdog.yaml
    ├── web_server.yaml
    └── wifi.yaml
```


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
- Doxygen HTML/PDF: `docs/html/`, `docs/latex/`
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
- Doxygen headers, GPL v3.0 licensing
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

# Changelog

> **Scope & Purpose:**
> This changelog provides a concise, developer-focused summary of all significant changes to PumpHouseBoss. For detailed release notes, see RELEASE.md.


## [0.10.0d] - 2025-08-28
### Added
- Major refactor of 
  - Implemented input (solenoid emulation) and output (Hall-Effect flow sensor)
  - Implement display functionality
  - Implemented (button) control functionality
  - Implemented (LED) indication functionaliPumpHouseBoss Test Harness
  - Segmented code into `components`, `fragments`, and `packages` subdirectories for maintainability
  - Implemented robust singleton pattern and defensive programming in C++ helpers
  - Added comprehensive error logging and bounds checks in all helper functions
  - Modularized YAML configuration for hardware, controls, display, and logic
  - Added and standardized documentation blocks to all YAML fragments
  - Created `phb-test-specification.md` to consolidate hardware, features, and operator info
  - Improved Makefile and build scripts for safety, modularity, and clarity

### Changed
- Standardized capitalization and terminology (e.g., "TestPoint") across code and documentation
- Updated table of contents and section headings in documentation for clarity and accuracy
- Refined and simplified main YAML file structure
- Improved event handling and debounce logic for button inputs
- Enhanced display logic and lambda usage for LCD updates

### Fixed
- Corrected typos, spelling, and grammar in documentation and code comments
- Fixed pointer initialization and null checks in C++ code to prevent runtime errors
- Addressed issues with output frequency setting and PWM reliability on ESP32 LEDC

### Developer Impact
- Contributors must use new modular configuration and documentation standards
- Improved onboarding and maintainability for new hardware variants
- Hardened codebase against operator


## [0.9.0d] - 2025-08-10
### Added
-- Refactored header validation script (`pco-header.py`) with a robust state machine for strict schema enforcement, field order, multiline, and blank line rules
-- New PumpHouseBoss Test Harness variant (`phb-test.yaml`) for hardware and firmware testing, including PWM output and LCD support
-- Improved error reporting with precise line numbers and context for all header validation failures
-- Debug instrumentation for tracing state transitions and parser logic
-- Updated documentation and code comments for maintainability and onboarding

### Changed
- Major reorganization of Python scripts for clarity and maintainability
- State machine logic now enforces schema-driven validation, including multiline and blank line rules
- Multiline continuation logic is stricter and more predictable; all indented lines must conform to standards
- Blank line enforcement after multiline fields is now schema-driven
- Improved copyright and license validation to match project standards
- Removed duplicate and stray function definitions, reducing code bloat and errors
- Enhanced developer workflow with better error messages and debug output

### Fixed
- Fatal errors due to missing or misordered function definitions
- Logic errors in multiline continuation and field transitions
- Issues with header parsing for Makefile, YAML, and Python files
- Improved standards enforcement and automation for all project files

### Developer Impact
- All contributors must follow new header and multiline standards for all project files
- Test harness variant enables hardware regression and integration testing
- Debug output and error reporting make troubleshooting and onboarding easier
- Documentation and code comments updated for clarity and standards compliance


## [0.8.0d] - 2025-08-02
### Added
-- Standardized and refined headers in YAML, Bash, and Makefile files
-- Full PCO pre-commit framework for automated standards enforcement, with example scripts (pass, warn, fail) and the first functional PCO script for version checking
-- Refactored and modularized all documentation automation targets in the Makefile (`docs`, `docs-deploy`)
-- Nixed redundant or superfluous documentation automation targets in the Makefile (`docs-esphome`, `docs-mkdoc`)
-- Improved and standardized scripts for extracting YAML headers and generating Markdown for MkDocs and Wiki
-- Ensured all documentation targets and scripts are standards-compliant and maintainable
-- Validated output directories and file structure for documentation
-- Improved documentation for the documentation process itself
-- Major refactor of pre-commit automation: removed legacy code paths, unified script selection, improved summary banners, spinner, and color output
-- Enhanced standards enforcement: staged grep/awk version string checking, robust header and policy validation, and DRY output logic
-- Updated and validated all Markdown documentation, including TOC accuracy and standards compliance
-- Improved onboarding and developer experience: clarified documentation, added file tree, and streamlined setup instructions
-- Strengthened session continuity and check-in procedures in documentation and scripts
-- Validated and fixed file permissions for all scripts and assets
-- Improved regression testing and automation for build, upload, and logging workflows
-- UI improvements for ST7789 display
-- Pinout maps for ESP32S3, ST7789, Pico-LCD
-- `secrets.template.yaml` for onboarding

### Changed
- Improved quoting and substitution practices in YAML for ESPHome compatibility
- Enhanced template sensors and metadata blocks for Home Assistant integration
- Upgraded pre-commit.sh for modular, maintainable, and DRY checks
- Validated build, upload, and logging workflows for ESPHome devices
- Addressed and resolved issues with serial logging and firmware output
- Makefile automation, .gitignore, and documentation


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

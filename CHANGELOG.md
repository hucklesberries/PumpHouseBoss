# Changelog

> **Scope & Purpose:**
> This changelog provides a concise, developer-focused summary of all significant changes to PumpHouseBoss. For detailed release notes, see RELEASE.md.

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

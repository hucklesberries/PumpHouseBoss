# Release Notes

> **Scope & Purpose:**
> This document provides detailed release notes, milestones, and project status for each version of PumpHouseBoss. It is the authoritative record of changes and improvements for each release.

> **⚠️ _This project is currently under active development and is _not_ ready for practical deployment. Use at your own risk!_ ⚠️**


## Version 0.8.0d – 2025-08-02

**Milestone: YAML core improvements, header standardization, PCO framework, and enhanced automation**

### Highlights
- Refined and standardized headers in all YAML, Bash, and Makefile files
- Improved quoting and substitution practices in YAML for ESPHome compatibility
- Modularized configuration and package includes for maintainability
- Enhanced template sensors and metadata blocks for Home Assistant integration
- Upgraded pre-commit.sh for modular, maintainable, and DRY checks
- Populated arrays for YAML, Bash, and Makefile discovery in automation scripts
- Added the full PCO pre-commit framework for automated standards enforcement
- Provided example PCO scripts (pass, warn, fail) for framework demonstration
- Implemented the first functional PCO script to check version numbers in YAML files
- Planned new script for strict header standards enforcement across all project files
- Validated build, upload, and logging workflows for ESPHome devices
- Addressed and resolved issues with serial logging and firmware output
- Maintained code quality and project standards through automation and review

### Project Status
- YAML and automation scripts are now robust, maintainable, and standards-compliant
- Header and quoting practices are consistent across the project
- Build, upload, and logging workflows validated for all variants
- Standards enforcement and automation are integrated into the workflow

---

## Version 0.7.0 – 2025-07-26

**Pre-release milestone: Support for multiple Variants, and improved/automated processes and documentation**

### Highlights
- Support for multiple hardware variants with modular configuration
- Consistent terminology and improved documentation throughout the project
- Added a Table of Contents, FAQ, and Contact/Support sections to the README
- Enhanced Makefile automation and clarified target documentation
- Improved onboarding workflow and stepwise Getting Started instructions
- Security best practices: secrets template, gitignore updates, and onboarding guidance
- Cleaned up and organized project TODOs and release notes
- General code and documentation cleanup for clarity and maintainability

### Project Status
- Modular YAML includes for all major subsystems
- Secure secrets management and onboarding template
- Automated build, upload, and logging via Makefile
- Comprehensive documentation and workflow standards
- Comprehensive documentation and workflow standards

---

## Version 0.6.7 – 2025-07-23

**Pre-release milestone: Modular, maintainable, and secure ESPHome system for ESP32S3**

### Highlights
- Major UI improvements: ST7789 display now shows Hostname, SSID, IP, and MAC address, with robust centering and fallback for missing values
- Font size and layout adjustments for better data fit and readability
- Fixed MAC address display and improved sensor value handling

- Provided pinout maps for ESP32S3, ST7789 display, and Pico-LCD hardware components
- Improved Makefile automation and .gitignore for secrets and generated files
- Updated `secrets.template.yaml` and documentation for secure workflow
- Refined check-in checklist and commit message standards
- General code cleanup, header consistency, and version reference updates

### Project Status
- Modular YAML includes for all major subsystems
- Secure secrets management and onboarding template
- Automated build, upload, and logging via Makefile
- Comprehensive documentation and workflow standards

---

> **Note:** This is a pre-release for internal and development use. v1.x.y will mark the first stable public release.


# Release Notes

## Version 0.3.0 – Common Source Consolidation

**Date:** 2025-07-15

### 🔄 Changed

- Refactoring
- Wifi working

### 🆕 Added

- Several make targets
- Support for OTA
- Autogeneration notice in `.makefile`
- FriendlyName and NodeName fields in `.makefile` and YAML config
- Optional static IP configuration prompt

### 🛠 Maintenance

- `.makefile` now created only with user-specified or defaulted values
- `.gitignore` updated to match `*/VERSION` and not assume device names

### 🙏 Co-Authorship

This release co-authored by:

- **Roland Tembo Hendel**
- **ChatGPT by OpenAI**

The design, automation tooling, and documentation were collaboratively built through conversational engineering.

### ⚠️ Note

- Ensure `common/secrets.yaml` is excluded from version control
- Use `make clobber` to reset a device if needed

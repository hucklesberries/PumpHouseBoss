
# Firmware & Configuration

**See also:** [README.md](README.md) | [Wiki Home](Home.md) | [Overview](Overview.md) | [Getting Started](Getting-Started.md) | [Hardware Overview](Hardware-Overview.md) | [Usage & Troubleshooting](Usage-and-Troubleshooting.md) | [Developer Guide](Developer-Guide.md) | [FAQ](FAQ.md) | [Contact & Support](Contact-and-Support.md)

This section covers YAML configuration, secrets management, and the build/upload process.

## Modular YAML Configuration
- Device and variant-specific YAML files
- Includes for common hardware and features

## Secrets Management
- Use `common/secrets.template.yaml` as a base
- Never commit real secrets to the repo

## Build & Upload
- Use Makefile targets: `make build`, `make upload`, `make run`
- See [Getting Started](Getting-Started.md) for setup

---
For advanced configuration, see [CONTRIBUTING.md](CONTRIBUTING.md).


# Usage & Troubleshooting

**See also:** [README.md](README.md) | [Wiki Home](Home.md) | [Overview](Overview.md) | [Getting Started](Getting-Started.md) | [Hardware Overview](Hardware-Overview.md) | [Firmware & Configuration](Firmware-and-Configuration.md) | [Developer Guide](Developer-Guide.md) | [FAQ](FAQ.md) | [Contact & Support](Contact-and-Support.md)

This section provides guidance on using PumpHouseBoss and resolving common issues.

## Logging & Monitoring
- Use `make logs`, `make logs-follow`, and related targets
- Log files are stored in the `logs/` directory

## Common Issues
- Build failures: Check for missing secrets/config files
- Upload failures: Check device connection and `COMM_PATH`
- Logging issues: Ensure device is running and correct log target is used

## Regression Testing
- Run `make regression-test` to validate builds

---
For more help, see the [FAQ](FAQ.md) or open an issue on GitHub.

# ESPHome Makefile Project

This project provides a streamlined Makefile-based workflow for managing ESPHome device configurations, builds, uploads, and logs, along with automatic generation of device-specific static IP settings.

## Quick Start

1. Copy the repository to your project directory:

```bash
git clone <your-repo-url>
cd <your-repo-name>
```

2. Run the configuration script:

```bash
./configure.sh
```

This will create a `.makefile` with your device-specific settings.

3. Use the Makefile targets to manage your device:

```bash
make            # Default: build, upload, and show logs
make build      # Build firmware only
make upload     # Upload via USB or OTA
make run        # Build, upload, and show logs
make logs       # View device logs
make check      # Validate ESPHome config
make clean      # Remove build and generated files
```

## Files and Structure

```
.
├── Makefile             # Master build system
├── VERSION              # Project version (used in logs)
├── configure.sh         # Script to generate .makefile interactively
├── .makefile            # Auto-generated per-device config (excluded from git)
├── common/              # Shared YAML fragments
│   ├── wifi.yaml
│   ├── ota.yaml
│   ├── logging.yaml
│   └── web_server.yaml
├── <device-name>/       # One directory per device
│   ├── <device-name>.yaml   # Main device config
│   └── custom.yaml          # Generated static IP settings
└── build/               # Compiled firmware binaries
```

## Example `.makefile`

```makefile
NODE_NAME      = sysmon-ph
NODE_STATIC_IP = 10.11.2.16
NODE_GATEWAY   = 10.11.0.1
NODE_SUBNET    = 255.255.0.0
NODE_DNS1      = 10.11.0.1
NODE_DNS2      = 1.1.1.1
COM_PORT       = COM6
ESPHOME        = /cygdrive/c/Users/youruser/AppData/Local/Programs/Python/Python313/Scripts/esphome.exe
```

## Notes

- All generated files are ignored by git.
- The `configure.sh` script will prompt for missing values and create a `.makefile`.
- Modular YAML via `!include` keeps common logic DRY.

## License

This project is licensed under the terms of the [GNU General Public License v3.0](LICENSE).  
You are free to use, modify, and distribute this code, provided that all copies and derivatives remain under the same license.

# ------------------------------------------------------------------------------
#  @file        Makefile
#  @brief       Master Makefile for ESPHome-based device management
#  @details     This Makefile drives the build, upload, and configuration
#               process for ESPHome projects. It leverages a .makefile for per-device
#               definitions and includes safety mechanisms to prevent destructive errors.
#
#  @author      Roland Tembo Hendel
#  @email       rhendel@nexuslogic.com
#
#  @license     GNU General Public License v3.0
#               SPDX-License-Identifier: GPL-3.0-or-later
#  @copyright   Copyright (c) 2025 Roland Tembo Hendel
#               This program is free software: you can redistribute it and/or
#               modify it under the terms of the GNU General Public License
#               as published by the Free Software Foundation, either version 3
#               of the License, or (at your option) any later version.
#
#               This program is distributed in the hope that it will be useful,
#               but WITHOUT ANY WARRANTY; without even the implied warranty of
#               MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#               GNU General Public License for more details.
#
#               You should have received a copy of the GNU General Public License
#               along with this program. If not, see <https://www.gnu.org/licenses/>.
#
#  @note        Co-developed with ChatGPT by OpenAI.
# ------------------------------------------------------------------------------

# Load project version string
VERSION := $(shell cat VERSION)

# Default target — full pipeline: build + upload + logs
.DEFAULT_GOAL := run


# ----------------------------------------------------"a3yy--------------------------
# Build Targets
# ------------------------------------------------------------------------------
 
# Load per-device config if available
-include .makefile

# _makefile target — ensures presence before dependent targets run
.PHONY: _makefile
_makefile:
ifeq (,$(wildcard .makefile))
	$(error .makefile not present. Run 'make configure' or 'bash ./configure.sh' before 'make $(MAKECMDGOALS))
endif

# Run interactive configuration script to generate .makefile and YAML
.PHONY: configure
configure:
	@./configure.sh

# Compile the ESPHome firmware for the specified device
.PHONY: build
build: _makefile
	@echo Building firmware for $(DEVICE_NAME)...
	esphome compile $(DEVICE_NAME)/$(DEVICE_NAME).yaml

# Generate documentation from YAML and save to docs/
.PHONY: doc
doc: _makefile
	@echo "Generating documentation from all YAML files in common/..."
	@mkdir -p docs
	@for file in common/*.yaml; do \
		name=$$(basename $$file .yaml); \
		if [ "$$name" != "secrets" ]; then \
			echo "→ $$file"; \
			esphome compile $$file --only-generate > docs/$$name-doc.txt || echo "[WARN] Failed to generate docs for $$file"; \
		else \
			echo "[SKIP] Skipping secrets.yaml"; \
		fi; \
	done
	@echo "Documentation saved to docs/*.txt"

# Upload the compiled firmware to the device (USB or OTA)
.PHONY: upload
upload: _makefile
	@echo Uploading firmware to $(DEVICE_NAME)...
	esphome upload $(DEVICE_NAME)/$(DEVICE_NAME).yaml --device $(UPLOAD_PATH)

# View live log output from the device
.PHONY: logs
logs: _makefile
	@echo Streaming logs from $(DEVICE_NAME)...
	esphome logs $(DEVICE_NAME)/$(DEVICE_NAME).yaml

# Build, upload, and start logging in one step
.PHONY: run
run: build upload logs


# ----------------------------------------------------"a3yy--------------------------
# Documentation Targets
# ------------------------------------------------------------------------------
DOXYFILE = Doxyfile

# Generate HTML and PDF from YAML documentation
.PHONY: doxygen
doxygen:
	@echo "Generating HTML and PDF documentation from YAML files..."
	@mkdir -p docs/html docs/latex
	@doxygen $(DOXYFILE)
	@echo "Building PDF from LaTeX..."
	@$(MAKE) -C docs/latex > /dev/null 2>&1 || echo "[WARN] PDF build may have issues."
	@echo "Done. View HTML at docs/html/index.html or PDF at docs/latex/refman.pdf"


# ------------------------------------------------------------------------------
# Cleanup Targets
# Note: These targets are not dependent on the generated .makefile and may be
#       called at any time, including after `distclean`.
# ------------------------------------------------------------------------------

# Remove only generated config and local build cache for local YAML
.PHONY: clean
clean:
	@echo "Removing local YAML outputs local build cache elements..."
	@if [ -n "$(DEVICE_NAME)" ]; then \
		case "$(DEVICE_NAME)" in \
			common|docs|build|src|include|.|/) \
				echo "[WARN] Skipping cleanup for protected DEVICE_NAME: '$(DEVICE_NAME)'" ;; \
			*) \
				echo "Cleaning generated YAML for $(DEVICE_NAME)..."; \
				rm -f "$(DEVICE_NAME)/$(DEVICE_NAME).yaml" ;; \
		esac \
	else \
		echo "[WARN] DEVICE_NAME not set — skipping YAML cleanup"; \
	fi
	@if [ -d "$(DEVICE_NAME)/.esphome" ]; then \
		find $(DEVICE_NAME)/.esphome -type f \( \( -name "$(DEVICE_NAME)*" -o -name "$(NODE_NAME)*" \) -a ! -name ".gitignore" \) -exec rm -v {} +; \
	fi

# Remove all compiled objects and the device directory
.PHONY: clobber
clobber: clean
	@echo "Clobbering entire build cache..."
	@if [ -n "$(DEVICE_NAME)" ]; then \
		case "$(DEVICE_NAME)" in \
			common|docs|build|src|include|.|/) \
				echo "[ERROR] Refusing to delete protected directory: '$(DEVICE_NAME)'"; \
				exit 1 ;; \
			*) \
				echo "Removing generated device directory: $(DEVICE_NAME)"; \
				rm -rf "$(DEVICE_NAME)" ;; \
		esac \
	else \
		echo "[WARN] DEVICE_NAME not set — skipping device dir cleanup"; \
	fi
	rm -rf $(DEVICE_NAME)/.esphome/

# Remove all generated content including documentation and .makefile
.PHONY: distclean
distclean: clobber
	@echo "Distcleaning all for archive/export..."
	rm -f .makefile
	rm -rf docs/


# ------------------------------------------------------------------------------
# Utility Targets
# Note: These targets are not dependent on the generated .makefile and may be
#       called at any time, including after `distclean`.
# ------------------------------------------------------------------------------

# Show the version of ESPHome currently installed
.PHONY: version
version:
	@echo "Project Version: $(VERSION)"
	@echo -n "ESPHome "
	@esphome --version

# Display the currently loaded configuration variables
.PHONY: buildvars
buildvars:
	@echo "Device name:   $(DEVICE_NAME)"
	@echo "Node name:     $(NODE_NAME)"
	@echo "Friendly name: $(FRIENDLY_NAME)"
	@echo "Upload path:   $(UPLOAF_PATH)"
	@echo "WiFi IP:       $(if $(WIFI_STATIC_IP),$(WIFI_STATIC_IP),[ dynamic ])"
	@echo "WiFi Gateway:  $(if $(WIFI_GATEWAY),$(WIFI_GATEWAY),[ dynamic ])"
	@echo "WiFi Subnet:   $(if $(WIFI_SUBNET),$(WIFI_SUBNET),[ dynamic ])"
	@echo "WiFi DNS1:     $(if $(WIFI_DNS1),$(WIFI_DNS1),[ dynamic ])"
	@echo "WiFi DNS2:     $(if $(WIFI_DNS2),$(WIFI_DNS2),[ dynamic ])"

# Print a list of available Makefile targets and descriptions
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  configure  Generate configuration (.makefile and YAML)"
	@echo "  build      Compile firmware"
	@echo "  upload     Upload firmware"
	@echo "  logs       View device logs via the specified upload path"
	@echo "  run        Build, upload, and stream logs"
	@echo "  doxygen    Generate doxygen style documentation"
	@echo "  doc        Generate ESPHome style documentation"
	@echo "  clean      Remove local YAML outputs local build cache elements"
	@echo "  clobber    Clobber entire build cache."
	@echo "  distclean  Sanitize all generated files for archive/export"
	@echo "  version    Show platform and ESPHome version"
	@echo "  buildvars  Show current build configuration values"
	@echo "  help       Show this message"


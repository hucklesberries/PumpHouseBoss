################################################################################
#  @file        Makefile
#  @brief       Joi ESPHome Master Makefile.
#
#  @author      Roland Tembo Hendel
#  @email       rhendel@nexuslogic.com
#  @license     GNU General Public License v3.0
#               SPDX-License-Identifier: GPL-3.0-or-later
# ------------------------------------------------------------------------------
#
# BUILD TARGETS:
#   make         -  default is 'run' (build + upload + logs)
#   make build   -  build image only
#   make upload  -  upload (USB or OTA)
#   make run     -  build + upload + logs
#   make logs    -  stream logs from device
#   make clean   -  remove build output
#   make help    -  show help information
#   make config  -  generate static IP settings yaml
#   make check   -  validate config syntax
#
# EXAMPLE .makefile
#   NODE_NAME      = sysmon-ph
#   NODE_STATIC_IP = 192.168.1.2
#   NODE_GATEWAY   = 192.168.1.1
#   NODE_SUBNET    = 255.255.0.0
#   NODE_DNS1      = 192.168.1.1
#   NODE_DNS2      = 1.1.1.1
#   COM_PORT       = COM1
#   ESPHOME        = /path/to/esphome.exe
#
# NOTE: run configure.sh to create a .makefile
#
################################################################################


# ==============================================================================
# ***************************** BUILD DEFINITIONS ****************************** 
# ==============================================================================

-include .makefile

ESPHOME       ?= esphome
VERSION       := $(shell cat VERSION)

DEVICE_NAME   ?= $(NODE_NAME)
DEVICE_DIR     = $(DEVICE_NAME)
BUILD_DIR     := $(DEVICE_DIR)/.esphome
CONFIG_FILE    = $(DEVICE_DIR)/config.yaml
DEVICE_FILE    = $(DEVICE_DIR)/$(DEVICE_NAME).yaml
DEVICE_PORT   ?= $(COM_PORT)


# ==============================================================================
# ********************************** TARGETS ***********************************
# ==============================================================================

.PHONY: all build upload run logs clean clobber help config check

all: run

config:
	@echo ">>> Regenerating \"$(CONFIG_FILE)\"..."
	@mkdir -p "$(DEVICE_DIR)"
	@echo "node_name:     $(NODE_NAME)"         >  "$(CONFIG_FILE)"
	@echo "friendly_name: $(FRIENDLY_NAME)"     >> "$(CONFIG_FILE)"
	@echo "static_ip:     $(NODE_STATIC_IP)"    >> "$(CONFIG_FILE)"
	@echo "gateway:       $(NODE_GATEWAY)"      >> "$(CONFIG_FILE)"
	@echo "subnet:        $(NODE_SUBNET)"       >> "$(CONFIG_FILE)"
	@echo "dns1:          $(NODE_DNS1)"         >> "$(CONFIG_FILE)"
	@echo "dns2:          $(NODE_DNS2)"         >> "$(CONFIG_FILE)"

build: config
	@echo ">>> Building image for \"$(DEVICE_NAME)\" version $(VERSION)..."
	"$(ESPHOME)" compile "$(DEVICE_FILE)"
	@cp "$(DEVICE_DIR)/.esphome/build/$(DEVICE_NAME)/image.bin" "$(DEVICE_DIR)/$(DEVICE_NAME).bin"
	@echo ">>> Image copied to \"$(DEVICE_DIR)/$(DEVICE_NAME).bin\""

upload: config
	@echo ">>> Uploading image to \"$(DEVICE_PORT)\"..."
	"$(ESPHOME)" upload "$(DEVICE_FILE)" --device "$(DEVICE_PORT)"

run: config
	@echo ">>> Flashing and logging from \"$(DEVICE_PORT)\"..."
	"$(ESPHOME)" run "$(DEVICE_FILE)" --device "$(DEVICE_PORT)"

logs:
	@echo ">>> Streaming logs from \"$(DEVICE_PORT)\"..."
	"$(ESPHOME)" logs "$(DEVICE_FILE)" --device "$(DEVICE_PORT)"

check:
	@echo "🔍 Validating ESPHome configuration..."
	@if [ ! -f $(DEVICE_FILE) ]; then \
		echo "❌ Error: Device file '$(DEVICE_FILE)' not found."; exit 1; \
	fi
	@if [ ! -f .makefile ]; then \
		echo "❌ Error: .makefile not found. Run ./configure.sh first."; exit 1; \
	fi
	@missing_vars=0; \
	for var in NODE_NAME NODE_STATIC_IP NODE_GATEWAY NODE_SUBNET NODE_DNS1 COM_PORT; do \
		if ! grep -q "$$var" .makefile; then \
			echo "⚠️  Warning: Missing $$var in .makefile"; \
			missing_vars=1; \
		fi; \
	done; \
	if [ $$missing_vars -eq 1 ]; then \
		echo "❌ Error: One or more required variables missing in .makefile"; \
		exit 1; \
	fi
	@echo "✅ .makefile looks good."
	@echo "🧪 Running ESPHome config check..."
	@$(ESPHOME) config $(DEVICE_FILE)

clean:
	@echo ">>> Cleaning build and config artifacts..."
	@rm -f "$(CONFIG_FILE)"
	@rm -rf "$(BUILD_DIR)"
	@rm -rf "$(DEVICE_DIR)/$(DEVICE_NAME).bin"

clobber: clean

help:
	@echo "Available targets:"
	@echo "  make           - Build, upload, and logs (default)"
	@echo "  make build     - Compile image only"
	@echo "  make upload    - Upload via OTA or USB"
	@echo "  make run       - Build, upload, and start logging"
	@echo "  make logs      - Stream logs from device"
	@echo "  make check     - Validate config syntax"
	@echo "  make clean     - Remove build and cache directories"
	@echo "  make clobber   - Same as clean"
	@echo "  make help      - Show this message"
	@echo "  make config    - Generate static IP YAML fragment"


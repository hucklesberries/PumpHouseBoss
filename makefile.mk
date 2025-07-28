# ------------------------------------------------------------------------------
#  File:         makefile.mk
#  File Type:    Makefile Include
#  Purpose:      Make Macros and Helper Functions
#  Version:      0.7.1
#  Date:         2025-07-24
#  Author:       Roland Tembo Hendel <rhendel@nexuslogic.com>
#
#  Description:  Shared Makefile macros and helper functions for ESPHome-based
#                device management. Provides OS detection, Python/esptool
#                auto-detection, safe recursive delete, and colorized output macros.
#
#  Features:     - OS detection for cross-platform compatibility
#                - Python/esptool auto-detection for firmware operations
#                - Safe recursive delete macro with protected directory checks
#                - Colorized output macros for consistent messaging
#                - Designed for inclusion in project Makefiles
#
#  License:      GNU General Public License v3.0
#                SPDX-License-Identifier: GPL-3.0-or-later
#  Copyright:    (c) 2025 Roland Tembo Hendel
#                This program is free software: you can redistribute it and/or
#                modify it under the terms of the GNU General Public License.
# ------------------------------------------------------------------------------


# Detect OS (necessary for path/EOL conversion from stupid MS Windows)
UNAME_S := $(shell uname -s)
ifeq ($(findstring CYGWIN,$(UNAME_S)),CYGWIN)
	WIN_CMD = 1
else ifeq ($(findstring MINGW,$(UNAME_S)),MINGW)
	WIN_CMD = 1
else
	WIN_CMD = 0
endif

# Auto-detect Python executable with esptool module
#   Windows users: If esptool is only available in your Windows Python, override this variable in your environment:
#   export PYTHON_WITH_ESPTOOL=/cygdrive/c/Users/youruser/AppData/Local/Programs/Python/Python311/python.exe
#   (adjust the path as needed; see Makefile docs for details)
PYTHON_WITH_ESPTOOL ?= $(shell \
	for py in python3 python; do \
		if "$$py" -c "import esptool" 2>/dev/null; then echo "$$py"; break; fi \
	done)

# Macro: Run esptool command via Python (single-line variable for safe recipe expansion)
ESPTOOL_CMD = $(PYTHON_WITH_ESPTOOL) -m esptool --chip $(PLATFORM) --port $(UPLOAD_PATH)

# Macro: Safe recursive delete
SAFE_RM = \
	if [ -z "$1" ]; then \
		echo -e "$(RED)[SAFE_RM]$(NC) Refusing to delete: directory not specified"; \
	elif [ "$(if $(filter $(1),$(PROTECTED_DIRS)),yes,no)" = "yes" ]; then \
		echo -e "$(RED)[SAFE_RM]$(NC) Refusing to delete protected directory: $1"; \
	else \
		echo -e "$(YELLOW)[SAFE_RM]$(NC) Deleting directory: $1"; \
		rm -rf "$1"; \
	fi

# Color support detection and color variables
ifeq (,$(findstring dumb,$(TERM)))
	ifneq (,$(TERM))
		RED    := \033[0;31m
		GREEN  := \033[0;32m
		YELLOW := \033[0;33m
		NC     := \033[0m
	endif
endif

# Output colorized normalization macros
INFO  := $(GREEN)[INFO]$(NC)
WARN  := $(YELLOW)[WARN]$(NC)
ERROR := $(RED)[ERROR]$(NC)
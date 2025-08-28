# ==============================================================================
#  File:         phb-pro.mk
#  File Type:    Makefile
#  Purpose:      PumpHouse Boss Pro Custom Configuration
#  Version:      0.10.0d
#  Date:         2025-07-24
#  Author:       Roland Tembo Hendel <rhendel@nexuslogic.com>
#
#  Description:  This configuration file describes custom overrides of variable
#                default values used by the Master Makefile.
#
#  Note:         This file is excluded from version control and should *not*
#                be included in the source repository.
#
#  License:      GNU General Public License v3.0
#                SPDX-License-Identifier: GPL-3.0-or-later
#  Copyright:    (c) 2025 Roland Tembo Hendel
#                This program is free software: you can redistribute it and/or
#                modify it under the terms of the GNU General Public License.
# ==============================================================================


# Required configuration values
VARIANT        ?= phb-pro
NODE_NAME      ?= phb-pro-00.lab

# [Optional] programming values (required for uploading and other device operations)
COMM_PATH      ?= phb-pro-00.lab

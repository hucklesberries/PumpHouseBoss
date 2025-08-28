// =============================================================================
//  File:         esp32bootcode.h
//  File Type:    C++ Header File
//  Purpose:      Support for ESP32 Native Reset Reason Codes
//  Version:      0.10.0d
//  Date:         2025-08-20
//  Author:       Roland Tembo Hendel <rhendel@nexuslogic.com>
//
//  Description:  Reports native ESP32 reset reason code and description.
//
//  License:      GNU General Public License v3.0
//                SPDX-License-Identifier: GPL-3.0-or-later
//  Copyright:    (c) 2025 Roland Tembo Hendel
//                This program is free software: you can redistribute it and/or
//                modify it under the terms of the GNU General Public License.
// =============================================================================

#pragma once
#include "esphome/core/component.h"
#include "esp_system.h"

namespace esphome {
namespace bootcode {

class BootCode : public Component {
public:
    esp_reset_reason_t mBootCode = ESP_RST_UNKNOWN;

    // Singleton accessor.
    static BootCode& get() {
        static BootCode instance;
        return instance;
    }

    // Returns the ESP32 native reset reason code
    esp_reset_reason_t mGetBootCode() const {
        return esp_reset_reason();
    }

    // Returns a human-readable native ESP32 reset reason
    std::string mGetBootReason() const {
        esp_reset_reason_t reason = esp_reset_reason();
        switch (reason) {
            case ESP_RST_POWERON:      return "Power On Reset";
            case ESP_RST_EXT:          return "External System Reset";
            case ESP_RST_SW:           return "Software Reset";
            case ESP_RST_PANIC:        return "Exception/Panic";
            case ESP_RST_INT_WDT:      return "Interrupt Watchdog";
            case ESP_RST_TASK_WDT:     return "Task Watchdog";
            case ESP_RST_WDT:          return "Other Watchdog";
            case ESP_RST_DEEPSLEEP:    return "Deep Sleep Reset";
            case ESP_RST_BROWNOUT:     return "Brownout Reset";
            case ESP_RST_SDIO:         return "SDIO Reset";
            default:                   return "Unknown";
        }
    }

};

}  // namespace bootcode
}  // namespace
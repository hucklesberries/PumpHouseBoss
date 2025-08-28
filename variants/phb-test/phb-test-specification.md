# PumpHouseBoss Test Harness - Product Specification

## Introduction
PumpHouseBoss Test Harness is a modular hardware and software platform designed to test, validate, and demonstrate the PumpHouseBoss water distribution system controllers.
This document is the authoritative guide for the PumpHouseBoss Test Harness variant.  
It describes in detail the feature set, functional overview, hardware and hardware pinout, controls & indications, state machine logic, and modular configuration strategy.
It consolidates and supersedes previous documentation files (`phb-test-hardware.md`, `phb-test-overview.md`).  

---

## Table of Contents
1. [Features](#features)
2. [Hardware](#hardware)
3. [Pinout Map: ESP32-S3](#pinout-map-esp32-s3-44-pin-package-top-view)
4. [Pinout Notes](#pinout-notes)
5. [Controls](#controls)
6. [Indications](#indications)
7. [High-Level Functional Overview](#high-level-functional-overview)
8. [Modular YAML Configuration](#modular-yaml-configuration)
9. [Future Enhancements](#future-enhancements)
10. [Deprecation Notice](#deprecation-notice)

---

## Features
- 8 independently operated and configured TestPoints:
  - Programmable PWM output line to simulate a Hall-Effect Flow Sensor
  - Input line to simulate solenoid valve
- 4-line LCD (`lcd_pcf8574` interface)
- 4-button controller
- 4 LEDs for system status and operational status indications
- HTTP monitoring/control interface 
- Info, diagnostic, and debug logging
- Support for serial and OTA log viewing and firmware updates

---

## Hardware
PumpHouseBoss Test Harness has been designed for and tested on the ESP32-S3 microcontroller, specifically the Espressif ESP32-S3-DevKitC-1-N8R8
- ESP32-S3-WROOM-1 dual-core processor, 240 MHz @ 3.3V
- 8 MB PSRAM
- 8 MB Flash
- On-chip support for WiFi and BLE
- 44-pin package, 33 digital IO pins
- See [Espressif ESP32-S3-DevKitC-1 documentation](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32s3/esp32-s3-devkitc-1/index.html)

### Pinout Map: ESP32-S3 (44 Pin Package, Top View)

```text
                              ┌──────────────────┐
                VCC  [   NC] ─┤ 01 ┌────────┐ 44 ├── [GND  ]  GND
                VCC  [   NC] ─┤ 02 │        │ 43 ├── [OUT  ]  GPIO43  outputTP0
  BTN_RESET     RST  [INLOW] ─┤ 03 │        │ 42 ├── [IN   ]  GPIO44  inputTP0
     BTN_UP  GPIO04  [   IN] ─┤ 04 │        │ 41 ├── [OUT  ]  GPIO01  outputTP1
   BTN_DOWN  GPIO05  [   IN] ─┤ 05 └────────┘ 40 ├── [IN   ]  GPIO02  inputTP1
 BTN_SELECT  GPIO06  [   IN] ─┤ 06            39 ├── [OUT  ]  GPIO42  outputTP2
  LED_WHITE  GPIO07  [  OUT] ─┤ 07            38 ├── [IN   ]  GPIO41  inputTP2
  LED_GREEN  GPIO15  [  OUT] ─┤ 08            37 ├── [OUT  ]  GPIO40  outputTP3
   LED_BLUE  GPIO16  [  OUT] ─┤ 09            36 ├── [IN   ]  GPIO39  inputTP3
    LED_RED  GPIO17  [  OUT] ─┤ 10            35 ├── [NC   ]  GPIO38
   DISP_SDA  GPIO18  [  OUT] ─┤ 11  ESP32-S3  34 ├── [-----]  GPIO37
             GPIO08  [   NC] ─┤ 12            33 ├── [-----]  GPIO36
             GPIO03  [-----] ─┤ 13            32 ├── [-----]  GPIO35
             GPIO46  [-----] ─┤ 14            31 ├── [-----]  GPIO00
   DISP_SCL  GPIO09  [  OUT] ─┤ 15            30 ├── [-----]  GPIO45
  outputTP7  GPIO10  [  OUT] ─┤ 16            29 ├── [OUT  ]  GPIO48  outputTP4
   inputTP7  GPIO11  [   IN] ─┤ 17            28 ├── [IN   ]  GPIO47  inputTP4
  outputTP6  GPIO12  [  OUT] ─┤ 18            27 ├── [OUT  ]  GPIO21  outputTP5
   inputTP6  GPIO13  [   IN] ─┤ 19            26 ├── [IN   ]  GPIO20  inputTP5
             GPIO14  [   NC] ─┤ 20            25 ├── [NC   ]  GPIO19
         5V     VIN  [5V_IN] ─┤ 21            24 ├── [GND  ]  GND
                GND  [  GND] ─┤ 22            23 ├── [GND  ]  GND
                              └───┐USB┌─┐USB┌────┘
                                  └───┘ └───┘
```

### Pinout Notes
- **Power:** Supply 5V to VIN (on-board regulator).
- **GND:** Tie pins 22, 23, 24, and 44 low.
- **BTN_RESET:** Active low; button press pulls to GND for system reset.
- **PULLUPS:** 
  - 680Ω: LED_WHITE, LED_BLUE  
  - 1kΩ:  LED_GREEN, LED_RED  

---

## Controls

| CONTROL    | INPUT         | FUNCTION                                      |
|------------|---------------|-----------------------------------------------|
| BTN_RESET  | press/release | System reset                                  |
| BTN_UP     | press/release | Scroll up system display                      |
| BTN_SELECT | press/release | Select (operational mode dependent)           |
| BTN_DOWN   | press/release | Scroll down system display                    |

---

## Indications

| LED        | ACTIVITY      | INDICATION                                    |
|------------|---------------|-----------------------------------------------|
| LED_WHITE  | off           | No power                                      |
|            | flash (1s)    | System initialization                         |
|            | solid         | Normal operation                              |
| LED_GREEN  | off           | WiFi disconnected                             |
|            | flash (1s)    | WiFi initialization pending                   |
|            | solid         | WiFi connected                                |
| LED_BLUE   | off           | TestPoint output disabled                     |
|            | solid         | TestPoint output enabled                      |
| LED_RED    | off           | TestPoint input state low                     |
|            | solid         | TestPoint input state high                    |

---

## High-Level Functional Overview

The PumpHouseBoss Test Harness implements a robust state machine for user interaction and system monitoring.  
Key features include:

- **AUTO/MANUAL Modes:**  
  The system operates in either AUTO (automatic screen cycling) or MANUAL (user-driven) mode, with clear transitions based on button events and inactivity timers.

- **Screen Management:**  
  Displays TestPoint screens and an info screen, cycling through enabled screens in AUTO mode and allowing manual selection in MANUAL mode.

- **Button Handling:**  
  UP, DOWN, and SELECT buttons allow users to cycle screens, toggle TestPoint enable states, and switch between AUTO and MANUAL modes.

- **TestPoint Control and PWM Logic:**  
  Each TestPoint can be enabled or disabled. When enabled, a PWM output is configured for that TestPoint, allowing control of frequency and duty cycle. The system displays real-time frequency, duty cycle, and input status for each TestPoint.

- **Timers:**  
  Auto-scroll and inactivity timers manage screen cycling and automatic return to AUTO mode after user inactivity.

- **Display Logic:**  
  LCD shows current mode, countdown timers, TestPoint data, and system info.

- **Web and OTA Integration:**  
  Includes web server for remote monitoring/control and supports over-the-air firmware updates.

- **Diagnostics and Logging:**  
  System logs all state transitions, button events, and diagnostics for debugging and traceability.

- **Modular Configuration:**  
  The YAML configuration is organized into modular fragments for maintainability and future extensibility.

---

## Modular YAML Configuration

- The configuration is split into modular YAML fragments for easier maintenance and extension.
- Each fragment defines a logical part of the system (hardware, controls, display, TestPoint logic, etc.).
- Fragments can be reused or replaced for different hardware variants or test scenarios.

---

## Future Enhancements

- Refine Display with custom icons and button indications
- Enhance button-based TestPoint configuration (i.e. frequency/duty-cycle)
- Design advanced test modes and features:
  - flow profiles
  - output (flow) shut-off when input (solenoid) goes high

---

## Deprecation Notice

This document supersedes and deprecates:
- `phb-test-hardware.md`
- `phb-test-overview.md`

All future updates should be made here.
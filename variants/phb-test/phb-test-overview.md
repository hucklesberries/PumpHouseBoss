# PumpHouseBoss Test Harness - Hardware Guide

## Description
PumpHouseBoss Test Harness is a hardware test fixture for the PumpHouseBoss Pro 
and PumpHouseBoss Standard Water Distribution System Monitor and Controllers.

## Features
- 8 programmable PWM output lines
- 4 line LCD (lcd_pcf8574 interface)
- menu driven line toggle enable/disable


## Controls
|CONTROL|INPUT|FUNCTION|
|---|---|---|
|BTN_DISP|||
||press/releases|rotate active output line in display|
|BTN_CTRL|||
||press/release|toggle output line enable|
|BTN_RESET|press/release|system reset|


## Indications
|LED|ACTIVITY|INDICATION|
|---|---|---|
|LED_WHITE|||
||solid|normal operation|
||slow flash|system initialization|
||rapid flash|system failure|
||off|no power|
| LED_GREEN |||
||off|WiFi disconnected|
||slow flash|WiFi connecting|
||rapid flash|WiFi initialization pending|
||solid|WiFi connected|


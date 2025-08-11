# PumpHouseBoss Professional - Hardware Guide

## Description
PumpHouseBoss Professional is an Advanced Water Distribution System Monitor and Controller.

## Features
- Ingress and egress flow monitoring, metering
- Over/under flow-rate detection, alerts and alarms
- Automated solenoid control for emergency water-shutoff or
  water-flow management/control
- Manual emergency override to shut-off water-flow
- 4 line LCD (lcd_pcf8574 interface)
- Historical flow-rate/usage graphing
- Home Assistant integration via ESPHome
- Supports up to 8 MMUs (flow-sensor + solenoid) to monitor and control up to 8 water lines


## Controls
|CONTROL|INPUT|FUNCTION|
|---|---|---|
|BTN_DISP|||
||press/releases|rotate active MMU in display|
||hold 3s|toggle freeze display|
|BTN_CTRL|||
||press/release|toggle MMU manual override for active MMU|
||hold 3s|toggle MMU manual override|
|BTN_RESET|||
||press/release|system reset|


## Indications
|LED|ACTIVITY|INDICATION|
|---|---|---|
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
| LED_BLUE |||
||off|Home Assistant disconnected|
||slow flash|Home Assistant connecting|
||rapid flash|Home Assistant initialization pending|
||solid|Home Assistant connected|
| LED_RED |||
||off|MMU open (normal operation)|
||slow flash|one or more MMUs in manual shut-off state|
||rapid flash|on or more MMUs in automatic shut-off state|
||solid|all MMUs in shut-off state|

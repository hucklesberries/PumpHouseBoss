# PumpHouseBoss Professional - Hardware Guide

## Pinout Map: ESP32-S3 (44 Pin Package, Top View'')

```text

                              ┌──────────────────┐
                VCC  [   NC] ─┤ 01 ┌────────┐ 44 ├── [GND  ]  GND
                VCC  [   NC] ─┤ 02 │        │ 43 ├── [OUT  ]  GPIO43  MMU7_CTRL
  BTN_RESET     RST  [INLOW] ─┤ 03 │        │ 42 ├── [PWMIN]  GPIO44  MMU7_SENS
             GPIO04  [   NC] ─┤ 04 │        │ 41 ├── [OUT  ]  GPIO01  MMU6_CTRL
   BTN_DISP  GPIO05  [   IN] ─┤ 05 └────────┘ 40 ├── [PWMIN]  GPIO02  MMU6_SENS
   BTN_CTRL  GPIO06  [   IN] ─┤ 06            39 ├── [OUT  ]  GPIO42  MMU5_CTRL
  LED_WHITE  GPIO07  [  OUT] ─┤ 07            38 ├── [PWMIN]  GPIO41  MMU5_SENS
  lED_GREEN  GPIO15  [  OUT] ─┤ 08            37 ├── [OUT  ]  GPIO40  MMU4_CTRL
   LED_BLUE  GPIO16  [  OUT] ─┤ 09            36 ├── [PWMIN]  GPIO39  MMU4_SENS
    LED_RED  GPIO17  [  OUT] ─┤ 10            35 ├── [OUT  ]  GPIO38  MMU3_CTRL
   DISP_SDA  GPIO18  [INOUT] ─┤ 11  ESP32-S3  34 ├── [PWMIN]  GPIO37  MMU3_SENS
             GPIO08  [   NC] ─┤ 12            33 ├── [OUT  ]  GPIO36  MMU2_CTRL
             GPIO03  [-----] ─┤ 13            32 ├── [PWMIN]  GPIO35  MMU2_SENS
             GPIO46  [-----] ─┤ 14            31 ├── [-----]  GPIO00
   DISP_SCL  GPIO09  [  OUT] ─┤ 15            30 ├── [-----]  GPIO45
             GPIO10  [   NC] ─┤ 16            29 ├── [NC   ]  GPIO48
             GPIO11  [   NC] ─┤ 17            28 ├── [OUT  ]  GPIO47  MMU1_CTRL
             GPIO12  [   NC] ─┤ 18            27 ├── [PWMIN]  GPIO21  MMU1_SENS
             GPIO13  [   NC] ─┤ 19            26 ├── [OUT  ]  GPIO20  MMU0_CTRL
             GPIO14  [   NC] ─┤ 20            25 ├── [PWMIN]  GPIO19  MMU0_SENS
         5V     VIN  [5V_IN] ─┤ 21            24 ├── [GND  ]  GND
                GND  [  GND] ─┤ 22            23 ├── [GND  ]  GND
                              └───┐USB┌─┐USB┌────┘
                                  └───┘ └───┘

```

## Notes:
  - Power:     supply 5v to VIN (on-board regulator)
  - GND:       tie pins 22, 23, 24, and 44 low
  - BTN_RESET: active low; button press pulls to GND for system reset

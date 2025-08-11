# PumpHouseBoss Standard - Hardware Guide

## Pinout Map: ESP32 (30 Pin Package, Top View'')

```text
                               ┌────────────────┐
   BTN_RESET          [   EN] ─┤ 01 ┌──────┐ 30 ├─ [NC   ]  GPIO23  NC
    BTN_DISP  GPIO36  [   IN] ─┤ 02 │      │ 29 ├─ [OUT  ]  GPIO22  DISP_SCL
    BTN_CTRL  GPIO39  [   NC] ─┤ 03 │      │ 28 ├─ [-----]  GPIO01  NC
              GPIO34  [   NC] ─┤ 04 └──────┘ 27 ├─ [-----]  GPIO03  NC
              GPIO35  [   NC] ─┤ 05          26 ├─ [INOUT]  GPIO21  DISP_SDA
   LED_WHITE  GPIO32  [  OUT] ─┤ 06          25 ├─ [NC   ]  GPIO19  NC
   LED_GREEN  GPIO33  [  OUT] ─┤ 07          24 ├─ [NC   ]  GPIO18  NC
    LED_BLUE  GPIO25  [  OUT] ─┤ 08  ESP-32  23 ├─ [-----]  GPIO05  NC
     LED_RED  GPIO26  [   NC] ─┤ 09          22 ├─ [OUT  ]  GPIO17  MMU0_LED
          NC  GPIO27  [   NC] ─┤ 10          21 ├─ [OUT  ]  GPIO16  MMU0_CONTROL
          NC  GPIO14  [   NC] ─┤ 11          20 ├─ [PWMIN]  GPIO04  MMU0_SENSE
          NC  GPIO12  [-----] ─┤ 12          19 ├─ [-----]  GPIO02  NC
          NC  GPIO13  [   NC] ─┤ 13          18 ├─ [-----]  GPIO15  NC
                 GND  [  GND] ─┤ 14          17 ├─ [GND  ]  GND
                 VIN  [5V_IN] ─┤ 15          16 ├─ [NC   ]  VCC
                               └─────┐USB┌──────┘
                                     └───┘
```

## Notes:
  - Power:     supply 5v to VIN (on-board regulator)
  - GND:       tie pins 14 and 17 low
  - BTN_RESET: active low; button press pulls to GND for system reset

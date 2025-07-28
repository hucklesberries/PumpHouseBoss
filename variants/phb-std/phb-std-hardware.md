# PumpHouseBoss Pro - Hardware Guide

## Pinout Map: ESP32 (30 Pin Package, Top View'')

```text
                               ┌────────────────┐
   BTN_RESET          [   EN] ─┤ 01 ┌──────┐ 30 ├─ [NC   ]  GPIO23  NC
              GPIO36  [   NC] ─┤ 02 │      │ 29 ├─ [OUT  ]  GPIO22  DISP_SCL
    BTN_CTRL  GPIO39  [   IN] ─┤ 03 │      │ 28 ├─ [-----]  GPIO01  NC
   LED_WHITE  GPIO34  [   IN] ─┤ 04 └──────┘ 27 ├─ [-----]  GPIO03  NC
   LED_GREEN  GPIO35  [   IN] ─┤ 05          26 ├─ [INOUT]  GPIO21  DISP_SDA
    LED_BLUE  GPIO32  [  OUT] ─┤ 06          25 ├─ [NC   ]  GPIO19  NC
     LED_RED  GPIO33  [  OUT] ─┤ 07          24 ├─ [NC   ]  GPIO18  NC
          NC  GPIO25  [  OUT] ─┤ 08  ESP-32  23 ├─ [XXX  ]  GPIO05  NC
          NC  GPIO26  [   NC] ─┤ 09          22 ├─ [NC   ]  GPIO17  NC
          NC  GPIO27  [   NC] ─┤ 10          21 ├─ [OUT  ]  GPIO16  MMU0_CTRL
          NC  GPIO14  [   NC] ─┤ 11          20 ├─ [PWMIN]  GPIO04  MMU0_SENS
          NC  GPIO12  [-----] ─┤ 12          19 ├─ [-----]  GPIO02  NC
          NC  GPIO13  [   NC] ─┤ 13          18 ├─ [-----]  GPIO15  NC
                 GND  [  GND] ─┤ 14          17 ├─ [GND  ]  GND
                 VIN  [5V_IN] ─┤ 15          16 ├─ [NC   ]  NC
                               └─────┐USB┌──────┘
                                     └───┘
```

## Notes:
  - Power:     supply 5v to VIN (on-board regulator)
  - GND:       tie pins 14 and 17 low
  - BTN_RESET: active low; button press pulls to GND for system reset

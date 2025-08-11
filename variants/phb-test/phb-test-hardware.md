# PumpHouseBoss Test Harness - Hardware Guide

## Pinout Map: ESP32-S3 (44 Pin Package, Top View'')

```text

                              ┌──────────────────┐
                VCC  [   NC] ─┤ 01 ┌────────┐ 44 ├── [GND  ]  GND
                VCC  [   NC] ─┤ 02 │        │ 43 ├── [IN   ]  GPIO43  BTN_DISP
  BTN_RESET     RST  [INLOW] ─┤ 03 │        │ 42 ├── [IN   ]  GPIO44  BTN_CTRL
    FLOW_00  GPIO04  [   NC] ─┤ 04 │        │ 41 ├── [OUT  ]  GPIO01  LED_WHITE
    FLOW_01  GPIO05  [   NC] ─┤ 05 └────────┘ 40 ├── [OUT  ]  GPIO02  LED_GREEN
    FLOW_02  GPIO06  [   NC] ─┤ 06            39 ├── [NC   ]  GPIO42
    FLOW_03  GPIO07  [   NC] ─┤ 07            38 ├── [NC   ]  GPIO41
    FLOW_04  GPIO15  [   NC] ─┤ 08            37 ├── [NC   ]  GPIO40
    FLOW_05  GPIO16  [   NC] ─┤ 09            36 ├── [NC   ]  GPIO39
    FLOW_06  GPIO17  [   NC] ─┤ 10            35 ├── [NC   ]  GPIO38
   DISP_SDA  GPIO18  [INOUT] ─┤ 11  ESP32-S3  34 ├── [NC   ]  GPIO37
    FLOW_07  GPIO08  [   NC] ─┤ 12            33 ├── [NC   ]  GPIO36
             GPIO03  [-----] ─┤ 13            32 ├── [NC   ]  GPIO35
             GPIO46  [-----] ─┤ 14            31 ├── [-----]  GPIO00
   DISP_SCL  GPIO09  [  OUT] ─┤ 15            30 ├── [-----]  GPIO45
             GPIO10  [   NC] ─┤ 16            29 ├── [NC   ]  GPIO48
             GPIO11  [   NC] ─┤ 17            28 ├── [NC   ]  GPIO47
             GPIO12  [   NC] ─┤ 18            27 ├── [NC   ]  GPIO21
             GPIO13  [   NC] ─┤ 19            26 ├── [NC   ]  GPIO20
             GPIO14  [   NC] ─┤ 20            25 ├── [NC   ]  GPIO19
         5V     VIN  [5V_IN] ─┤ 21            24 ├── [GND  ]  GND
                GND  [  GND] ─┤ 22            23 ├── [GND  ]  GND
                              └───┐USB┌─┐USB┌────┘
                                  └───┘ └───┘

```

## Notes:
  - Power:     supply 5v to VIN (on-board regulator)
  - GND:       tie pins 22, 23, 24, and 44 low
  - BTN_RESET: active low; button press pulls to GND for system reset

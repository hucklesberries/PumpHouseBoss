// =============================================================================
//  File:         phb-test.h
//  File Type:    C++ Header File
//  Purpose:      Helper functions for PumpHouseBoss TestPoint access
//  Version:      0.10.0d
//  Date:         2025-08-20
//  Author:       Roland Tembo Hendel <rhendel@nexuslogic.com>
//
//  Description:  Core custom component for the PumpHouse Boss Test Harness.
//                - Provides centralized and indexed access to TestPoint
//                  components, incl. inputs, outputs, numbers (frequency and
//                  duty cycle), and switches.
//                - Provides control logic for TestPoint PWM outputs, including
//                  enable/disable and frequency and duty cycle configuration.
//                - Improves code maintainability and readability by avoiding
//                  repetitive vector declarations in lambdas.
//
//  License:      GNU General Public License v3.0
//                SPDX-License-Identifier: GPL-3.0-or-later
//  Copyright:    (c) 2025 Roland Tembo Hendel
//                This program is free software: you can redistribute it and/or
//                modify it under the terms of the GNU General Public License.
// =============================================================================

#pragma once


namespace esphome {
namespace phb_test {


// the number of supported TestPoints
// - values between 1 and 8 are supported
// - attempts to access Test Points whose indexes are greater than the supported
//   maximum are logged and ignored
// - this value is set as part of the build process and target configuration
#define DEF_TEST_POINTS __CONTROL_POINTS__


// -----------------------------------------------------------------------------
// Helper class for indexed access to TestPoint data.
// Provides methods to access switch, frequency, duty cycle, and input state
// for each TestPoint by index (0-7).
// Returns safe defaults for out-of-range indices.
// NOTE: Due to problems encountered with the ESPHome local component registration
//       methods, this class was implemented as a singleton. When the underlying
//       issues are resolved, this class should be refactored to integrate with
//       ESPhome via the prescribed registration method.
//
class phb_test : public Component {
private:
    esphome::binary_sensor::BinarySensor *_InputArray[DEF_TEST_POINTS]     = {nullptr};
    esphome::ledc::LEDCOutput            *_OutputArray[DEF_TEST_POINTS]    = {nullptr};
    esphome::template_::TemplateNumber   *_DutyCycleArray[DEF_TEST_POINTS] = {nullptr};
    esphome::template_::TemplateNumber   *_FrequencyArray[DEF_TEST_POINTS] = {nullptr};
    esphome::template_::TemplateSwitch   *_SwitchArray[DEF_TEST_POINTS]    = {nullptr};
    bool _Initialized = false;


    // Component Setup:
    // Initialize pointer arrays with the pre-configured TestPoint component objects.
    // NOTE: this function MUST be called after all component objects are defined.
    void setup() override {
        if(_Initialized) {
            return;
        }
        for (int i = 0; i < DEF_TEST_POINTS; i++) {
           switch(i)  {
               case 0:
                   _OutputArray[i]    = &id(outputTP0);
                   _SwitchArray[i]    = &id(switchTP0);
                   _DutyCycleArray[i] = &id(numTP0DutyCycle);
                   _FrequencyArray[i] = &id(numTP0Frequency);
                   _InputArray[i]     = &id(inputTP0);
                   break;
               case 1:
                   _OutputArray[i]    = &id(outputTP1);
                   _SwitchArray[i]    = &id(switchTP1);
                   _DutyCycleArray[i] = &id(numTP1DutyCycle);
                   _FrequencyArray[i] = &id(numTP1Frequency);
                   _InputArray[i]     = &id(inputTP1);
                   break;
               case 2:
                   _OutputArray[i]    = &id(outputTP2);
                   _SwitchArray[i]    = &id(switchTP2);
                   _DutyCycleArray[i] = &id(numTP2DutyCycle);
                   _FrequencyArray[i] = &id(numTP2Frequency);
                   _InputArray[i]     = &id(inputTP2);
                   break;
               case 3:
                   _OutputArray[i]    = &id(outputTP3);
                   _SwitchArray[i]    = &id(switchTP3);
                   _DutyCycleArray[i] = &id(numTP3DutyCycle);
                   _FrequencyArray[i] = &id(numTP3Frequency);
                   _InputArray[i]     = &id(inputTP3);
                   break;
               case 4:
                   _OutputArray[i]    = &id(outputTP4);
                   _SwitchArray[i]    = &id(switchTP4);
                   _DutyCycleArray[i] = &id(numTP4DutyCycle);
                   _FrequencyArray[i] = &id(numTP4Frequency);
                   _InputArray[i]     = &id(inputTP4);
                   break;
               case 5:
                   _OutputArray[i]    = &id(outputTP5);
                   _SwitchArray[i]    = &id(switchTP5);
                   _DutyCycleArray[i] = &id(numTP5DutyCycle);
                   _FrequencyArray[i] = &id(numTP5Frequency);
                   _InputArray[i]     = &id(inputTP5);
                   break;
               case 6:
                   _OutputArray[i]    = &id(outputTP6);
                   _SwitchArray[i]    = &id(switchTP6);
                   _DutyCycleArray[i] = &id(numTP6DutyCycle);
                   _FrequencyArray[i] = &id(numTP6Frequency);
                   _InputArray[i]     = &id(inputTP6);
                   break;
               case 7:
                   _OutputArray[i]    = &id(outputTP7);
                   _SwitchArray[i]    = &id(switchTP7);
                   _DutyCycleArray[i] = &id(numTP7DutyCycle);
                   _FrequencyArray[i] = &id(numTP7Frequency);
                   _InputArray[i]     = &id(inputTP7);
                   break;
                case 8:
                   ESP_LOGE("phb_test", "setup: Maxiumum 8 Test Points supported.");
                   break;
                default:
                   break;
           }
        }
        _Initialized = true;
    }


public:

    // Singleton Accessor:
    // this calls setup(), which is usually done as part of the ESPHome registration
    // process - when this is registered as a local component, this function is
    // removed when this is converted to a regular instance class.
    static phb_test& mGet() {
        static phb_test instance;
        if (!instance._Initialized) {
            instance.setup();
            instance._Initialized = true;
        }
        return instance;
    }

    // Accessor to get the switch state of a TestPoint
    // - returns true if the switch for the given TestPoint index (0-7) is enabled (on)
    // - returns false if idx is out of range.
    bool mIsEnabled(int idx) {
        if (idx < 0 || idx >= DEF_TEST_POINTS) {
            ESP_LOGE("phb_test", "mIsEnabled: Invalid index or null pointer: idx=%d", idx);
            return false;
        }
        return(_SwitchArray[idx]->state);
    }

    // Accessor to enable the switch for a TestPoint
    // - enables the switch for the given TestPoint index (0-7).
    // - does nothing if idx is out of range.
    void mTPEnable(int idx) {
        if (idx < 0 || idx >= DEF_TEST_POINTS) {
            ESP_LOGE("phb_test", "mTPEnable: Invalid index or null pointer: idx=%d", idx);
            return;
        }
        _OutputArray[idx]->turn_on();
        _OutputArray[idx]->update_frequency(_FrequencyArray[idx]->state);
        _OutputArray[idx]->set_level(_DutyCycleArray[idx]->state / 100.0f);
        ESP_LOGI("phb_test", "mTPEnable, idx=%d, frequency=%.2f, duty_cycle=%.2f", idx, _FrequencyArray[idx]->state, _DutyCycleArray[idx]->state);
    }

    // Accessor to disable the switch for a TestPoint
    // - disables the switch for the given TestPoint index (0-7).
    // - does nothing if idx is out of range.
    void mTPDisable(int idx) {
        if (idx < 0 || idx >= DEF_TEST_POINTS) {
            ESP_LOGE("phb_test", "mTPDisable: Invalid index or null pointer: idx=%d", idx);
            return;
        }
        _OutputArray[idx]->turn_off();
        ESP_LOGI("phb_test", "mTPDisable");
    }

    // Accessor to get the frequency value of a TestPoint
    // - returns the frequency value for the given TestPoint index (0-7).
    // - returns 0.0f if idx is out of range.
    float mGetFrequency(int idx) {
        if (idx < 0 || idx >= DEF_TEST_POINTS) {
            ESP_LOGE("phb_test", "mGetFrequency: Invalid index or null pointer: idx=%d", idx);
            return 0.0f;
        }
        return(_FrequencyArray[idx]->state);
    }

    // Accessor to set the frequency value of a TestPoint
    // - sets the frequency value for the given TestPoint index (0-7).
    // - does nothing if idx is out of range.
    void mSetFrequency(int idx, float frequency) {
        if (idx < 0 || idx >= DEF_TEST_POINTS) {
            ESP_LOGE("phb_test", "mSetFrequency: Invalid index or null pointer: idx=%d", idx);
            return;
        }
        _FrequencyArray[idx]->publish_state(frequency);
        ESP_LOGI("phb_test", "mSetFrequency: idx=%d, frequency=%.2f", idx, frequency);
        if (_SwitchArray[idx]->state) {
            _OutputArray[idx]->update_frequency(frequency);
        }
    }

    // Accessor to get the duty cycle value of a TestPoint
    // - returns the duty cycle value for the given TestPoint index (0-7).
    // - returns 0.0f if idx is out of range.
    float mGetDutyCycle(int idx) {
        if (idx < 0 || idx >= DEF_TEST_POINTS) {
            ESP_LOGE("phb_test", "mGetDutyCycle: Invalid index or null pointer: idx=%d", idx);
            return 0.0f;
        }
        return(_DutyCycleArray[idx]->state);
    }

    // Accessor to set the duty cycle value of a TestPoint
    // - sets the duty cycle value for the given TestPoint index (0-7).
    // - does nothing if idx is out of range.
    void mSetDutyCycle(int idx, float duty_cycle) {
        if (idx < 0 || idx >= DEF_TEST_POINTS) {
            ESP_LOGE("phb_test", "mSetDutyCycle: Invalid index or null pointer: idx=%d", idx);
            return;
        }
        ESP_LOGI("phb_test", "mSetDutyCycle: idx=%d, duty_cycle=%.2f", idx, duty_cycle);
        if (_SwitchArray[idx]->state) {
            _OutputArray[idx]->set_level(duty_cycle / 100.0f);
        }
    }

    // Accessor to get the input state for a TestPoint
    // - returns the input state for the given TestPoint index (0-7).
    // - returns false if idx is out of range.
    bool mGetInputState(int idx) {
        if (idx < 0 || idx >= DEF_TEST_POINTS) {
            ESP_LOGE("phb_test", "mGetInputState: Invalid index or null pointer: idx=%d", idx);
            return false;
        }
        return(_InputArray[idx]->state);
    }

};

} // namespace phb_test
} // namespace esphome

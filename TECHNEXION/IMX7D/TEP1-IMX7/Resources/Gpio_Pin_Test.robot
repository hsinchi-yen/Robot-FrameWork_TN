*** Comments ***
=========================================================================
 Copyright 2024 Technexion Ltd.
 Test Case No      : Case TNPT-144
 Purpose           : GPIO PIN Check and Test for TEP1-IMX7, applicable for yocto 4.2 
 Script name       : Gpio_Pin_Test.robot
 Author            : Lance
 Date created      : 20240830

 Wiring Config in TEP1 IMX7
"GPIO_PORT1_IO3"<---->"GPIO_PORT1_IO1"
gpioset 1 4=0~1
gpioget 4 13

"GPIO_PORT1_IO2"<---->"GPIO_PORT1_IO4"
gpioset 4 2=0~1
gpioget 4 12
=========================================================================

*** Settings ***
Resource        ../Resources/Common_Params.robot

*** Variables ***
${active}            1
${inactive}          0

#Check Spec.
${PULL_UP_CHECK_GPIO_PORT1_IO3}          "GPIO_PORT1_IO3"\=active
${PULL_UP_CHECK_GPIO_PORT1_IO4}          "GPIO_PORT1_IO4"\=active
${PULL_DOWN_CHECK_GPIO_PORT1_IO3}          "GPIO_PORT1_IO3"\=inactive
${PULL_DOWN_CHECK_GPIO_PORT1_IO4}          "GPIO_PORT1_IO4"\=inactive

*** Keywords ***
Check GPIO Pins Info
   SerialLibrary.Write Data    gpioinfo | grep -E "gpiochip|GPIO_PORT"${\n}
   Sleep    1
   ${gpio_pininfo_log}=    Seriallibrary.Read All Data    UTF-8
   Log    ${gpio_pininfo_log}
   
GPIO_Pins State Check
    SerialLibrary.Write Data    gpioget GPIO_PORT1_IO1${\n}
    Sleep    0.5
    SerialLibrary.Write Data    gpioget GPIO_PORT1_IO2${\n}
    Sleep    0.5
    SerialLibrary.Write Data    gpioget GPIO_PORT1_IO3${\n}
    Sleep    0.5
    SerialLibrary.Write Data    gpioget GPIO_PORT1_IO4${\n}
    Sleep    1
    ${gpip_state_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${gpip_state_log}


GPIO_Set_Test_Pull_Down
    SerialLibrary.Write Data    gpioset --hold-period 20ms -t0 GPIO_PORT1_IO1=${inactive}${\n}
    Sleep    0.5
    SerialLibrary.Write Data    gpioset --hold-period 20ms -t0 GPIO_PORT1_IO2=${inactive}${\n}
    Sleep    1
    ${gpip_set_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${gpip_set_log}

GPIO_get_Test_Pull_Down
    SerialLibrary.Write Data    gpioget GPIO_PORT1_IO3${\n}
    Sleep    0.5
    SerialLibrary.Write Data    gpioget GPIO_PORT1_IO4${\n}
    Sleep    1
    ${gpip_get_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${gpip_get_log}
    Run Keyword And Continue On Failure    Should Contain    ${gpip_get_log}    ${PULL_DOWN_CHECK_GPIO_PORT1_IO3}
    Run Keyword And Continue On Failure    Should Contain    ${gpip_get_log}    ${PULL_DOWN_CHECK_GPIO_PORT1_IO4}

GPIO_Set_Test_Pull_Up
    SerialLibrary.Write Data    gpioset --hold-period 20ms -t0 GPIO_PORT1_IO1=${active}${\n}
    Sleep    0.5
    SerialLibrary.Write Data    gpioset --hold-period 20ms -t0 GPIO_PORT1_IO2=${active}${\n}
    Sleep    1
    ${gpip_set_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${gpip_set_log}

GPIO_get_Test_Pull_Up
    SerialLibrary.Write Data    gpioget GPIO_PORT1_IO3${\n}
    Sleep    0.5
    SerialLibrary.Write Data    gpioget GPIO_PORT1_IO4${\n}
    Sleep    1
    ${gpip_get_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${gpip_get_log}
    Run Keyword And Continue On Failure    Should Contain    ${gpip_get_log}    ${PULL_UP_CHECK_GPIO_PORT1_IO3}
    Run Keyword And Continue On Failure    Should Contain    ${gpip_get_log}    ${PULL_UP_CHECK_GPIO_PORT1_IO4}
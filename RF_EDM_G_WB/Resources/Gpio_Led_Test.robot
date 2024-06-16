*** Settings ***
Resource          ../Resources/Common_Params.robot
Library    OperatingSystem

*** Variables ***
${GPIO_LED_FILE}        /sys/class/leds/gpio-led/brightness
${GPIO_LED_DIR}         /sys/class/leds/
${GPIO_LED_TARGET}      gpio-led
${LED_ON}               1
${LED_OFF}              0
${INTERVAL}             0.5


*** Keywords ***
GPIO_LED_Test
    SerialLibrary.Write Data    ls ${GPIO_LED_DIR}${\n}
    Sleep    0.5
    ${gpio_led_file}=    SerialLibrary.Read All Data    UTF-8
    ${isGpiofolder}=    Run Keyword And Return Status    Should Contain    ${gpio_led_file}    ${GPIO_LED_TARGET}
    IF    ${isGpiofolder} == $True
            Flashing LED
            Log    ${gpio_led_file}
    ELSE
            Log     gpio-led = ${isGpiofolder}
            Log     ${gpio_led_file}
    END

    
GPIO_LED_ON
    SerialLibrary.Write Data    echo ${LED_ON} > ${GPIO_LED_FILE}${\n}

GPIO_LED_OFF
    SerialLibrary.Write Data    echo ${LED_OFF} > ${GPIO_LED_FILE}${\n}

Flashing LED
    FOR    ${counter}    IN RANGE    1    6   
        GPIO_LED_OFF
        Sleep    ${INTERVAL}
        GPIO_LED_ON
        Sleep    ${INTERVAL}
    END
    ${led_testlog}=    Seriallibrary.Read All Data    UTF-8
    Log    ${led_testlog}
    Run Keyword And Continue On Failure    Should Not Contain    ${led_testlog}    Permission Denied
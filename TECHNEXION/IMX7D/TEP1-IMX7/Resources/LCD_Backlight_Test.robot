=========================================================================
 Copyright 2024 Technexion Ltd.
 Test Case No      : TNPT PWM Test
 Purpose           : This test robot is used to test LCD Backlight in TEP1-IMX7
 Category          : Functional Test  
 Script name       : LCD_Backlight_Test.robot
 Author            : Lance
 Date created      : 20240906
=========================================================================

*** Settings ***
Resource          ../Resources/Common_Params.robot
Library        Collections


*** Variables ***
${BACKLIGHT_FOLDER}        /sys/bus/platform/drivers/pwm-backlight/backlight_lcd/backlight/backlight_lcd
${ACTUAL_BRIGHTNESS}       6


*** Keywords *** 
LCD Backlight Test
    SerialLibrary.Write Data    ls ${BACKLIGHT_FOLDER}${\n}
    Sleep    1
    ${bklt_log}=    SerialLibrary.Read All Data    UTF-8
    ${bl_fdchk}=     Run Keyword And Return Status    Should Contain    ${bklt_log}    actual_brightness 


    IF    ${bl_fdchk} == $True
        Backlight Step Test
        Sleep    2
        Backlight Set to Default
    ELSE
        Fail    "actual_brigtness" node not found
    END

  


Backlight Set to Default
    SerialLibrary.Write Data    echo ${ACTUAL_BRIGHTNESS} > ${BACKLIGHT_FOLDER}/brightness${\n}
    Sleep    1
    ${bk_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${bk_log}

Backlight Set Off
    SerialLibrary.Write Data    echo 0 > ${BACKLIGHT_FOLDER}/brightness${\n}
    Sleep    1
    ${bk_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${bk_log}

Backlight Step Test
    FOR    ${test}    IN RANGE    1    8
        SerialLibrary.Write Data    echo ${test} > ${BACKLIGHT_FOLDER}/brightness${\n}
        Sleep    1 
    END
    Sleep    1
    ${bklog}=    SerialLibrary.Read All Data    UTF-8
    Log    ${bklog} 
    

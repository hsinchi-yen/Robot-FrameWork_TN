=========================================================================
 Copyright 2024 Technexion Ltd.
 Test Case No      : TNPT PWM Test
 Purpose           : This test robot is used to test PWM function in TEP1-IMX7
 Category          : Functional Test  
 Script name       : PWM_Test.robot
 Author            : Lance
 Date created      : 20240902
=========================================================================

*** Settings ***
Resource          ../Resources/Common_Params.robot
Library        Collections


*** Variables ***
${PWMFD}              /sys/class/pwm
${PWM_EN}             pwm0
${LEDS_PERIOD}        1000000
${LEDS_BRIGHT}        1000000
${LEDS_DIM}           20
${pwm_un_access}      cannot access


*** Keywords *** 
Enable PWM Folders
    @{pwm_folder}=    Create List
    SerialLibrary.Write Data    ls ${PWMFD}${\n}
    Sleep    1
    ${PWMFDS_log}=    SerialLibrary.Read All Data    UTF-8

    @{lines}=    Split To Lines    ${PWMFDS_log}
    ${PWMFDS_log}=      Get From List    ${lines}    -2

    ${PWMFDS}=      Get Regexp Matches     ${PWMFDS_log}    pwmchip\\w
    
    FOR    ${element}    IN    @{PWMFDS}
        ${new_element}=    Replace String    ${element}    ${element}    ${PWMFD}/${element}
        Log    ${new_element}
        Append To List    ${pwm_folder}    ${new_element}   
    END

    #export 0 for enabling the pwm0 folder
    FOR    ${element}    IN    @{pwm_folder}
        SerialLibrary.Write Data    echo 0 > ${element}/export${\n}
        Sleep    0.5
    END
    Sleep    1
    ${set_export_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${set_export_log}

    #Collect folders for test
        @{test_pwm_folder}=    Create List
    FOR    ${element}    IN    @{pwm_folder}
        SerialLibrary.Write Data    ls ${element}/${PWM_EN}${\n}
        Sleep    0.5
        ${pwm_enable_log}=    SerialLibrary.Read All Data    UTF-8
        
        ${en_pwm}=    Run Keyword And Return Status    Should Contain    ${pwm_enable_log}    ${pwm_un_access}
        IF    ${en_pwm} == $False
              Append To List     ${test_pwm_folder}     ${element}/${PWM_EN}  
              SerialLibrary.Write Data    echo 1 > ${element}/${PWM_EN}/enable${\n} 
        END

    END
    Log Many   @{test_pwm_folder}
    Flash PWM LEDs        ${test_pwm_folder}

Flash PWM LEDs
    [Arguments]    ${TEST_PWM_FOLDERS}
    FOR   ${I}   IN RANGE   6
        Sleep   1
        FOR   ${FD}   IN   @{TEST_PWM_FOLDERS}
            SerialLibrary.Write Data   echo ${LEDS_BRIGHT} > ${FD}/duty_cycle${\n}
            Sleep   1
            SerialLibrary.Write Data   echo ${LEDS_DIM} > ${FD}/duty_cycle${\n}
            Sleep   1
        END
        Sleep    1
    END

    ${test_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${test_log}
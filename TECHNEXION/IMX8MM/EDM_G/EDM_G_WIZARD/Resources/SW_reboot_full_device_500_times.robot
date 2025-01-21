=========================================================================
 Copyright 2024 Technexion Ltd.
 Test Case No      : Case TNPT-208
 Category          : Stress Test  
 Script name       : SW_reboot_full_device_500_times.robot
 Author            : Raymond 
 Date created      : 20240719
=========================================================================
*** Settings ***
Library        Collections
Library        Process
Resource          ../Resources/Common_Params.robot



*** Variables ***

*** Keywords ***
WIFI Detect 
    ${WLAN_INF_STRING}    Set Variable      mlan0: flags
    SerialLibrary.Write Data    ifconfig ${WIFI_INF}\n
        ${kernel_op_log}=    SerialLibrary.Read Until    ${TERMINATOR}
        Log to Console      ${kernel_op_log}
        Log      ${kernel_op_log}

        ${found_in_var}=    Run Keyword And Return Status    Should Contain    ${kernel_op_log}    ${WLAN_INF_STRING} 

        IF    ${found_in_var}
             Log To Console    mlan0 device is detected
        ELSE
             Fail    mlan0 is not detected.

        END

Booting time record and wait for login
    ${BOOT_TIMEOUT}    Set Variable    180
    ${RETRY_INTERVAL}    Set Variable    3
    ${total_retry_time}    Set Variable    0
    ${start_time}=    Get Time    epoch
    ${end_time}=    Evaluate    ${start_time} + ${BOOT_TIMEOUT}

    WHILE    True
        ${current_time}=    Get Time    epoch
        
        ${is_timeout}=    Evaluate    $current_time > $end_time
        IF    ${is_timeout}
        
            Fail    Timeout: system boot should within ${BOOT_TIMEOUT} seconds
        END

        ${bootlog}=    SerialLibrary.Read Until    ${LOGIN_PROMPT}
        Log    ${bootlog}
        ${is_login}=    Run Keyword And Return Status    Should Contain    ${bootlog}    ${LOGIN_PROMPT}

        IF    ${is_login}
            Log To Console    \n${bootlog}
            Log To Console    \nlogin to prompt mode
            SerialLibrary.Write Data    root\n 
            ${loginglog}=    SerialLibrary.Read Until    ${TERMINATOR}
            Sleep    1
            ${current_time}=    Get Time    epoch
            ${pure_boot_time}=    Evaluate    ${current_time} - ${start_time}

            Log     System Boot time: ${pure_boot_time} seconds
            Log To Console    System boot time: ${pure_boot_time} seconds    
            
            Log    system login successfully
            Log To Console    system login successfully
            RETURN    ${pure_boot_time}
        ELSE
            # Read until timeout after 1 minute, if system did not enter it will timeout after 3 minutes
            ${total_retry_time}=    Evaluate    ${total_retry_time} + ${RETRY_INTERVAL}
            Log    Not yet to Login. Keep waiting for ${RETRY_INTERVAL} seconds...
        END

        Sleep    ${RETRY_INTERVAL}
    END

Reboot full device 500 times
    ${LOOP_COUNT}=    Set Variable    501
    FOR    ${counter}    IN RANGE    1    ${LOOP_COUNT}  
        Log To Console  \n================Test Count:${counter}================\n
        
        Log    Test Count:${counter}
        Log To Console    \n System reboot ......\n
        SerialLibrary.Write Data    reboot\n

        Booting time record and wait for login     
        Sleep    10


        #Reboot Check Network-->Audio-->USB-->Camera(AR-0234)-->GPU
        Log To Console    \n #Checking Network\n
        WIFI Detect 
        Sleep    3 
        IPv4 Ping Test
        
        Sleep    5
        Log To Console    \n #Checking Audio device\n
        ${cardid_1st}=    Sound Card ID Checker
        Log To Console     Audio Device:${cardid_1st}
        Sleep    3 
        Log To Console    \n #Checking USB devices\n
        Check USB Devices
        Sleep    3 
        Log To Console    \n #Checking Camera\n
        Camera-TEVS-AR0234  
        Log To Console    \n #Checking GPU\n
        GLMark2 Test    20
        Sleep    1
    END
    Log To Console  \nTest Count:${counter} completed

  
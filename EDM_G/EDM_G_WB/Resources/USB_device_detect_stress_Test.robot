=========================================================================
 Copyright 2024 Technexion Ltd.
 Test Case No      : Case TNPT-204
 Category          : Stress Test  
 Script name       : USB_device_detect_Stress_Test.robot
 Author            : Raymond 
 Date created      : 20240716
=========================================================================
update by lance 20240716
use device gpp to on off the device
-------------------------------------------------------------------------
*** Settings ***
Library        Collections
Resource          ../Resources/Common_Params.robot


*** Variables ***

${INITIAL_DEVICE_COUNT}  0
${USB_SUCCESS_COUNT}       ${0}
${USB_FAILURE_COUNT}       ${0}

#set loop count
${STREE_LOOP}    501

*** Keywords ***
Check USB Devices
    ${current_success}=    Get Variable Value    ${USB_SUCCESS_COUNT}    ${0}
    ${current_fail}=    Get Variable Value    ${USB_FAILURE_COUNT}    ${0}
    # Write Data    fdisk -l | grep /dev/sd | grep Disk | cut -d ':' -f1 | cut -d ' ' -f2 | sort | wc -l${\n}
    # Sleep    1
    # ${result1}=    Read All Data   UTF-8
    # @{lines}=    Split To Lines    ${result1}
    # ${dev_count}=      Get From List    ${lines}    -2
    # log    ${dev_count}
    # Log To Console    Current Device Count: ${dev_count}
    
    Write Data    fdisk -l | grep /dev/sd | grep Disk | cut -d ':' -f1 | cut -d ' ' -f2 | sort | wc -l${\n}
    Sleep    1
    ${result1}=    Read All Data   UTF-8
    ${RE_result1}=    Get Regexp Matches    ${result1}    \\b\\d\\b
    ${dev_count}=      Get From List    ${RE_result1}    0
    log    Current Device Count:${dev_count}
    Log To Console    \nCurrent Device Count: ${dev_count}

  
    # Write Data    fdisk -l | grep /dev/sd | grep Disk | cut -d ':' -f1 | cut -d ' ' -f2 | sort${\n}
    # Sleep    1
    # ${result}=    Read All Data   UTF-8
    # @{lines}=    Split To Lines    ${result}
    # ${lines}=    Set Variable    @{lines}[2:-2]
    # Log    ${lines}
    # Log To Console    Found devices: ${lines}
    Write Data    fdisk -l | grep /dev/sd | grep Disk | cut -d ':' -f1 | cut -d ' ' -f2 | sort${\n}
    Sleep    1
    ${result2}=    Read All Data   UTF-8
    ${RE_result2}=    Get Regexp Matches    ${result2}    \\/dev\\/sd[a-z]
    log    Found Devices:${RE_result2}
  
    
    FOR    ${device}    IN    @{RE_result2}
        Write Data    udevadm info --query=all --name=${device} | grep "ID_VENDOR=" | sed 's/E: ID_//g'\n
        Sleep    1
        ${vendor_info}=    Read All Data   UTF-8
        @{lines}=    Split To Lines    ${vendor_info}
        ${vendor_info}=      Get From List    ${lines}    -2
        Set Global Variable    ${vendor_info}
        Set Global Variable    ${device}
        Log     ${vendor_info} for ${device}    
        Log To Console    ${vendor_info} ====> ${device}       
    END

    IF    ${INITIAL_DEVICE_COUNT} == 0
        Set Suite Variable    ${INITIAL_DEVICE_COUNT}    ${dev_count}
        Log     Initial device count recorded: ${INITIAL_DEVICE_COUNT}
        Log To Console    Initial device count recorded: ${INITIAL_DEVICE_COUNT}
        
    END

    IF    ${dev_count} != ${INITIAL_DEVICE_COUNT}
        Log To Console    USB Device Lost!! Device Count:${dev_count} not equal Initial device count :${INITIAL_DEVICE_COUNT}
        
        ${current_fail}=    Evaluate    ${current_fail} + 1
        Set Test Variable     ${USB_FAILURE_COUNT}    ${current_fail}
        Log To Console    --->USB FAIL COUNT : ${USB_FAILURE_COUNT}
        Fail    USB Device Lost!! Please check
    ELSE 
        Log    Checking Device Count: ${dev_count}, Matched!!
        Log To Console    Checking Device Count: ${dev_count} = Initial device count :${INITIAL_DEVICE_COUNT} , Matched!!
        ${current_success}=    Evaluate    ${current_success} + 1
        Set Test Variable     ${USB_SUCCESS_COUNT}    ${current_success}
        Log To Console    --->USB PASS COUNT : ${USB_SUCCESS_COUNT}
        Sleep    1
    END


Power ON_OFF And USB detection Test
      FOR    ${counter}    IN RANGE    1    ${STREE_LOOP}
        #Switch Port    ${PWR_SW_PORT}
        #Device OFF
        Device GPP-1326 OFF
        Sleep    3

        #Device ON 
        Device GPP-1326 ON   
        #Switch Port    ${SERIAL_PORT}
        ${locport}=    Get Current Port Locator
        Log    DUT : port ${locport}
        
        ${bootlog}=    SerialLibrary.Read Until    ${LOGIN_PROMPT}
        Log To Console    ${bootlog}
        Log    ${bootlog}
        Log To Console    Enter with root
        Write Data    root\n
        ${loginlog}=    SerialLibrary.Read Until    ${TERMINATOR}


        Check USB Devices
        Sleep    2  

        Run Keyword If    ${counter} == ${LOOP_COUNT}-1    Exit For Loop
         
    END
    Log To Console    \nTest Count:${counter} completed\n
    Log    \nTest Count:${counter} completed\n
    
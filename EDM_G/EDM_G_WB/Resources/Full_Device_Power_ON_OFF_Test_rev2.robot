=========================================================================
 Copyright 2024 Technexion Ltd.
 Test Case No      : Case TNPT-215_enahnced_check
 Category          : Stress Test  
 Script name       : Full_Device_Power_ON_OFF_Test_rev2.robot
 Author            : Raymond 
 Date created      : 20241225
=========================================================================
Revise by Lance 20250317
Tweak the script to fit the edm-g widzard board
Extra variable - LOOP_TIME is added to control the loop time
-------------------------------------------------------------------------

*** Settings ***
Resource        ../Resources/Common_Params.robot

*** Variables ***
${Touch_SUCCESS_COUNT}       ${0}
${Touch_FAILURE_COUNT}       ${0}
${BT_SUCCESS_COUNT}       ${0}
${BT_FAILURE_COUNT}       ${0}
${WIFI_SUCCESS_COUNT}       ${0}
${WIFI_FAILURE_COUNT}       ${0}
${LAN1_SUCCESS_COUNT}       ${0}
${LAN1_FAILURE_COUNT}       ${0}
#${LAN2_SUCCESS_COUNT}       ${0}
#${LAN2_FAILURE_COUNT}       ${0}
${AUDIO_SUCCESS_COUNT}       ${0}
${AUDIO_FAILURE_COUNT}       ${0}
${Camera_SUCCESS_COUNT}       ${0}
${Camera_FAILURE_COUNT}       ${0}

#Stress Test Loop Time
${STREE_LOOP}    2

*** Keywords ***
Full device ON OFF 
    Log    LOOP:${LOOP_TIME}
    Check USB Devices  #USB initial check test
    FOR    ${counter}    IN RANGE    1    ${STREE_LOOP}
        Log To Console  \n================Test Count:${counter}================\n
        
        Log    Test Count:${counter}
        Log To Console    \n System POWER OFF ......\n
        Device GPP-1326 OFF
        Sleep    3
        Device GPP-1326 ON
        Log To Console    \n System POWER ON ......\n
        Booting time record and wait for login
        Sleep    10
   
        Log To Console    \n######## Checking Touch Device ########\n
        Run Keyword And Continue On Failure    Touch Dedect 
        Sleep    3

        Log To Console    \n######## Checking Network ########\n
        Run Keyword And Continue On Failure    BT Detect 
        Sleep    3
        Run Keyword And Continue On Failure    WIFI Detect 
        Sleep    3
        Run Keyword And Continue On Failure    LAN1 Detect
        Sleep    3 
        
        # Run Keyword And Continue On Failure    LAN2 Detect
        # Sleep    3 
        Log To Console    \n######## Checking USB devices ########\n
        Run Keyword And Continue On Failure    Check USB Devices
        Sleep    3 
        
        Log To Console    \n######## Checking Audio device ########\n
        Run Keyword And Continue On Failure    Audio Detect
        Sleep    3 
        Log To Console    \n######## Checking Camera device ########\n
        Run Keyword And Continue On Failure    Camera Detect
        Sleep    3 
        

    END  
    IF    ${Touch_FAILURE_COUNT} > 0
        Log To Console    \n=========================
        Log To Console    Touch Final Result: FAIL
        Log    PASS COUNT: ${Touch_SUCCESS_COUNT}    console=yes
        Log    FAIL COUNT: ${Touch_FAILURE_COUNT}    console=yes
        Log To Console    =========================  
        
        
    ELSE
        Log To Console    \n=========================
        Log To Console    Touch Final Result: PASS 
        Log    PASS COUNT: ${Touch_SUCCESS_COUNT}    console=yes
        Log    FAIL COUNT: ${TOuch_FAILURE_COUNT}    console=yes
        Log To Console    =========================
    END    
    IF    ${BT_FAILURE_COUNT} > 0
        Log To Console    \n=========================
        Log To Console    BT Final Result: FAIL
        Log    PASS COUNT: ${BT_SUCCESS_COUNT}    console=yes
        Log    FAIL COUNT: ${BT_FAILURE_COUNT}    console=yes
        Log To Console    =========================  
        
        
    ELSE
        Log To Console    \n=========================
        Log To Console    BT Final Result: PASS 
        Log    PASS COUNT: ${BT_SUCCESS_COUNT}    console=yes
        Log    FAIL COUNT: ${BT_FAILURE_COUNT}    console=yes
        Log To Console    =========================
    END      
    IF    ${WIFI_FAILURE_COUNT} > 0
        Log To Console    \n=========================
        Log To Console    WIFI Final Result: FAIL
        Log    PASS COUNT: ${WIFI_SUCCESS_COUNT}    console=yes
        Log    FAIL COUNT: ${WIFI_FAILURE_COUNT}    console=yes
        Log To Console    =========================  
        
        
    ELSE
        Log To Console    \n=========================
        Log To Console    WIFI Final Result: PASS 
        Log    PASS COUNT: ${WIFI_SUCCESS_COUNT}    console=yes
        Log    FAIL COUNT: ${WIFI_FAILURE_COUNT}    console=yes
        Log To Console    =========================
    END  
    IF    ${LAN1_FAILURE_COUNT} > 0
        Log To Console    \n=========================
        Log To Console    LAN1 Final Result: FAIL
        Log    PASS COUNT: ${LAN1_SUCCESS_COUNT}    console=yes
        Log    FAIL COUNT: ${LAN1_FAILURE_COUNT}    console=yes
        Log To Console    =========================  
        
        
    ELSE
        Log To Console    \n=========================
        Log To Console    LAN1 Final Result: PASS 
        Log    PASS COUNT: ${LAN1_SUCCESS_COUNT}    console=yes
        Log    FAIL COUNT: ${LAN1_FAILURE_COUNT}    console=yes
        Log To Console    =========================
    END
    # IF    ${LAN2_FAILURE_COUNT} > 0
    #     Log To Console    \n=========================
    #     Log To Console    LAN2 Final Result: FAIL
    #     Log    PASS COUNT: ${LAN2_SUCCESS_COUNT}    console=yes
    #     Log    FAIL COUNT: ${LAN2_FAILURE_COUNT}    console=yes
    #     Log To Console    =========================  
        
        
    # ELSE
    #     Log To Console    \n=========================
    #     Log To Console    LAN2 Final Result: PASS 
    #     Log    PASS COUNT: ${LAN2_SUCCESS_COUNT}    console=yes
    #     Log    FAIL COUNT: ${LAN2_FAILURE_COUNT}    console=yes
    #     Log To Console    =========================
    # END
    IF    ${USB_FAILURE_COUNT} > 0
        Log To Console    \n=========================
        Log To Console    USB Final Result: FAIL
        Log    PASS COUNT: ${USB_SUCCESS_COUNT}    console=yes
        Log    FAIL COUNT: ${USB_FAILURE_COUNT}    console=yes
        Log To Console    =========================  
        
        
    ELSE
        Log To Console    \n=========================
        Log To Console    USB Final Result: PASS 
        Log    PASS COUNT: ${USB_SUCCESS_COUNT}    console=yes
        Log    FAIL COUNT: ${USB_FAILURE_COUNT}    console=yes
        Log To Console    =========================
    END

    IF    ${AUDIO_FAILURE_COUNT} > 0
        Log To Console    \n=========================
        Log To Console    Audio Final Result: FAIL
        Log    PASS COUNT: ${AUDIO_SUCCESS_COUNT}    console=yes
        Log    FAIL COUNT: ${AUDIO_FAILURE_COUNT}    console=yes
        Log To Console    =========================  
        
        
    ELSE
        Log To Console    \n=========================
        Log To Console    Audio Final Result: PASS 
        Log    PASS COUNT: ${AUDIO_SUCCESS_COUNT}    console=yes
        Log    FAIL COUNT: ${AUDIO_FAILURE_COUNT}    console=yes
        Log To Console    =========================
    END

    IF    ${Camera_FAILURE_COUNT} > 0
        Log To Console    \n=========================
        Log To Console    Camera Final Result: FAIL
        Log    PASS COUNT: ${Camera_SUCCESS_COUNT}    console=yes
        Log    FAIL COUNT: ${Camera_FAILURE_COUNT}    console=yes
        Log To Console    =========================  
        
        
    ELSE
        Log To Console    \n=========================
        Log To Console    Camera Final Result: PASS 
        Log    PASS COUNT: ${Camera_SUCCESS_COUNT}    console=yes
        Log    FAIL COUNT: ${Camera_FAILURE_COUNT}    console=yes
        Log To Console    =========================
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

Audio Detect
    ${current_success}=    Get Variable Value    ${AUDIO_SUCCESS_COUNT}    ${0}
    ${current_fail}=    Get Variable Value    ${AUDIO_FAILURE_COUNT}    ${0}
    SerialLibrary.Write Data    aplay -l${\n}
        ${log}=    SerialLibrary.Read Until    ${TERMINATOR}
        Log    ${log}
        Log To Console    ${log}

        ${found_in_var}=    Run Keyword And Return Status    Should Contain    ${log}    ${SND_CARD_DEV} 
        # ${cardid_1st}    ${_}=    Sound Card ID Checker
        
        # IF    "${cardid_1st}"   
        IF    ${found_in_var}   
               Log To Console     \nAudio device is detected\n   
               ${current_success}=    Evaluate    ${current_success} + 1
               Set Test Variable     ${AUDIO_SUCCESS_COUNT}    ${current_success}
               Log To Console    --->AUDIO PASS COUNT : ${AUDIO_SUCCESS_COUNT}
                                
        ELSE
               Log To Console    \nAUDIO is not detected
               ${current_fail}=    Evaluate    ${current_fail} + 1
               Set Test Variable     ${AUDIO_FAILURE_COUNT}    ${current_fail}
               Log To Console     --->AUDIO FAIL COUNT : ${AUDIO_FAILURE_COUNT}
               Sleep    1
               SerialLibrary.Write Data    dmesg -T\n 
               ${dmesg_log}=    SerialLibrary.Read Until    ${TERMINATOR}
               Log    ${dmesg_log}
               Run Keyword And Continue On Failure    Should Not Contain    ${dmesg_log}    i2c: Error check busy bus
               Run Keyword And Continue On Failure    Should Contain    ${log}    ${SND_CARD_DEV}
               Fail    \nAUDIO is not detected\n 
        END
   
    
Touch Dedect
    ${current_success}=    Get Variable Value    ${Touch_SUCCESS_COUNT}    ${0}
    ${current_fail}=    Get Variable Value    ${Touch_FAILURE_COUNT}    ${0}
    ${touch_msg}=    Set Variable    Touch Screen
    SerialLibrary.Write Data    evtest&${\n}
    Sleep    1
    
    ${result}=    SerialLibrary.Read Until     Select the device  
    Log    ${result}    console=yes
    ${found_in_var}=    Run Keyword And Return Status    Should Contain     ${result}    ${touch_msg}
    SerialLibrary.Write Data    ${\n}
    Sleep    1
    ${result}=    SerialLibrary.Read Until    ${TERMINATOR}
    
    IF    ${found_in_var}
            Log To Console    Touch Screen is detected\n 
            ${current_success}=    Evaluate    ${current_success} + 1
            Set Test Variable     ${Touch_SUCCESS_COUNT}    ${current_success}
            Log To Console    --->Touch PASS COUNT : ${Touch_SUCCESS_COUNT}
             
    ELSE
            Log To Console    Touch Screen is not detected
            ${current_fail}=    Evaluate    ${current_fail} + 1
            Set Test Variable     ${Touch_FAILURE_COUNT}    ${current_fail}
            Log To Console    --->Touch FAIL COUNT : ${Touch_FAILURE_COUNT}
            Fail    Touch Screen is not detected\n
             
    END
BT Detect 
    ${current_success}=    Get Variable Value    ${BT_SUCCESS_COUNT}    ${0}
    ${current_fail}=    Get Variable Value    ${BT_FAILURE_COUNT}    ${0}
    ${BT_INF_STRING}    Set Variable      ${BT_INF}: 
    SerialLibrary.Write Data    hciconfig ${BT_INF}\n
        ${kernel_op_log}=    SerialLibrary.Read Until    ${TERMINATOR}
        Log to Console      ${kernel_op_log}
        Log      ${kernel_op_log}

        ${found_in_var}=    Run Keyword And Return Status    Should Contain    ${kernel_op_log}    ${BT_INF_STRING} 

        IF    ${found_in_var}
             Log To Console    ${BT_INF} is detected\n 
             ${current_success}=    Evaluate    ${current_success} + 1
             Set Test Variable     ${BT_SUCCESS_COUNT}    ${current_success}
             Log To Console    --->BT PASS COUNT : ${BT_SUCCESS_COUNT}
             
        ELSE
             Log To Console    ${BT_INF} is not detected
             ${current_fail}=    Evaluate    ${current_fail} + 1
             Set Test Variable     ${BT_FAILURE_COUNT}    ${current_fail}
             Log To Console    --->BT FAIL COUNT : ${BT_FAILURE_COUNT}
             Fail    ${BT_INF} is not detected\n
             

        END
WIFI Detect 
    ${current_success}=    Get Variable Value    ${WIFI_SUCCESS_COUNT}    ${0}
    ${current_fail}=    Get Variable Value    ${WIFI_FAILURE_COUNT}    ${0}
    ${WLAN_INF_STRING}    Set Variable      ${WIFI_INF}: flags
    SerialLibrary.Write Data    ifconfig ${WIFI_INF}\n
        ${kernel_op_log}=    SerialLibrary.Read Until    ${TERMINATOR}
        Log to Console      \n${kernel_op_log}
        Log      ${kernel_op_log}

        ${found_in_var}=    Run Keyword And Return Status    Should Contain    ${kernel_op_log}    ${WLAN_INF_STRING} 

        IF    ${found_in_var}
             Log To Console    ${WIFI_INF} is detected\n 
             ${current_success}=    Evaluate    ${current_success} + 1
             Set Test Variable     ${WIFI_SUCCESS_COUNT}    ${current_success}
             Log To Console    --->WIFI PASS COUNT : ${WIFI_SUCCESS_COUNT}
             
        ELSE
             Log To Console    ${WIFI_INF} is not detected
             ${current_fail}=    Evaluate    ${current_fail} + 1
             Set Test Variable     ${WIFI_FAILURE_COUNT}    ${current_fail}
             Log To Console    --->WIFI FAIL COUNT : ${WIFI_FAILURE_COUNT}
             Fail    ${WIFI_INF} is not detected\n
             

        END
   


 LAN1 Detect
    ${current_success}=    Get Variable Value    ${LAN1_SUCCESS_COUNT}    ${0}
    ${current_fail}=    Get Variable Value    ${LAN1_FAILURE_COUNT}    ${0}
    ${ETH_INF_STRING}    Set Variable      ${ETH_INF}: flags
    SerialLibrary.Write Data    ifconfig ${ETH_INF}\n
        ${kernel_op_log}=    SerialLibrary.Read Until    ${TERMINATOR}
        Log to Console      \n${kernel_op_log}
        Log      ${kernel_op_log}

        ${found_in_var}=    Run Keyword And Return Status    Should Contain    ${kernel_op_log}    ${ETH_INF_STRING}

        IF    ${found_in_var}
              Log     ${ETH_INF} is detected\n    console=yes
              ${current_success}=    Evaluate    ${current_success} + 1
              Set Test Variable     ${LAN1_SUCCESS_COUNT}    ${current_success}
              Log To Console    --->LAN1 PASS COUNT : ${LAN1_SUCCESS_COUNT}
              
        ELSE
             Log To Console    ${ETH_INF} is not detected\n
             ${current_fail}=    Evaluate    ${current_fail} + 1
             Set Test Variable     ${LAN1_FAILURE_COUNT}    ${current_fail}
             Log To Console     --->LAN1 FAIL COUNT : ${LAN1_FAILURE_COUNT}
             Fail    ${ETH_INF} is not detected\n  
             
             #Log     ${ETH1_INF} is not detected\n   console=yes
             #Run Keyword And Continue On Failure    Should Contain    ${kernel_op_log}    ${ETH_INF_STRING} 
        END
# LAN2 Detect
#     ${current_success}=    Get Variable Value    ${LAN2_SUCCESS_COUNT}    ${0}
#     ${current_fail}=    Get Variable Value    ${LAN2_FAILURE_COUNT}    ${0}
#     ${ETH_INF_STRING}    Set Variable      ${ETH2_INF}: flags
#     SerialLibrary.Write Data    ifconfig ${ETH2_INF}\n
#         ${kernel_op_log}=    SerialLibrary.Read Until    ${TERMINATOR}
#         Log to Console      \n${kernel_op_log}
#         Log      ${kernel_op_log}

#         ${found_in_var}=    Run Keyword And Return Status    Should Contain    ${kernel_op_log}    ${ETH_INF_STRING}

#         IF    ${found_in_var}
#               Log     ${ETH2_INF} is detected\n    console=yes
#               ${current_success}=    Evaluate    ${current_success} + 1
#               Set Test Variable     ${LAN2_SUCCESS_COUNT}    ${current_success}
#               Log To Console    --->LAN2 PASS COUNT : ${LAN2_SUCCESS_COUNT}
              
#         ELSE
#              Log To Console    ${ETH2_INF} is not detected\n
#              ${current_fail}=    Evaluate    ${current_fail} + 1
#              Set Test Variable     ${LAN2_FAILURE_COUNT}    ${current_fail}
#              Log To Console     --->LAN2 FAIL COUNT : ${LAN2_FAILURE_COUNT}
#              Fail    ${ETH2_INF} is not detected\n  
             
#              #Log     ${ETH1_INF} is not detected\n   console=yes
#              #Run Keyword And Continue On Failure    Should Contain    ${kernel_op_log}    ${ETH_INF_STRING} 
#         END  


Camera Detect
    #Check Camera Device exist or not 
        ${current_success}=    Get Variable Value    ${Camera_SUCCESS_COUNT}    ${0}
        ${current_fail}=    Get Variable Value    ${Camera_FAILURE_COUNT}    ${0}
        SerialLibrary.Write Data    dmesg | grep 'Product:TE' | cut -d',' -f1 | sed 's/.*Product: *//'${\n}
        Sleep    1
        ${result}=    Read All Data   UTF-8
        ${camera_match}=    Get Regexp Matches   ${result}    TEV[A-Z]\-AR\\d+

        IF    ${camera_match} 
              ${camera_info}=    Set Variable    ${camera_match[0]}  
               Log    \nCamera device is detected:${camera_info}    console=yes
               ${current_success}=    Evaluate    ${current_success} + 1
               Set Test Variable     ${Camera_SUCCESS_COUNT}    ${current_success}
               Log To Console    --->Camera PASS COUNT : ${Camera_SUCCESS_COUNT}
               Sleep    1
               Camera-TEVS-AR0234 
               Sleep    5
               
        ELSE
               Log to console    Camera is not detected\n
               ${current_fail}=    Evaluate    ${current_fail} + 1
               Set Test Variable     ${Camera_FAILURE_COUNT}    ${current_fail}
               Log To Console     --->Camera FAIL COUNT : ${Camera_FAILURE_COUNT}
               Sleep    1
               SerialLibrary.Write Data    dmesg -T\n 
               ${dmesg_log}=    SerialLibrary.Read Until    ${TERMINATOR}
               Log    ${dmesg_log}
               Run Keyword And Continue On Failure    Should Not Contain    ${dmesg_log}    Failed to read from register
               Fail     Camera is not detected\n 
        END
    
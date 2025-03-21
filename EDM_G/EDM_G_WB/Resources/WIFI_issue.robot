*** Settings ***
Library           SerialLibrary    encoding=UTF-8   
Library           Collections
Library           String
Library           Process
Library           DateTime

Resource       ../Resources/Common_Params.robot
Library        ../Libraries/EnvVariablesReturnLib.py


*** Variables ***
${TIMEOUT}    10 minutes
${RETRY_INTERVAL}    5 seconds


${WLAN_SUCCESS_COUNT}    0
${WLAN_FAILURE_COUNT}    0
${WLAN_INF_STRING}      wlan0: flags
*** Keywords ***



# Waiting and Login
#     ${bootlog}=    SerialLibrary.Read Until     ${LOGIN_PROMPT}
#     Log        ${bootlog}
#     ${is_login}=    Run Keyword And Return Status    Should Contain    ${bootlog}   ${LOGIN_PROMPT}
#     Log To Console    \n${bootlog}
#     Log To Console    \nlogin to prompt mode
#     SerialLibrary.Write Data    root\n 
#     ${loginglog}=    SerialLibrary.Read Until     ${TERMINATOR} 
#     Sleep    1
   

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

  

dump wifi temperture 
        SerialLibrary.Write Data    bash get_cpu_wifi_temp.sh\n
        ${wifi_temp_log}=    SerialLibrary.Read Until    ${TERMINATOR}
        Log to Console      ${wifi_temp_log}
        Log      ${wifi_temp_log}


Check Bus    
    Seriallibrary.Write Data    cat /sys/kernel/debug/mmc0/ios${\n}
    Sleep    1
    ${Bus_result}=    SerialLibrary.Read All Data    UTF-8
    Log    ${Bus_result}
    Run Keyword And Continue On Failure    Should NOT Contain    ${Bus_result}    off

Get Wifi Ip Address Retry
    ${start_time}=    Get Current Date
    ${end_time}=    Add Time To Date    ${start_time}    ${TIMEOUT}
    
    WHILE    True
        ${current_time}=    Get Current Date
        ${time_diff}=    Subtract Date From Date    ${current_time}    ${start_time}
      
        
        ${is_timeout}=    Evaluate    $current_time > $end_time
        IF    ${is_timeout}
            Fail    Timeout: Failed to get Wifi IP address within ${TIMEOUT}
        END
        
        ${wifi_ip_string}=    Attempt To Get Wifi Ip
        IF    "${wifi_ip_string}" != "${EMPTY}"
            RETURN    ${wifi_ip_string}
        END
        
        Log    Failed to get IP address. Retrying in ${RETRY_INTERVAL}...
        Sleep    ${RETRY_INTERVAL}
    END

Attempt To Get Wifi Ip
    SerialLibrary.Write Data    ifconfig ${WIFI_INF}${\n}
    Sleep    1
    ${wifi_chk_log}=        SerialLibrary.Read All Data    UTF-8
    ${wifi_ip_match}=       Get Regexp Matches    ${wifi_chk_log}    inet 10\.88\.\\d+\.\\d+
    ${wifi_ip_string}=    Set Variable    ${EMPTY}
    IF    ${wifi_ip_match}
          ${wifi_ip_string}=    Strip String    @{wifi_ip_match}    characters=inet${SPACE}
          Set Global Variable    ${wifi_ip_string}
    END
    RETURN    ${wifi_ip_string}

System reboot And WLAN device detection
    ${LOOP_TIME}=    Set Variable      1001
    FOR    ${counter}    IN RANGE    1    ${LOOP_TIME}
        Log To Console  \nTest Count:${counter}\n
        Log     Test Count:${counter} 
        
        #Send reboot command
        Log To Console    \n System reboot ......\n
        SerialLibrary.Write Data    reboot\n
        #Sleep    5

        Booting time record and wait for login

        #dmesg dumplog
        SerialLibrary.Write Data    dmesg -T\n 
        ${dmesg_log}=    SerialLibrary.Read Until    ${TERMINATOR}
        Log    ${dmesg_log}
        Should not Contain    ${dmesg_log}    HTC_dump_counter_info

        Sleep    1

        #wlan0 dump test
        SerialLibrary.Write Data    ifconfig wlan0\n
        ${kernel_op_log}=    SerialLibrary.Read Until    ${TERMINATOR}
        Log to Console      ${kernel_op_log}
        Log      ${kernel_op_log}

        ${found_in_var}=    Run Keyword And Return Status    Should Contain    ${kernel_op_log}    ${WLAN_INF_STRING} 

        IF    ${found_in_var}
             Log To Console    wlan0 device is detected
             ${WLAN_SUCCESS_COUNT}=    Evaluate    ${WLAN_SUCCESS_COUNT} + 1
             Log To Console    WLAN_PASS COUNT : ${WLAN_SUCCESS_COUNT}
             dump wifi temperture 

             SerialLibrary.Write Data    dmesg -T\n 
             ${dmesg_log}=    SerialLibrary.Read Until    ${TERMINATOR}
             Log    ${dmesg_log}
             Run Keyword And Continue On Failure    Should not Contain    ${dmesg_log}    Call trace

             #Sleep    1
             Sleep    3
        ELSE
             Log To Console    wlan0 is not detected.
             ${WLAN_FAILURE_COUNT}=    Evaluate    ${WLAN_FAILURE_COUNT} +1
             Log To Console     WLAN_FAIL COUNT : ${WLAN_FAILURE_COUNT}
             dump wifi temperture 
        END
        #Start CPU stress 
        # SerialLibrary.Write Data    taskset 0x1 stress-ng --cpu 4 --io 1 --timeout 600 &${\n}
        # SerialLibrary.Write Data    taskset 0x2 stress-ng --cpu 4 --io 1 --timeout 600 &${\n}
        # SerialLibrary.Write Data    taskset 0x4 stress-ng --cpu 4 --io 1 --timeout 600 &${\n}
        # SerialLibrary.Write Data    taskset 0x8 stress-ng --cpu 4 --io 1 --timeout 600 &${\n}
        #Start Memory stress 
        # SerialLibrary.Write Data    stressapptest -M 500 -C 4 -s 600 -W &${\n}
        Log To Console    Start to perform Iperf3 Testing....
        WIFI_Stress_12H.Initial Check and Setup server 
        WIFI_Stress_12H.Execute Bandwidth Chart
        WIFI_Stress_12H.Open Browser to Bandwidth Chart 
        WIFI_Stress_12H.Input Test Parameter
        WIFI_Stress_12H.Submit Iperf3 
        Sleep    180
        Capture Page Screenshot    WIFI_ScreenShot_Loop_${counter}.png
        Sleep    1
        WIFI_Stress_12H.Close Process 
        Sleep    3
        Reset Input Buffer    
        Reset Output Buffer    
        Check Bus
        SerialLibrary.Write Data    dmesg -T\n 
        ${dmesg_log}=    SerialLibrary.Read Until    ${TERMINATOR}
        Log    ${dmesg_log}
        Should not Contain    ${dmesg_log}    SDIO bus operation failed
        Check Bus
        SerialLibrary.Write Data    dmesg -T\n 
        ${dmesg_log}=    SerialLibrary.Read Until    ${TERMINATOR}
        Log    ${dmesg_log}
        Should not Contain    ${dmesg_log}    SDIO bus operation failed

        Sleep    1
        
        
        #Log To Console    PAUSE for ${PAUSE_TIME} Secs    UTF-8
    END

    Log    PASS COUNT: ${WLAN_SUCCESS_COUNT}
    Log    FAIL COUNT: ${WLAN_FAILURE_COUNT}
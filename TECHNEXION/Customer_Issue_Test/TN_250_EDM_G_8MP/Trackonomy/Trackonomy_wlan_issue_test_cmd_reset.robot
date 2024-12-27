*** Settings ***
Library           SerialLibrary    encoding=UTF-8   
#Library           SSHLibrary
Library           Collections
Library           String
Library           Process
Library    Telnet
Suite Setup       Run Keywords     Open Serial Port 

Suite Teardown    Run Keywords    Close Serial Port 

*** Variables ***
${SERIAL_PORT}     /dev/ttyUSB1
#${PWR_SW_PORT}     /dev/ttyUSB1
${LOGIN_PROMPT}    edm-g-imx8mp login: 
${TERMINATOR}    root@edm-g-imx8mp:~#
${WLAN_INF_STRING}    wlan0: flags
${PAUSE_TIME}      15

# loop 4 = (5-1)
${LOOP_TIME}       501

${WLAN_SUCCESS_COUNT}    0
${WLAN_FAILURE_COUNT}    0


#power relay's login info
${PWR_HOST}            10.88.88.73
${USERNAME}            root

*** Keywords ***
Open Serial Port
    Add Port   ${SERIAL_PORT}
    ...        baudrate=115200
    ...        bytesize=8
    ...        parity=N
    ...        stopbits=1
    ...        timeout=60
    Reset Input Buffer     ${SERIAL_PORT}
    Reset Output Buffer    ${SERIAL_PORT}


Close Serial Port
    Delete All Ports

#SSH Open Connection And Log In         
#   SSHLibrary.Open Connection     ${PWR_HOST}
#   Login               ${USERNAME}        

#SSH Close All Connections
#    SSHLibrary.Close Connection

#Device ON
#    [Documentation]    Device POWER ON
#    SSHLibrary.Write    ./DOUT_CTRL.sh ON
#    ${read_output}=     SSHLibrary.Read
#    Log to Console      ${read_output}
#    Sleep    0.5

#Device OFF
#    [Documentation]    Device POWER OFF
#    SSHLibrary.Write    ./DOUT_CTRL.sh OFF
#    ${read_output}=    SSHLibrary.Read
#    sleep     0.25
#    Log to Console      ${read_output}
#    Sleep    0.5

Waiting and Login
    ${bootlog}=    SerialLibrary.Read Until     ${LOGIN_PROMPT}
    Log To Console    \n${bootlog}
    Log To Console    \nlogin to prompt mode
    SerialLibrary.Write Data    root\n 
    ${loginglog}=    SerialLibrary.Read Until     ${TERMINATOR} 
    Sleep    1

dump wifi temperture 
        SerialLibrary.Write Data    bash get_cpu_wifi_temp.sh\n
        ${wifi_temp_log}=    SerialLibrary.Read Until    ${TERMINATOR}
        Log to Console      ${wifi_temp_log}
        Log      ${wifi_temp_log}

run iperf test 
        SerialLibrary.Write Data    bash iperf_test.sh\n
        Sleep    45 seconds
        ${iperf_log}=    SerialLibrary.Read Until    5 tx test is done
        Sleep    1
        Log to Console      ${iperf_log}
        Log      ${iperf_log}
        Run Keyword And Continue On Failure    Should Contain     ${iperf_log}    5 tx test is done
        Run Keyword And Continue On Failure    Should Not Contain    ${iperf_log}    error

*** Test cases ***
Power ON_OFF And WLAN device detection
    FOR    ${counter}    IN RANGE    1    ${LOOP_TIME}
        Log To Console  \nTest Count:${counter}\n
        Log     Test Count:${counter} 
        
        #Device OFF
        #Log To Console    PAUSE for ${PAUSE_TIME} Secs    UTF-8

        #Device ON 
        #Sleep    1    
        #${locport}=    Get Current Port Locator
        #Log To Console   DUT : port ${locport}

        #Send reboot command
        Log To Console    \n System reboot ......\n
        SerialLibrary.Write Data    reboot\n
        Sleep    5

        Waiting and Login

        #dmesg dumplog
        SerialLibrary.Write Data    dmesg -T\n 
        ${dmesg_log}=    SerialLibrary.Read Until    ${TERMINATOR}
        Log    ${dmesg_log}
        Run Keyword And Continue On Failure    Should not Contain    ${dmesg_log}    Call trace

        Sleep    1

        dump wifi temperture 

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
             Log To Console    \n perform iperf test\n
             run iperf test 
             dump wifi temperture

            #dmesg dumplog
             SerialLibrary.Write Data    dmesg -T\n 
             ${dmesg_log}=    SerialLibrary.Read Until    ${TERMINATOR}
             Log    ${dmesg_log}
             Run Keyword And Continue On Failure    Should not Contain    ${dmesg_log}    Call trace

        Sleep    1
             Sleep    1


        ELSE
             Log To Console    wlan0 is not detected.
             ${WLAN_FAILURE_COUNT}=    Evaluate    ${WLAN_FAILURE_COUNT} +1
             Log To Console     WLAN_FAIL COUNT : ${WLAN_FAILURE_COUNT}
             dump wifi temperture 
        END
        
        Log To Console    PAUSE for ${PAUSE_TIME} Secs    UTF-8
    END

    Log    PASS COUNT: ${WLAN_SUCCESS_COUNT}
    Log    FAIL COUNT: ${WLAN_FAILURE_COUNT}




*** Settings ***
Library           SerialLibrary    encoding=UTF-8   
Library           SSHLibrary
Library           Collections
Library           String
Library           Process
Suite Setup       Run Keywords     Open Serial Port 
...    AND     SSH Open Connection And Log In  

Suite Teardown    Run Keywords    Close Serial Port       AND     
...    SSH Close All Connections 

*** Variables ***
${SERIAL_PORT}     /dev/ttyUSB0
#${PWR_SW_PORT}     /dev/ttyUSB1
${LOGIN_PROMPT}    edm-g-imx8mp login: 
${TERMINATOR}    root@edm-g-imx8mp:~#
${WLAN_INF_STRING}    wlan0: flags
${PAUSE_TIME}      60
${TEST_TERM_STRING}    tx test is done

${WLAN_SUCCESS_COUNT}    0
${WLAN_FAILURE_COUNT}    0


#power relay's login info
${PWR_HOST}            10.88.88.176
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

SSH Open Connection And Log In         
   SSHLibrary.Open Connection     ${PWR_HOST}
   Login               ${USERNAME}        

SSH Close All Connections
    SSHLibrary.Close Connection

Device ON
    [Documentation]    Device POWER ON
    #SSHLibrary.Write    ./DOUT_CTRL.sh ON
    SSHLibrary.Write    bash gpio_84.sh ON
    ${read_output}=     SSHLibrary.Read
    Log to Console      ${read_output}
    Sleep    0.5

Device OFF
    [Documentation]    Device POWER OFF
    #SSHLibrary.Write    ./DOUT_CTRL.sh OFF
    SSHLibrary.Write    bash gpio_84.sh OFF
    ${read_output}=    SSHLibrary.Read
    sleep     0.25
    Log to Console      ${read_output}
    Sleep    0.5

Waiting and Login
    ${bootlog}=    SerialLibrary.Read Until     ${LOGIN_PROMPT}
    Log    ${bootlog}
    Log To Console    \n${bootlog}
    Log To Console    \nlogin to prompt mode
    SerialLibrary.Write Data    root\n 
    ${loginglog}=    SerialLibrary.Read Until     ${TERMINATOR} 
    Sleep    1


*** Test cases ***
Power ON_OFF And WLAN device detection
    FOR    ${cpu_load}    IN RANGE    5    105    5
        Log To Console  \nCPU Load:${cpu_load}\%\n
        Log     CPU LOAD:${cpu_load}\%
        
        Device OFF
        Log To Console    PAUSE for ${PAUSE_TIME} Secs    UTF-8
        Sleep    ${PAUSE_TIME}
        Device ON 
        #Sleep    1    
        ${locport}=    Get Current Port Locator
        Log To Console   DUT : port ${locport}
        #system login
        Waiting and Login

        #check wlan device
        SerialLibrary.Write Data    bash get_cpu_wifi_temp.sh\n
        Sleep    1
        SerialLibrary.Write Data    ifconfig wlan0\n
        #${wlan_check_log}=   SerialLibrary.Read Until    ${TERMINATOR}
        Sleep    1
        ${wlan_check_log}=   SerialLibrary.Read All Data    UTF-8
        Log to Console      ${wlan_check_log}
        Log      ${wlan_check_log}
        ${found_in_var}=    Run Keyword And Return Status    Should Contain    ${wlan_check_log}    ${WLAN_INF_STRING} 

        IF    ${found_in_var}
             Log To Console    wlan0 device is detected
             ${WLAN_SUCCESS_COUNT}=    Evaluate    ${WLAN_SUCCESS_COUNT} + 1
             Log To Console    WLAN_PASS COUNT : ${WLAN_SUCCESS_COUNT}
        ELSE
             Log To Console    wlan0 is not detected.
             ${WLAN_FAILURE_COUNT}=    Evaluate    ${WLAN_FAILURE_COUNT} +1
             Log To Console     WLAN_FAIL COUNT : ${WLAN_FAILURE_COUNT}
        END

        #Test cpu and wifi load
        Log To Console    ADD CPU ${cpu_load}\% loading and WIFI loading
        SerialLibrary.Write Data    bash add_load.sh ${cpu_load}\n 
        #Sleep    10 minutes
        #${kernel_test_log}=    SerialLibrary.Read Until    ${TEST_TERM_STRING}
        #Sleep    1
        #Log    ${kernel_test_log}
        
        FOR    ${counter}    IN RANGE    1    11
            Sleep    30
            ${kernel_test_log}=    SerialLibrary.Read Until    ${counter}${SPACE}${TEST_TERM_STRING}
            Log To Console    ${kernel_test_log}
            Log    ${kernel_test_log}
        END
        Run Keyword And Continue On Failure    Should Contain    ${kernel_test_log}    10 ${TEST_TERM_STRING}
    END


    Log    PASS COUNT: ${WLAN_SUCCESS_COUNT}
    Log    FAIL COUNT: ${WLAN_FAILURE_COUNT}

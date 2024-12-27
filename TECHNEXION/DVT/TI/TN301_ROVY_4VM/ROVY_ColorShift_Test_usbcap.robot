*** Settings ***
Library           SerialLibrary    encoding=UTF-8
Library           SSHLibrary
Library           Collections
Library           String
Library    Process
Library    OperatingSystem
Suite Setup       Run Keywords     Open Serial Port 
...    AND     SSH Open Connection And Log In  

Suite Teardown    Run Keywords    Close Serial Port  
...    SSH Close All Connections     

*** Variables ***
${SERIAL_PORT}      /dev/ttyS0
${LOGIN_PROMPT}     rovy-4vm login:

#${SERIAL_PWR_CTL}    /dev/ttyUSB0

${PWR_HOST}           10.88.88.60
${USERNAME}           root

#loop +1 equals desire loop number
${LOOP_TIME}         2
${TERMINATOR}        root@rovy-4vm:/

#PAUSE VARIABLE
${PAUSE_TIME}    3

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
    SSHLibrary.Write    ./DOUT_CTRL.sh ON
    ${read_output}=     SSHLibrary.Read
    Log to Console      ${read_output}
    Sleep    0.5

Device OFF
    [Documentation]    Device POWER OFF
    SSHLibrary.Write    ./DOUT_CTRL.sh OFF
    ${read_output}=    SSHLibrary.Read
    sleep     0.25
    Log to Console      ${read_output}
    Sleep    0.5


Waiting and Login
    Sleep    5
    ${bootlog}=   SerialLibrary.Read Until     ${LOGIN_PROMPT}
    Log To Console    \n${bootlog}
    Log To Console    \nlogin to prompt mode
    SerialLibrary.Write Data    root\n 
    ${loginglog}=   SerialLibrary.Read Until     ${TERMINATOR}
    Sleep    2 
    ${2ndlogs}=     SerialLibrary.Read All Data     UTF-8 
    Log    ${loginglog}
    Log    ${2ndlogs}
    

Store the capture file with Uvccam
    [Arguments]    ${cap_filename}
    ${cap_result}=    Run    uvccapture -x1280 -y720 -o${cap_filename}.jpeg -m
    Sleep    3
    Log To Console     ${cap_result}
    Log                ${cap_result}
    Sleep    1

*** Test cases ***
VizionPanel Color Shift Stress Test

    FOR    ${counter}    IN RANGE    1    ${LOOP_TIME} 
        Log to Console    \n Test count: ${counter}
        Sleep    1
        Log To Console    \n Device OFF
        Device OFF
        Log To Console    \n PAUSE for ${PAUSE_TIME} SECS
        Sleep    ${PAUSE_TIME}

        Device ON
        Waiting and Login
        Sleep    10

        Log To Console    capture the panel display
        Store the capture file with Uvccam    testpic_${counter}
          
        Sleep    2
        Log            <img src="testpic_${counter}.jpeg">        html=true

    END




*** Settings ***
Library           SerialLibrary    encoding=UTF-8
Library           SSHLibrary
Library           Collections
Library           String
Library    Process
Suite Setup       Run Keywords     Open Serial Port 
...    AND     SSH Open Connection And Log In  

Suite Teardown    Run Keywords    Close Serial Port  
...    SSH Close All Connections     

*** Variables ***
${SERIAL_PORT}      /dev/ttyS0
${LOGIN_PROMPT}     rovy-4vm login:

#${SERIAL_PWR_CTL}    /dev/ttyUSB0

${PWR_HOST}           10.88.88.94
${USERNAME}           root

#loop +1 equals desire loop number
${LOOP_TIME}         1001
${TERMINATOR}        root@rovy-4vm:/

#PAUSE VARIABLE
${PAUSE_TIME}    5

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
    Sleep    1

Capture the display of the panel
    [Arguments]    ${cap_filename}
    SerialLibrary.Write Data    bash capture_panel_display.sh ${cap_filename}${\n}
    ${testlog}=    SerialLibrary.Read Until        ${TERMINATOR}
    Sleep    1
    SerialLibrary.Write Data    sync${\n}
    Log    ${testlog}
    Sleep    1

Store the capture file
    [Arguments]    ${cap_filename}
    SerialLibrary.Write Data    scp ${cap_filename}.jpeg lance@10.88.88.96:\/mnt\/HDD_Backup\/RF_TDA4VM_Colorshift\/pic_log\/${\n}
    Sleep    2
    SerialLibrary.Write Data    TNonez1021${\n}
    Sleep    1
    ${testlog}=    SerialLibrary.Read All Data    UTF-8
    Log    ${testlog}

Purge capture file
    [Arguments]    ${cap_filename}
    SerialLibrary.Write Data    rm${SPACE}-rf${SPACE}${cap_filename}.jpeg${\n}
    Sleep    1
    SerialLibrary.Write Data    sync${\n}
    Sleep    1
    ${testlog}=    SerialLibrary.Read All Data    UTF-8
    Log    ${testlog}

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
        Sleep    5

        Log To Console    capture the panel display
        Capture the display of the panel    testpic_${counter}
        Log To Console    store file to server
        Store the capture file              testpic_${counter}            
        Sleep    2

        Log            <img src="testpic_${counter}.jpeg">        html=true
        
        Purge capture file    testpic_${counter} 
    END




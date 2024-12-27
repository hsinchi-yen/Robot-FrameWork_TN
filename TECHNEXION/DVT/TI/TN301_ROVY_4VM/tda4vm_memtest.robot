*** Settings ***
Library           SerialLibrary    encoding=UTF-8
Library           Collections
Library           String
Library           Process
Suite Setup       Open Serial Port
Suite Teardown    Close Serial Port

*** Variables ***
${SERIAL_PORT}     /dev/ttyS0
${PWR_SW_PORT}     /dev/ttyUSB0 
${TERMINATOR}      root@rovy-4vm:
${IPER_SERV}       10.88.88.82
${ETH}             eth0
${MEM_TEST_CMD}    memtester -t 10 7000M 1\n
# loop 4 = (5-1)
${LOOP_TIME}       2

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

    Add Port   ${PWR_SW_PORT}
    ...        baudrate=115200
    ...        bytesize=8
    ...        parity=N
    ...        stopbits=1
    ...        timeout=60
    Reset Input Buffer     ${PWR_SW_PORT}
    Reset Output Buffer    ${PWR_SW_PORT}

Close Serial Port
    Delete All Ports

Device ON
    Write Data    gpioset gpiochip2 6=1\n
    ${SW_log}=    Read All Data    UTF-8
    sleep     0.25
    Log    ${SW_log}
    Sleep    1

Device OFF
    Write Data    gpioset gpiochip2 6=0\n
    ${SW_log}=    Read All Data    UTF-8
    sleep     0.25
    Log    ${SW_log}
    Sleep    1

*** Test cases ***
Power ON_OFF And Touch detection Test
    Switch Port    ${PWR_SW_PORT}
    FOR    ${counter}    IN RANGE    1    1001
        Log To Console  \nTest Count:${counter}\n
        Log     Test Count:${counter} 
        Device OFF
        Log To Console    PAUSE for 3 Secs    UTF-8
        Sleep    3
        
        Device ON 
        Sleep    0.5      
        Switch Port    ${SERIAL_PORT}
        ${locport}=    Get Current Port Locator
        Log To Console   DUT : port ${locport}
        Sleep    15
        ${bootlog}=    Read Until    ${TERMINATOR}
        #Log To Console    ${bootlog}    UTF-8
        Log    ${bootlog}

        Sleep    1
        Write Data    \n
        ${bootlog}=    Read All Data
        Log    ${bootlog}
        Log To Console   Start to run Memtester
        Write Data    ${MEM_TEST_CMD}
        Sleep    13m 
        ${tda4vmlog}=    Read Until    Done.
        Log    ${tda4vmlog}
        Sleep    1

        Should Not Contain    ${tda4vmlog}    FAILURE
        Switch Port    ${PWR_SW_PORT}
    END



*** Settings ***
Library           SerialLibrary    encoding=UTF-8
Library           Collections
Library           String
Library           Process
Suite Setup       Open Serial Port
Suite Teardown    Close Serial Port

*** Variables ***
${SERIAL_PORT}    /dev/ttyUSB3
${PWR_SW_PORT}    /dev/ttyUSB5 
${TERMINATOR}       root@rovy-4vm:
${IPER_SERV}        10.88.88.82
${ETH}              eth0

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
    Sleep    5

Device OFF
    Write Data    gpioset gpiochip2 6=0\n
    ${SW_log}=    Read All Data    UTF-8
    sleep     0.25
    Log    ${SW_log}
    Sleep    5

*** Test cases ***
Power ON_OFF And Touch detection Test
    Switch Port    ${PWR_SW_PORT}
    FOR    ${counter}    IN RANGE    1    100 
        Log To Console  \nTest Count:${counter}\n
        Log     Test Count:${counter} 
        Device OFF
        Sleep    3

        Device ON 
        Sleep    1      
        Switch Port    ${SERIAL_PORT}
        Sleep    20

        ${locport}=    Get Current Port Locator
        Log To Console   ${locport}

        ${bootlog}=    Read Until    ${TERMINATOR}
        Log    Log:${counter}
        Log    ${bootlog}

        Sleep    2
        Write Data    \n 
        ${tda4vmlog}=    Read All Data    UTF-8
        Log    ${tda4vmlog}
        Sleep    1

        Write Data    lsmod\n
        Sleep    0.5
        ${tda4vmlog}=    Read All Data    UTF-8
        Log To Console  ${tda4vmlog}  
        Log    ${tda4vmlog}    

        Should Contain    ${tda4vmlog}    exc3000
        Sleep    2

        Write Data    i2cdetect -y -r 4\n
        Sleep    0.25
        ${tda4vmlog}=    Read Until    ${TERMINATOR}
        Should Contain    ${tda4vmlog}=     20: -- -- -- 23 -- -- -- -- -- -- UU -- UU 2d -- --
        Log    ${tda4vmlog}
        Log To Console    ${tda4vmlog}    UTF-8
        Sleep    3

        Write Data    evtest\n 
        Sleep    0.5
        ${tda4vmlog}=    Read Until    Select the device event number
        Should Contain    ${tda4vmlog}    EETI EXC80H60 Touch Screen
        Log To Console    ${tda4vmlog}
        Write Data    0\n
        Sleep    0.5
        ${tda4vmlog}=    Read Until    Testing ...
        Log    ${tda4vmlog}
        Sleep    2

        ${locport}=    Get Current Port Locator
        Log To Console    ${locport}
        Sleep    1
        
        Switch Port    ${PWR_SW_PORT}
        ${locport}=    Get Current Port Locator
        Log To Console    ${locport}
    END



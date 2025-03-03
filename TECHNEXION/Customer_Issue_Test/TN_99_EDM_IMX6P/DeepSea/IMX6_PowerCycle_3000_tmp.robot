*** Settings ***
Library           SerialLibrary    encoding=UTF-8
Library           Collections
Library           String
Library           Process
Suite Setup       Open Serial Port
Suite Teardown    Close Serial Port

*** Variables ***
${SERIAL_PORT}     /dev/ttyUSB0
${PWR_SW_PORT}     /dev/ttyUSB1 
${TERMINATOR}      \#
${LOGIN_PROMPT}    buildroot login:
# loop 4 = (5-1)
${LOOP_TIME}       3001

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
    [Documentation]    Device POWER ON
    Write Data    gpioset gpiochip2 6=1\n
    ${SW_log}=    Read All Data    UTF-8
    sleep     0.25
    Log to Console    ${SW_log}
    Sleep    1

Device OFF
    [Documentation]    Device POWER OFF
    Write Data    gpioset gpiochip2 6=0\n
    ${SW_log}=    Read All Data    UTF-8
    sleep     0.25
    Log to Console    ${SW_log}
    Sleep    1

*** Test cases ***
Power ON_OFF And Touch detection Test
    FOR    ${counter}    IN RANGE    1    ${LOOP_TIME}
        Switch Port    ${PWR_SW_PORT}
        Log To Console  \nTest Count:${counter}\n
        Log     Test Count:${counter} 
        Device OFF
        Log To Console    PAUSE for 5 Secs    UTF-8
        Sleep    5

        Device ON 
        Sleep    1    
        Switch Port    ${SERIAL_PORT}
        ${locport}=    Get Current Port Locator
        Log To Console   DUT : port ${locport}
        Sleep    2
        ${bootlog}=    Read Until    ${LOGIN_PROMPT}
        Log To Console    ${bootlog}
        Log    ${bootlog}
        Should Contain    ${bootlog}    ${LOGIN_PROMPT}
        Sleep    1
        Log To Console    Login test wtih root account
        Write Data    root\n
        Sleep    1
        ${loginlog}=    Read Until    ${TERMINATOR}
        Write Data    cat /sys/devices/virtual/thermal/thermal_zone0/temp\n
        ${kernelcheck_log}=    Read Until    ${TERMINATOR}
        Log to Console    ${kernelcheck_log}
        Log    ${kernelcheck_log}
        Should Contain    ${kernelcheck_log}    ${TERMINATOR}
        Sleep    1
    END



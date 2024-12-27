*** Settings ***
Library           SerialLibrary    encoding=UTF-8
Library           Collections
Library           String
Library           Process
Suite Setup       Open Serial Port
Suite Teardown    Close Serial Port

*** Variables ***
#Test device
${SERIAL_PORT}     /dev/ttyS0

#Power device
${PWR_SW_PORT}     /dev/ttyUSB0
${TERMINATOR}      \# 
${BOOT_PROMPT}    (none) login:
# loop 4 = (5-1)

${PAUSE_TIME}      30
${LOOP_TIME}       11
${KERNEL_VER}      Linux (none) 4.9.88_2.0.0-00023

${BOOT_SUCCESS_COUNT}    0
${BOOT_FAILURE_COUNT}    0

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
Power ON_OFF And Check System bootup Test
    FOR    ${counter}    IN RANGE    1    ${LOOP_TIME}
        Switch Port    ${PWR_SW_PORT}
        Log To Console  \nTest Count:${counter}\n
        Log     Test Count:${counter} 
        Device OFF
        Log To Console    PAUSE for ${PAUSE_TIME} Secs    UTF-8
        Sleep    ${PAUSE_TIME}

        Device ON 
        #Sleep    1    
        Switch Port    ${SERIAL_PORT}
        ${locport}=    Get Current Port Locator
        Log To Console   DUT : port ${locport}
        #Sleep    1
        ${bootlog}=    Read Until    ${BOOT_PROMPT}
        Log To Console    ${bootlog}
        Log    ${bootlog}
        
        Run Keyword And Continue On Failure    Should Contain    ${bootlog}    ${BOOT_PROMPT} 

        ${found_in_var}=    Run Keyword And Return Status    Should Not Contain    ${bootlog}    ${BOOT_PROMPT} 

        IF    ${found_in_var}
             Log To Console    Skip to Login and boot failure is detected
             ${BOOT_FAILURE_COUNT}=    Evaluate    ${BOOT_FAILURE_COUNT} + 1
             Log To Console    BOOT_FAIL COUNT : ${BOOT_FAILURE_COUNT}
        ELSE
            Should Contain    ${bootlog}    ${BOOT_PROMPT}  
            #Sleep    1
            Log To Console    Login with root
            Write Data    root\n
            ${loginlog}=    Read Until    ${TERMINATOR}
            Write Data    uname -a\n
            ${kernelcheck_log}=    Read Until    ${TERMINATOR}
            Log to Console    ${kernelcheck_log} 
            Log    ${kernelcheck_log}
            Should Contain    ${kernelcheck_log}    ${KERNEL_VER}
            Sleep    1
            ${BOOT_SUCCESS_COUNT}=    Evaluate    ${BOOT_SUCCESS_COUNT} +1
            Log To Console    BOOT_PASS COUNT : ${BOOT_SUCCESS_COUNT}
        END
    END

    Log    PASS COUNT: ${BOOT_SUCCESS_COUNT} 
    Log    FAIL COUNT: ${BOOT_FAILURE_COUNT} 


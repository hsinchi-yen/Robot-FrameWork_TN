=========================================================================
 Copyright 2024 Technexion Ltd.
 Test Case No      : TNPT-426
 Purpose           : This test robot is used to Reserved UART function in TEP1-IMX7
 Category          : Functional Test  
 Script name       : Uart_Test.robot
 Author            : Lance
 Date created      : 20240902
=========================================================================

*** Settings ***
Resource          ../Resources/Common_Params.robot
Library        Collections


*** Variables ***
${UART_RXTEST_PATTERN}        rx_testpatten_from_uart_abcdefghij1234567890
${UART_TXTEST_PATTERN}        TX_TESTPATTER_FROM_DUT_ABCDEFGHIJKLMNOPQRSTUV

${UART_7}=                  /dev/ttymxc6

#your host PC's UART that connect to DUT
${PC_VERIFY_UART}           /dev/ttyUSB1

*** Keywords *** 
DUT Uart TX Test
    Set DUT TX Uart Setting
    SerialLibrary.Write Data     echo "${UART_TXTEST_PATTERN}" > ${UART_7}${\n}
    SerialLibrary.Switch Port    ${PC_VERIFY_UART}
    ${uart_test_log}=    SerialLibrary.Read Until    ${UART_TXTEST_PATTERN}     
    Log    ${uart_test_log}
    Run Keyword And Continue On Failure    Should Contain    ${uart_test_log}    ${UART_TXTEST_PATTERN} 
    SerialLibrary.Switch Port    ${SERIAL_PORT}

DUT Uart RX Test
    Set DUT RX Uart Setting
    SerialLibrary.Switch Port    ${PC_VERIFY_UART}
    SerialLibrary.Write Data     ${UART_RXTEST_PATTERN}${\n}
    SerialLibrary.Switch Port    ${SERIAL_PORT}
    ${uart_test_log}=    SerialLibrary.Read Until    ${UART_RXTEST_PATTERN}    
    Log    ${uart_test_log}
    Run Keyword And Continue On Failure    Should Contain    ${uart_test_log}    ${UART_RXTEST_PATTERN}
    SerialLibrary.Write Data     killall cat${\n}
    Sleep    0.5
    ${killcat_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${killcat_log}

Set DUT TX Uart Setting
    SerialLibrary.Write Data    stty -F /dev/ttymxc6 115200 -ixon -ixoff -crtscts${\n}
    Sleep    1
    ${set_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${set_log}

Set DUT RX Uart Setting
    SerialLibrary.Write Data    stty -F /dev/ttymxc6 115200 -ixon -ixoff -crtscts${\n}
    SerialLibrary.Write Data    cat ${UART_7}&${\n}
    Sleep    1
    ${set_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${set_log}
    
Open Test Serial Port
    Add Port   ${PC_VERIFY_UART}
    ...        baudrate=115200
    ...        bytesize=8
    ...        parity=N
    ...        stopbits=1
    ...        timeout=60
    Reset Input Buffer     ${PC_VERIFY_UART}
    Reset Output Buffer    ${PC_VERIFY_UART}

Close Test Serial Port
    SerialLibrary.Delete Port    ${PC_VERIFY_UART}
*** Settings ***
Library           SerialLibrary    encoding=ascii
Library           Collections
Library           String
Force Tags        eth    has-serial
Suite Setup       Open Serial Port
Suite Teardown    Close Serial Port

*** Variables ***
${SERIAL_PORT}      /dev/ttyUSB0
${TERMINATOR}       root@edm-g-imx8mp
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

Close Serial Port
    Delete All Ports

Check Iperf3 Bitrate
    [Arguments]    ${iperf_output}    ${speed}
    @{lines}=    Split To Lines    ${iperf_output}
    ${last_line}=    Get From List    ${lines}    -4
    ${second_last_line}=    Get From List    ${lines}    -5
    Log    last_line_content:${last_line}
    Log    Sec_last_line_content:${second_last_line} 
    ${receiver_bitrate}=    Get Regexp Matches    ${last_line}    \\d+\\sKbits/sec
    ${sender_bitrate}=    Get Regexp Matches    ${second_last_line}    \\d+\\sKbits/sec

    ${receiver_bitrate}=    Convert To String    ${receiver_bitrate} 
    ${sender_bitrate}=    Convert To String    ${sender_bitrate}

    ${receiver_bitrate_digi}=    Get Regexp Matches     ${receiver_bitrate}    \\d+
    ${sender_bitrate_digi}=    Get Regexp Matches     ${sender_bitrate}    \\d+

    ${receiver_bitrate_digi}=    Convert To Integer    @{receiver_bitrate_digi}
    ${sender_bitrate_digi}=      Convert To Integer   @{sender_bitrate_digi}

    Should Be True    ${receiver_bitrate_digi} > ${speed}
    Should Be True    ${sender_bitrate_digi} > ${speed}  

*** Test cases ***

Check Ethernet Devices
    [Timeout]      30
    Write Data     dmesg\n
    sleep          3
    ${read}=       Read Until    ${TERMINATOR}
    sleep          1 
    Log            ${read}  
    Write Data     ifconfig -a\n
    ${read1}=       Read Until    ${TERMINATOR} 
    Should Contain    ${read1}    eth0:
    Sleep          1
    Log            ${read1} 

Eth 1G Throughput Test
    ${speed}=    Set Variable    900000
    Write Data     iperf3 -c ${IPER_SERV} -p 5204 -f k\n 
    ${iperflog}=    Read Until    ${TERMINATOR}
    Sleep    10
    Log    ${iperflog}
    #Log To Console    ${iperflog}
    sleep    1
    Check Iperf3 Bitrate    ${iperflog}     ${speed}
    sleep    1

Eth 100M BaseT Test
    ${speed}=    Set Variable    90000
    Write Data     ethtool -s ${ETH} speed 100 duplex full\n
    ${testlog}=    Read Until    Link is Up
    sleep     3
    Should Contain    ${testlog}    Link is Up
    Write Data     iperf3 -c ${IPER_SERV} -p 5204 -f k\n
    ${iperflog}=    Read Until    ${TERMINATOR}
    Sleep    10
    Log    ${iperflog}
    #Log To Console    ${iperflog}
    Check Iperf3 Bitrate    ${iperflog}     ${speed}
    sleep    1

Eth 10M BaseT Test
    ${speed}=    Set Variable    9000
    Write Data     ethtool -s ${ETH} speed 10 duplex full\n
    ${testlog}=    Read Until    Link is Up
    sleep     3
    Should Contain    ${testlog}    Link is Up
    Write Data     iperf3 -c ${IPER_SERV} -p 5204 -f k\n
    ${iperflog}=    Read Until    ${TERMINATOR}
    Sleep    10
    Log    ${iperflog}
    #Log To Console    ${iperflog}
    Check Iperf3 Bitrate    ${iperflog}     ${speed}
    sleep    1

Eth 1G Setting roll back
    Write Data     ethtool -s ${ETH} speed 1000 duplex full autoneg on\n
    ${testlog}=    Read Until    Link is Up
    Should Contain       ${testlog}    Link is Up

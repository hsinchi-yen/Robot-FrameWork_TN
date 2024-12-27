*** Settings ***
Library        Collections
Resource       ../Resources/Common_Params.robot
Library        ../Libraries/EnvVariablesReturnLib.py


*** Variables ***
${P_STREAMS}         4

${TEST_SECONDS}      20
# unit - Mbits/sec
${TX_RATE_SPEC}      50
${RX_RATE_SPEC}      100

${BIDIR_TX_RATE_SPEC}     10
${BIDIR_RX RATE_SPEC}     70

${CRITERION_UNIT}    Mbits/sec

*** Keywords ***
Wifi Iperf3 Tx Test
    Eth Ip Address Checker
    ${wifi_ip}=    Get Wifi Ip Address
    SerialLibrary.Write Data    iperf3 -c ${IPERF_SERV} -B ${wifi_ip} -P ${P_STREAMS} -t ${TEST_SECONDS}${\n}
    ${Iperf3_log}=    SerialLibrary.Read Until    ${TERMINATOR}
    Log    ${Iperf3_log}
    Wifi Transmission Bitrate Check    ${Iperf3_log}    ${TX_RATE_SPEC}
    Eth Ip Address Resume


Wifi Iperf3 Rx Test
    Eth Ip Address Checker
    ${wifi_ip}=    Get Wifi Ip Address
    SerialLibrary.Write Data    iperf3 -c ${IPERF_SERV} -B ${wifi_ip} -P ${P_STREAMS} -t ${TEST_SECONDS} -R${\n}
    ${Iperf3_log}=    SerialLibrary.Read Until    ${TERMINATOR}
    Log    ${Iperf3_log}
    Wifi Transmission Bitrate Check    ${Iperf3_log}    ${RX_RATE_SPEC}
    Eth Ip Address Resume

Wifi Iperf3 Bidirection Test
    Eth Ip Address Checker
    ${wifi_ip}=    Get Wifi Ip Address
    SerialLibrary.Write Data    iperf3 -c ${IPERF_SERV} -B ${wifi_ip} -P ${P_STREAMS} -t ${TEST_SECONDS} --bidir${\n}
    ${Iperf3_log}=    SerialLibrary.Read Until    ${TERMINATOR}
    Log    ${Iperf3_log}
    Wifi Bidir Transmission Bitrate Check     ${Iperf3_log}
    Eth Ip Address Resume

Get Wifi Ip Address
    SerialLibrary.Write Data    ifconfig ${WIFI_INF}${\n}
    Sleep    1
    ${wifi_chk_log}=        SerialLibrary.Read All Data    UTF-8
    ${wifi_ip_match}=       Get Regexp Matches    ${wifi_chk_log}    inet 10\.88\.\\d+\.\\d+
    ${wifi_ip_string}=      Strip String    @{wifi_ip_match}    characters=inet${SPACE}
    RETURN   ${wifi_ip_string}

Eth Ip Address Checker
    SerialLibrary.Write Data    connmanctl disable ethernet${\n}
    Sleep    0.5
    SerialLibrary.Write Data    connmanctl enable wifi${\n}
    Sleep    5
    ${eth_chk_log}=        SerialLibrary.Read All Data    UTF-8
    Log    ${eth_chk_log}

Eth Ip Address Resume
    SerialLibrary.Write Data    connmanctl enable ethernet${\n}
    Sleep    10
    ${eth_up_log}=        SerialLibrary.Read All Data    UTF-8
    Log    ${eth_up_log}

Wifi Transmission Bitrate Check
    [Arguments]    ${iperf_output}   ${test_spec}
    @{lines}=    Split To Lines    ${iperf_output}
    ${sender_line}=      Get From List    ${lines}    -5
    ${receiver_line}=    Get From List    ${lines}    -4

    Log    sender_content:$${sender_line}
    Log    receiver_content:${receiver_line}

    ${sender_rate}=        Get Regexp Matches    ${sender_line}           \\d+[.\\d+]*\\s${CRITERION_UNIT}
    ${receiver_rate}=      Get Regexp Matches    ${receiver_line}         \\d+[.\\d+]*\\s${CRITERION_UNIT}
    
    ${sender_rate}=        Convert To String     ${sender_rate}
    ${receiver_rate}=      Convert To String     ${receiver_rate}

    ${sender_digi}=        Get Regexp Matches     ${sender_rate}          \\d+[.\\d+]*
    ${receiver_digi}=      Get Regexp Matches     ${receiver_rate}        \\d+[.\\d+]*

    ${sender_digi}=        Convert To Number   @{sender_digi}
    ${receiver_digi}=      Convert To Number    @{receiver_digi}

    Log    sender_digi:${sender_digi} ${CRITERION_UNIT} 
    Log    receiver_digi:${receiver_digi} ${CRITERION_UNIT} 

    Should Be True        ${sender_digi} >= ${test_spec}
    Should Be True        ${receiver_digi} >= ${test_spec}

Wifi Bidir Transmission Bitrate Check 
    [Arguments]    ${iperf_output}    
    @{lines}=    Split To Lines    ${iperf_output}
    ${tx_sender_line}=      Get From List    ${lines}    -15
    ${tx_receiver_line}=    Get From List    ${lines}    -14

    ${rx_sender_line}=      Get From List    ${lines}    -5
    ${rx_receiver_line}=    Get From List    ${lines}    -4

    Log    tx_sender_content:$${rx_sender_line}
    Log    tx_receiver_content:${rx_receiver_line}
    Log    rx_sender_content:$${rx_sender_line}
    Log    rx_receiver_content:${rx_receiver_line}

    ${tx_sender_rate}=        Get Regexp Matches    ${tx_sender_line}           \\d+[.\\d+]*\\s${CRITERION_UNIT}
    ${tx_receiver_rate}=      Get Regexp Matches    ${tx_receiver_line}         \\d+[.\\d+]*\\s${CRITERION_UNIT}
    ${rx_sender_rate}=        Get Regexp Matches    ${rx_sender_line}           \\d+[.\\d+]*\\s${CRITERION_UNIT}
    ${rx_receiver_rate}=      Get Regexp Matches    ${rx_receiver_line}         \\d+[.\\d+]*\\s${CRITERION_UNIT}
    
    ${tx_sender_rate}=        Convert To String     ${tx_sender_rate}
    ${tx_receiver_rate}=      Convert To String     ${tx_receiver_rate}
    ${rx_sender_rate}=        Convert To String     ${rx_sender_rate}
    ${rx_receiver_rate}=      Convert To String     ${rx_receiver_rate}

    ${tx_sender_digi}=        Get Regexp Matches     ${tx_sender_rate}          \\d+[.\\d+]*
    ${tx_receiver_digi}=      Get Regexp Matches     ${tx_receiver_rate}        \\d+[.\\d+]*
    ${rx_sender_digi}=        Get Regexp Matches     ${rx_sender_rate}          \\d+[.\\d+]*
    ${rx_receiver_digi}=      Get Regexp Matches     ${rx_receiver_rate}        \\d+[.\\d+]*


    ${tx_sender_digi}=        Convert To Number    @{tx_sender_digi}
    ${tx_receiver_digi}=      Convert To Number    @{tx_receiver_digi}
    ${rx_sender_digi}=        Convert To Number    @{rx_sender_digi}
    ${rx_receiver_digi}=      Convert To Number    @{rx_receiver_digi}

    Log    tx_sender_digi:${tx_sender_digi} ${CRITERION_UNIT} 
    Log    tx_receiver_digi:${tx_receiver_digi} ${CRITERION_UNIT} 
    Log    rx_sender_digi:${rx_sender_digi} ${CRITERION_UNIT} 
    Log    rx_receiver_digi:${rx_receiver_digi} ${CRITERION_UNIT} 


    #${result_tx_sender_digi_ge}    Evaluate    ${tx_sender_digi} >= ${BIDIR_TX_RATE_SPEC}
    #${result+tx_receiver_digi_ge}    Evaluate    ${tx_receiver_digi} >= ${BIDIR_TX_RATE_SPEC}
    #${rx_sender_digi_ge}    Evaluate    ${rx_sender_digi} >= ${BIDIR_RX RATE_SPEC} 
    #${rx_receiver_digi_ge}    Evaluate    ${rx_receiver_digi} >= ${BIDIR_RX RATE_SPEC} 

    Should Be True        ${tx_sender_digi} >= ${BIDIR_TX_RATE_SPEC}
    Should Be True        ${tx_receiver_digi} >= ${BIDIR_TX_RATE_SPEC}
    Should Be True        ${rx_sender_digi} >= ${BIDIR_RX RATE_SPEC} 
    Should Be True        ${rx_receiver_digi} >= ${BIDIR_RX RATE_SPEC} 
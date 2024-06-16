*** Settings ***
Library        Collections
Resource       ../Resources/Common_Params.robot
Library        ../Libraries/EnvVariablesReturnLib.py


*** Variables ***
${P_STREAMS}         4
${TEST_SECONDS}      20
# unit - Mbits/sec
${1G_RATE_SPEC}      900
${100M_RATE_SPEC}    98
${10M_RATE_SPEC}     8

${CRITERION_UNIT}    Mbits/sec

*** Keywords ***
ETH Iperf3 Tx Test
    SerialLibrary.Write Data    iperf3 -c ${IPERF_SERV} -P ${P_STREAMS} -t ${TEST_SECONDS}${\n}
    ${Iperf3_log}=    SerialLibrary.Read Until    ${TERMINATOR}
    Log    ${Iperf3_log}
    Transmission Bitrate Check     ${Iperf3_log}

ETH Iperf3 Rx Test
    SerialLibrary.Write Data    iperf3 -c ${IPERF_SERV} -P ${P_STREAMS} -t ${TEST_SECONDS} -R${\n}
    ${Iperf3_log}=    SerialLibrary.Read Until    ${TERMINATOR}
    Log    ${Iperf3_log}
    Transmission Bitrate Check     ${Iperf3_log}

ETH Iperf3 Bidirection Test
    SerialLibrary.Write Data    iperf3 -c ${IPERF_SERV} -P ${P_STREAMS} -t ${TEST_SECONDS} --bidir${\n}
    ${Iperf3_log}=    SerialLibrary.Read Until    ${TERMINATOR}
    Log    ${Iperf3_log}
    Bidir Transmission Bitrate Check     ${Iperf3_log}


Transmission Bitrate Check
    [Arguments]    ${iperf_output}    
    @{lines}=    Split To Lines    ${iperf_output}
    ${sender_line}=      Get From List    ${lines}    -5
    ${receiver_line}=    Get From List    ${lines}    -4

    Log    sender_content:$${sender_line}
    Log    receiver_content:${receiver_line}

    ${sender_rate}=        Get Regexp Matches    ${sender_line}           \\d+\\s${CRITERION_UNIT}
    ${receiver_rate}=      Get Regexp Matches    ${receiver_line}         \\d+\\s${CRITERION_UNIT}
    
    ${sender_rate}=        Convert To String     ${sender_rate}
    ${receiver_rate}=      Convert To String     ${receiver_rate}

    ${sender_digi}=        Get Regexp Matches     ${sender_rate}          \\d+
    ${receiver_digi}=      Get Regexp Matches     ${receiver_rate}        \\d+

    ${sender_digi}=        Convert To Integer    @{sender_digi}
    ${receiver_digi}=      Convert To Integer    @{receiver_digi}

    Log    sender_digi:${sender_digi} ${CRITERION_UNIT} 
    Log    receiver_digi:${receiver_digi} ${CRITERION_UNIT} 

    Should Be True        ${sender_digi} > ${1G_RATE_SPEC}
    Should Be True        ${receiver_digi} > ${1G_RATE_SPEC}

Bidir Transmission Bitrate Check 
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

    ${tx_sender_rate}=        Get Regexp Matches    ${tx_sender_line}           \\d+\\s${CRITERION_UNIT}
    ${tx_receiver_rate}=      Get Regexp Matches    ${tx_receiver_line}         \\d+\\s${CRITERION_UNIT}
    ${rx_sender_rate}=        Get Regexp Matches    ${rx_sender_line}           \\d+\\s${CRITERION_UNIT}
    ${rx_receiver_rate}=      Get Regexp Matches    ${rx_receiver_line}         \\d+\\s${CRITERION_UNIT}
    
    ${tx_sender_rate}=        Convert To String     ${tx_sender_rate}
    ${tx_receiver_rate}=      Convert To String     ${tx_receiver_rate}
    ${rx_sender_rate}=        Convert To String     ${rx_sender_rate}
    ${rx_receiver_rate}=      Convert To String     ${rx_receiver_rate}

    ${tx_sender_digi}=        Get Regexp Matches     ${tx_sender_rate}          \\d+
    ${tx_receiver_digi}=      Get Regexp Matches     ${tx_receiver_rate}        \\d+
    ${rx_sender_digi}=        Get Regexp Matches     ${rx_sender_rate}          \\d+
    ${rx_receiver_digi}=      Get Regexp Matches     ${rx_receiver_rate}        \\d+


    ${tx_sender_digi}=        Convert To Integer    @{tx_sender_digi}
    ${tx_receiver_digi}=      Convert To Integer    @{tx_receiver_digi}
    ${rx_sender_digi}=        Convert To Integer    @{rx_sender_digi}
    ${rx_receiver_digi}=      Convert To Integer    @{rx_receiver_digi}

    Log    tx_sender_digi:${tx_sender_digi} ${CRITERION_UNIT} 
    Log    tx_receiver_digi:${tx_receiver_digi} ${CRITERION_UNIT} 
    Log    rx_sender_digi:${rx_sender_digi} ${CRITERION_UNIT} 
    Log    rx_receiver_digi:${rx_receiver_digi} ${CRITERION_UNIT} 

    Should Be True        ${tx_sender_digi} > ${1G_RATE_SPEC}
    Should Be True        ${tx_receiver_digi} > ${1G_RATE_SPEC}
    Should Be True        ${rx_sender_digi} > ${1G_RATE_SPEC}
    Should Be True        ${rx_receiver_digi} > ${1G_RATE_SPEC}





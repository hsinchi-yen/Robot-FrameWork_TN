*** Settings ***
Library        Collections
Resource       ../Resources/Common_Params.robot
Library        ../Libraries/EnvVariablesReturnLib.py
Library        String


*** Variables ***
${WIFI_SSID}            HOTSPOT_ORBI
${WIFI_PASSPHRASE}      4355atectoair


*** Keywords ***
Wifi Connection test
    ${wifi_conn_phrase}=    Get Wifi Connention hashkey
    Log    ${wifi_conn_phrase}
    SerialLibrary.Write Data    connmanctl${\n}
    Sleep    1
    SerialLibrary.Write Data    agent on${\n}
    Sleep    1
    SerialLibrary.Write Data    connect ${wifi_conn_phrase}${\n}
    Sleep    1
    SerialLibrary.Write Data    ${WIFI_PASSPHRASE}${\n}
    Sleep    10
    SerialLibrary.Write Data    state${\n}
    Sleep    1
    ${connamm_conf_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${connamm_conf_log}
    Should Contain    ${connamm_conf_log}    SessionMode
    SerialLibrary.Write Data    exit${\n}

    
Get Wifi Connention hashkey
    ${trim_wifi_mac}=    Get Wifi Device Mac Id
    SerialLibrary.Write Data    connmanctl enable wifi${\n}
    Sleep    0.5
    SerialLibrary.Write Data    connmanctl scan wifi${\n}
    Sleep    8
    ${connman_log}=    SerialLibrary.Read All Data    UTF-8
    Should Contain    ${connman_log}    Scan completed for wifi
    SerialLibrary.Write Data    connmanctl services${\n}
    Sleep    5
    ${service_log}=    SerialLibrary.Read All data    UTF-8
    Log    ${service_log}
    Log    ${trim_wifi_mac}
    ${ssid_wifi_hashkey}=    Get Regexp Matches    ${service_log}    ${WIFI_SSID}\\s{9}wifi_${trim_wifi_mac}_\\w*
    ${str_wifi_hashkey}=    Convert To String    ${ssid_wifi_hashkey}
    ${wifi_hashkey}=    Get Regexp Matches    ${str_wifi_hashkey}    wifi_${trim_wifi_mac}_\\w*
    ${wifi_hashkey}=    Convert To String    @{wifi_hashkey}
    
    #Log    ${ssid_wifi_hashkey}
    #Log    ${wifi_hashkey}
    RETURN    ${wifi_hashkey}   


Get Wifi Device Mac Id
   SerialLibrary.Write Data    ifconfig ${WIFI_INF}${\n}
   Sleep    1
   ${wifiinf_log}=    SerialLibrary.Read All Data     UTF-8
   #Log To Console    ${wifiinf_log}
   ${wifi_mac}=    Get Regexp Matches    ${wifiinf_log}    \\w{2}:\\w{2}:\\w{2}:\\w{2}:\\w{2}:\\w{2}
   Log     ${wifi_mac}
   ${wifi_mac_stripped}=    Remove String     @{wifi_mac}    :    
   Log    ${wifi_mac_stripped}
   RETURN    ${wifi_mac_stripped}
    
    

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





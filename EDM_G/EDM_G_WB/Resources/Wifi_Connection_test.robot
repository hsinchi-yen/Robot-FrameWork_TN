=========================================================================
 Copyright 2024 Technexion Ltd.
 Test Case No      : Case TNPT-42  / Case TNPT 56
 Category          : Function 
 Script name       : WIFI_connection_test.robot

Test requirements :
The remote power relay board is required

remote relay boards :
PICO-IMX8MM - PICO-PI 8M + PowerRelay Board
FLEX-IMX8MM - FLEX-PI + PowerRelay Board
The Keyword - Tester Wifi Connection test is operated in the remote power relay board
The dipole MHF4 attena connected to the remote relay board is required.

 Author            : Lance
 Date created      : 20240624
 Date updated      : 20250211
=========================================================================
Revised date : 20250117      Raymond  
...    Use while loop to wait state and get regexp , show IP and iwconfig info after connection
Revised date : 20250211      Lance
...    Add more information to describe how the WIFI AP mode be proceesed.


*** Settings ***
Library        Collections
Resource       ../Resources/Common_Params.robot
Library        ../Libraries/EnvVariablesReturnLib.py
Library        String


*** Variables ***
#${WIFI_SSID}            TECHNEXION-RDTEST-5G-WIFI6-WPA3
${WIFI_SSID}            TECHNEXION-RDTEST-5G
${WIFI_PASSPHRASE}      82273585

${WIFI_TETHER_SSID}     ROBOT_SIT_AP
${WIFI_TETHER_PWD}      12345678
${WIFI_TETHER_SERVIP}   192.168.0.1

#Modify the prompt base on what baseboard you use
${TEST_TERMINATOR}=     root@flex-imx8mm:~#



*** Keywords ***
# Wifi Connection test
#     ${wifi_conn_phrase}=    Get Wifi Connention hashkey
#     Log    ${wifi_conn_phrase}
#     SerialLibrary.Write Data    connmanctl${\n}
#     Sleep    1
#     SerialLibrary.Write Data    agent on${\n}
#     Sleep    1
#     SerialLibrary.Write Data    connect ${wifi_conn_phrase}${\n}
#     Sleep    1
#     SerialLibrary.Write Data    ${WIFI_PASSPHRASE}${\n}
#     Sleep    10
#     SerialLibrary.Write Data    state${\n}
#     Sleep    5
#     ${connamm_conf_log}=    SerialLibrary.Read All Data    UTF-8
#     Log    ${connamm_conf_log}
#     Should Contain    ${connamm_conf_log}    State = ready
#     SerialLibrary.Write Data    exit${\n}
#     Sleep    1
#     Wifi Link Signal Check
Wifi Connection test
    ${wifi_conn_phrase}=    Get Wifi Connention hashkey
    Log    ${wifi_conn_phrase}
    SerialLibrary.Write Data    connmanctl${\n}
    Sleep    1
    SerialLibrary.Write Data    agent on${\n}
    Sleep    1
    Reset Input Buffer
    SerialLibrary.Write Data    connect ${wifi_conn_phrase}${\n}
    Sleep    1
    ${response}=    SerialLibrary.Read All Data
    Log To Console    ${\n}
    Run Keyword If    'Already connected' in '''${response}'''    Log    \n${WIFI_SSID} Already Connected    console=yes   #Same SSID re-connected
    ...    ELSE IF    'Passphrase?' in '''${response}'''    #New SSID connected
    ...    Run Keywords    Log    \n${WIFI_SSID} Connected    console=yes
    ...    AND    SerialLibrary.Write Data    ${WIFI_PASSPHRASE}${\n}
    ...    ELSE    Log    \n${WIFI_SSID} Connected    console=yes     #The saved SSID re-connected
    Sleep    1
    
    WHILE    True
         SerialLibrary.Write Data    state${\n}
         Sleep    3
         ${line}=    SerialLibrary.Read All Data   
         ${Regexp_output}=    Get Regexp Matches     ${line}     State = ready   
         IF     ${Regexp_output}   
            BREAK
         ELSE IF    'State = idle' in '''${line}'''
             CONTINUE
         ELSE IF    'State =' in '''${line}''' and 'ready' not in '''${line}''' and 'idle' not in '''${line}'''
             Fail    WiFi Connection Failed: Unexpected State Detected
         END
    END

    SerialLibrary.Write Data    exit${\n}
    Sleep    1
    Reset Input Buffer
    Log to console    \n=====================iwconfig result===============================
    SerialLibrary.Write Data    iwconfig ${WIFI_INF}${\n}
    Sleep    1
    ${result}=    SerialLibrary.Read All Data
    Log    ${result}    console=yes
    Get Wifi Ip Address
    Log To Console    \nConnected WIFI IP is : ${wifi_ip_string}\n

Get Wifi Connention hashkey
    ${trim_wifi_mac}=    Get Wifi Device Mac Id
    SerialLibrary.Write Data    connmanctl enable wifi${\n}
    Sleep    0.5
    SerialLibrary.Write Data    connmanctl scan wifi${\n}
    Sleep    10
    ${connman_log}=    SerialLibrary.Read All Data    UTF-8
    Should Contain    ${connman_log}    Scan completed for wifi
    SerialLibrary.Write Data    connmanctl services${\n}
    Sleep    10
    ${service_log}=    SerialLibrary.Read All data    UTF-8
    Log    ${service_log}
    Log    ${trim_wifi_mac}
    ${ssid_wifi_hashkey}=    Get Regexp Matches    ${service_log}    ${WIFI_SSID}\\s{1,9}wifi_${trim_wifi_mac}_\\w*
    ${str_wifi_hashkey}=    Convert To String    ${ssid_wifi_hashkey}
    ${wifi_hashkey}=    Get Regexp Matches    ${str_wifi_hashkey}    wifi_${trim_wifi_mac}_\\w*
    ${wifi_hashkey}=    Convert To String    @{wifi_hashkey}
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
    
Wifi Link Signal Check
    SerialLibrary.Write Data     iw dev ${WIFI_INF} link${\n}
    Sleep    1
    ${wifisig_log}=    SerialLibrary.Read All Data     UTF-8
    Should Contain    ${wifisig_log}    signal:
    Log    Wifi Signal info: ${wifisig_log}
    Sleep    1

Wifi Tether Mode Activate
    @{tether_state}=    Create List    wifi tethering: Already enabled    entered forwarding state
    SerialLibrary.Write Data     connmanctl tether wifi on ${WIFI_TETHER_SSID} ${WIFI_TETHER_PWD}${\n}
    Sleep    3
    ${wifitether_log}=    SerialLibrary.Read All Data     UTF-8
    Should Contain Any     ${wifitether_log}    @{tether_state}
    Log    Wifi tether on info: ${wifitether_log}
    Sleep    1
    Tether Mode Stat check

Tether Mode Stat check
    FOR    ${counter}    IN RANGE    1    11
        SerialLibrary.Write Data    ifconfig tether${\n}
        Sleep    2
        ${tether_stat_log}=    SerialLibrary.Read All Data    UTF-8
        Log    ${tether_stat_log}
        ${tether_ok}=    Run Keyword And Return Status    Should Contain    ${tether_stat_log}    192\.168\.0\.1
        Exit For Loop If    ${tether_ok} == ${True}
    END

Wifi Tether Mode Deactivate
    SerialLibrary.Write Data     connmanctl tether wifi off${\n}
    Sleep    5
    ${wifitether_log}=    SerialLibrary.Read All Data     UTF-8
    Should Contain    ${wifitether_log}    Disabled tethering for wifi
    Log    Wifi tether on info: ${wifitether_log}
    Sleep    1

Wifi Client Connect Test
    Tester Wifi Connection test
    Verify Remote Connected IP


Get Tester Wifi Device Mac Id
   SSHLibrary.Write     ifconfig wlan0
   ${inf_log}=      SSHLibrary.Read Until   ${TEST_TERMINATOR}
   Log      ${inf_log}
   ${tester_mac}=    Get Regexp Matches    ${inf_log}    \\w{2}:\\w{2}:\\w{2}:\\w{2}:\\w{2}:\\w{2}
   Log     ${tester_mac}
   ${tester_mac}=    Remove String     @{tester_mac}    :    
   Log    ${tester_mac}
   RETURN    ${tester_mac}

Get Tester Wifi Connention hashkey
    ${trim_wifi_mac}=    Get Tester Wifi Device Mac Id
    SSHLibrary.Write           connmanctl enable wifi
    SSHLibrary.Start Command   connmanctl scan wifi
    ${dut_connman_log}=    SSHLibrary.Read Command Output
    Should Contain    ${dut_connman_log}    Scan completed for wifi
    SSHLibrary.Start Command    connmanctl services
    ${dut_service_log}=    SSHLibrary.Read Command Output

    FOR   ${count}     IN RANGE    1    11
        SSHLibrary.Write           connmanctl enable wifi
        SSHLibrary.Start Command   connmanctl scan wifi
        ${dut_connman_log}=    SSHLibrary.Read Command Output
        Should Contain    ${dut_connman_log}    Scan completed for wifi
        SSHLibrary.Start Command    connmanctl services
        ${dut_service_log}=    SSHLibrary.Read Command Output
        Exit For Loop If     '${WIFI_TETHER_SSID}' in '''${dut_service_log}'''
    END

    Log    ${dut_service_log}
    Log    ${trim_wifi_mac}
    ${ssid_wifi_hashkey}=    Get Regexp Matches    ${dut_service_log}    ${WIFI_TETHER_SSID}\\s{1,9}wifi_${trim_wifi_mac}_\\w*
    ${str_wifi_hashkey}=    Convert To String    ${ssid_wifi_hashkey}
    ${wifi_hashkey}=    Get Regexp Matches    ${str_wifi_hashkey}    wifi_${trim_wifi_mac}_\\w*
    ${wifi_hashkey}=    Convert To String    @{wifi_hashkey}
    
    Log    ${ssid_wifi_hashkey}
    Log    ${wifi_hashkey}
    RETURN    ${wifi_hashkey}
    

Tester Wifi Connection test
    ${wifi_conn_phrase}=    Get Tester Wifi Connention hashkey
    Log    ${wifi_conn_phrase}
    SSHLibrary.Write    connmanctl
    SSHLibrary.Write    agent on
    SSHLibrary.Write    connect ${wifi_conn_phrase}
    Sleep   5
    SSHLibrary.Write    ${WIFI_TETHER_PWD}
    SSHLibrary.Write    state
    ${connamm_conf_log}=    SSHLibrary.Read Until   connmanctl>
    Log    ${connamm_conf_log}
    
    SSHLibrary.Write        exit
    ${connmanexit_log}=    SSHLibrary.Read Until   ${TEST_TERMINATOR}
    Log     ${connmanexit_log}
    Sleep   3

   #SSHLibrary.Write        dmesg | tail -3
   #${dmesg_connect_event}=         SSHLibrary.Read Until   ${TEST_TERMINATOR}
   #Should Contain          ${dmesg_connect_event}     wlan0: link becomes ready
   #Sleep    1
       FOR    ${count}    IN RANGE    1     11
        SSHLibrary.Start Command    ifconfig wlan0
        ${c_wlan_log}=    SSHLibrary.Read Command Output
        Log    ${c_wlan_log}
        Exit For Loop If    'inet addr:192.168' in ''' ${c_wlan_log}'''
        Sleep    3
    END
   Tether Conn Checker
    

Tester Wifi Connection Setting Purge
    ${wifi_conn_phrase}=    Get Tester Wifi Connention hashkey
    Log    ${wifi_conn_phrase}
    SSHLibrary.Write    connmanctl config ${wifi_conn_phrase} remove
    Sleep   3

Verify Remote Connected IP
    SerialLibrary.Write Data     ifconfig tether${\n}
    Sleep   2
    ${tethermode_log}=      SerialLibrary.Read All Data     UTF-8
    Should Contain      ${tethermode_log}       tether: flags

    SerialLibrary.Write Data    arp -i tether -a${\n}
    Sleep   3
    ${connectip_log}=       SerialLibrary.Read All Data     UTF-8
    Log     ${connectip_log}

Tether Conn Checker
    SSHLibrary.Write    iwconfig wlan0
    ${Conn_SSID_IW_log}=    SSHLibrary.Read Until    ${TEST_TERMINATOR}
    Should Contain    ${Conn_SSID_IW_log}    ${WIFI_TETHER_SSID}

#Use for WIFI Concurrent Mode Test
Disable the Ethernet Connection
    SerialLibrary.Write Data    connmanctl disable ethernet${\n}
    Sleep    2
    ${eth_off_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${eth_off_log}
    Should Contain    ${eth_off_log}   Disable ethernet
    SerialLibrary.Write Data    ifconfig ${ETH_INF}${\n}
    Sleep    1
    ${eth_off_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${eth_off_log}

#Use for WIFI Concurrent Mode Test
Enable the Ethernet Connection
    SerialLibrary.Write Data    connmanctl enable ethernet${\n}
    Sleep    2
    ${eth_off_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${eth_off_log}
    Should Contain    ${eth_off_log}   Enabled ethernet
    SerialLibrary.Write Data    ifconfig ${ETH_INF}${\n}
    Sleep    1
    ${eth_off_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${eth_off_log}

Disable the Wifi Connection
    SerialLibrary.Write Data    connmanctl disable wifi${\n}
    Sleep    2
    ${eth_off_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${eth_off_log}
    Should Contain    ${eth_off_log}   Disable wifi
    SerialLibrary.Write Data    ifconfig ${ETH_INF}${\n}
    Sleep    1
    ${eth_off_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${eth_off_log}

#Use for WIFI Concurrent Mode Test
Enable the wifi Connection
    @{wifi_enable_phrases}=    Create List    Enabled wifi     wifi is already enabled  
    SerialLibrary.Write Data    connmanctl enable wifi${\n}
    Sleep    2
    ${eth_off_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${eth_off_log}
    Should Contain Any    ${eth_off_log}   @{wifi_enable_phrases}
    SerialLibrary.Write Data    ifconfig ${ETH_INF}${\n}
    Sleep    1
    ${eth_off_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${eth_off_log}

*** Settings ***
Library        Collections
Resource       ../Resources/Common_Params.robot
Library        ../Libraries/EnvVariablesReturnLib.py
Library        String


*** Variables ***
#${WIFI_SSID}            TECHNEXION-RDTEST-5G
${WIFI_SSID}            TECHNEXION-RDTEST
${WIFI_PASSPHRASE}      82273585

${WIFI_TETHER_SSID}     ROBOT_SIT_AP
${WIFI_TETHER_PWD}      12345678
${WIFI_TETHER_SERVIP}   192.168.0.1

${TEST_TERMINATOR}=     root@flex-imx8mm:~#


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
    Should Contain    ${connamm_conf_log}    State = ready
    SerialLibrary.Write Data    exit${\n}
    Sleep    1
    Wifi Link Signal Check

    
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
    SerialLibrary.Write Data     iw dev wlan0 link${\n}
    Sleep    1
    ${wifisig_log}=    SerialLibrary.Read All Data     UTF-8
    Should Contain    ${wifisig_log}    signal:
    Log    Wifi Signal info: ${wifisig_log}
    Sleep    1

Wifi Tether Mode Activate
    SerialLibrary.Write Data     connmanctl tether wifi on ${WIFI_TETHER_SSID} ${WIFI_TETHER_PWD}${\n}
    Sleep    5
    ${wifitether_log}=    SerialLibrary.Read All Data     UTF-8
    Should Contain    ${wifitether_log}    entered forwarding state
    Log    Wifi tether on info: ${wifitether_log}
    Sleep    1

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
    Sleep   10
    SSHLibrary.Write    ${WIFI_TETHER_PWD}
    SSHLibrary.Write    state
    ${connamm_conf_log}=    SSHLibrary.Read Until   connmanctl>
    Log    ${connamm_conf_log}
    
    SSHLibrary.Write        exit
    ${connmanexit_log}=    SSHLibrary.Read Until   ${TEST_TERMINATOR}
    Log     ${connmanexit_log}
    Sleep   3

    SSHLibrary.Write        dmesg | tail -3
    ${dmesg_connect_event}=         SSHLibrary.Read Until   ${TEST_TERMINATOR}
    Should Contain          ${dmesg_connect_event}     wlan0: link becomes ready
    Sleep    1

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


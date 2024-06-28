*** Settings ***
Library        Collections
Resource       ../Resources/Common_Params.robot
Library        ../Libraries/EnvVariablesReturnLib.py
Library        String


*** Variables ***
${WIFI_SSID}            TECHNEXION-RDTEST-5G
${WIFI_PASSPHRASE}      82273585

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
    
Wifi Link Signal Check
    SerialLibrary.Write Data     iw dev wlan0 link${\n}
    Sleep    1
    ${wifisig_log}=    SerialLibrary.Read All Data     UTF-8
    Should Contain    ${wifisig_log}    signal:
    Log    Wifi Signal info: ${wifisig_log}
    Sleep    1
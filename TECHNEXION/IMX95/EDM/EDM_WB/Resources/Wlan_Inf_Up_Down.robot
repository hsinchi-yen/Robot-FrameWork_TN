*** Settings ***
Resource          ../Resources/Common_Params.robot

*** Variables ***
${WLAN_UP EVENT}        link becomes ready

*** Keywords ***
WIFI Init State Check
    SerialLibrary.Write Data    ifconfig ${WIFI_INF}${\n}
    Sleep    1
    ${wifi_if_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${wifi_if_log}

WIFI Interface Down Test
    SerialLibrary.Write Data    ifconfig ${WIFI_INF} down${\n}
    Sleep    60
    SerialLibrary.Write Data    ifconfig ${WIFI_INF}${\n}
    Sleep    1
    ${wifi_if_log}=    SerialLibrary.Read All Data    UTF-8
    Run Keyword And Continue On Failure    Should Not Contain    ${wifi_if_log}    inet
    Log    ${wifi_if_log}

WIFI Interface Up Test
    SerialLibrary.Write Data    ifconfig ${WIFI_INF} up${\n}
    Sleep    3
    SerialLibrary.Write Data    connmanctl scan wifi${\n}
    Sleep    30
    SerialLibrary.Write Data     ifconfig ${WIFI_INF}${\n}
    Sleep    1
    ${wifi_if_log}=    SerialLibrary.Read All Data    UTF-8
    #Run Keyword And Continue On Failure    Should Contain    ${wifi_if_log}    ${WLAN_UP EVENT} 
    Run Keyword And Continue On Failure    Should Contain    ${wifi_if_log}    inet
    Log    ${wifi_if_log}    console=yes
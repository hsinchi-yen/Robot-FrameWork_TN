*** Settings ***
Resource        ../Resources/Common_Params.robot

*** Variables ***
#${ETH_INF}          eth0
#${WIFI_INF}         wlan0
${BT_INF}           hci0

*** Keywords ***
LAN1 Ethernet MAC Check
   SerialLibrary.Write Data    ifconfig ${ETH1_INF}${\n}
   Sleep    1
   ${ethinf_log}=    SerialLibrary.Read All Data     UTF-8
   #Log To Console    ${ethinf_log}
   ${eth_mac}=    Get Regexp Matches    ${ethinf_log}    \\w{2}:\\w{2}:\\w{2}:\\w{2}:\\w{2}:\\w{2}
   Log        ${eth_mac}
   Should Not Be Empty    ${eth_mac}
   Log     ${ethinf_log}
   RETURN    ${eth_mac}
LAN2 Ethernet MAC Check
   SerialLibrary.Write Data    ifconfig ${ETH2_INF}${\n}
   Sleep    1
   ${ethinf_log}=    SerialLibrary.Read All Data     UTF-8
   #Log To Console    ${ethinf_log}
   ${eth_mac}=    Get Regexp Matches    ${ethinf_log}    \\w{2}:\\w{2}:\\w{2}:\\w{2}:\\w{2}:\\w{2}
   Log        ${eth_mac}
   Should Not Be Empty    ${eth_mac}
   Log     ${ethinf_log}
   RETURN    ${eth_mac}
WIFI MAC Check
   SerialLibrary.Write Data    ifconfig ${WIFI_INF}${\n}
   Sleep    1
   ${wifiinf_log}=    SerialLibrary.Read All Data     UTF-8
   #Log To Console    ${wifiinf_log}
   ${wifi_mac}=    Get Regexp Matches    ${wifiinf_log}    \\w{2}:\\w{2}:\\w{2}:\\w{2}:\\w{2}:\\w{2}
   Log     ${wifiinf_log}
   RETURN    ${wifi_mac}

BT MAC Check
   SerialLibrary.Write Data    hciconfig ${BT_INF} -a${\n}
   Sleep    1
   ${btinf_log}=    SerialLibrary.Read All Data     UTF-8
   #Log To Console    ${wifiinf_log}
   ${bt_mac}=    Get Regexp Matches    ${btinf_log}    BD Address:\\s\\w{2}:\\w{2}:\\w{2}:\\w{2}:\\w{2}:\\w{2}
   Log     ${btinf_log}
   RETURN    ${bt_mac}
*** Settings ***
Resource        ../Resources/Common_Params.robot


*** Variables ***
${SUSPEND_WORD}        Suspending console(s)
${WAKEUP_WORD}         PM: suspend exit
${PINGFAIL_WORD}       Network is unreachable
${IP_GATEWAY}          10.88.88.1
${PING_TIME}           3
#${ETH_INF}             eth0

*** Keywords ***
Set Resume DUT from Console And Set DUT to Sleep
   SerialLibrary.Write Data    echo enabled >/sys/class/tty/$(awk '{print $1}' </proc/consoles)/power/wakeup${\n}
   Sleep    1
   SerialLibrary.Write Data    echo mem >/sys/power/state${\n}
   Sleep    2
   ${suspend_msg}=    SerialLibrary.Read All Data    UTF-8
   #Run Keyword And Continue On Failure    Should Contain    ${suspend_msg}    ${SUSPEND_WORD}
   Log    ${suspend_msg}
   Sleep    10

LAN1 Get DUT MAC
    SerialLibrary.Write Data    ifconfig ${ETH1_INF} | grep ether | awk -F ' ' '{print $2}'${\n}
    Sleep    1
    ${list_mac_log}=    SerialLibrary.Read All Data    UTF-8
    ${match_macid}=    Get Regexp Matches    ${list_mac_log}    \\w{2}:\\w{2}:\\w{2}:\\w{2}:\\w{2}:\\w{2}
    ${return_macid}=    Convert To String    @{match_macid}
    Log    ${return_macid} 
    RETURN     ${return_macid} 

LAN1 Set Wake On Lan and Set DUT to Sleep
    SerialLibrary.Write Data    ethtool -s ${ETH1_INF} wol g${\n}
    Sleep    1
    SerialLibrary.Write Data    echo mem >/sys/power/state${\n}
    Sleep    2
    ${suspend_msg}=    SerialLibrary.Read All Data    UTF-8
    Run Keyword And Continue On Failure    Should Contain    ${suspend_msg}    ${SUSPEND_WORD}
    Log    ${suspend_msg}
    Sleep    10



Wake Up DUT from Sleep
    #send wake key \n
    SerialLibrary.Write Data    ${\n}
    Sleep    0.2
    SerialLibrary.Write Data    ${\n}
    Sleep    3
    ${wakenup_msg}=    SerialLibrary.Read All Data    UTF-8
    #Run Keyword And Continue On Failure    Should Contain    ${wakenup_msg}    ${WAKEUP_WORD}
    Log    ${wakenup_msg}

LAN1 Wake Up DUT via Ethernet Magic Packet
    #send magic Packet
    [Arguments]    ${dut_mac}
    Send Magic Packet    ${CONSOLE_ETH_INF}    ${dut_mac}
    Sleep    3
    ${wakenup_msg}=    SerialLibrary.Read All Data    UTF-8
    Run Keyword And Continue On Failure    Should Contain    ${wakenup_msg}    ${WAKEUP_WORD}
    Log    ${wakenup_msg}


LAN1 Down Workaround
    #Solve the know issue after wake on lan    
    SerialLibrary.Write Data    ifconfig ${ETH1_INF} down${\n}
    Sleep    1
    SerialLibrary.Write Data    ifconfig ${ETH1_INF} up${\n}
    Sleep    3
    ${workaround_record}=    Seriallibrary.Read All Data    UTF-8
    Log    ${workaround_record}

LAN1 Ethernet Interface Check
    SerialLibrary.Write Data    ping -I ${ETH1_INF} ${IP_GATEWAY} -c ${PING_TIME} ${\n}
    ${ping_msg}=    SerialLibrary.Read Until    ${TERMINATOR}
    Run Keyword And Continue On Failure    Should Not Contain    ${ping_msg}    ${PINGFAIL_WORD}
    Log    ${ping_msg}     console=yes   




Wifi Interface Check
    SerialLibrary.Write Data    ping -I ${WIFI_INF} ${IP_GATEWAY} -c ${PING_TIME} ${\n}
    ${ping_msg}=    SerialLibrary.Read Until    ${TERMINATOR}
    Run Keyword And Continue On Failure    Should Not Contain    ${ping_msg}    ${PINGFAIL_WORD}
    Log    ${ping_msg}    console=yes
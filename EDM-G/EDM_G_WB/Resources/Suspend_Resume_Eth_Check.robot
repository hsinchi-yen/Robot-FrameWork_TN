*** Settings ***
Resource        ../Resources/Common_Params.robot

*** Variables ***
${SUSPEND_WORD}        Suspending console(s)
${WAKEUP_WORD}         PM: suspend exit
${PINGFAIL_WORD}       Network is unreachable
${IP_GATEWAY}          10.88.88.1
${PING_TIME}           3
${ETH_INF}             eth0

*** Keywords ***
Set Resume DUT from Console And Set DUT to Sleep
   SerialLibrary.Write Data    echo enabled >/sys/class/tty/$(awk '{print $1}' </proc/consoles)/power/wakeup${\n}
   Sleep    1
   SerialLibrary.Write Data    echo mem >/sys/power/state${\n}
   Sleep    2
   ${suspend_msg}=    SerialLibrary.Read All Data    UTF-8
   Run Keyword And Continue On Failure    Should Contain    ${suspend_msg}    ${SUSPEND_WORD}
   Log    ${suspend_msg}
   Sleep    10

Set Wake On Lan and Set DUT to Sleep
    SerialLibrary.Write Data    ethtool -s ${ETH_INF} wol g${\n}
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
    ${wakenup_msg}=    SerialLibrary.Read Until    ${TERMINATOR}
    Run Keyword And Continue On Failure    Should Contain    ${wakenup_msg}    ${WAKEUP_WORD}
    Log    ${wakenup_msg}

Ethernet Interface Check
    SerialLibrary.Write Data    ping -I ${ETH_INF} ${IP_GATEWAY} -c ${PING_TIME} ${\n}
    ${ping_msg}=    SerialLibrary.Read Until    ${TERMINATOR}
    Run Keyword And Continue On Failure    Should Not Contain    ${ping_msg}    ${PINGFAIL_WORD}
    Log    ${ping_msg}

Wifi Interface Check
    SerialLibrary.Write Data    ping -I ${WIFI_INF} ${IP_GATEWAY} -c ${PING_TIME} ${\n}
    ${ping_msg}=    SerialLibrary.Read Until    ${TERMINATOR}
    Run Keyword And Continue On Failure    Should Not Contain    ${ping_msg}    ${PINGFAIL_WORD}
    Log    ${ping_msg}
=========================================================================
 Copyright 2024 Technexion Ltd.
 Test Case No      : TNPT PWM Test
 Purpose           : This test robot is used to test PWM function in TEP1-IMX7
 Category          : Functional Test  
 Script name       : LTE_Modem_Test.robot
 Author            : Lance
 Date created      : 20240909
=========================================================================

*** Settings ***
Resource          ../Resources/Common_Params.robot
Library        Collections


*** Variables ***
${SIMCARD_CHECK_CMD}              /usr/lib/ofono/test/list-modems
${SIM_ALIVE_STRING}               Present = 1
${WWW_DNS}                        www.google.com

${DL_SERVER_IP}                   10.88.88.229    
#http://10.88.88.229/Utilities/
${OOKLA_SPEEDTESTER_ARM32}       ookla-speedtest-1.1.1-linux-armhf.tgz

${OOKLA_UTILITY}                 ./speedtest

#modem list command
${MODEMS_LIST}                   /usr/lib/ofono/test/list-modems
${APNCONFIGSET}                  /usr/lib/ofono/test/create-internet-context internet
${APNCONFIGCHK}                  /usr/lib/ofono/test/list-contexts
${PREFIX_ENABLE_MODEM}           /usr/lib/ofono/test/online-modem

${MODEMACTIVATION}               /usr/lib/ofono/test/activate-context
${LTE_INF}                       wwan0


*** Keywords *** 
SIM Card Check
    SerialLibrary.Write Data    ${SIMCARD_CHECK_CMD}${\n}
    ${sim_chk_log}=    SerialLibrary.Read Until    ${TERMINATOR}
    Log    ${sim_chk_log}
    Should Contain    ${sim_chk_log}    ${SIM_ALIVE_STRING}

LTE Modem Connect Test
    ${lte_node}=    Get Modem node
    Log    ${lte_node}
    SerialLibrary.Write Data    ${APNCONFIGSET}${\n}
    Sleep    1
    SerialLibrary.Write Data    ${APNCONFIGCHK}${\n}
    ${lte_testlog}=    SerialLibrary.Read Until    ${TERMINATOR}
    Log    ${lte_testlog}
    Sleep    1
    SerialLibrary.Write Data    ${PREFIX_ENABLE_MODEM} ${lte_node}${\n}
    Sleep    2
    ${lte_testlog}=    SerialLibrary.Read All Data    UTF-8
    Log    ${lte_testlog}
    Run Keyword And Continue On Failure    Should Contain    ${lte_testlog}    Setting modem ${lte_node} online...

    SerialLibrary.Write Data    ${MODEMACTIVATION}${\n}
    Sleep    1
    ${lte_testlog}=    SerialLibrary.Read All Data    UTF-8
    Log    ${lte_testlog}

    SerialLibrary.Write Data    ifconfig ${LTE_INF}${\n}
    Sleep    1
    ${lte_testlog}=    SerialLibrary.Read All Data    UTF-8
    Log     ${lte_testlog}
    Run Keyword And Continue On Failure    Should Match Regexp   ${lte_testlog}    inet\ \\w+.\\w+.\\w+.\\w+

LET Ping Test
    SerialLibrary.Write Data    ping -I ${LTE_INF} -c 3 ${WWW_DNS}${\n}
    ${lte_pinglog}=    SerialLibrary.Read Until    ${TERMINATOR}
    Log    ${lte_pinglog}
    Should Contain    ${lte_pinglog}    0% packet loss


Get Modem node
    SerialLibrary.Write Data    ${SIMCARD_CHECK_CMD}${\n}
    ${sim_chk_log}=    SerialLibrary.Read Until    ${TERMINATOR}
    Log    ${sim_chk_log}
    ${device_node}=    Get Regexp Matches    ${sim_chk_log}    /\\w+_\\d{1}
    Log    ${device_node}
    ${r_device_node}=    Convert To String    @{device_node}
    RETURN    ${r_device_node}

LTE Modem Speed Test
    SerialLibrary.Write Data    ifconfig -a | grep -E "${ETH_INF}|wlan" -A 2${\n}
    Sleep    1
    ${chklog}=    SerialLibrary.Read All Data    UTF-8
    Log    ${chklog}

    ${conn_stat}=    Run Keyword And Return Status    Should Match Regexp    ${chklog}    inet\ \\w+.\\w+.\\w+.\\w+

    IF    ${conn_stat} == $True
        Load Speedtest Utility
        Run Modem Test   
    ELSE    
        Log    Internal LAN Connection is ${conn_stat}
        Fail
    END

Load Speedtest Utility
    SerialLibrary.Write Data    wget -O http://${DL_SERVER_IP}/Utilities/ARM32/${OOKLA_SPEEDTESTER_ARM32}${\n}
    ${modemspeed_log}=    SerialLibrary.Read Until    ${TERMINATOR}
    Log    ${modemspeed_log}
    SerialLibrary.Write Data    tar -zxvf ${OOKLA_SPEEDTESTER_ARM32}${\n}
    ${modemspeed_log}=    SerialLibrary.Read Until    ${TERMINATOR}
    Log    ${modemspeed_log}

Run Modem Test
    SerialLibrary.Write Data    ${OOKLA_UTILITY} -p no${\n}
    Sleep    1
    SerialLibrary.Write Data    Yes${\n}
    ${ookla_log}=    SerialLibrary.Read Until    ${TERMINATOR}
    Log    ${ookla_log}
    

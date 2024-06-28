*** Settings ***
Library        Collections
Resource       ../Resources/Common_Params.robot
Library        ../Libraries/EnvVariablesReturnLib.py

*** Variables ***
#${DEST_IPv4}        10.88.88.144
#${DEST_IPv6}        fe80::d9d7:d988:8a5f:5ec4
${PING_TIME}        5
${ERR_MESSAGE}      Network is unreachable
${ERR_MESSAGE_2}    100% packet loss

*** Keywords ***
IPv4 Ping Test
    #obtain IP address in console machine via self-build library EnvVariablesReturnLib.py
    ${DEST_IPv4}=    Ip4_Addr_Finder    ${CONSOLE_ETH_INF}
    SerialLibrary.Write Data    ping -c ${PING_TIME} ${DEST_IPv4}${\n}
    ${Ipv4_pinglog}=    SerialLibrary.Read Until     ${TERMINATOR}   
    Log    ${Ipv4_pinglog}
    Should Not Contain     ${Ipv4_pinglog}    ${ERR_MESSAGE}
    Check Ping Count    ${PING_TIME}    ${Ipv4_pinglog}


IPv6 Ping Test
    #obtain IP address in console machine via self-build library EnvVariablesReturnLib.py
    ${DEST_IPv6}=    Ip6 Addr Finder     ${CONSOLE_ETH_INF}
    SerialLibrary.Write Data    ping -6 -c ${PING_TIME} ${DEST_IPv6}%${ETH_INF}${\n}
    ${Ipv6_pinglog}=    SerialLibrary.Read Until     ${TERMINATOR}   
    Log    ${DEST_IPv6}
    Should Not Contain     ${Ipv6_pinglog}    ${ERR_MESSAGE_2}
    Check Ping Count    ${PING_TIME}    ${Ipv6_pinglog}


Check Ping Count
    [Arguments]    ${test_count}    ${Log_data}
    @{lines}=    Split To Lines    ${Log_data}
    ${ping_statistic}=    Get From List    ${lines}    -3
    Log    ${ping_statistic}
    Should Match Regexp    ${ping_statistic}    ${PING_TIME} packets transmitted, ${PING_TIME} received, 0% packet loss, time \\d+ms



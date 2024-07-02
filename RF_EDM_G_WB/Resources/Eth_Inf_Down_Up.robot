*** Settings ***
Library        Collections
Resource          ../Resources/Common_Params.robot
Library        ../Libraries/EnvVariablesReturnLib.py

*** Variables ***
${Link_up_event}    link becomes ready
${PING_TIME}        5
${ERR_MESSAGE}      Network is unreachable

*** Keywords ***
ETH Interface DOWN Test
    #command line for set interface down
    SerialLibrary.Write Data    ifconfig ${ETH_INF} down${\n}
    Sleep    1
    SerialLibrary.Write Data    ifconfig ${ETH_INF}${\n}
    Sleep    1
    ${ethlog}=    SerialLibrary.Read All Data    UTF-8   
    Log    ${ethlog}
    Should Not Contain    ${ethlog}    inet
    Ping Test After ETH down


ETH Interface UP Test
    #command linf for set interface up
    SerialLibrary.Write Data    ifconfig ${ETH_INF} up${\n}
    ${ethlog}=    SerialLibrary.Read Until    ${Link_up_event}
    Log    ${ethlog}
    Sleep    5
    SerialLibrary.Write Data    ifconfig ${ETH_INF} | grep -E "inet "${\n}
    ${ethlog}=    SerialLibrary.Read Until     ${TERMINATOR}   

    Log    ${ethlog}
    Should Contain    ${ethlog}    inet
    Ping Test After ETH up

Ping Test After ETH down
    ${DEST_IPv4}=    Ip4_Addr_Finder    ${CONSOLE_ETH_INF}
    SerialLibrary.Write Data    ping -I ${ETH_INF} -c ${PING_TIME} ${DEST_IPv4}${\n}
    ${Ipv4_pinglog}=    SerialLibrary.Read Until     ${TERMINATOR}   
    Log    ${Ipv4_pinglog}
    Should Contain     ${Ipv4_pinglog}    ${ERR_MESSAGE}
    
Ping Test After ETH up
    #obtain IP address in console machine via self-build library EnvVariablesReturnLib.py
    ${DEST_IPv4}=    Ip4_Addr_Finder    ${CONSOLE_ETH_INF}
    SerialLibrary.Write Data    ping -I ${ETH_INF} -c ${PING_TIME} ${DEST_IPv4}${\n}
    ${Ipv4_pinglog}=    SerialLibrary.Read Until     ${TERMINATOR}   
    Log    ${Ipv4_pinglog}
    Should Not Contain     ${Ipv4_pinglog}    ${ERR_MESSAGE}
    Check Ping Count    ${PING_TIME}    ${Ipv4_pinglog}
*** Settings ***
Library        Collections
Resource          ../Resources/Common_Params.robot
Library        ../Libraries/EnvVariablesReturnLib.py

*** Variables ***
${Link_up_event}    link becomes ready
${PING_TIME}        5
${ERR_MESSAGE}      Network is unreachable

*** Keywords ***

#LAN1_Eth1
LAN1 Interface DOWN Test
    #command line for set interface down
    SerialLibrary.Write Data    ifconfig ${ETH1_INF} down${\n}
    Sleep    1
    SerialLibrary.Write Data    ifconfig ${ETH1_INF}${\n}
    Sleep    1
    ${ethlog}=    SerialLibrary.Read All Data    UTF-8   
    Log    ${ethlog}
    Should Not Contain    ${ethlog}    inet
    Ping Test After LAN1 down


LAN1 Interface UP Test
    #command linf for set interface up
    SerialLibrary.Write Data    ifconfig ${ETH1_INF} up${\n}
    ${ethlog}=    SerialLibrary.Read Until    ${Link_up_event}
    Log    ${ethlog}
    Sleep    20
    SerialLibrary.Write Data    ifconfig ${ETH1_INF} | grep -E "inet "${\n}
    ${ethlog}=    SerialLibrary.Read Until     ${TERMINATOR}   
    Log    ${ethlog}
    Should Contain    ${ethlog}    inet
    Ping Test After LAN1 up

Ping Test After LAN1 down
    ${DEST_IPv4}=    Ip4_Addr_Finder    ${CONSOLE_ETH_INF}
    SerialLibrary.Write Data    ping -I ${ETH1_INF} -c ${PING_TIME} ${DEST_IPv4}${\n}
    ${Ipv4_pinglog}=    SerialLibrary.Read Until     ${TERMINATOR}   
    Log    ${Ipv4_pinglog}
    Should Contain     ${Ipv4_pinglog}    ${ERR_MESSAGE}
    
Ping Test After LAN1 up
    #obtain IP address in console machine via self-build library EnvVariablesReturnLib.py
    ${DEST_IPv4}=    Ip4_Addr_Finder    ${CONSOLE_ETH_INF}
    SerialLibrary.Write Data    ping -I ${ETH1_INF} -c ${PING_TIME} ${DEST_IPv4}${\n}
    ${Ipv4_pinglog}=    SerialLibrary.Read Until     ${TERMINATOR}   
    Log    ${Ipv4_pinglog}
    Should Not Contain     ${Ipv4_pinglog}    ${ERR_MESSAGE}
    LAN1 Check Ping Count    ${PING_TIME}    ${Ipv4_pinglog}



#LAN2_Eth0
LAN2 Interface DOWN Test
    #command line for set interface down
    SerialLibrary.Write Data    ifconfig ${ETH2_INF} down${\n}
    Sleep    1
    SerialLibrary.Write Data    ifconfig ${ETH2_INF}${\n}
    Sleep    1
    ${ethlog}=    SerialLibrary.Read All Data    UTF-8   
    Log    ${ethlog}
    Should Not Contain    ${ethlog}    inet
    Ping Test After LAN2 down


LAN2 Interface UP Test
    #command linf for set interface up
    SerialLibrary.Write Data    ifconfig ${ETH2_INF} up${\n}
    ${ethlog}=    SerialLibrary.Read Until    ${Link_up_event}
    Log    ${ethlog}
    Sleep    20
    SerialLibrary.Write Data    ifconfig ${ETH2_INF} | grep -E "inet "${\n}
    ${ethlog}=    SerialLibrary.Read Until     ${TERMINATOR}   
    Log    ${ethlog}
    Should Contain    ${ethlog}    inet
    Ping Test After LAN2 up

Ping Test After LAN2 down
    ${DEST_IPv4}=    Ip4_Addr_Finder    ${CONSOLE_ETH_INF}
    SerialLibrary.Write Data    ping -I ${ETH2_INF} -c ${PING_TIME} ${DEST_IPv4}${\n}
    ${Ipv4_pinglog}=    SerialLibrary.Read Until     ${TERMINATOR}   
    Log    ${Ipv4_pinglog}
    Should Contain     ${Ipv4_pinglog}    ${ERR_MESSAGE}
    
Ping Test After LAN2 up
    #obtain IP address in console machine via self-build library EnvVariablesReturnLib.py
    ${DEST_IPv4}=    Ip4_Addr_Finder    ${CONSOLE_ETH_INF}
    SerialLibrary.Write Data    ping -I ${ETH2_INF} -c ${PING_TIME} ${DEST_IPv4}${\n}
    ${Ipv4_pinglog}=    SerialLibrary.Read Until     ${TERMINATOR}   
    Log    ${Ipv4_pinglog}
    Should Not Contain     ${Ipv4_pinglog}    ${ERR_MESSAGE}
    LAN2 Check Ping Count    ${PING_TIME}    ${Ipv4_pinglog}
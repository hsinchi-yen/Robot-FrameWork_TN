*** Settings ***
Resource        ../Resources/common_variables.robot

*** Variables ***
${Link_up_event}    link becomes ready

*** Keywords ***
ETH Interface DOWN Test
    #command line for set interface down
    SerialLibrary.Write Data    ifconfig ${ETH_INF} down${\n}
    Sleep    5
    SerialLibrary.Write Data    ifconfig ${ETH_INF}${\n}
    Sleep    1
    ${ethlog}=    SerialLibrary.Read Until     ${TERMINATOR}   
    Log    ${ethlog}
    Should Not Contain    ${ethlog}    inet


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

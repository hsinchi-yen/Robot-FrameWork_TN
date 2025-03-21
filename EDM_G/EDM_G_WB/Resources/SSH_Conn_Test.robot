*** Comments ***
=========================================================================
 Copyright 2024 Technexion Ltd.
 DUT               : Applicable for all platform
 Purpose           : SSH connection test 
 Script name       : SSH_Conn_Test.robot
 Author            : lancey 
 Date created      : 2025007
=========================================================================
*** Settings ***
Library        Collections
Resource          ../Resources/Common_Params.robot
Library        ../Libraries/EnvVariablesReturnLib.py

*** Variables ***
#
${DUT_USERID}    root


*** Keywords ***
SSH connection test
    #obtain IP address in console machine via self-build library EnvVariablesReturnLib.py
    ${TESTPC_IPv4}=    Ip4_Addr_Finder    ${CONSOLE_ETH_INF}
    ${DUT_IP}=    Get DUT IP Address
    #Run Process    ssh-keygen -f "/home/lance/.ssh/known_hosts" -R ${DUT_IP}

    SSHLibrary.Open Connection     ${DUT_IP}
    SSHLibrary.Login               ${PWR_USERID}     
    
    SSHLibrary.Start Command    who
    ${read_shhoutput}=     SSHLibrary.Read Command Output
    Log      ${read_shhoutput}
    Run Keyword And Continue On Failure    Should Contain    ${read_shhoutput}    ${TESTPC_IPv4}
    Sleep    1
    #SSHLibrary.Close Connection

Get DUT IP Address
    SerialLibrary.Write Data    ifconfig ${ETH_INF} | grep "inet "${\n}
    Sleep    1
    ${ifchk_log}=    SerialLibrary.Read All Data    UTF-8
    #Log    ${ifchk_log}    
    ${eth_ip_match}=       Get Regexp Matches    ${ifchk_log}     inet 10\.\\d+\.\\d+\.\\d+
    ${eth_ip_string}=      Strip String    @{eth_ip_match}    characters=inet${SPACE}
    Log    ${eth_ip_string}
    RETURN    ${eth_ip_string}

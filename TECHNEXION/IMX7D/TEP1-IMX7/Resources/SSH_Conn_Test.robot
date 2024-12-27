=========================================================================
 Copyright 2024 Technexion Ltd.
 Test Case No      : TNPT 218 SSH Connection 
 Purpose           : This test robot is used to test SSH connection of the DUT
 Category          : Functional Test  
 Script name       : SSH_Conn_Test.robot
 Author            : Lance
 Date created      : 20240830
=========================================================================

*** Settings ***
Resource          ../Resources/Common_Params.robot
Library        Collections


*** Variables ***
${DUT_LOGIN_ACC}      root
${DUT_NET_DEV}        wlan0


*** Keywords *** 
Get DUT Ip Address
    [Arguments]    ${NET_DEV}
    SerialLibrary.Write Data    ifconfig ${NET_DEV} | grep "inet " | awk -F " " '{print $2}'${\n}
    Sleep    1
    ${dut_chk_log}=        SerialLibrary.Read All Data    UTF-8
    Log    ${dut_chk_log}
    ${dut_ip_match}=       Get Regexp Matches    ${dut_chk_log}    10\.\\d+\.\\d+\.\\d+
    ${dut_ip_string}=      Convert To String    @{dut_ip_match}    
    RETURN   ${dut_ip_string}

SSH Connection Test
    ${dut_ip_addr}=    Get DUT Ip Address    ${DUT_NET_DEV}
    #Log    ${dut_ip_addr}

    SSHLibrary.Open Connection     ${dut_ip_addr}        timeout=30s
    SSHLibrary.Login               ${DUT_LOGIN_ACC}
    Sleep    2
    ${SSH_State_log}=       SSHLibrary.EXecute Command    echo $SSH_CONNECTION
    Log    ${SSH_State_log}
    Should Contain    ${SSH_State_log}    ${dut_ip_addr}${SPACE}22



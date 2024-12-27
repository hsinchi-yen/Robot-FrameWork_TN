=========================================================================
 Copyright 2024 Technexion Ltd.
 Test Case No      : TNPT-6 SOM and Baseboard Information check
 Purpose           : This test robot only applied for TEP-IMX7D 
 Category          : Functional Test  
 Script name       : SystemInfo_Check_Test.robot
 Author            : Lance
 Date created      : 20240910
=========================================================================

*** Settings ***
Resource          ../Resources/Common_Params.robot

*** Variables ***
#modified for imx7d-tep1
${SYSINFO_SCRIPT}       SysInfo_test.sh
${DL_SERVER_IP}         10.88.88.229

*** Keywords *** 
System Info Check Test
    Download SystemInfo Script
    SerialLibrary.Write Data    bash ${SYSINFO_SCRIPT}${\n}
    ${sysinfo_log}=    SerialLibrary.Read Until    ${TERMINATOR}
    Log    ${sysinfo_log}
    Board Info Verify    ${sysinfo_log}


Download SystemInfo Script
    SerialLibrary.Write Data    ifconfig -a | grep -E "${ETH_INF}|wlan" -A 2${\n}
    Sleep    1
    ${chklog}=    SerialLibrary.Read All Data    UTF-8
    Log    ${chklog}

    ${conn_stat}=    Run Keyword And Return Status    Should Match Regexp    ${chklog}    inet\ \\w+.\\w+.\\w+.\\w+

    IF    ${conn_stat} == $True
          SerialLibrary.Write Data    wget -O ${SYSINFO_SCRIPT} http://${DL_SERVER_IP}/test_scripts/${SYSINFO_SCRIPT}${\n}
          ${dl_log}=    SerialLibrary.Read Until    ${TERMINATOR}
          Log    ${dl_log}   
    ELSE    
        Log    Internal LAN/WLAN Connection is ${conn_stat}
        Fail
    END

Board Info Verify
    [Arguments]    ${boardinfo_log}
    Run Keyword And Continue On Failure  Should Contain    ${boardinfo_log}    TechNexion TEP1-IMX7D rev A2 board

        

=========================================================================
 Copyright 2024 Technexion Ltd.
 Test Case No      : TNPT-851 Bluetooth BLE Throughput 1M PHY 
 Category          : Functional Test  
 Script name       : BLE_throughput_test.robot
 Author            : Raymond
 Date created      : 20241210
=========================================================================

*** Settings ***
Library    String
Resource          ../Resources/Common_Params.robot



*** Variables ***

${BLE_SCRIPT_1}       tn_ble_test_logger.sh
${BLE_SCRIPT_2}       p_show_test_result.sh
${DL_SERVER_IP}         10.88.88.229
${BLE_SIM_MAC}    F8:6F:46:FD:44:84

*** Keywords *** 
BLE throughput Test
    Download BLE Scripts
    SerialLibrary.Write Data    bash ${BLE_SCRIPT_1} testlog 20 ${\n}
    Sleep    1
    SerialLibrary.Write Data    ${BLE_SIM_MAC}${\n}
    Sleep    1
    Read SerialConsole and output
   
Read SerialConsole and output
    WHILE    True
        ${line}=    SerialLibrary.Read Until    ${\n}
        Log     ${line}    console=yes
        IF    'Filename: /tmp/testlog_prescan.log' in '''${line}'''    BREAK
    END
Download BLE Scripts
    SerialLibrary.Write Data    ifconfig -a | grep -E "eth|mlan|wlan" -A 2${\n}
    Sleep    1
    ${chklog}=    SerialLibrary.Read All Data    UTF-8
    Log    ${chklog}

    ${conn_stat}=    Run Keyword And Return Status    Should Match Regexp    ${chklog}    inet\ \\w+.\\w+.\\w+.\\w+

    IF    ${conn_stat} == $True
          Log To Console    \n
          SerialLibrary.Write Data    ${\n}
          SerialLibrary.Write Data    wget -O ${BLE_SCRIPT_1} http://${DL_SERVER_IP}/RF_TestScripts/${BLE_SCRIPT_1}${\n}
          Sleep    1
          SerialLibrary.Write Data    wget -O ${BLE_SCRIPT_2} http://${DL_SERVER_IP}/RF_TestScripts/${BLE_SCRIPT_2}${\n}
          Sleep    1

          ${dl_log}=    SerialLibrary.Read Until    ${TERMINATOR}
          Log    ${dl_log} 
    ELSE    
        Log    Internal LAN/WLAN Connection is ${conn_stat}
        Fail
    END


        

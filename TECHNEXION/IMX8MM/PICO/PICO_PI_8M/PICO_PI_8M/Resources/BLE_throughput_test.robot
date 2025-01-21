=========================================================================
 Copyright 2024 Technexion Ltd.
 Test Case No      : TNPT-851 Bluetooth BLE Throughput 1M PHY 
 Category          : Functional Test  
 Script name       : BLE_throughput_test.robot
 Author            : Raymond,Lance 
 Date created      : 20241210
=========================================================================
Revised date : 20250114 
modified for fitting two wifi chip iw416 / qca9377, optimized test time
=========================================================================

*** Settings ***
Library    String
Resource          ../Resources/Common_Params.robot


*** Variables ***

${BLE_SCRIPT_1}       rf_ble_test_logger.sh
${BLE_SCRIPT_2}       rf_show_test_result.sh
${DL_SERVER_IP}       10.88.88.229
#Use you own BLE Simulator
${BLE_SIM_MAC}        D0:28:3F:B0:44:4F
${BLE_TERMINATOR}     BLE Test Done!.

${IW_RATE_BAR}        80
${QCA_RATE_BAR}       25

*** Keywords *** 
BLE throughput Test
    Download BLE Scripts
    SerialLibrary.Write Data    bash -x ${BLE_SCRIPT_1} ${BLE_SIM_MAC} testlog 1${\n}
    ${ble_test_log}=    SerialLibrary.Read Until    ${BLE_TERMINATOR}   
    Log    ${ble_test_log}
    Should Contain    ${ble_test_log}    ${BLE_TERMINATOR}
#   SerialLibrary.Write Data    ${BLE_SIM_MAC}${\n}
#   Sleep    1
#   Read SerialConsole and output
    BLE Result Verification    ${ble_test_log}

   
#Read SerialConsole and output
#    WHILE    True
#        ${line}=    SerialLibrary.Read Until    ${\n}
#        Log     ${line}    console=yes
#        IF    'Filename: /tmp/testlog_prescan.log' in '''${line}'''    BREAK
#    END

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

BLE Result Verification
    [Arguments]    ${test_log}
    @{lines}=           Split To Lines    ${test_log}
    ${ble_result}=      Get From List    ${lines}    -4
    ${wifi_inf}=        Get From List    ${lines}    -1

    ${ble_result}=        Get Regexp Matches    ${ble_result}           \\d+.\\d+
    ${wifi_inf}=          Get Regexp Matches    ${wifi_inf}             NetDEV:\\[\wlan0\\]

    ${ble_result}=        Convert To String    ${ble_result[0]}
    ${wifi_inf}=          Convert To String    ${wifi_inf[0]}    

    #Log Many    ${ble_result}    ${wifi_inf}
    #Log To Console   ${wifi_inf}
    Run Keyword If  "${wifi_inf}" == "NetDEV:[mlan0]"      Show IW Result        ${ble_result}
    Run Keyword If  "${wifi_inf}" == "NetDEV:[wlan0]"      Show QCA9377 Result   ${ble_result}

Show IW Result
    [Arguments]    ${test_result}
    Log    ${test_result}
    ${test_result}=    Convert To Number    ${test_result}
    Should Be True    ${test_result} >= ${IW_RATE_BAR} 

Show QCA9377 Result
    [Arguments]    ${test_result}
    Log    ${test_result}
    ${test_result}=    Convert To Number    ${test_result}
    Should Be True    ${test_result} >= ${QCA_RATE_BAR}

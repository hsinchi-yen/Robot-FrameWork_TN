=========================================================================
 Copyright 2024 Technexion Ltd.
 Test Case No      : TNPT-147 CAN BUS transmission 
 Purpose           : This test robot only applied for TEP-IMX7D with two canbus ports
 Category          : Functional Test  
 Script name       : Canbus_Test.robot
 Author            : Lance
 Date created      : 20240828
=========================================================================

*** Settings ***
Resource          ../Resources/Common_Params.robot

*** Variables ***
#modified for imx7d-tep1
${CAN_DEV_A}      can0
${CAN_DEV_B}      can1

#Can bus test pattern for sedning
${Classic_CAN_Test_Pattern}        123#DEADBEEF
${CAN_FD_Test_Pattern}             213##311223344

#Verify pattern
${C_Can_Verified_Pattern}          123\ \ \ [4]\ \ DE AD BE EF

*** Keywords *** 
Check Can Devices
    SerialLibrary.Write Data    ifconfig -a | grep can${\n}
    Sleep    1
    ${candump_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${candump_log}
    ${found_can_a}=    Run Keyword And Return Status    Should Contain    ${candump_log}    ${CAN_DEV_A}
    ${found_can_b}=    Run Keyword And Return Status    Should Contain    ${candump_log}    ${CAN_DEV_B}

    IF    ${found_can_a} == $True and ${found_can_b} == $True
            RETURN    $True
    ELSE    
            RETURN    $False
    END

Set Can Interface Up
    [Arguments]    ${CAN_DEV}
    SerialLibrary.Write Data    /sbin/ip link set ${CAN_DEV} type can bitrate 125000${\n}
    Sleep    1
    SerialLibrary.Write Data    ifconfig ${CAN_DEV} up${\n}
    Sleep    1
    ${can_set_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${can_set_log}

Classic Can TX Test
    SerialLibrary.Write Data    candump ${CAN_DEV_B}&${\n}
    Sleep    1
    SerialLibrary.Write Data    cansend ${CAN_DEV_A} ${Classic_CAN_Test_Pattern}&${\n}
    Sleep    1
    ${can_send_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${can_send_log}
    Run Keyword And Continue On Failure    Should Contain    ${can_send_log}    ${C_Can_Verified_Pattern}
    #clear candump process
    SerialLibrary.Write Data    killall candump${\n}
    Sleep    1
    ${candump_clr_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${candump_clr_log}
    
Classic Can RX Test
    SerialLibrary.Write Data    candump ${CAN_DEV_A}&${\n}
    Sleep    1
    SerialLibrary.Write Data    cansend ${CAN_DEV_B} ${Classic_CAN_Test_Pattern}&${\n}
    Sleep    1
    ${can_send_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${can_send_log}
    Run Keyword And Continue On Failure    Should Contain    ${can_send_log}    ${C_Can_Verified_Pattern}
    #clear candump process
    SerialLibrary.Write Data    killall candump${\n}
    Sleep    1
    ${candump_clr_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${candump_clr_log}
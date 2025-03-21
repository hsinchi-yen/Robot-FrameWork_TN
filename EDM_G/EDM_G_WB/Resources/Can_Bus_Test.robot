=========================================================================
 Copyright 2025 Technexion Ltd.
 Test Case No      : Case TNPT-174
 Category          : Function 
 Script name       : Can_Bus_Test.robot
 Author            : Lance
 Date created      : 20250212
=========================================================================

*** Settings ***
Library         String
Library         DateTime
Library         Collections
Resource        ../Resources/Common_Params.robot


*** Variables ***
${CAN_DEV_1}=    can0
${CAN_DEV_2}=    can1

#Can Bus Pattern _ send for test
@{CAN_TEST_PATTERN}=      5A1#11.2233.44556677.88
...    123#DEADBEEF
...    5AA#
...    1F334455#1122334455667788_B
...    123#R
...    00000123#R3
...    333#R8_E

#Receive for verification
@{CAN_VERIFY_PATTERN}=    5A1${SPACE*3}\[8\]${SPACE*2}11 22 33 44 55 66 77 88
...    123${SPACE*3}\[4\]${SPACE*2}DE AD BE EF
...    5AA${SPACE*3}\[0\]
...    1F334455${SPACE*3}\[8\]${SPACE*2}11 22 33 44 55 66 77 88
...    123${SPACE*3}\[0\]${SPACE*2}remote request
...    00000123${SPACE*3}\[3\]${SPACE*2}remote request
...    333${SPACE*3}\[8\]${SPACE*2}remote request

*** Keywords ***
Check CAN Nodes
    SerialLibrary.Write Data    ifconfig -a | grep can${\n}
    Sleep    1
    ${can_chk_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${can_chk_log}
    ${candev1_state}=    Run Keyword And Return Status    Should Contain    ${can_chk_log}    ${CAN_DEV_1}
    ${candev2_state}=    Run Keyword And Return Status    Should Contain    ${can_chk_log}    ${CAN_DEV_2}
    RETURN    ${candev1_state}    ${candev2_state}
    
Set Two Canbus Up
    SerialLibrary.Write Data    ip link set ${CAN_DEV_1} up type can bitrate 125000${\n}
    Sleep    0.5
    SerialLibrary.Write Data    ip link set ${CAN_DEV_2} up type can bitrate 125000${\n}
    Sleep    0.5
    SerialLibrary.Write Data    ifconfig -a | grep can -A 7${\n}
    Sleep    2
    ${can_inf_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${can_inf_log}

Set Single Canbus Up
    SerialLibrary.Write Data    ip link set ${CAN_DEV_1} up type can bitrate 125000 loopback on${\n}
    Sleep    0.5
    SerialLibrary.Write Data    ifconfig -a | grep can -A 7${\n}
    Sleep    2
    ${can_inf_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${can_inf_log}

Two Way Canbus Pattern Test
    SerialLibrary.Write Data    candump ${CAN_DEV_1}&${\n}

    FOR    ${tst_pattern}    ${verify_pattern}    IN ZIP    ${CAN_TEST_PATTERN}    ${CAN_VERIFY_PATTERN}
        SerialLibrary.Write Data    cansend ${CAN_DEV_2} ${tst_pattern}${\n}
        Sleep    1
        ${can_test_log}=    SerialLibrary.Read All Data    UTF-8
        Log    ${can_test_log}    console=$True
        Run Keyword And Continue On Failure    Should Contain    ${can_test_log}    ${verify_pattern}
        Sleep    1
    END

    #clear candump running in background
    SerialLibrary.Write Data     killall candump${\n}
    

One Way Canbus Pattern Test
    SerialLibrary.Write Data    candump ${CAN_DEV_1}&${\n}
    FOR    ${tst_pattern}    ${verify_pattern}    IN ZIP    ${CAN_TEST_PATTERN}    ${CAN_VERIFY_PATTERN}
        SerialLibrary.Write Data    cansend ${CAN_DEV_1} ${tst_pattern}${\n}
        Sleep    1
        ${can_test_log}=    SerialLibrary.Read All Data    UTF-8
        Log    ${can_test_log}    console=$True
        Run Keyword And Continue On Failure    Should Contain    ${can_test_log}    ${verify_pattern}
        Sleep    1
    END
    #clear candump running in background
    SerialLibrary.Write Data     killall candump${\n}


Classic Canbus Test
    ${candev1_state}    ${candev2_state}    Check CAN Nodes

    IF    ${candev1_state} == ${True} and ${candev2_state} == ${True}
        Log To Console    Test Wire-Loopback CAN
        Set Two Canbus Up
        Two Way Canbus Pattern Test
    ELSE
        #Temporary test method, idealy use the external test board for validation
        Log To Console    Test with self-loopback CAN
        Set Single Canbus Up
        One Way Canbus Pattern Test
    END

    


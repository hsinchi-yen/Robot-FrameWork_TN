=========================================================================
 Copyright 2024 Technexion Ltd.
 Test Case No      : Case TNPT-215
 Category          : Stress Test  
 Script name       : Full_Device_Power_ON_OFF_Test.robot
 Author            : Raymond 
 Date created      : 20240723
=========================================================================
*** Settings ***
Library        Collections
Library        Process
Resource          ../Resources/Common_Params.robot


*** Variables ***
${touch_msg}    Touch Screen

*** Keywords ***
Detection Touch device
    
    SerialLibrary.Write Data    evtest&${\n}
    Sleep    1
    
    ${result}=    SerialLibrary.Read Until     Select the device  
    Log    ${result}    console=yes
    Should Contain     ${result}    ${touch_msg}
    SerialLibrary.Write Data    ${\n}
    Sleep    1
    ${result}=    SerialLibrary.Read Until    ${TERMINATOR}
Full device Power ON OFF Test 10 times
    ${LOOP_COUNT}=    Set Variable    2
    FOR    ${counter}    IN RANGE    1    ${LOOP_COUNT}  
        Log To Console  \n================Test Count:${counter}================\n
        
        Log    Test Count:${counter}
        Log To Console    \n System POWER OFF ......\n
        Device OFF
        Sleep    3
        Device ON
        Log To Console    \n System POWER ON ......\n
        Booting time record and wait for login
        Sleep    10
        
        #Reboot Check touch device -->Network-->Audio-->USB-->Camera(AR-0234)-->GPU
        Log To Console    \n #Checking i2C touch\n
        Detection Touch device
        Sleep    2
        Log To Console    \n #Checking Network\n
        WIFI Detect 
        Sleep    2
        Log To Console    Check LAN1 ${ETH1_INF}....
        LAN1 IPv4 Ping Test
        Sleep    5
        Log To Console    \n #Checking Audio device\n
        ${cardid_1st}    ${_}=    Sound Card ID Checker
        Log To Console    ${cardid_1st}
        Sleep    3 
        Log To Console    \n #Checking USB devices\n
        Check USB Devices
        Sleep    3 
        # Log To Console    \n #Checking Camera\n
        # Camera-TEVS-AR0234  
        Log To Console    \n #Checking GPU\n
        GLMark2 Test    20
        Sleep    5
    END
    Log To Console  \nTest Count:${counter} completed

  
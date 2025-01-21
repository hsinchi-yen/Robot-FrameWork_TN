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


*** Keywords ***



Full device Power ON OFF Test 10 times
    ${LOOP_COUNT}=    Set Variable    21
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
        
        #Reboot Check Network-->Audio-->USB-->Camera(AR-0234)-->GPU
        Log To Console    \n #Checking Network\n
        WIFI Detect 
        Sleep    2
        Log To Console    Check LAN1 ${ETH1_INF}....
        LAN1 IPv4 Ping Test
        Sleep    5 
        Log To Console    Check LAN2 ${ETH2_INF}....
        LAN2 IPv4 Ping Test
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

  
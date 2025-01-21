=========================================================================
 Copyright 2024 Technexion Ltd.
 Test Case No      : Case TNPT-216
 Category          : Stress Test  
 Script name       : Suspend_Resume_Eth_Check.robot
 Author            : Raymond 
 Date created      : 20240723
=========================================================================
*** Settings ***
Library        Collections
Library        Process
Resource          ../Resources/Common_Params.robot


*** Variables ***



*** Keywords ***



Full device Suspend Wake Up Test 10 times
    ${LOOP_COUNT}=    Set Variable    11
    FOR    ${counter}    IN RANGE    1    ${LOOP_COUNT}  
        Log To Console   Test Count:${counter}
        Log    Test Count:${counter}
        Set Resume DUT from Console And Set DUT to Sleep
        Log To Console    Suspend System
        Wake Up DUT from Sleep
        Log To Console    Resume from System 
        Sleep    10
        
        #Reboot Check Network-->Audio-->USB-->Camera(AR-0234)-->GPU
        Log To Console    \n #Checking Network\n
        WIFI Detect 
        Sleep    3 
        IPv4 Ping Test
        Sleep    5 
    
        Log To Console    \n #Checking Audio device\n
        ${cardid_1st}=    Sound Card ID Checker
        Log To Console     Audio Device:${cardid_1st}
        Sleep    3 
        Log To Console    \n #Checking USB devices\n
        Check USB Devices
        Sleep    3 
        Log To Console    \n #Checking Camera\n
        Camera-TEVS-AR0234  
        Log To Console    \n #Checking GPU\n
        GLMark2 Test    20
        Sleep    1
    END
    Log To Console  \nTest Count:${counter} completed

  
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
    ${LOOP_COUNT}=    Set Variable    11
    FOR    ${counter}    IN RANGE    1    ${LOOP_COUNT}  
        Log    Test Count:${LOOP_COUNT}
        Power Cycle And Relogin
        Sleep    10
        #Reboot Check USB-->Network-->Camera(AR-0234)
        Check USB Devices
        Sleep    3 
        HDMI+LVDS
        Sleep    3
        #Camera-TEVS-AR0234   
        GLMark2 Test    20
        Sleep    1
    END
    Log To Console  \nTest Count:${counter} completed

  
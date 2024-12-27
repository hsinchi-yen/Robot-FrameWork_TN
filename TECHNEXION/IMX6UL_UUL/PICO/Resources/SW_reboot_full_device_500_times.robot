=========================================================================
 Copyright 2024 Technexion Ltd.
 Test Case No      : Case TNPT-208
 Category          : Stress Test  
 Script name       : SW_reboot_full_device_500_times.robot
 Author            : Raymond 
 Date created      : 20240719
=========================================================================
*** Settings ***
Library        Collections
Library        Process
Library        BuiltIn
Library        random
Resource          ../Resources/Common_Params.robot



*** Variables ***

*** Keywords ***

Reboot full device 500 times
    ${LOOP_COUNT}=    Set Variable    11
    FOR    ${counter}    IN RANGE    1    ${LOOP_COUNT}  
        Log    Test Count:${LOOP_COUNT}
        Send Reboot command then Check Reboot State And Relogin     
        # Sleep    10
        #Reboot Check USB-->Network-->Camera(AR-0234)
        Check USB Devices
        Sleep    3 
        IPv4 Ping Test
        Sleep    3
        #Camera-TEVS-AR0234  
        #GLMark2 Test    20
        Sleep    1
    END
    Log To Console  \nTest Count:${counter} completed

  
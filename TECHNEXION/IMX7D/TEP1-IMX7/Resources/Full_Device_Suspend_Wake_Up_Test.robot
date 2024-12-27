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
        Log    Test Count:${LOOP_COUNT}
        Set Resume DUT from Console And Set DUT to Sleep
        Wake Up DUT from Sleep
        Sleep    5
    END
    Log To Console  \nTest Count:${counter} completed

  
=========================================================================
 Copyright 2024 Technexion Ltd.
 Test Case No      : Case TNPT-185
 Category          : Stress Test  
 Script name       : WLAN_Interface_Up_Down_Stress.robot
 Author            : Raymond 
 Date created      : 20240920
=========================================================================
*** Settings ***
Library        Collections
Resource          ../Resources/Common_Params.robot
Resource          ../Resources/Eth_Inf_Down_Up.robot
Library           ../Libraries/EnvVariablesReturnLib.py

*** Variables ***



*** Keywords ***
  
WLAN Interface UP DOWN 500 times
    ${LOOP_COUNT}=    Set Variable    501
    FOR    ${counter}    IN RANGE    1    ${LOOP_COUNT}  
        Log    Test Count:${counter}
        Log To Console    \nTest Count:${counter}
        WIFI Init State Check
        WIFI Interface Down Test
        WIFI Interface Up Test
    END
    Log To Console  \nTest Count:${counter} completed
   
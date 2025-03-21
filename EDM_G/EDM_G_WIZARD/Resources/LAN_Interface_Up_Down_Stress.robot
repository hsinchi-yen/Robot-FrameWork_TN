=========================================================================
 Copyright 2024 Technexion Ltd.
 Test Case No      : Case TNPT-196
 Category          : Stress Test  
 Script name       : LAN_Interface_Up_Down_Stress.robot
 Author            : Raymond 
 Date created      : 20240715
=========================================================================
*** Settings ***
Library        Collections
Resource          ../Resources/Common_Params.robot
Resource          ../Resources/Eth_Inf_Down_Up.robot
Library           ../Libraries/EnvVariablesReturnLib.py

*** Variables ***
#most of variables are defined in Common_Params.robot
#loop count
${STREE_LOOP}    501

*** Keywords ***
LAN Interface UP DOWN 500 times
    FOR    ${counter}    IN RANGE    1    ${STREE_LOOP}
        Log    Test Count:${STREE_LOOP}
        ETH Interface DOWN Test
        ETH Interface UP Test
        Sleep    5
    END
    Log To Console  \nTest Count:${counter} completed

  
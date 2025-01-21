=========================================================================
 Copyright 2024 Technexion Ltd.
 Test Case No      : Case TNPT-216_enhanced_check
 Category          : Stress Test  
 Script name       : Suspend_Resume_Eth_Check.robot
 Author            : Raymond 
 Date created      : 20241230
=========================================================================
*** Settings ***
Library        Collections
Library        Process
Resource          ../Resources/Common_Params.robot


*** Variables ***



*** Keywords ***



Full device Suspend Wake Up Test 
    ${LOOP_COUNT}=    Set Variable    11
    FOR    ${counter}    IN RANGE    1    ${LOOP_COUNT}  
        Log To Console  \n================Test Count:${counter}================\n
        Log    Test Count:${counter}
        Log To Console    Suspend System
        Set Resume DUT from Console And Set DUT to Sleep
        
        Wake Up DUT from Sleep
        Log To Console    Resume from System 
        Sleep    10
        
        Log To Console    \n######## Checking Touch Device ########\n
        Run Keyword And Continue On Failure    Touch Dedect 
        Sleep    3

        Log To Console    \n######## Checking Network ########\n
        Run Keyword And Continue On Failure    Full_Device_Power_ON_OFF_Test_rev2.WIFI Detect 
        Sleep    3
        Run Keyword And Continue On Failure    LAN1 Detect
        Sleep    3 
        # Run Keyword And Continue On Failure    LAN2 Detect
        # Sleep    3 
        Log To Console    \n######## Checking USB devices ########\n
        Run Keyword And Continue On Failure    Check USB Devices
        Sleep    3 
        
        Log To Console    \n######## Checking Audio device ########\n
        Run Keyword And Continue On Failure    Audio Detect
        Sleep    3 
        Log To Console    \n######## Checking Camera device ########\n
        Run Keyword And Continue On Failure    Camera Detect
        Sleep    3 
        

    END  
    IF    ${Touch_FAILURE_COUNT} > 0
        Log To Console    \n=========================
        Log To Console    Touch Final Result: FAIL
        Log    PASS COUNT: ${Touch_SUCCESS_COUNT}    console=yes
        Log    FAIL COUNT: ${Touch_FAILURE_COUNT}    console=yes
        Log To Console    =========================  
        
        
    ELSE
        Log To Console    \n=========================
        Log To Console    Touch Final Result: PASS 
        Log    PASS COUNT: ${Touch_SUCCESS_COUNT}    console=yes
        Log    FAIL COUNT: ${TOuch_FAILURE_COUNT}    console=yes
        Log To Console    =========================
    END    
    IF    ${WIFI_FAILURE_COUNT} > 0
        Log To Console    \n=========================
        Log To Console    WIFI Final Result: FAIL
        Log    PASS COUNT: ${WIFI_SUCCESS_COUNT}    console=yes
        Log    FAIL COUNT: ${WIFI_FAILURE_COUNT}    console=yes
        Log To Console    =========================  
        
        
    ELSE
        Log To Console    \n=========================
        Log To Console    WIFI Final Result: PASS 
        Log    PASS COUNT: ${WIFI_SUCCESS_COUNT}    console=yes
        Log    FAIL COUNT: ${WIFI_FAILURE_COUNT}    console=yes
        Log To Console    =========================
    END  
    IF    ${LAN1_FAILURE_COUNT} > 0
        Log To Console    \n=========================
        Log To Console    LAN1 Final Result: FAIL
        Log    PASS COUNT: ${LAN1_SUCCESS_COUNT}    console=yes
        Log    FAIL COUNT: ${LAN1_FAILURE_COUNT}    console=yes
        Log To Console    =========================  
        
        
    ELSE
        Log To Console    \n=========================
        Log To Console    LAN1 Final Result: PASS 
        Log    PASS COUNT: ${LAN1_SUCCESS_COUNT}    console=yes
        Log    FAIL COUNT: ${LAN1_FAILURE_COUNT}    console=yes
        Log To Console    =========================
    END
    # IF    ${LAN2_FAILURE_COUNT} > 0
    #     Log To Console    \n=========================
    #     Log To Console    LAN2 Final Result: FAIL
    #     Log    PASS COUNT: ${LAN2_SUCCESS_COUNT}    console=yes
    #     Log    FAIL COUNT: ${LAN2_FAILURE_COUNT}    console=yes
    #     Log To Console    =========================  
        
        
    # ELSE
    #     Log To Console    \n=========================
    #     Log To Console    LAN2 Final Result: PASS 
    #     Log    PASS COUNT: ${LAN2_SUCCESS_COUNT}    console=yes
    #     Log    FAIL COUNT: ${LAN2_FAILURE_COUNT}    console=yes
    #     Log To Console    =========================
    # END
    IF    ${USB_FAILURE_COUNT} > 0
        Log To Console    \n=========================
        Log To Console    USB Final Result: FAIL
        Log    PASS COUNT: ${USB_SUCCESS_COUNT}    console=yes
        Log    FAIL COUNT: ${USB_FAILURE_COUNT}    console=yes
        Log To Console    =========================  
        
        
    ELSE
        Log To Console    \n=========================
        Log To Console    USB Final Result: PASS 
        Log    PASS COUNT: ${USB_SUCCESS_COUNT}    console=yes
        Log    FAIL COUNT: ${USB_FAILURE_COUNT}    console=yes
        Log To Console    =========================
    END

    IF    ${AUDIO_FAILURE_COUNT} > 0
        Log To Console    \n=========================
        Log To Console    Audio Final Result: FAIL
        Log    PASS COUNT: ${AUDIO_SUCCESS_COUNT}    console=yes
        Log    FAIL COUNT: ${AUDIO_FAILURE_COUNT}    console=yes
        Log To Console    =========================  
        
        
    ELSE
        Log To Console    \n=========================
        Log To Console    Audio Final Result: PASS 
        Log    PASS COUNT: ${AUDIO_SUCCESS_COUNT}    console=yes
        Log    FAIL COUNT: ${AUDIO_FAILURE_COUNT}    console=yes
        Log To Console    =========================
    END

    IF    ${Camera_FAILURE_COUNT} > 0
        Log To Console    \n=========================
        Log To Console    Camera Final Result: FAIL
        Log    PASS COUNT: ${Camera_SUCCESS_COUNT}    console=yes
        Log    FAIL COUNT: ${Camera_FAILURE_COUNT}    console=yes
        Log To Console    =========================  
        
        
    ELSE
        Log To Console    \n=========================
        Log To Console    Camera Final Result: PASS 
        Log    PASS COUNT: ${Camera_SUCCESS_COUNT}    console=yes
        Log    FAIL COUNT: ${Camera_FAILURE_COUNT}    console=yes
        Log To Console    =========================
    END

  
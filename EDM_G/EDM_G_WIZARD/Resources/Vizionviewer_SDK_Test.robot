=========================================================================
 Copyright 2025 Technexion Ltd.
 Test Case No      : TNPT-689 Vizionviewer SDK Test
 Category          : Software fuction - preinstall packages  
 Script name       : Vizionviewer_SDK_Test.robot
 Author            : Lance
 Date created      : 20250320
=========================================================================

*** Settings ***
Library           String
Library           Collections
Resource          ../Resources/Common_Params.robot


*** Variables ***
#Most variable are referred from Common_Params.robot
${VV_SDK_CMD}        vizionviewer
${VV_CTRL}           vizion-ctl
@{VV_FILES}    TechNexion VizionSDK    TechNexion VizionSDK - Development files    TechNexion VizionViewer

*** Keywords *** 
Check VizionViewer SDK packages
    SerialLibrary.Write Data    dpkg -l | grep vizio${\n}
    Sleep    1
    ${vv_sdk_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${vv_sdk_log}
    FOR    ${element}    IN    @{VV_FILES}
            Run Keyword And Continue On Failure    Should Contain    ${vv_sdk_log}    ${element}
    END

    VizionViewer Launch Test
    VizionCtl Test

VizionViewer Launch Test
    SerialLibrary.Write Data    ${VV_SDK_CMD}${\n}
    Sleep    5
    SerialLibrary.Write Data    ${CTRL_C}
    ${vv_run_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${vv_run_log}
    Should Contain    ${vv_run_log}    \[VzLog\]
    Sleep    3

VizionCtl Test
    SerialLibrary.Write Data    ${VV_CTRL}${\n}
    Sleep    3
    ${vzc_run_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${vzc_run_log}
    Should Contain    ${vzc_run_log}    display logs.
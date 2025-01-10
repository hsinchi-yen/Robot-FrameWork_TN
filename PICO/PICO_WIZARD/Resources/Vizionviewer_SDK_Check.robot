*** Comments ***
=========================================================================
 Copyright 2024 Technexion Ltd.
 DUT               : Applicable for all platform
 Purpose           : Vizionviewer_SDK_Check pre-install check 
 Script name       : Vizionviewer_SDK_Check.robot
 Author            : lancey 
 Date created      : 2025007
=========================================================================
*** Settings ***
Library        Collections
Resource          ../Resources/Common_Params.robot

*** Variables ***
#
${VV_PKG}    packagegroup-tn-vizionsdk
${VV_SDK}    vizionsdk
${VV_DEV}    vizionsdk-dev
${VV_APP}    vizionviewer


*** Keywords ***
Vizionviewer packages Checker
    SerialLibrary.Write Data    dpkg -l | grep vizio${\n}
    Sleep    2
    ${vv_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${vv_log}

    Run Keyword And Continue On Failure    Should Contain    ${vv_log}    ${VV_PKG}
    Run Keyword And Continue On Failure    Should Contain    ${vv_log}    ${VV_SDK}
    Run Keyword And Continue On Failure    Should Contain    ${vv_log}    ${VV_DEV}
    Run Keyword And Continue On Failure    Should Contain    ${vv_log}    ${VV_APP} 


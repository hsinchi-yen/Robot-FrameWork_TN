*** Comments ***
=========================================================================
 Copyright 2024 Technexion Ltd.
 DUT               : EDM_G_8MP _ EDM_G_WB
 Purpose           : Regresson Test for Essential Functionality 
 Script name       : EDM-G-8MP_with_EDM-G_WIZARD_Others.robot
 Author            : lancey 
 Date created      : 20240603
=========================================================================
*** Settings ***
Library           Collections
Library           String
Library           Process

#include resource
Resource          ../Resources/Common_Params.robot

Suite Setup       Run Keywords     Open Serial Port 
...    AND     SSH Open Connection And Log In  

Suite Teardown    Run Keywords    Close Serial Port       AND     
...    SSH Close All Connections 

*** Variables ***
#${SERIAL_PORT}      /dev/ttyS0
#${TERMINATOR}       root@edm-g-imx8mp:~#

*** Keywords ***
##

*** Test Cases ***
AUDIO ISSUE
    [Tags]              Test A-System and Function    
    [Documentation]     AUDIO ISSUE Investigation
    
    Audio Issue with Reboot
WIFI ISSUE
    [Tags]              Test A-System and Function    
    [Documentation]     Intermittent error with WLAN
    System reboot And WLAN device detection


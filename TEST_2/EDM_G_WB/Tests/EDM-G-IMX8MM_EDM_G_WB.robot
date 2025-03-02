*** Comments ***
=========================================================================
 Copyright 2024 Technexion Ltd.
 DUT               : PICO_IMX8MM _ PICO_PI8M
 Purpose           : Regresson Test for Essential Functionality 
 Script name       : PICO-IMX8MM_with_PICO_PI8M.robot
 Author            : lancey 
 Date created      : 20241231
=========================================================================
*** Settings ***
Library           Collections
Library           String
Library           Process

#include resource
Resource          ../Resources/Common_Params.robot

Suite Setup       Run Keywords     Open Serial Port 
#...    AND     SSH Open Connection And Log In  

Suite Teardown    Run Keywords    Close Serial Port        
#...    AND     SSH Close All Connections 

*** Variables ***
#${SERIAL_PORT}      /dev/ttyS0
#${TERMINATOR}       root@edm-g-imx8mp:~#

*** Keywords ***


*** Test Cases ***
Case TNPT-26
    #RobotFile: Console_Check.robot
    [Tags]              Test A-System and Function    
    [Documentation]     UART console check
    Check Console State Dmesg
    Check Console ID in virtual filesystem directory 

Case TNPT-22
    [Tags]              eMMC Flash Tool Test
    [Documentation]     dd command - Linux
    SerialLibrary.Close Port
    Perform Flash Image Process with dd
    SerialLibrary.Open Port
    
Case TNPT-131
    [Tags]              eMMC Flash Tool Test
    [Documentation]     bmaptool - Linux
    SerialLibrary.Close Port
    Perform Flash Image Process with Bmaptool
    SerialLibrary.Open Port
           



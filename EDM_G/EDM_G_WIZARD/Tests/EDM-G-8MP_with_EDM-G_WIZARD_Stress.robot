*** Comments ***
=========================================================================
 Copyright 2024 Technexion Ltd.
 DUT               : EDM_G_8MP _ EDM_G_WIZARD
 Purpose           : Strss Test for Essential Core Functionality
 Script name       : EDM-G-8MP_with_EDM-G_WIZARD_Stress.robot
 Author            : lancey 
 Date created      : 20240218
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
#refer to Common_Params.robot
#${SERIAL_PORT}      /dev/ttyS0
#${TERMINATOR}       root@edm-g-imx8mp:~#

*** Keywords ***
#refer to Common_Params.robot

*** Test Cases ***  
Case TNPT-222
    #Refer to IO_operation_on_multi_core_Stress_NG.robot
    [Tags]              Test A-System and Function    stress
    [Documentation]     StressNG for 12hrs 
    StressNG Test  

Case TNPT-176
    #Refer to GPU_Test.robot
    [Tags]              Test A-System and Function    stress
    [Documentation]     GPU Test Glmark2 for 12hrs 
    GLMark2 Test

Case TNPT-196
    [Tags]              Test A-System and Function    stress
    [Documentation]     LAN Interface up / down stress test 
    LAN Interface UP DOWN 500 times
Case TNPT-204
    [Tags]              Test A-System and Function    stress
    [Documentation]     USB device detect stress test 
    Power ON_OFF And USB detection Test 

Case TNPT-177 
    [Tags]              Test A-System and Function    stress  
    [Documentation]     WIFI Stress 12H
    Start WIFI stress

Case TNPT-167 
    [Tags]              Test A-System and Function    stress  
    [Documentation]     CPU_MEM_GPU_WIFI_Stresss
    Start CPU MEM GPU WIFI stress

Case TNPT-215
    [Tags]              Enhanced rate calculate    stress
    [Documentation]     Full_Device_Power_ON_OFF_Test (rev2)
    Full device ON OFF 
Case TNPT-208
    [Tags]              Enhanced rate calculate    stress
    [Documentation]     SW reboot stress with full device test  (rev2)
    Full device reboot
Case TNPT-216
    [Tags]              Enhanced rate calculate    stress
    [Documentation]     Full_device Suspend Wake Up Test (rev2)
    Full device Suspend Wake Up Test   

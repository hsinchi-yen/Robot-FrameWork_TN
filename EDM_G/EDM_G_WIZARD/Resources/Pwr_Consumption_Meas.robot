=========================================================================
 Copyright 2025 Technexion Ltd.
 Test Case No      : 870 - 874 power consumption test cases
 Category          : External Device - Power supply Operation  
 Script name       : Pwr_Consumption_Meas.robot
 Author            : Lance
 Date created      : 20250320
=========================================================================

*** Settings ***
Library           String
Library           Collections
Resource          ../Resources/Common_Params.robot


*** Variables ***
#Most variable are referred from Common_Params.robot
${PARSE_CPU_RATE}    top -bn1 | grep "Cpu(s)"
${GPU_BURN_CMD}      glmark2-es2-wayland --fullscreen --annotate

*** Keywords *** 
Power Consumption with Idle Mode
    #Get the cpu usage rate
    Repeat Keyword    3    Read CPU Rate
    ${idle_pwr}=    Get Average Power Reading
    Log    Idle power consumption: ${idle_pwr} Watt    console=${DEBUG_LOG}

Power Consumption with Suspend Mode
    Set Resume DUT from Console And Set DUT to Sleep
    ${Suspend_pwr}=    Get Average Power Reading
    Log    Suspend power consumption: ${Suspend_pwr} Watt    console=${DEBUG_LOG}
    Wake Up DUT from Sleep

Power Consumption with GPU running
    #burn the gpu
    SerialLibrary.Write Data    ${GPU_BURN_CMD}${\n}
    Sleep    5
    ${gpu_burn_pwr}=    Get Average Power Reading
    Log    Burn GPU power consumption: ${gpu_burn_pwr} Watt    console=${DEBUG_LOG}
    #force the gpu test to be terminated
    SerialLibrary.Write Data    ${CTRL_C}
    Sleep    2
    ${gpu_end_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${gpu_burn_pwr}

Power Consumption with CPU Load
    SerialLibrary.Write Data     grep processor /proc/cpuinfo | wc -l${\n}
    Sleep    1
    ${data}=    SerialLibrary.Read All Data    UTF-8
    @{lines}=    Split To Lines    ${data}
    ${CPU_Num}=      Get From List    ${lines}    1
    SerialLibrary.Write Data    stress-ng -c ${CPU_Num}${\n}
    Sleep    20
    ${cpu_burn_pwr}=    Get Average Power Reading
    Log    Burn CPU power consumption: ${cpu_burn_pwr} Watt    console=${DEBUG_LOG}
    #force the cpu test to be terminated
    SerialLibrary.Write Data    ${CTRL_C}
    Sleep    2
    ${cpu_burn_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${cpu_burn_log}

Read CPU Rate
    SerialLibrary.Write Data    ${PARSE_CPU_RATE}${\n}
    Sleep    1
    ${cpu_rate_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${cpu_rate_log}
    ${gpu_burn_pwr}=    Get Average Power Reading

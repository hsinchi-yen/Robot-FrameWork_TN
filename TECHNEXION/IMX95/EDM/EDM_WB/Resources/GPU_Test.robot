*** Comments ***
=========================================================================
 Copyright 2024 Technexion Ltd.
 Test Case No      : Case TNPT-176
 Category          : Stress Test  
 Script name       : GPU_Test.robot
 Author            : Raymond 
 Date created      : 20240712
=========================================================================
*** Settings ***
Library        Collections
Library        DateTime
Library        Process
Resource       ../Resources/Common_Params.robot

*** Variables ***
#Unit is seconds
${Glmark2_PID_Name}=   glmark2-es2-way
${default_duration_seconds}=     43200       


*** Keywords ***
Run Glmark2 Command 
    ${start_time}=    Get Time    epoch
    SerialLibrary.Write Data     glmark2-es2-wayland --fullscreen --annotate &${\n}
    Sleep    1
    SerialLibrary.Write Data    ps | awk '/${Glmark2_PID_Name}/ {print $1}'${\n}
    Sleep    1   
    ${pid}=    SerialLibrary.Read All Data    UTF-8
    ${RE_PID}=       Get Regexp Matches    ${pid}            \\[\\d+\]\\s+(\\d+)    1
    ${GLMark2_PID}=    Get From List    ${RE_PID}       0
    Set Global Variable    ${GLMark2_PID}      
    RETURN    ${GLMark2_PID}

Wait For Test Duration And Terminate
    [Arguments]    ${duration}=${default_duration_seconds}
    #${duration_seconds}=    Convert Time    ${Duration}    result_format=number
    Sleep    ${duration}
    Terminate GLMark2 Process

Terminate GLMark2 Process
      
    Log To Console    Terminating GLMark2 process with PID: ${GLMark2_PID}
    SerialLibrary.Write Data    kill ${GLMark2_PID}${\n}
    Sleep    3
    ${output}=    SerialLibrary.Read All Data    UTF-8
    Log    ${output}

GLMark2 Test
    #specify the timing by argument set like "GLMark2 Test 10"
    [Arguments]    ${duration}=${default_duration_seconds} 
    Run Glmark2 Command
    Wait For Test Duration And Terminate    ${duration}
    Log    GLMark2 test completed and terminated after ${duration}
    Log To Console    GLMark2 test completed and terminated after ${duration}
 





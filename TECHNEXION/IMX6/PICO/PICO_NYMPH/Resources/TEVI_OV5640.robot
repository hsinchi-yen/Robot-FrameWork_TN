=========================================================================
 Copyright 2024 Technexion Ltd.
 Test Case No      : Case TNPT-517
 Category          : Camera Test  
 Script name       : TEVI_OV5640.robot
 Author            : Raymond 
 Date created      : 20240813
=========================================================================
*** Settings ***
Library        Collections
Library        Process
Resource          ../Resources/Common_Params.robot



*** Variables ***
${gst_PID_Name}=       gst-launch-1.0


*** Keywords ***

Run GST Command 
    ${start_time}=    Get Time    epoch
    SerialLibrary.Write Data     gst-launch-1.0 v4l2src device=/dev/video0 ! autovideosink &${\n}
    Sleep    1
    # ${log}=    SerialLibrary.Read All Data    UTF-8
    # Should Not Contain    ${log}    stream error
    SerialLibrary.Write Data    ps | awk '/${gst_PID_Name}/ {print $1}'${\n}
    Sleep    1   
    ${pid}=    SerialLibrary.Read All Data    UTF-8
    ${RE_PID}=       Get Regexp Matches    ${pid}            \\[\\d+\]\\s+(\\d+)    1
    ${gst_PID}=    Get From List    ${RE_PID}       0
    Set Global Variable    ${gst_PID}      
    RETURN    ${gst_PID}

Wait For Test Duration And Terminate
    #${duration_seconds}=    Convert Time    ${Duration}    result_format=number
    ${duration_time}=    Set Variable     10
    Log    ${duration_time}
    Sleep    ${duration_time}
    Terminate GST Process

Terminate GST Process
    
    Log To Console    Terminating GST process with PID: ${gst_PID}
    SerialLibrary.Write Data    kill ${gst_PID}${\n}
    Sleep    2
    ${output}=    SerialLibrary.Read All Data    UTF-8
    Log    ${output}

Camera-TEVI_OV5640
    Run GST Command
    Wait For Test Duration And Terminate
    


  
=========================================================================
 Copyright 2025 Technexion Ltd.
 Test Case No      : TNPT-125 VPU Video Decode Test
 Category          : Functional Test  
 Script name       : Video_Decode_Test.robot
 Author            : Raymond
 Date created      : 20250217
=========================================================================

*** Settings ***
Library    String
Resource          ../Resources/Common_Params.robot



*** Variables ***

${Video_Decode_SCRIPT}       VPU_Decode_test.sh
${DL_SERVER_IP}         10.88.88.229
@{Video_Decode_Sample_files}    
...    H264_HD_24FPS    H264_HD_25FPS    H264_FHD_30FPS    H264_FHD_25FPS
...    H265_FHD_30FPS    H265_FHD_24FPS    H265_HD_30FPS
...    VP8_HD_25FPS      VP8_FHD_25FPS 
...    VP9_FHD_59FPS 
*** Keywords *** 



Read SerialConsole and output
    FOR    ${files}    IN    @{Video_Decode_Sample_files}
        ${line}=    SerialLibrary.Read Until    PASS
        Log     ${line}    console=yes
        IF    'FAIL' in '''${line}'''    Fail
        #IF    '${TERMINATOR}' in '''${line}'''    BREAK
    END   
Download Video Decode Script
    SerialLibrary.Write Data    ifconfig -a | grep -E "eth|mlan|wlan" -A 2${\n}
    Sleep    1
    ${chklog}=    SerialLibrary.Read All Data    UTF-8
    Log    ${chklog}

    ${conn_stat}=    Run Keyword And Return Status    Should Match Regexp    ${chklog}    inet\ \\w+.\\w+.\\w+.\\w+

    IF    ${conn_stat} == $True
          SerialLibrary.Write Data    wget -O ${Video_Decode_SCRIPT} http://${DL_SERVER_IP}/RF_TestScripts/${Video_Decode_SCRIPT}${\n}
          Sleep    1

          ${dl_log}=    SerialLibrary.Read Until    ${TERMINATOR}
          Log    ${dl_log} 
    ELSE    
        Log    Internal LAN/WLAN Connection is ${conn_stat}
        Fail
    END


        
Video Decode Test
    Download Video Decode Script
    Log To Console    \nStart playing for each Video sample files... 
    SerialLibrary.Write Data    bash ${Video_Decode_SCRIPT}${\n}
    
    Read SerialConsole and output
=========================================================================
 Copyright 2025 Technexion Ltd.
 Test Case No      : TNPT-126 VPU Video Encode Test
 Category          : Functional Test  
 Script name       : Video_Encode_Test.robot
 Author            : Raymond
 Date created      : 20250217
=========================================================================
Revised date : 20250321
Tweak and optimize the script
-------------------------------------------------------------------------

*** Settings ***
Library    String
Resource          ../Resources/Common_Params.robot

#http://10.88.88.229/Videos/touchdown.yuv
#encode test
#  echo "Test file converting with vpu encoder - ${VPU_ENC}"
#  gst-launch-1.0 -e filesrc location="${SRC_FILE}" ! videoparse format=2 width=1920 height=1080 framerate=30/1 ! "${VPU_ENC}" ! "${VPU_MUXER}" ! filesink location="${dst_file}"
#  converted_stat=$?
#  sync
#  sleep 0.5

*** Variables ***
${Video_Encode_SCRIPT}       VPU_Encode_test.sh
${RAW_FILE4ENC}              touchdown.yuv
${DL_SERVER_IP}              10.88.88.229

${VPU_ENC}                   vpuenc_h264
${VPU_MUXER}                 avimux
${DST_FILE}                  touchdown.avi


*** Keywords ***    
Video Encode Test
    Check RAW File
    #Download Video Decode Script
    Log To Console    \nStart performing Video Encoding...
    #launching vpu coding command 
    SerialLibrary.Write Data    gst-launch-1.0 -e filesrc location="${RAW_FILE4ENC}" ! videoparse format=2 width=1920 height=1080 framerate=30/1 ! ${VPU_ENC} ! ${VPU_MUXER} ! filesink location="${DST_FILE}"${\n}
    ${enc_log}=    SerialLibrary.Read Until    ${TERMINATOR}
    Sleep    1
    Should Contain    ${enc_log}    Execution ended

    SerialLibrary.Write Data    gst-play ${DST_FILE}${\n}
    ${play_log}=     SerialLibrary.Read Until    ${TERMINATOR}
    Log    ${play_log}
 
Check RAW File
    SerialLibrary.Write Data    ls -l${\n}
    Sleep    3
    ${file_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${file_log}
    ${file_ok}=    Run Keyword And Return Status    Should Contain    ${file_log}    ${RAW_FILE4ENC}
    IF    ${file_ok} == ${False}
          Download RAW_FILE4ENC           
    END

Download RAW_FILE4ENC
    ${file_save}=    Set Variable    'touchdown.yuv' saved
    SerialLibrary.Write Data    wget -O ${RAW_FILE4ENC} http://${DL_SERVER_IP}/Videos/${RAW_FILE4ENC}${\n}
    ${file_ok}=    Set Variable    ${False}
    WHILE    ${file_ok} == ${False}
        ${file_load_log}=    SerialLibrary.Read Until       ${file_save}
        ${file_ok}=    Run Keyword And Return Status    Should Contain    ${file_load_log}    ${file_save}
        Sleep    1
    END
    Sleep    5
    SerialLibrary.Write Data    ls -l${\n}
    Sleep    3
    ${file_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${file_log}

#Read SerialConsole and output
#    FOR    ${files}    IN    @{Video_Encode_Sample_files}
#        ${line}=    SerialLibrary.Read Until    PASS
#        Log     ${line}    console=yes
#        IF    'FAIL' in '''${line}'''    Fail
##        #IF    '${TERMINATOR}' in '''${line}'''    BREAK
#   END   

#Download Progress checker
#    ${isDone}=    Set Variable    ${False}
#    WHILE    not ${isDone}
#        ${dl_log}=    SerialLibrary.Read Until    100
#        ${isDone}=    Run Keyword And Return Status    Should Contain    ${dl_log}    100%
#        Log To Console    ${dl_log}
#        Sleep    1
#    END
#    Log    ${dl_log}    console=yes

#Download Video Decode Script
#    SerialLibrary.Write Data    ifconfig -a | grep -E "eth|mlan|wlan" -A 2${\n}
#    Sleep    1
#    ${chklog}=    SerialLibrary.Read All Data    UTF-8
#    Log    ${chklog}

#    ${conn_stat}=    Run Keyword And Return Status    Should Match Regexp    ${chklog}    inet\ \\w+.\\w+.\\w+.\\w+
#
#    IF    ${conn_stat} == $True
#          SerialLibrary.Write Data    wget -O ${Video_Encode_SCRIPT} http://${DL_SERVER_IP}/RF_TestScripts/${Video_Encode_SCRIPT}${\n}
#          Sleep    1

#         ${dl_log}=    SerialLibrary.Read Until    ${TERMINATOR}
#          Log    ${dl_log} 
#          #Download Progress checker
#    ELSE    
#        Log    Internal LAN/WLAN Connection is ${conn_stat}
#        Fail
#    END
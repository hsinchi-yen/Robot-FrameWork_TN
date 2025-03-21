=========================================================================
 Copyright 2025 Technexion Ltd.
 Test Case No      : TNPT-67, 419, 423, 70
 Category          : Display 
 Script name       : Display_test.robot
 Author            : Lance
 Date created      : 20250312
=========================================================================
Test purpose:
- Perform glmark2-es2-wayland benchmark test
- To verify the HDMI display function
- To verify the HDMI EDID content
- To verify the current resolution for display include hdmi, lvds, mipi and ttl
- To verify the color bar test for display include hdmi, lvds, mipi and ttl
-------------------------------------------------------------------------

*** Settings ***
Library        Collections
Resource       ../Resources/Common_Params.robot

*** Variables ***
#most of the variables are defined in Common_Params.robot
${GPU_TEST_CMD}      glmark2-es2-wayland --fullscreen --annotate

${HDMI_KEY_KEYWODR}    DesignWare HDMI
@{EDID CONTAINER}      Identifier    
...    ModelName    
...    VendorName


# dictionary (dict) for color bar test   
&{COLOR_BAR}    red=fb-test -r
...    green=fb-test -g    
...    blue=fb-test -b  
...    white=fb-test -w  
...    black=cat /dev/zero > /dev/fb0
...    Fullcolor=fb-test 

#Download Server IP for vpu test
${DL_SERVER_IP}         10.88.88.229
${TEST_CLIP_FILE}       big_buck_bunny_1080p_H264_AAC_25fps_7200K.mp4

*** Keywords ***
3D Glmark Benchmark Test
    SerialLibrary.Write Data    ${GPU_TEST_CMD}${\n}
    Sleep    6m 30s
    ${3dbenchmark_log}=        SerialLibrary.Read All Data    UTF-8
    Log    ${3dbenchmark_log}
    ${3D_Score}=    Extract Glmark2 Score    ${3dbenchmark_log}
    Should Contain    ${3dbenchmark_log}    glmark2 Score:
    Log    GPU Benchmark Score : ${3D_Score}
    
Extract Glmark2 Score
    [Arguments]    ${glmark_log}
    @{lines}=    Split To Lines    ${glmark_log}
    ${score_line}=      Get From List    ${lines}    -3
    Log    score line:${score_line}
 
    ${score_entity}=       Get Regexp Matches    ${score_line}            \\d{2,}
    ${return_score}=       Convert To String     ${score_entity}

    RETURN    ${return_score}

Find HDMI I2C Bus
    SerialLibrary.Write Data    i2cdetect -l${\n}
    Sleep    1
    ${i2clog}=    SerialLibrary.Read All Data    UTF-8
    Log    ${i2clog}
    ${matches}=    Get Regexp Matches    ${i2clog}    i2c-(\\d)\\s+i2c\\s+${HDMI_KEY_KEYWODR}
    ${i2c_hdmi}=   Get Regexp Matches    ${matches[0]}    (\\d)
    ${i2c_id}=    Get From List    ${i2c_hdmi}    1   
    Log    HDMIID: ${i2c_id}    console=${DEBUG_LOG}
    RETURN    ${i2c_id}

EDID Content Check
    [Arguments]    ${edid_datalog}
    FOR    ${content}    IN    @{EDID CONTAINER}
        Run Keyword And Continue On Failure    Should Contain    ${edid_datalog}    ${content}
    END

Parse HDMI EDID
    ${i2c_bus}=    Find HDMI I2C Bus
    SerialLibrary.Write Data    get-edid -b ${i2c_bus} | parse-edid${\n}
    ${hdmi_edid_log}=    SerialLibrary.Read Until    ${TERMINATOR}
    Log    ${hdmi_edid_log}    console=${DEBUG_LOG}
    EDID Content Check    ${hdmi_edid_log}

Cur Resolution Check
    SerialLibrary.Write Data    fbset${\n}
    Sleep    1
    ${cur_res_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${cur_res_log}
    ${cur_res}=    Get Regexp Matches    ${cur_res_log}    geometry\\s(\\d+\\s\\d+)\\s
    ${is_cur_res_valid}=    Run Keyword And Return Status    Should Not Be Empty    ${cur_res}
    #check if the resolution is correct or being set
    IF    ${is_cur_res_valid}
        ${cur_res}=    Get Regexp Matches    ${cur_res_log}    mode\\s\"(\\d+x\\d+)\"
        Log    ${cur_res}    console=${DEBUG_LOG}
        Log    Resolution is set
    ELSE
        Fail    Fail to get current resolution
    END

Stop the weston service
    SerialLibrary.Write Data    systemctl stop weston${\n}
    Sleep    1
    ${stoplog}=    SerialLibrary.Read All Data    UTF-8
    Log    ${stoplog}    console=${DEBUG_LOG}

Start the weston service
    SerialLibrary.Write Data    systemctl start weston${\n}
    Sleep    1
    ${startlog}=    SerialLibrary.Read All Data    UTF-8
    Log    ${startlog}    console=${DEBUG_LOG}

Color Bar Test
    FOR    ${color}    IN    @{COLOR_BAR}
        SerialLibrary.Write Data    ${COLOR_BAR}[${color}]${\n}
        Sleep    3
        ${colorlog}=    SerialLibrary.Read All Data    UTF-8
        Log    Test Color:${color}, ${colorlog}    console=${DEBUG_LOG}
    END


Download Short Video Clip for Display Test
    SerialLibrary.Write Data    ifconfig -a | grep -E "eth|mlan|wlan" -A 2${\n}
    Sleep    1
    ${chklog}=    SerialLibrary.Read All Data    UTF-8
    Log    ${chklog}

    ${conn_stat}=    Run Keyword And Return Status    Should Match Regexp    ${chklog}    inet\ \\w+.\\w+.\\w+.\\w+

    IF    ${conn_stat} == $True
          SerialLibrary.Write Data    wget -O ${TEST_CLIP_FILE} http://${DL_SERVER_IP}/Videos/${TEST_CLIP_FILE}${\n}
          ${clip_dl_log}=    SerialLibrary.Read Until    ${TERMINATOR}
          Log    ${clip_dl_log} 
    ELSE    
        Log    Internal LAN/WLAN Connection is ${conn_stat}
        Fail
    END

VPU Short Test Clip Play
    Download Short Video Clip for Display Test
    SerialLibrary.Write Data    timeout 10 gst-play-1.0 ${TEST_CLIP_FILE}${\n}
    ${clip_play_log}=    SerialLibrary.Read Until    0:00:09.1
    Log    ${clip_play_log}    console=${DEBUG_LOG}
    Run Keyword And Continue On Failure    Should Contain    ${clip_play_log}    0:00:09.0

GPU Short Test Play
    SerialLibrary.Write Data    timeout 10 ${GPU_TEST_CMD}${\n}
    ${gpu_play_log}=    SerialLibrary.Read Until    ${TERMINATOR}
    Log    ${gpu_play_log}    console=${DEBUG_LOG}
    Run Keyword And Continue On Failure    Should Contain    ${gpu_play_log}    glmark2 Score:

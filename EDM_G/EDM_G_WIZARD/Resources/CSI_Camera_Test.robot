=========================================================================
 Copyright 2025 Technexion Ltd.
 Test Case No      : Case TNPT - For Tevs Camera test
 Category          : Peripherials - CSI1 Cameras 
 Script name       : CSI1_Camera_Test.robot
 Test Cases Converage : ALL TEVS Camera for CSI1 and CSI2
 TNPT-740,TNPT739,TNPT-738,TNPT-736,TNPT-735,TNPT-734,TNPT-733
 Author            : Lance
 Date created      : 20250214
=========================================================================

*** Settings ***
Library         String
Library         DateTime
Library         Collections
Resource        ../Resources/Common_Params.robot

*** Variables ***
#define CSI video interface
${CAM_PROBED_KEYWO}=    probe success

#${CSI_INF}=             CSI1
#${CSI_DEV}=           video0
#${CSI_ADDR}=          1-0048
#${MXC_ISI_ID}=          mxc_isi.0

##use regex to filter resolution
${Resolution_temp}=    video/x-raw,${SPACE}*format=YUY2,.*\/1

@{err_msgs}=    Create List    ERROR    error

${CON_HOSTPC_IP}=    10.88.89.66
${STORAGE_PATH}=     ./Result
${NC_PORT}=          12345

*** Keywords ***
Check Cam Probe
    [Arguments]    ${CSI_DEV}    ${CSI_ADDR}    ${MXC_ISI_ID}
    SerialLibrary.Write Data    dmesg | grep -iE "${CSI_DEV}|${CSI_ADDR}|${MXC_ISI_ID}"${\n}
    Sleep    1
    ${dmesg_cam_log}=    SerialLibrary.Read All Data
    Log    ${dmesg_cam_log}
    ${cam_alive_state}=    Run Keyword And Return Status    Should Contain    ${dmesg_cam_log}    ${CAM_PROBED_KEYWO}
    RETURN    ${cam_alive_state}

Retrive Cam Infos
    [Arguments]    ${CSI_DEV}    ${CSI_ADDR}    ${MXC_ISI_ID}
    SerialLibrary.Write Data    dmesg | grep -iE "${CSI_DEV}|${CSI_ADDR}|${MXC_ISI_ID}"${\n}
    Sleep    1
    ${dmesg_cam_log}=    SerialLibrary.Read All Data    
    ${match_tevs}=        Get Regexp Matches    ${dmesg_cam_log}    TEVS-AR\\d+
    ${match_Version}=     Get Regexp Matches    ${dmesg_cam_log}    Version:\\d+.\\d+.\\d.\\d

    RETURN   ${match_tevs}    ${match_Version}

Show Cam all default resolution
    [Arguments]    ${csi_dev}
    #1st resolution set
    #gst-device-monitor-1.0 Video/Source:video/x-raw | awk '/Device found:/{p=1} p; /device\.path = \/dev\/video0/{exit}'

    #2nd resolution set
    #gst-device-monitor-1.0 Video/Source:video/x-raw | awk '/Device found:/{found++;} found==2, /\/dev\/video1/ {if ($0 ~ /Device found:/) found==0; else print}'


    IF    '${csi_dev}' == 'video0'
        #SerialLibrary.Write Data        gst-device-monitor-1.0 Video/Source:video/x-raw${\n}
        SerialLibrary.Write Data       gst-device-monitor-1.0 Video/Source:video/x-raw | awk '/Device found:/{p=1} p; /device\\\.path = \\\/dev\\\/${csi_dev}/{exit}'${\n}
        ${cam_res_log}=    SerialLibrary.Read Until    ${TERMINATOR}
        Log    ${cam_res_log}
    ELSE
        SerialLibrary.Write Data        gst-device-monitor-1.0 Video/Source:video/x-raw | awk '/Device found:/{found++;} found==2, /\\\/dev\\\/${csi_dev}/ \{if ($0 ~ /Device found:/) found==0; else print\}'${\n}
        ${cam_res_log}=    SerialLibrary.Read Until    ${TERMINATOR}
        Log    ${cam_res_log}
    END

    #SerialLibrary.Write Data        gst-device-monitor-1.0 Video/Source:video/x-raw${\n}
    #${cam_res_log}=    SerialLibrary.Read Until    ${TERMINATOR}
    Log    ${cam_res_log}

    #Extract resolution que
       ${match_res_set}=    Get Regexp Matches    ${cam_res_log}    ${Resolution_temp}
    Log    ${match_res_set}
    RETURN    ${match_res_set}

Check Vizion Ctl 
    SerialLibrary.Reset Input Buffer    ${SERIAL_PORT}
    SerialLibrary.Reset Output Buffer    ${SERIAL_PORT}
    ${vizion_ctl_file}=    Set Variable    \/usr\/bin\/vizion-ctl
    SerialLibrary.Write Data    find / | grep vizion-ctl${\n}
    Sleep    2
    ${chk_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${chk_log}
    ${vizion_ctl_true}=    Run Keyword And Return Status    Should Contain    ${chk_log}    ${vizion_ctl_file}
    RETURN    ${vizion_ctl_true}

Network Connect checker
    #obtain IP address in console machine via self-build library EnvVariablesReturnLib.py
    ${CON_HOSTPC_IP}=    Ip4_Addr_Finder    ${CONSOLE_ETH_INF}
    SerialLibrary.Write Data    ping -c 3 ${CON_HOSTPC_IP}${\n}
    ${net_pinglog}=    SerialLibrary.Read Until     ${TERMINATOR}   
    Log    ${net_pinglog}
    ${isconn}=    Run Keyword And Return Status    Should Not Contain     ${net_pinglog}    ${ERR_MESSAGE}
    
    IF    ${isconn} == ${False}
        SerialLibrary.Write Data    ifconfig ${ETH_INF} up${\n}
        Sleep    0.5
        SerialLibrary.Write Data    ifconfig ${WIFI_INF} up${\n}
        Sleep    0.5
        SerialLibrary.Write Data    systemctl restart connman${\n}
        ${conn_op_log}=    SerialLibrary.Read Until    ${TERMINATOR}
        Sleep    3
        Log    ${conn_op_log}    console=${DEBUG_LOG}
        SerialLibrary.Write Data    ping -c 3 ${CON_HOSTPC_IP}${\n}
        ${net_pinglog}=    SerialLibrary.Read Until     ${TERMINATOR}  
        Log    ${net_pinglog}
        ${isconn}=    Run Keyword And Return Status    Should Not Contain     ${net_pinglog}    ${ERR_MESSAGE}
    ELSE
        Log     ping OK: ${net_pinglog}
        RETURN    ${isconn}
    END

IP obtained checker
    ${ip_state}=    Set Variable    ${False}
    WHILE    not ${ip_state}
        SerialLibrary.Write Data    ifconfig -a | grep -iE "${ETH_INF}|${WIFI_INF}" -A 3${\n}
        Sleep    1
        ${inet_log}=    SerialLibrary.Read All Data    UTF-8
        ${ip_state}=    Run Keyword And Return Status    Should Match Regexp    ${inet_log}    inet 10\.88\.\\d+\.\\d+
        Log    ${inet_log}    console=${DEBUG_LOG}     
    END

CSI Cam Test
    [Arguments]    ${CSI_INF}    ${CSI_DEV}    ${CSI_ADDR}    ${MXC_ISI_ID}
    ${iscamup}=    Check Cam Probe    ${CSI_DEV}    ${CSI_ADDR}    ${MXC_ISI_ID}
    ${net_stat}=    Network Connect checker
    IP obtained checker

    IF    ${iscamup} == ${True}
        ${cam_tevs_type}    ${cam_ver}    Retrive Cam Infos    ${CSI_DEV}    ${CSI_ADDR}    ${MXC_ISI_ID}
        ${cam_tevs_type}    ${cam_ver}    Set Variable    ${cam_tevs_type}[0]    ${cam_ver}[0]
        Log    Cam Type: ${cam_tevs_type}, Cam FW: ${cam_ver} 
        ${cam_test_res_set}=    Show Cam all default resolution    ${CSI_DEV}    
        #SerialLibrary.Write Data    gst-launch-1.0 v4l2src device=${CSI_DEV} ! autovideosink${\n}
        FOR    ${test_res}    IN    @{cam_test_res_set}
            ${w_display}=    Get Regexp Matches    ${test_res}    width=\\d+
            ${h_display}=    Get Regexp Matches    ${test_res}    height=\\d+
            ${w_display}=    Set Variable   ${w_display}[0]   
            ${h_display}=    Set Variable   ${h_display}[0]   
            #Launch camera for test...
            #SerialLibrary.Write Data    timeout 5 gst-launch-1.0 v4l2src device=/dev/${CSI_DEV} ! ${test_res} ! waylandsink${\n}
            SerialLibrary.Write Data    timeout 5 gst-launch-1.0 v4l2src device=/dev/${CSI_DEV} ! textoverlay text="CAM: ${cam_tevs_type}, DEV:${CSI_INF}, ${w_display},${h_display}" valignment=top halignment=left ! ${test_res} ! waylandsink${\n}
            #Log To Console    gst-launch-1.0 v4l2src device=${CSI_DEV} ! ${test_res} ! waylandsink
            Sleep    8
            ${cam_test_log}=    SerialLibrary.Read All Data    
            Log    ${cam_test_log}    console=yes
            
            Run Keyword And Continue On Failure    Should Not Contain Any   ${cam_test_log}    @{err_msgs}
            Sleep    0.5
            #Capture with Jpeg Test
            Log To Console    JPEG Capture Test...
            ${f_w}=    Get Regexp Matches    ${w_display}    \\d+
            ${f_h}=    Get Regexp Matches    ${h_display}    \\d+
            SerialLibrary.Write Data    gst-launch-1.0 v4l2src device=/dev/${CSI_DEV} num-buffers=4 ! textoverlay text="CAM: ${cam_tevs_type}, SCR:${CSI_INF}, ${w_display},${h_display}" valignment=top halignment=left ! ${test_res} ! jpegenc snapshot=true ! filesink location=${cam_tevs_type}_${f_w}[0]x${f_h}[0].jpeg${\n}
            #Sleep    1
            #Transfer capture file to PC - initial the listening process in pc
            #Run Process    nc -l -p ${NC_PORT} > ${cam_tevs_type}_${f_w}[0]x${f_h}[0].jpeg&
            #Transfer capture file from DUT
            SerialLibrary.Write Data    nc ${CON_HOSTPC_IP} ${NC_PORT} < ${cam_tevs_type}_${f_w}[0]x${f_h}[0].jpeg${\n}
            ${rc}    ${output}    Run And Return Rc And Output    nc -l -p ${NC_PORT} > ${STORAGE_PATH}/${CSI_INF}_${cam_tevs_type}_${f_w}[0]x${f_h}[0].jpeg
            Log    Return Code: ${rc}
            Log    Output: ${output}
            Sleep    2
            Log            <img src="${CSI_INF}_${cam_tevs_type}_${f_w}[0]x${f_h}[0].jpeg">        html=true
        END
        Sleep    3
    ELSE
        Fail    Camera: /dev/${CSI_DEV} Probe Fail.
    END

Vizion Control Test
    [Arguments]    ${CSI_DEV}
    #vizion control parameter set 1
    @{vizion_ctrl_info_cmd_que}    Create List    -D
    ...    -n 
    ...    -L 
    ...    -u
    ...    --isp-fw-version
    ...    --tevs-fw-version
    ...    --uvc--fw-version
    ...    -v 

    @{vizion_ctrl_param_cmd_que}    Create List    brightness 
    ...    contrast
    ...    saturation
    ...    white_balance_mode
    ...    white_balance_temperature
    ...    gamma
    ...    exposure_mode
    ...    exposure
    ...    throughput
    ...    gain
    ...    flip_mode
    ...    flick_mode
    ...    bsl_mode
    ...    bsl_mode
    ...    sharpness
    ...    backlight_compensation
    ...    special_effect
    ...    pan_target
    ...    tilt_target
    ...    zoom_target
    
    @{vizion_ctrl_param_verify_que}    Create List    1
    ...    1
    ...    1
    ...    0
    ...    15000
    ...    1
    ...    0
    ...    50000
    ...    900
    ...    64
    ...    3
    ...    3
    ...    1
    ...    0
    ...    2
    ...    15
    ...    4
    ...    1
    ...    1
    ...    8
    
    ${is_vizion_ctl}=    Check Vizion Ctl
    
    IF    ${is_vizion_ctl} == ${False}
        Fail    ${is_vizion_ctl} is not available
    ELSE
            #vizion-ctrl parameters Test set 1
        FOR    ${param}    IN    @{vizion_ctrl_info_cmd_que} 
            #launch command : vizion-ctl -d /dev/videoX ${params set 1}
            SerialLibrary.Write Data    vizion-ctl -d /dev/${CSI_DEV} ${param}${\n}
            Sleep    1
            ${vizion_ctl_test_log}=    SerialLibrary.Read All Data    UTF-8
            Log    ${vizion_ctl_test_log}    
            Run Keyword And Continue On Failure    Should Not Contain Any    ${vizion_ctl_test_log}    @{err_msgs}
        END

        #vizion-ctrl parameters Test set 2
        FOR    ${param}    ${chk_val}    IN ZIP    ${vizion_ctrl_param_cmd_que}    ${vizion_ctrl_param_verify_que}
            #Log    ${param} : ${chk_val}    console=yes
            SerialLibrary.Write Data    vizion-ctl -d /dev/${CSI_DEV} -s ${param}=${chk_val}${\n}
            Sleep    0.5
            SerialLibrary.Write Data    vizion-ctl -d /dev/${CSI_DEV} -g ${param}${\n}
            Sleep    1
            ${vizion_ctl_test_log}=    SerialLibrary.Read All Data    UTF-8
            Log    ${vizion_ctl_test_log}    console=yes    
            Run Keyword And Continue On Failure    Should Not Contain Any    ${vizion_ctl_test_log}    @{err_msgs}
        END 
        
    END


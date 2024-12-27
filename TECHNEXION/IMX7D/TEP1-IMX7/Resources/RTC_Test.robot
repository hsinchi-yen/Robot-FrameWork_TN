=========================================================================
 Copyright 2024 Technexion Ltd.
 Test Case No      : RTC - Real-Time clock 
 Purpose           : This test robot is used to test RTC 
 Category          : Functional Test  
 Script name       : RTC_Test.robot
 Author            : Lance
 Date created      : 20240903
=========================================================================

*** Settings ***
Resource          ../Resources/Common_Params.robot
Library        Collections


*** Variables ***
${WWW_DNS_IP}            8.8.8.8
${SIT_TEST_SER}          10.88.88.229
${LOCALTIME_PATCH}       /Local_Time/localtime
${NTP_SERVER_DNS}        TIME.google.com
${RTC_NODE}              /dev/rtc
${POWER_OFF_TIME}        1m


*** Keywords *** 
RTC Test
    ${wwwconnected}=    Check WWW Connection  

    IF    ${wwwconnected} == $True
        Sync Localtime to CST
        Sync NTP Time to DUT
        Sync Current Time to HW clock
        Device OFF
        Sleep    ${POWER_OFF_TIME} 
        Power Cycle And Relogin
    ELSE
        Log    "WWW connection is loss"
    END

    Check DUT HW clock

Check WWW Connection
    ${no_loss_keyword}=    Set Variable        0% packet loss
    
    SerialLibrary.Write Data    ping -c 3 ${WWW_DNS_IP}${\n}
    Sleep    4
    ${pinglog}=    SerialLibrary.Read All Data    UTF-8
    #Log    ${pinglog}
    ${zero_pkt_loss}=    Run Keyword And Return Status    Should Contain    ${pinglog}    ${no_loss_keyword}
    [Return]    ${zero_pkt_loss}

Sync Localtime to CST 
    SerialLibrary.Write Data    wget -q -O /etc/localtime http://${SIT_TEST_SER}/Local_Time/localtime${\n}
    Sleep    1
    SerialLibrary.Write Data    date${\n}
    Sleep    1
    ${time_z_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${time_z_log}
    Should Contain    ${time_z_log}    CST

Sync NTP Time to DUT
    SerialLibrary.Write Data    ntpd -q TIME.google.com${\n}
    ${ntpsync_log}=    SerialLibrary.Read Until    ${TERMINATOR}
    Log    ${ntpsync_log}

Sync Current Time to HW clock
    SerialLibrary.Write Data    hwclock -w -f ${RTC_NODE}${\n}
    Sleep    1
    SerialLibrary.Write Data    hwclock -f ${RTC_NODE} && date${\n}
    Sleep    1
    ${sync_t_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${sync_t_log}
    
Check DUT HW clock
    #get sys time
    ${cur_sys_time}=    Get Current Date
    #get dut time
    SerialLibrary.Write Data    hwclock -f ${RTC_NODE}${\n}
    ${sync_t_log}=    SerialLibrary.Read Until    ${TERMINATOR}

    Log    System time: ${cur_sys_time}
    Log    Dut RTC HW time: ${sync_t_log}

    ${cur_sys_time}    Get Regexp Matches    ${cur_sys_time}    \\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}.\\d{3}
    ${dut_time}=    Strip The DateTime String    ${sync_t_log}

    ${cur_sys_time}=    Convert To String    ${cur_sys_time}
    ${dut_time}=    Convert To String    ${dut_time}

    ${cur_sys_time}=    Convert Date    ${cur_sys_time}
    ${dut_time}=    Convert Date    ${dut_time}
    ${time_diff}=    Subtract Date From Date    ${dut_time}   ${cur_sys_time}
    Log    ${time_diff}
    Should Be True    ${time_diff} >=-1 and ${time_diff} <=1

Strip The DateTime String
    [Arguments]    ${raw_log}
    Log    ${raw_log}
    ${dt_pattern}    Set Variable    \\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}.\\d{3}
    ${dt_matches}    Get Regexp Matches    ${raw_log}    ${dt_pattern}
    RETURN    ${dt_matches}


    




    



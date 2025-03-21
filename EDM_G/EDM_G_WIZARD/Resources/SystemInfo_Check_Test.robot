=====================================================================================
 Copyright 2024 Technexion Ltd.
 Test Case No      : Case TNPT-6
 Category          : Test A-System and Function
 Script name       : Sysinfo.robot
 Author            : Raymond, Lance
 Date created      : 20240830
----------------------------------------------------------------------------------------
 Changlog : Use SysInfo.sh script on SIT http server instaed of the test implementation.
 Update date : 20250103
=====================================================================================


*** Settings ***
Library           Collections
Library           Process
Library            String

Resource       ../Resources/Common_Params.robot
Library        ../Libraries/EnvVariablesReturnLib.py


*** Variables ***
#External Script
${SIT_DL_SERV}        http://10.88.88.229/RF_TestScripts/
${SYSINFO_SCRIPT}     SysInfo_test.sh


*** Keywords ***
System Info Check
    Check the SystemInfo command
    Show System Information
    #Modify the loglevel due to the loglevel is different from previous kernel version, since the kernel 6.6
    Change Console Log Level

Download SystemInfo Script
    SerialLibrary.Write Data    ifconfig -a | grep -E "eth|mlan|wlan" -A 2${\n}
    Sleep    1
    ${chklog}=    SerialLibrary.Read All Data    UTF-8
    Log    ${chklog}

    ${conn_stat}=    Run Keyword And Return Status    Should Match Regexp    ${chklog}    inet\ \\w+.\\w+.\\w+.\\w+

    IF    ${conn_stat} == $True
        Check the SystemInfo command   
    ELSE    
        Log    Internal LAN/WLAN Connection is ${conn_stat}
        Fail
    END

Show System Information
    SerialLibrary.Write Data    bash ${SYSINFO_SCRIPT}${\n}
    Sleep    3
    ${SysInfoLog}=    SerialLibrary.Read All Data    UTF-8
    Log    ${SysInfoLog}    console=yes
    Board Info Verify       ${SysInfoLog}

Check the SystemInfo command
    SerialLibrary.Write Data    ls -1 ${SYSINFO_SCRIPT}${\n}
    Sleep    1
    ${cmdlog}=    SerialLibrary.Read All Data    UTF-8
    ${iscmd}=    Run Keyword And Return Status    Should Contain    ${cmdlog}    cannot access '${SYSINFO_SCRIPT}'

    IF    ${iscmd} == $True
        Log    script: ${SYSINFO_SCRIPT} is not existed
        SerialLibrary.Write Data    wget -O ${SYSINFO_SCRIPT} ${SIT_DL_SERV}${SYSINFO_SCRIPT}${\n}
        Sleep    2
        SerialLibrary.Write Data    sync${\n}
        Sleep    1
        ${dl_log}=    SerialLibrary.Read All Data    UTF-8
    ELSE
        Log    script: ${SYSINFO_SCRIPT} is existed
    END
    
Board Info Verify
    [Arguments]    ${boardinfo_log}
    Run Keyword And Continue On Failure  Should Contain    ${boardinfo_log}    TechNexion EDM-G-IMX8MP and WIZARD baseboard

Change Console Log Level
    SerialLibrary.Write Data    echo "7 4 1 7" > /proc/sys/kernel/printk${\n}
    SerialLibrary.Write Data    cat /proc/sys/kernel/printk${\n}
    Sleep    1
    ${log_lv_dump$}=    SerialLibrary.Read All Data    UTF-8
    Log    ${log_lv_dump$}
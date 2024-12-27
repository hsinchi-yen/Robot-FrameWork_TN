*** Settings ***
Resource        ../Resources/Common_Params.robot

*** Variables ***
${crash_message}    end Kernel panic - not syncing: sysrq triggered crash

*** Keywords ***
Enable The Watchdog Via Devfs
   SerialLibrary.Write Data    echo 1 > /dev/watchdog${\n}
   ${watchdog_en_log}=    SerialLibrary.Read Until     ${TERMINATOR}
   Log        ${watchdog_en_log}


Trigger The Watchdog Via Test Commandline
    SerialLibrary.Write Data    echo c > /proc/sysrq-trigger${\n}
    Sleep    1
    ${trigger_log}=    SerialLibrary.Read Until    ${crash_message}
    Log    ${trigger_log}
    Should Contain    ${trigger_log}   ${crash_message}
    #Sleep    30
    Sleep    65    #For IMX6UL/IMX6UUL
    SerialLibrary.Write Data    \n
    ${reboot_log}=    SerialLibrary.Read Until    ${LOGIN_PROMPT}
    Log     ${reboot_log}
    ${isBoot}=    Run Keyword And Return Status    Should Contain    ${reboot_log}   ${LOGIN_PROMPT}
    IF    ${isBoot} == $True
        SerialLibrary.Write Data    ${LOGIN_ACC}\n
        ${login_OK}=    SerialLibrary.Read Until    ${TERMINATOR}
        Log        ${login_OK}
    ELSE
        Log        Fail to Login after reboot
    END
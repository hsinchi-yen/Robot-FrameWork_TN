*** Settings ***
Resource        ../Resources/Common_Params.robot

*** Variables ***
${FORMAT}        epoch
${TIME_FORMAT}   %Y-%m-%d %H:%M:%S 
${BOOT_UP_TIME_SPEC}   60
#adjust Power down keyword for IMX7
${PWR_DOWN_KEYWORD}    reboot: System halted

*** Keywords ***
Power Cycle And Relogin
   Device OFF
   Sleep    3

   ${initial_time}=    Get Time    ${FORMAT}
   Log    ${initial_time}
   Device ON
   ${bootlog}=    SerialLibrary.Read Until     ${LOGIN_PROMPT} 
   Log        ${bootlog}
   Run Keyword And Continue On Failure    Should Contain    ${bootlog}   ${LOGIN_PROMPT}

   ${is_login}=    Run Keyword And Return Status    Should Contain    ${bootlog}   ${LOGIN_PROMPT}

    IF    ${is_login} == $True
        SerialLibrary.Write Data    ${LOGIN_ACC}${\n}
        ${loginlog}=    SerialLibrary.Read Until    ${TERMINATOR}
        Run Keyword And Continue On Failure    Should Contain    ${loginlog}    ${TERMINATOR}
        ${final_time}=    Get Time    ${FORMAT}
        Log    ${final_time}
    ELSE
        Log    Fail to enter Login prompt
        ${final_time}=    Get Time    ${FORMAT}
        Log    ${final_time}
    END

    ${time_diff}=    Evaluate    ${final_time} - ${initial_time}
    Log    Time difference: ${time_diff} seconds.

    ${time_diff}=    Convert To Integer    ${time_diff}
    Should Be True    ${time_diff} <= ${BOOT_UP_TIME_SPEC}
 
    

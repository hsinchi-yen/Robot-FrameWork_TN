*** Settings ***
Resource        ../Resources/Common_Params.robot

*** Variables ***
${FORMAT}        epoch
${TIME_FORMAT}   %Y-%m-%d %H:%M:%S 
${BOOT_UP_TIME_SPEC}   29
${PWR_DOWN_KEYWORD}    reboot: Power down

*** Keywords ***
Power Cycle And Relogin
   #Device OFF
   Device GPP-1326 OFF

   Sleep    1.5

   ${initial_time}=    Get Time    ${FORMAT}
   Log    ${initial_time}
   #Device ON
   Device GPP-1326 ON
   ${bootlog}=    SerialLibrary.Read Until     ${LOGIN_PROMPT} 
   Log        ${bootlog}
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
 
    

*** Settings ***
Resource        ../Resources/Common_Params.robot

*** Variables ***
${FORMAT}        epoch
${TIME_FORMAT}   %Y-%m-%d %H:%M:%S 
${BOOT_UP_TIME_SPEC}   40
#modified for PICO-IMX7D
${PWR_DOWN_KEYWORD}    reboot: System halted

*** Keywords ***
Power Cycle And Relogin
   SerialLibrary.Close Port
   Device OFF
   Sleep    3
   ${initial_time}=    Get Time    ${FORMAT}
   Log    ${initial_time}
   Device ON
   Sleep    1
   SerialLibrary.Open Port
   ${bootlog}=    SerialLibrary.Read Until     ${LOGIN_PROMPT} 
   Log        ${bootlog}
   ${is_login}=    Run Keyword And Return Status    Should Contain    ${bootlog}   ${LOGIN_PROMPT}

    IF    ${is_login} == $True
        #Sleep    5
        #Reset Input Buffer     ${SERIAL_PORT}
        #Reset Output Buffer    ${SERIAL_PORT}
        SerialLibrary.Write Data    ${LOGIN_ACC}${\n}
        SerialLibrary.Write Data    ${\n}
        Sleep    0.5
        ${loginlog0}=    SerialLibrary.Read All Data    UTF-8 
        Log    ${loginlog0}  
        SerialLibrary.Write Data    uname -a${\n}"
        ${loginlog}=    SerialLibrary.Read Until    ${TERMINATOR}
        Run Keyword And Continue On Failure    Should Contain    ${loginlog}    ${TERMINATOR}
        ${final_time}=    Get Time    ${FORMAT}
        Log    ${final_time}
    ELSE
        Log    Fail to enter Login prompt
        ${final_time}=    Get Time    ${FORMAT}
        Log    ${final_time}
    END

    ${time_diff}=    Evaluate    ${final_time} - ${initial_time} -3
    Log    Time difference: ${time_diff} seconds.

    ${time_diff}=    Convert To Integer    ${time_diff}
    Run Keyword And Continue On Failure     Should Be True    ${time_diff} <= ${BOOT_UP_TIME_SPEC}
 
    

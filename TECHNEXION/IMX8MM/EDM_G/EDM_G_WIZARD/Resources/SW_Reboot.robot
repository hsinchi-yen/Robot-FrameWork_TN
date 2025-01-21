*** Settings ***
Resource        ../Resources/Common_Params.robot

*** Variables ***
##

*** Keywords ***
Send Reboot command then Check Reboot State And Relogin
   SerialLibrary.Write Data    reboot${\n}
   ${bootlog}=    SerialLibrary.Read Until     ${LOGIN_PROMPT} 
   Log        ${bootlog}
    ${is_login}=    Run Keyword And Return Status    Should Contain    ${bootlog}   ${LOGIN_PROMPT}
      
    IF    ${is_login} == $True
        SerialLibrary.Write Data    ${LOGIN_ACC}${\n}
        ${loginlog}=    SerialLibrary.Read Until    ${TERMINATOR}
        Run Keyword And Continue On Failure    Should Contain    ${loginlog}    ${TERMINATOR}
      
    ELSE
        
        Log    Fail to enter Login prompt
    END



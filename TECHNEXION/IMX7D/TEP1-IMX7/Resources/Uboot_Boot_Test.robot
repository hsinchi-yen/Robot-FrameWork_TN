*** Settings ***
Resource        ../Resources/Common_Params.robot

*** Variables ***
${PRIOR_UBOOT_PROMPT}    Hit any key to stop autoboot:
${UBOOT_PROMPT}          \=>

*** Keywords ***
Enter Uboot Mode then Check Uboot prompt and boot
   SerialLibrary.Write Data    reboot${\n}
   ${bootlog}=    SerialLibrary.Read Until     ${PRIOR_UBOOT_PROMPT}
   Log        ${bootlog}
   ${is_prior_uboot}=    Run Keyword And Return Status    Should Contain    ${bootlog}   ${PRIOR_UBOOT_PROMPT}

    IF    ${is_prior_uboot} == $True
        SerialLibrary.Write Data    ${\n}${\n}
        SerialLibrary.Write Data    version${\n}
        ${uboot_log}=    SerialLibrary.Read Until    ${UBOOT_PROMPT}
        Log    ${uboot_log}
        Run Keyword And Continue On Failure    Should Contain    ${uboot_log}    ${UBOOT_PROMPT}
    ELSE
        Log    Fail to enter uboot Mode
    END

    #boot from Uboot
    SerialLibrary.Write Data    boot${\n}
    ${bootlog_fromuboot}=        SerialLibrary.Read Until    ${LOGIN_PROMPT}
    Sleep    3
    SerialLibrary.Write Data    ${LOGIN_ACC}${\n}${\n}
    Run Keyword And Continue On Failure    Should Contain    ${bootlog_fromuboot}    ${LOGIN_PROMPT}
    Sleep    10
    Log    ${bootlog_fromuboot}
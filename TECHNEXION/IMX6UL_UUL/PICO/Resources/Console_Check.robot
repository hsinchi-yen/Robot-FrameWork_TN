*** Settings ***
Resource        ../Resources/Common_Params.robot

*** Variables ***
#${console_ttymxcid}    ttymxc1
${console_ttymxcid}    ttymxc5
*** Keywords ***
Check Console State Dmesg
   SerialLibrary.Write Data    dmesg | grep console${\n}
   ${dmesglog}=    Seriallibrary.Read Until    ${TERMINATOR}
   Should Contain    ${dmesglog}    ${console_ttymxcid}
   Log    ${dmesglog}


Check Console ID in virtual filesystem directory
    SerialLibrary.Write Data    cat /proc/consoles${\n}
    ${proc_consolelog}=    Seriallibrary.Read Until     ${TERMINATOR}
    Should Contain    ${proc_consolelog}    ${console_ttymxcid}
    Log     ${proc_consolelog}
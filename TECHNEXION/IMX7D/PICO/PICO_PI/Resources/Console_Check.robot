*** Settings ***
Resource        ../Resources/Common_Params.robot

*** Variables ***
#modified for pico-imx7
${console_ttymxcid}    ttymxc4

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
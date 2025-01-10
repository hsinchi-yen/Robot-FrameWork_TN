*** Settings ***
Resource        ../Resources/Common_Params.robot

*** Variables ***
#UMS stop key strokes
${CTRL_C}                 \x03


*** Keywords ***
Perform Flash Image Process with Bmaptool
    Connect Serial    ${SERIAL_PORT}
    Send Reboot Command
    ${autobootlog}=    Wait For Boot Message    Normal Boot
    Run Keyword If     ${autobootlog} == ${True}    Send UMS Command
    ${device_found}=    Check USB Device Connected    
    Log    ${device_found}    
    Should Contain    ${device_found}    ${NXP_DEV_NAME}   
    ${device}=    Find UMS Device
    Bmaptool Flash Image To Device    ${TEST_IMAGE_BMAP}     ${TEST_IMAGE}     ${device}
    Disconnect Serial 
    Sleep    5
    SerialLibrary.Open Port
    SerialLibrary.Write Data    ${CTRL_C}
    Sleep    1
    SerialLibrary.Write Data    ${CTRL_C}
    Sleep    1
    Reset Input Buffer     ${SERIAL_PORT}
    Reset Output Buffer    ${SERIAL_PORT}
    Sleep    1
    SerialLibrary.Write Data    ${\n}boot${\n}
    Sleep    1
    ${bootlog_fromuboot}=        SerialLibrary.Read Until    ${LOGIN_PROMPT}
    Sleep    2
    SerialLibrary.Write Data    ${LOGIN_ACC}${\n}${\n}
    Run Keyword And Continue On Failure    Should Contain    ${bootlog_fromuboot}    ${LOGIN_PROMPT}
    Sleep    3
    Log    ${bootlog_fromuboot}

Perform Flash Image Process with dd
    Connect Serial    ${SERIAL_PORT}
    Send Reboot Command
    ${autobootlog}=    Wait For Boot Message    Normal Boot
    Run Keyword If     ${autobootlog} == ${True}    Send UMS Command
    ${device_found}=    Check USB Device Connected    
    Should Contain    ${device_found}    ${NXP_DEV_NAME}
    ${device}=    Find UMS Device
    Dd Flash Image To Device    ${TEST_IMAGE}     ${device}
    Disconnect Serial    
    Sleep    5
    SerialLibrary.Open Port
    SerialLibrary.Write Data    ${CTRL_C}
    Sleep    1
    SerialLibrary.Write Data    ${CTRL_C}
    Sleep    1
    Reset Input Buffer     ${SERIAL_PORT}
    Reset Output Buffer    ${SERIAL_PORT}
    Sleep    1
    SerialLibrary.Write Data    ${\n}boot${\n}
    Sleep    1
    ${bootlog_fromuboot}=        SerialLibrary.Read Until    ${LOGIN_PROMPT}
    Sleep    2
    SerialLibrary.Write Data    ${LOGIN_ACC}${\n}${\n}
    Run Keyword And Continue On Failure    Should Contain    ${bootlog_fromuboot}    ${LOGIN_PROMPT}
    Sleep    3
    Log    ${bootlog_fromuboot}
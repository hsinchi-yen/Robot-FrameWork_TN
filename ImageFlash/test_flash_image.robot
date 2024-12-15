*** Settings ***
Library    FlashImageLibrary.py

*** Variables ***
${TEST_IMAGE}    ../edm-g-imx8mp_edm-g-wb_yocto-4.0-qt6_qca9377_hdmi-1920x1080_20240220.wic 

*** Test Cases ***
Perform Flash
    Connect Serial    /dev/ttyS0
    Send Reboot Command
    ${autobootlog}=    Wait For Boot Message    Normal Boot
    Run Keyword If    '${autobootlog}' == 'True'    Send UMS Command
    ${device_found}=    Check USB Device Connected
    Run Keyword If    '${device_found}' == 'True'    Flash Image Process
    Disconnect Serial

*** Keywords ***
Flash Image Process
    ${device}=    Find UMS Device
    Flash Image To Device   ${TEST_IMAGE}     ${device}



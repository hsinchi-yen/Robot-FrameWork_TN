*** Settings ***
Resource        ../Resources/Common_Params.robot

# Host PC Environment configuration
# For better handling dd and bmaptool flash image process, we need to use serial port to control the UMS mode.
# Thd dd and bmaptool flash image process will be executed in UMS mode.
# In the process of flash image, the Host PC's auto mount function should be disabled prior to the flash image process.
# Disable the auto mount function by using the following command:
# Use the utility - dconf-editor to check the setting.
# sudo gsettings set org.gnome.desktop.media-handling automount false
# sudo gsettings set org.gnome.desktop.media-handling automount-open false
# sudo gsettings set org.gnome.desktop.media-handling autorun-never true
# The Host PC should be rebooted after the setting is changed.

# For the root permission, the Host PC should be configured to allow the user to access the serial port.
# Directly modify the /etc/sudoers file to allow the user to grand root permission.
# Add the following line to the /etc/sudoers file:
# username ALL=(ALL) NOPASSWD: ALL

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
    #Should Contain    ${device_found}    ${NXP_DEV_NAME}  
    Should Contain Any    ${device_found}  @{NXP_DEV_NAME}    
    ${device}=    Find UMS Device
    ${bmapflash_log}=    Bmaptool Flash Image To Device    ${TEST_IMAGE_BMAP}     ${TEST_IMAGE}     ${device}
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
    #Log    ${bmapflash_log}
    Log    ${bootlog_fromuboot}

Perform Flash Image Process with dd
    Connect Serial    ${SERIAL_PORT}
    Send Reboot Command
    ${autobootlog}=    Wait For Boot Message    Normal Boot
    Run Keyword If     ${autobootlog} == ${True}    Send UMS Command
    ${device_found}=    Check USB Device Connected    
    Should Contain Any   ${device_found}    @{NXP_DEV_NAME}
    ${device}=    Find UMS Device
    ${flash_log}=    Dd Flash Image To Device    ${TEST_IMAGE}     ${device}
    Sleep    10
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
    #Log    ${flash_log}
    Log    ${bootlog_fromuboot}
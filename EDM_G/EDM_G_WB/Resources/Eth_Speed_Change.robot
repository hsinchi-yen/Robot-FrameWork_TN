*** Settings ***
Library        Collections
Resource       ../Resources/Common_Params.robot
Library        ../Libraries/EnvVariablesReturnLib.py


*** Variables ***
${LINK_UP_EVENT}    link becomes ready

*** Keywords ***
Set 10Mb Test
    SerialLibrary.Write Data    ethtool -s ${ETH_INF} speed 10 duplex full${\n}
    Sleep    5
    ${set_10_log}=    SerialLibrary.Read All Data     UTF-8   
    Log    ${set_10_log}
    Should Contain    ${set_10_log}    ${LINK_UP_EVENT}
    SerialLibrary.Write Data    ethtool ${ETH_INF} | grep Speed${\n}
    Sleep    2
    ${set_10_log}=    SerialLibrary.Read All Data     UTF-8  
    Should Contain    ${set_10_log}    10Mb/s

Set 100Mb Test
    SerialLibrary.Write Data    ethtool -s ${ETH_INF} speed 100 duplex full${\n}
    Sleep    5
    ${set_100_log}=    SerialLibrary.Read All Data     UTF-8   
    Log    ${set_100_log}
    Should Contain    ${set_100_log}    ${LINK_UP_EVENT}
    SerialLibrary.Write Data    ethtool ${ETH_INF} | grep Speed${\n}
    Sleep    2
    ${set_100_log}=    SerialLibrary.Read All Data     UTF-8  
    Should Contain    ${set_100_log}    100Mb/s

Set 1000Mb Test
    SerialLibrary.Write Data    ethtool -s ${ETH_INF} speed 1000 duplex full autoneg on${\n}
    Sleep    5
    ${set_1000_log}=    SerialLibrary.Read All Data     UTF-8   
    Log    ${set_1000_log}
    Should Contain    ${set_1000_log}    ${LINK_UP_EVENT}
    SerialLibrary.Write Data    ethtool ${ETH_INF} | grep Speed${\n}
    Sleep    2
    ${set_1000_log}=    SerialLibrary.Read All Data     UTF-8  
    Should Contain    ${set_1000_log}    1000Mb/s


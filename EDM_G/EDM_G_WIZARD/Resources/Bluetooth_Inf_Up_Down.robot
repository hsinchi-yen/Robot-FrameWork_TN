*** Settings ***
Resource          ../Resources/Common_Params.robot

*** Variables ***
${BT_INF}           hci0

*** Keywords ***
BT Init State Check
    SerialLibrary.Write Data    hciconfig ${BT_INF} -a${\n}    UTF-8
    Sleep    1
    ${bthci_log}=    SerialLibrary.Read All Data    UTF-8
    Run Keyword And Continue On Failure    Should Contain    ${bthci_log}    UP RUNNING
    Log    ${bthci_log}
    Sleep    1
BT Interface Down Test
    SerialLibrary.Write Data    hciconfig ${BT_INF} down${\n}
    Sleep    5
    SerialLibrary.Write Data    hciconfig ${BT_INF} -a${\n}
    Sleep    1
    ${bthci_log}=    SerialLibrary.Read All Data    UTF-8
    Run Keyword And Continue On Failure    Should Contain    ${bthci_log}    DOWN
    Log    ${bthci_log}
    Sleep    1

BT Interface Up Test
    SerialLibrary.Write Data    hciconfig ${BT_INF} up${\n}
    Sleep    5
    SerialLibrary.Write Data    hciconfig ${BT_INF} -a${\n}
    Sleep    1
    ${bthci_log}=    SerialLibrary.Read All Data    UTF-8
    Run Keyword And Continue On Failure  Should Contain    ${bthci_log}    UP RUNNING
    Log    ${bthci_log}
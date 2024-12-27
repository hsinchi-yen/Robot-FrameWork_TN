=========================================================================
 Copyright 2024 Technexion Ltd.
 Test Case No      : TNPT PWM Test
 Purpose           : This test robot is used to check LCD resoution and touch device for TEP1-IMX7
 Category          : Functional Test  
 Script name       : Panel_Check_Test.robot
 Author            : Lance
 Date created      : 20240909
=========================================================================

*** Settings ***
Resource          ../Resources/Common_Params.robot
Library        Collections


*** Variables ***
${TOUCH_ID_STRINGS}        generic ft5x06 (82)


*** Keywords *** 
Touch IC Probe Test
    SerialLibrary.Write Data    evtest${\n}
    Sleep    1
    SerialLibrary.Write Data    ${\n}
    Sleep    1
    ${touch_node_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${touch_node_log}
    Should Contain    ${touch_node_log}    ${TOUCH_ID_STRINGS}
    Sleep    1
    SerialLibrary.Write Data    q${\n}
    Sleep    1
    ${op_log}=    SerialLibrary.Read All Data
    Log    ${op_log}



Touch Panel Resolution Check Test
    SerialLibrary.Write Data    fbset${\n}
    Sleep    1
    ${TPRC_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${TPRC_log}
    Should Contain    ${TPRC_log}    mode "800x480-54" 
    
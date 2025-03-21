=========================================================================
 Copyright 2025 Technexion Ltd.
 Test Case No      : None
 Category          : External Device - Power supply Operation  
 Script name       : GPP_PSU_Opeation.robot
 Author            : Lance
 Date created      : 20250226
=========================================================================

*** Settings ***
Library           String
Library           Collections
Resource          ../Resources/Common_Params.robot


*** Variables ***
#Device in Common_Params.robot
${POWER_UP_STATUS}        10010100
${POWER_DOWN_STATUS}      00010000

*** Keywords *** 
PSU Status
    SerialLibrary.Write Data                STATUS?\n    port_locator=${GPP_CON} 
    Sleep    1
    ${psu_status}=    SerialLibrary.Read All Data   UTF-8    port_locator=${GPP_CON}
    ${psu_status}=    Split To Lines   ${psu_status}    
    ${psu_status}=    Get From List    ${psu_status}    0
    ${psu_status}=    Convert To String    ${psu_status}
    Log    ${psu_status}    console=${DEBUG_LOG}     
    ${cur_pwr_status}=    Set Variable If    
    ...    "${psu_status}" == "${POWER_UP_STATUS}"      ON
    ...    "${psu_status}" == "${POWER_DOWN_STATUS}"    OFF
    Log    ${cur_pwr_status}    console=${DEBUG_LOG}
    RETURN    ${cur_pwr_status}

Get Average Power Reading
    #Get average power reading for sampling for 10 times
    ${total_pwr}=    Set Variable    0
    FOR    ${counter}    IN RANGE    1    11    
        ${cur_pwr}=    Get Power Reading
        ${total_pwr}=    Evaluate    ${total_pwr} + ${cur_pwr}
    END
    ${average_pwr}=    Evaluate    format(${total_pwr} / 10, '.2f')
    Log    ${average_pwr}    console=${DEBUG_LOG}
    RETURN    ${average_pwr}

Get Average Current Reading
    #Get average current reading for sampling for 10 times
    ${total_cur}=    Set Variable    0
    FOR    ${counter}    IN RANGE    1    11    
        ${cur_cur}=    Get Current Reading
        ${total_cur}=    Evaluate    ${total_cur} + ${cur_cur}
    END
    ${average_cur}=    Evaluate    format(${total_cur} / 10, '.2f')
    Log    ${average_cur}    console=${DEBUG_LOG}
    RETURN    ${average_cur}

Get Power Reading
    SerialLibrary.Write Data                :MEASure1:POWEr?\n    port_locator=${GPP_CON} 
    Sleep    1
    ${psu_voltage}=    SerialLibrary.Read All Data   UTF-8    port_locator=${GPP_CON}
    ${psu_voltage}=    Split To Lines   ${psu_voltage}    
    ${psu_voltage}=    Get From List    ${psu_voltage}    0
    ${psu_voltage}=    Convert To Number    ${psu_voltage}
    #Log    ${psu_voltage}    console=${DEBUG_LOG}     
    RETURN    ${psu_voltage}

Get Current Reading
    SerialLibrary.Write Data                :MEASure1:CURRent?\n    port_locator=${GPP_CON} 
    Sleep    1
    ${psu_current}=    SerialLibrary.Read All Data   UTF-8    port_locator=${GPP_CON}
    ${psu_current}=    Split To Lines   ${psu_current}    
    ${psu_current}=    Get From List    ${psu_current}    0
    ${psu_current}=    Convert To Number    ${psu_current}
    #Log    ${psu_current}    console=${DEBUG_LOG}     
    RETURN    ${psu_current}

Get Voltage Reading
    SerialLibrary.Write Data                :MEASure1:VOLTage?\n    port_locator=${GPP_CON} 
    Sleep    1
    ${psu_voltage}=    SerialLibrary.Read All Data   UTF-8    port_locator=${GPP_CON}
    ${psu_voltage}=    Split To Lines   ${psu_voltage}    
    ${psu_voltage}=    Get From List    ${psu_voltage}    0
    ${psu_voltage}=    Convert To Number    ${psu_voltage}
    #Log    ${psu_voltage}    console=${DEBUG_LOG}     
    RETURN    ${psu_voltage}

Set Output Voltage
    [Arguments]    ${voltage}
    #GPP Serial User Manual - Page 130
    SerialLibrary.Write Data                :SOURce1:VOLTage ${voltage}${\n}    port_locator=${GPP_CON}
    Sleep    3

#GWInstek GPP-1326 Power Supply Control
Device GPP-1326 ON
    [Documentation]    Device POWER ON
    #Log To Console    GPP-1326 ON
    #GPP Serial User Manual - Page 125
    SerialLibrary.Write Data                :OUTPut1:STATe ON${\n}    port_locator=${GPP_CON}

#GWInstek GPP-1326 Power Supply Control
Device GPP-1326 OFF
    [Documentation]    Device POWER OFF
    #GPP Serial User Manual - Page 125
    #Log To Console    GPP-1326 OFF
    SerialLibrary.Write Data                :OUTPut1:STATe OFF${\n}    port_locator=${GPP_CON}
    Sleep    0.5

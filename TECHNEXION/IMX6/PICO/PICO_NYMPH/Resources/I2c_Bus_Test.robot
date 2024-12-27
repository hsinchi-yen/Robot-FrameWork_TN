*** Settings ***
Library         String
Library         DateTime
Library         Collections
Resource        ../Resources/Common_Params.robot


*** Variables ***
#EEPROM address on TN134 PI-TEST board 
${Desired_Pattern}=        50: -- -- 52 53

*** Keywords ***
I2c Bus Scanning Test
    SerialLibrary.Write Data    i2cdetect -l${\n}
    Sleep    1
    ${i2c_test_log}=    Seriallibrary.Read All Data    UTF-8
    Log    ${i2c_test_log}
    ${i2cs}=    Get I2c buses     ${i2c_test_log}

    FOR    ${i2c_id}    IN    @{i2cs}
        Seriallibrary.Write Data    i2cdetect -y -r ${i2c_id}${\n}
        Sleep    1
        ${i2c_dump_log}=    Seriallibrary.Read All Data    UTF-8
        Log    ${i2c_dump_log}
        ${scan_state}=    Run Keyword And Return Status    Should Contain    ${i2c_dump_log}    ${Desired_Pattern}
        #Log To Console    Scan_state:${scan_state}
        Exit For Loop If    ${scan_state} == ${True}
        Continue For Loop If    ${scan_state} == ${False}
    END
    #Log To Console    ext:Scan_state:${scan_state}
    Should Be True    ${scan_state} == ${True}

Get I2c buses
    [Arguments]    ${i2clist_log}
    Log    ${i2clist_log}
    @{i2clist}=    Split To Lines    ${i2clist_log}
    ${i2clist}=    Get Slice From List    ${i2clist}    1
    ${i2clist}=    Get Slice From List    ${i2clist}    end=-1

    ${i2c_id_que}=    Create List

    FOR    ${element}    IN    @{i2clist}

        ${i2cid}=    Get Regexp Matches    ${element}    i2c-(\\d+)
        ${i2cid_number}=    Get From List    ${i2cid}    0
        Log    Extracted i2c number: ${i2cid_number} 

        ${i2c_num}=    Evaluate    __import__('re').search(r'\\d+$', '''${i2cid_number}''').group()
        Log    ${i2c_num}  
        ${i2c_num}=    Convert To String    ${i2c_num}
        Append To List    ${i2c_id_que}    ${i2c_num}       
    END

    RETURN    ${i2c_id_que}
    



    


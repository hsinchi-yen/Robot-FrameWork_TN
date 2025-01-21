=========================================================================
 Copyright 2024 Technexion Ltd.
 Test Case No      : Case TNPT-100/101
 Category          : Function 
 Script name       : I2c_Bus_Test.robot
 Author            : Lance
 Date created      : 20240617
=========================================================================
Revised date : 20250120      Raymond  
...    Added Read/Write data into EEPROM function and show progress while writing then compare data 



*** Settings ***
Library         String
Library         DateTime
Library         Collections
Resource        ../Resources/Common_Params.robot


*** Variables ***
#EEPROM address on TN134 PI-TEST board 
@{RW_Pattern}    50    51    52    53   #For R/W 
${Desired_Pattern}=        50: 50 51 52 53  #For scan 

#EEPROM address from IMX6 
#@{RW_Pattern}    54    55    56    57   
#${Desired_Pattern}=        50: -- -- -- -- 54 55 56 57  

#EEPROM address from IMX93
#@{RW_Pattern}    51    53
#${Desired_Pattern}=     50: -- 51 -- 53

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
        IF   ${scan_state} == ${True}
        Log   \nFound Target I2C bus:${i2c_id}\n${i2c_dump_log}    console=yes
        Set Global Variable    ${i2c_id}
        Exit For Loop
        Continue For Loop If    ${scan_state} == ${False}
        END
    END
    #Log To Console    ext:Scan_state:${scan_state}
    Should Be True    ${scan_state} == ${True}
    I2C EEPROM write
    I2C EEPROM read
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
    


Show Progress
    [Arguments]    ${current}    ${total}
    ${percentage}=    Evaluate    int(${current} / ${total} * 100)
    
    IF    ${percentage} == 100
        Log To Console    \rProgress: ${percentage}%    no_newline=True
        Log To Console    \nWrite Progress is done !
    ELSE
        Log To Console    \rProgress: ${percentage}%    no_newline=True
        Sleep    0.1s  
    END
    
I2C EEPROM write
    Log To Console    \nStart to Write data into EEPROM ....
    Sleep    3
    ${pattern_len}=    Get Length    ${RW_Pattern}
    ${total}=    Evaluate    ${pattern_len} * 256    
    ${count}=    Set Variable    ${0}
    
    FOR    ${p}    IN    @{RW_Pattern}
        FOR    ${hex}    IN RANGE    256
            ${count}=    Evaluate    ${count} + 1
            Show Progress    ${count}    ${total}
            Seriallibrary.Write Data    i2cset -y ${i2c_id} "0x${p}" ${hex} "0x${p}"${\n}
            Sleep    0.3
        END
    END
    

I2C EEPROM read
    Log To Console    \n
    Log To Console    \nStart to Read data from EEPROM ....
    Reset Input Buffer
    Reset Output Buffer
    Sleep    3
    FOR    ${p}    IN    @{RW_Pattern}
        
        Seriallibrary.Write Data    i2cdump -y ${i2c_id} "0x${p}"${\n}
        Sleep    1
        ${i2c_read_log}=    Seriallibrary.Read All Data    UTF-8
        Log    ${i2c_read_log}     console=yes
        Should Contain    ${i2c_read_log}    0x${p}
    END
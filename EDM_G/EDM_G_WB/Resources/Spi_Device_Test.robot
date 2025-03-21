*** Settings ***
Library         String
Library    DateTime
Resource        ../Resources/Common_Params.robot

*** Variables ***
${SPI_DEVICE}    /dev/spidev1.0
#loop n=n+1, test for 3 times, use loop as 4
${LOOP_TIME}     4

*** Keywords ***
Spi Device Test
    ${SPI_DEVICE}=    Check Spi Device Instance
    Log    spi device: ${SPI_DEVICE}

    FOR    ${test_counter}    IN RANGE    1    ${LOOP_TIME}
        ${test pattern}=    Generate Random String    32    [NUMBERS]abcdef
        SerialLibrary.Write Data    spidev_test -D ${SPI_DEVICE} -p ${test pattern} -v${\n}
        Sleep    1
        ${spi_test_log}=    Seriallibrary.Read All Data    UTF-8
        Log    ${spi_test_log}     
        Pattern Correctness Verification    ${test pattern}    ${spi_test_log}   
    END

Pattern Correctness Verification
    [Arguments]    ${verify_pattern}    ${test_log}

   @{lines}=    Split To Lines    ${test_log}
    ${tx_line}=      Get From List    ${lines}    -3
    ${rx_line}=      Get From List    ${lines}    -2

    Log    sender_content:${tx_line}
    Log    receiver_content:${rx_line}
    
    ${tx_verify_pattern}=    Get Regexp Matches    ${tx_line}         ${verify_pattern}
    ${rx_verify_pattern}=    Get Regexp Matches    ${tx_line}         ${verify_pattern}

    ${tx_verify_pattern}=    Convert To String    @{tx_verify_pattern}
    ${rx_verify_pattern}=    Convert To String    @{rx_verify_pattern}

    ${tx_pattern}=        Get Regexp Matches    ${tx_line}         (\\s\\w{2}){32}
    ${rx_pattern}=        Get Regexp Matches    ${rx_line}         (\\s\\w{2}){32}

    ${tx_pattern}=        Convert To String    @{tx_pattern}      
    ${rx_pattern}=        Convert To String    @{rx_pattern}        

    
    Log    ${tx_verify_pattern}
    Log    ${rx_verify_pattern}
    Should Be Equal As Strings    ${tx_verify_pattern}    ${verify_pattern}
    Should Be Equal As Strings    ${rx_verify_pattern}    ${verify_pattern}
    
    Log    ${tx_pattern}
    Log    ${rx_pattern}
    Should Be Equal As Strings       ${tx_pattern}    ${rx_pattern}

Check Spi Device Instance
    SerialLibrary.Write Data    ls /dev/spi*${\n}
    Sleep    1
    ${spi_dump_log}=          Seriallibrary.Read All Data    
    Log    ${spi_dump_log}

    @{spi_loglines}=     Split To Lines    ${spi_dump_log}
    ${spi_node}=         Get From List    ${spi_loglines}    -2
    ${spi_node_id}=      Get Regexp Matches    ${spi_node}         (\/dev\/spidev.+)

    ${spi_node_id}=    Convert To String    @{spi_node_id}
    RETURN   ${spi_node_id} 
*** Settings ***
Library        Collections
Resource       ../Resources/Common_Params.robot

*** Variables ***
#define memory usage for testing
${TEST_USAGE}=                0.7
#${MEM_TEST_PAUSE}=            35m
#${STRESSAPP_TEST_PAUSE}=      600  
${STRESSAPP_TEST_PAUSE}=      43200
#memtester runs 10m test requires 9 seconds. (unut: seconds)
${MEM_TEST_REQ_TIME}=    9
${STRESSAPP_TEST_REQ_TIME}=    120

*** Keywords ***
Memtester Test 
    ${allocated_mem}=       Get 70P Memory Size
    ${mem_test_pause}=      Memtester Time Calculator    ${allocated_mem}
    #Log To Console    pause seconds: ${mem_test_pause}
    Log    pause seconds: ${mem_test_pause}
    #${allocated_mem}=    Set Variable       10
    SerialLibrary.Write Data    memtester ${allocated_mem}m 1${\n}
    Sleep    ${mem_test_pause}
    #Sleep    1m
    #${mem_test_log}=        SerialLibrary.Read All Data     UTF-8
    ${mem_test_log}=        SerialLibrary.Read Until     ${TERMINATOR}
    Log    ${mem_test_log}
    Should Not Contain    ${mem_test_log}    FAILURE

Stressapptest Test 
    ${allocated_mem}=       Get 70P Memory Size
    Log    Test Memory size: ${allocated_mem}
    #${allocated_mem}=    Set Variable       10
    SerialLibrary.Write Data    stressapptest -M ${allocated_mem} -C 4 -s ${STRESSAPP_TEST_PAUSE} -W${\n}
    Sleep    ${STRESSAPP_TEST_PAUSE}
    #${mem_test_log}=        SerialLibrary.Read All Data     UTF-8
    ${mem_test_log}=        SerialLibrary.Read Until     ${TERMINATOR}
    Log    ${mem_test_log}
    Should Contain    ${mem_test_log}    PASS

Get 70P Memory Size
    SerialLibrary.Write Data    free -lm | grep Mem: | awk -F ' ' '{{print $4}}'${\n}
    Sleep    3
    ${query_mem_log}=    SerialLibrary.Read All Data    UTF-8    
    ${mem_size}=         Get Regexp Matches    ${query_mem_log}       \\d{3,}
    ${mem_digits}=       Convert To Number    @{mem_size}
    ${test_size}=        Evaluate    int(${mem_digits} * ${TEST_USAGE})
    ${Return_size}=      Convert To String    ${test_size}
    RETURN    ${Return_size}

Memtester Time Calculator
    [Arguments]    ${given_size}
    ${given_size}=    Convert To Number    ${given_size}
    #9 seconds for 10m memory size, excluded the read until default 30 seconds.
    ${need_time}=    Evaluate    int(((${given_size} - 30) / 10)*${MEM_TEST_REQ_TIME})
     ${need_time}=    Convert To String     ${need_time}
    Log    ${need_time}
    RETURN     ${need_time}

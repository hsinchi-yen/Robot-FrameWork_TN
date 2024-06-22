*** Settings ***
Library        Collections
Resource       ../Resources/Common_Params.robot

*** Variables ***
${TEST_USAGE}=                0.7
${MEM_TEST_PAUSE}=            35m
${STRESSAPP_TEST_PAUSE}=      35m  

*** Keywords ***
Memtester Test 
    ${allocated_mem}=       Get 70P Memory Size
    SerialLibrary.Write Data    memtester 1${allocated_mem}m 1${\n}
    Sleep    ${MEM_TEST_PAUSE}
    ${mem_test_log}=        SerialLibrary.Read All Data     UTF-8
    Should Not Contain    ${mem_test_log}    FAILURE

Stressapptest Test 
    ${allocated_mem}=       Get 70P Memory Size
    SerialLibrary.Write Data    stressapptest -M ${allocated_mem} -C 4 -W${\n}
    Sleep    ${MEM_TEST_PAUSE}
    ${mem_test_log}=        SerialLibrary.Read All Data     UTF-8
    Should Contain    ${mem_test_log}    PASS

Get 70P Memory Size
    SerialLibrary.Write Data    free -lm | grep Mem: | awk -F ' ' '{{print $4}}'${\n}
    Sleep    1
    ${query_mem_log}=    SerialLibrary.Read All Data    UTF-8    
    ${mem_size}=         Get Regexp Matches    ${query_mem_log}       \\d{3,}
    ${mem_digits}=       Convert To Number    @{mem_size}
    ${test_size}=        Evaluate    int(${mem_digits} * ${TEST_USAGE})
    ${Return_size}=      Convert To String    ${test_size}
    Log    ${Return_size}
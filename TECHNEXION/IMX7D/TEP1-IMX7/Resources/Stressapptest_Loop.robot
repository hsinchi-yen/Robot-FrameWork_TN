=========================================================================
 Copyright 2024 Technexion Ltd.
 Test Case No      : TNPT 172 
 Purpose           : This test robot is used to test memory with stressapptest 
 Category          : stress Test  
 Script name       : Stressapptest_Loop.robot
 Author            : Lance
 Date created      : 20240830
=========================================================================

*** Settings ***
Resource          ../Resources/Common_Params.robot
Library        Collections


*** Variables ***
${TEST_LOOP}        73
#define memory usage for testing
${TEST_USAGE}=                0.7
#${MEM_TEST_PAUSE}=            35m
${STRESSAPP_LOOP_PAUSE}=      600


*** Keywords *** 
StressApptest Loop 
    ${allocated_mem}=       Get 70P Memory Size
    Log    Test Memory size: ${allocated_mem}
    #${allocated_mem}=    Set Variable       10

    FOR    ${counter}    IN RANGE    1    ${TEST_LOOP}
        Log To Console    loop:${counter}
        SerialLibrary.Write Data    stressapptest -M ${allocated_mem} -C 2 -s ${STRESSAPP_LOOP_PAUSE} -W${\n}
        Sleep    590
        #${mem_test_log}=        SerialLibrary.Read All Data     UTF-8
        ${mem_test_log}=        SerialLibrary.Read Until     ${TERMINATOR}
        Log    ${mem_test_log}
        Run Keyword And Continue On Failure   Should Contain    ${mem_test_log}    PASS    
    END

Get 70P Memory Size
    SerialLibrary.Write Data    free -lm | grep Mem: | awk -F ' ' '{{print $4}}'${\n}
    Sleep    3
    ${query_mem_log}=    SerialLibrary.Read All Data    UTF-8    
    ${mem_size}=         Get Regexp Matches    ${query_mem_log}       \\d{3,}
    ${mem_digits}=       Convert To Number    @{mem_size}
    ${test_size}=        Evaluate    int(${mem_digits} * ${TEST_USAGE})
    ${Return_size}=      Convert To String    ${test_size}
    RETURN    ${Return_size}




*** Comments ***
=========================================================================
 Copyright 2024 Technexion Ltd.
 Test Case No      : Case TNPT-128
 Category          : Benchmark Test  
 Script name       : Memory Benchmark.robot
 Author            : Raymond 
 Date created      : 20241112
=========================================================================
*** Settings ***
Library        Collections
Library        DateTime
Library        Process
Resource       ../Resources/Common_Params.robot

*** Variables ***
${test_loop}    1
#mem score spec.
${SCORE_SPEC}    4000

     
*** Keywords ***
Run memory benchmark Command 
    SerialLibrary.Write Data    ramsmp -b 3 -l ${test_loop}${\n}
    ${mem_bench_log}=    SerialLibrary.Read Until    ${TERMINATOR}
    Log    ${mem_bench_log}
    Mem Score Verification    ${mem_bench_log}
  

#Read SerialConsole and output
#    WHILE    True
#        ${line}=    SerialLibrary.Read Until    ${\n}
#        Log     ${line}    console=yes
#        IF    '${TERMINATOR}' in '''${line}'''    BREAK
#    END

Mem Score Verification
    [Arguments]    ${test_score_log}
    @{lines}=    Split To Lines    ${test_score_log}
    ${avg_line}=      Get From List    ${lines}    -3
    Log    ${avg_line}

    ${last_avg_score}=       Get Regexp Matches    ${avg_line}        \\d+.\\d+
    ${last avg_score}=       Convert To String    ${last avg_score}[0]
    ${last avg_score}=       Convert To Number    ${last_avg_score}
    Log    ${last avg_score}    console=yes
    Should Be True        ${last_avg_score} > ${SCORE_SPEC}



*** Comments ***
=========================================================================
 Copyright 2024 Technexion Ltd.
 DUT               : Applicable for all platform
 Purpose           : Benchmark Test for SOC - Memory test , CPU test 
 Script name       : Benchmark_test.robot
 Author            : lancey 
 Date created      : 20250107
=========================================================================
*** Settings ***
Library        Collections
Resource          ../Resources/Common_Params.robot

*** Variables ***
${test_loop}    1
#mem score spec.
${SCORE_SPEC}    4000

*** Keywords ***
CPU Benchmark Test - Single Core
    SerialLibrary.Write Data    sysbench --test=cpu --cpu-max-prime=1000000 run${\n}
    ${cpu_bench_s_log}=    SerialLibrary.Read Until    ${TERMINATOR}
    Log    ${cpu_bench_s_log}


CPU Benchmark Test - Multi Core
    ${soc_cores}=    Get Core Qty
    Log    Cores of the CPU : ${soc_cores} 
    SerialLibrary.Write Data    sysbench --test=cpu --num-threads=${soc_cores} --cpu-max-prime=1000000 run${\n}
    ${cpu_bench_log}=    SerialLibrary.Read Until    ${TERMINATOR}
    Log    ${cpu_bench_log}

Get Core Qty
    SerialLibrary.Write Data    grep "processor" /proc/cpuinfo | wc -l${\n}
    Sleep    1
    ${cpu_qty_log}=    SerialLibrary.Read All Data    UTF-8
    #Log    ${cpu_qty_log}
    ${cpu_qty_match}=       Get Regexp Matches    ${cpu_qty_log}    \\d
    ${cpu_qty}=    Set Variable    ${cpu_qty_match}[0]
    RETURN    ${cpu_qty}

#---------------------------------------------------------------
#Memory Benchmark Test - Single Core
#    SerialLibrary.Write Data    ramspeed -b 3 -l 3${\n}
#    ${mem_bench_s_log}=    SerialLibrary.Read Until    ${TERMINATOR}
#    Log    ${mem_bench_s_log}


Memory Benchmark Test - Multi Core
    SerialLibrary.Write Data    ramsmp -b 3 -l ${test_loop}${\n}
    ${mem_bench_log}=    SerialLibrary.Read Until    ${TERMINATOR}
    Log    ${mem_bench_log}
    Mem Score Verification    ${mem_bench_log}

Mem Score Verification
    [Arguments]    ${test_score_log}
    @{lines}=    Split To Lines    ${test_score_log}
    ${avg_line}=      Get From List    ${lines}    -3
    Log    ${avg_line}

    ${last_avg_score}=       Get Regexp Matches    ${avg_line}        \\d+.\\d+
    ${last avg_score}=       Convert To String    ${last avg_score}[0]
    ${last avg_score}=       Convert To Number    ${last_avg_score}
    Log    ${last avg_score}    console=yes
    
    #${score}=    Get Regexp Matches    ${last_avg_score}    \\d+.\\d+
    #${score}=    Convert To String   ${score}
     
    #Log    ${score}
    #${score_digi}=        Convert To Number    ${score}
    Should Be True        ${last_avg_score} > ${SCORE_SPEC}




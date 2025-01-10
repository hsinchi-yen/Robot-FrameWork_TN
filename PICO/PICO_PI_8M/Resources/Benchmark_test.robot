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
    ${avg_score}=       Get Regexp Matches    ${test_score_log}    INTEGER\ \ \ AVERAGE:\ \ \ \\d+[.\\d+]*\\sMB/s
    ${score}=           Get Regexp Matches    ${avg_score}    \\d+.\\d+ MB/s
    Log    ${score}
    ${score_digi}=        Convert To Integer    ${score}
    Should Be True        ${score_digi} > ${SCORE_SPEC}
    


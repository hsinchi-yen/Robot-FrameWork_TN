*** Comments ***
=========================================================================
 Copyright 2024 Technexion Ltd.
 Script name       : SOM_Benchmark_Test.robot
 Purpose           : Operation for benchmark test for CPU RAM
 Author            : Lance
 Date created      : 20240829
=========================================================================
*** Settings ***
Library        Collections
Resource       ../Resources/Common_Params.robot

*** Variables ***
#Unit is seconds
${CORES_RAM_TEST_TIME}=   3m

*** Keywords ***
Run Ramsmp Test For Multicore
    SerialLibrary.Write Data    ramsmp -b 3 -l 1${\n}
    Sleep    ${CORES_RAM_TEST_TIME}
    ${ram_test_log}=    SerialLibrary.Read Until    ${TERMINATOR}
    Log    ${ram_test_log}


Run CPU Benchmark Test
    SerialLibrary.Write Data    sysbench cpu --cpu-max-prime=100000 --threads=2 run${\n}
    Sleep    3
    ${cpu_benchmark_log}=    SerialLibrary.Read Until    ${TERMINATOR}
    Log    ${cpu_benchmark_log}
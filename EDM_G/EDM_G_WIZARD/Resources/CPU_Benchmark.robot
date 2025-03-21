*** Comments ***
=========================================================================
 Copyright 2025 Technexion Ltd.
 Test Case No      : Case TNPT-127
 Category          : Benchmark Test  
 Script name       : CPU Benchmark.robot
 Author            : Raymond 
 Date created      : 20250108
=========================================================================
Revised 20250224    Lance
Adjust script for remove redunt if else statement
-------------------------------------------------------------------------

*** Settings ***
Library        Collections
Library        DateTime
Library        Process
Resource       ../Resources/Common_Params.robot

*** Variables ***

     


*** Keywords ***
Run CPU benchmark Command 
    
    SerialLibrary.Write Data     grep processor /proc/cpuinfo | wc -l${\n}
    Sleep    1
    ${data}=    SerialLibrary.Read All Data    UTF-8
    @{lines}=    Split To Lines    ${data}
    ${CPU_Num}=      Get From List    ${lines}    1
    Log    ${CPU_Num}
    Log    \nCPU Core Number is ${CPU_Num}    console=yes
    SerialLibrary.Write Data    sysbench --test=cpu --cpu-max-prime=100000 --num-threads=${CPU_Num} run${\n}   
    ${line}=    SerialLibrary.Read Until    ${TERMINATOR}  
    Log    ${line}    console=${DEBUG_LOG} 
    #to do add benchmark score verification




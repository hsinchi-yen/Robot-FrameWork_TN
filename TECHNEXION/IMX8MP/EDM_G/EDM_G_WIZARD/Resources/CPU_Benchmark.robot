*** Comments ***
=========================================================================
 Copyright 2025 Technexion Ltd.
 Test Case No      : Case TNPT-127
 Category          : Benchmark Test  
 Script name       : CPU Benchmark.robot
 Author            : Raymond 
 Date created      : 20250108
=========================================================================
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
   
    IF    ${CPU_Num} > 1 
        SerialLibrary.Write Data    sysbench --test=cpu --num-threads=${CPU_Num} --cpu-max-prime=100000 run${\n}
      
    ELSE IF   ${CPU_Num} == 1 
        SerialLibrary.Write Data    sysbench --test=cpu --cpu-max-prime=100000 run &${\n}

    END
    ${line}=    SerialLibrary.Read Until    ${TERMINATOR}  
    Log    ${line}    console=yes 





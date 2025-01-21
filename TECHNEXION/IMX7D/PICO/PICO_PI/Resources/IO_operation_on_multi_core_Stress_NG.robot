*** Comments ***
=========================================================================
 Copyright 2024 Technexion Ltd.
 Test Case No      : Case TNPT-222
 Category          : Stress Test  
 Script name       : IO_operation_on_multi_core_Stress_NG.robot
 Author            : Raymond 
 Date created      : 20240712
=========================================================================
*** Settings ***
Library        Collections
Library        DateTime
Library        Process
Resource       ../Resources/Common_Params.robot

*** Variables ***
#Unit is seconds

${Duration}=     43200s       
${CheckInterval}=    43210

*** Keywords ***
StressNG Command
    SerialLibrary.Write Data     grep processor /proc/cpuinfo | wc -l${\n}
    Sleep    1
    ${data}=    SerialLibrary.Read All Data    UTF-8
    @{lines}=    Split To Lines    ${data}
    ${CPU_Num}=      Get From List    ${lines}    1
    
    Log    ${CPU_Num}
    Log To Console    CPU Core Number is ${CPU_Num}
    Log    CPU Core Number is ${CPU_Num}
    
    IF    ${CPU_Num} == 4 

        SerialLibrary.Write Data    taskset 0x1 stress-ng --cpu ${CPU_Num} --io 1 --timeout ${Duration} &${\n}
        SerialLibrary.Write Data    taskset 0x2 stress-ng --cpu ${CPU_Num} --io 1 --timeout ${Duration} &${\n}
        SerialLibrary.Write Data    taskset 0x4 stress-ng --cpu ${CPU_Num} --io 1 --timeout ${Duration} &${\n}
        SerialLibrary.Write Data    taskset 0x8 stress-ng --cpu ${CPU_Num} --io 1 --timeout ${Duration} &${\n}

    ELSE IF    ${CPU_Num} == 2 
        SerialLibrary.Write Data    taskset 0x1 stress-ng --cpu ${CPU_Num} --io 1 --timeout ${Duration} &${\n}
        SerialLibrary.Write Data    taskset 0x2 stress-ng --cpu ${CPU_Num} --io 1 --timeout ${Duration} &${\n}
    ELSE IF    ${CPU_Num} == 1

        SerialLibrary.Write Data    taskset 0x1 stress-ng --cpu ${CPU_Num} --io 1 --timeout ${Duration} &${\n}

    END


Wait For Completion
    Sleep    ${CheckInterval}
    
    ${output}=    SerialLibrary.Read All Data    UTF-8
    #Log    ${output}
    Should Contain    ${output}    successful run completed
       
    RETURN    ${output} 
        
        

StressNG Test
    StressNG Command
    ${output}=    Wait For Completion
    Log To Console    Stress test completed
    Log To Console    ${output}
    Pass Execution    Stress test completed successfully
      
 





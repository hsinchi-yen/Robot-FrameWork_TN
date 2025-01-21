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

     


*** Keywords ***
Run memory benchmark Command 
    
    SerialLibrary.Write Data     ramsmp -b 3 -l 5${\n}
    Read SerialConsole and output
  

Read SerialConsole and output
    WHILE    True
        ${line}=    SerialLibrary.Read Until    ${\n}
        Log     ${line}    console=yes
        IF    '${TERMINATOR}' in '''${line}'''    BREAK
    END



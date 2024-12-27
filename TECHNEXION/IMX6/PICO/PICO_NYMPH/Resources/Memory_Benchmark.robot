*** Settings ***
Library        Collections
Library        Process
Library        OperatingSystem
Resource       ../Resources/Common_Params.robot

*** Variables ***


*** Keywords ***
Memory Benchmark
    SerialLibrary.Write Data    ramsmp -b 3 -l 1${\n}
    SerialLibrary.Read Until    ${TERMINATOR}
    
        
   
   

   
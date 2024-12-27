*** Settings ***
Library        Collections

Resource       ../Resources/Common_Params.robot

*** Variables ***
#{CPU_Num} is Global variable in IO_operation_on_multi_core_Stress_NG.robot

*** Keywords ***
Get Mem Size
    ${memsize}=    SerialLibrary.Write Data    free -m | grep 'Mem:' | awk -F ' ' '{print $2}'${\n}
    Sleep    1
    SerialLibrary.Read All Data
Memory Benchmark

    SerialLibrary.Write Data    sysbench --test=memory --memory-block-size=8K --memory-total-size=${1}  --num-threads=${CPU_Num} run${\n}
    Sleep    30
    SerialLibrary.Read All Data
    
        
   
   

   
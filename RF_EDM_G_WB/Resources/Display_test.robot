*** Settings ***
Library        Collections
Resource       ../Resources/Common_Params.robot

*** Variables ***
${GPU_TEST_CMD}      glmark2-es2-wayland

*** Keywords ***
3D Glmark Benchmark Test
    SerialLibrary.Write Data    ${GPU_TEST_CMD}${\n}
    Sleep    6m 30s
    ${3dbenchmark_log}=        SerialLibrary.Read All Data    UTF-8
    Log    ${3dbenchmark_log}
    ${3D_Score}=    Extract Glmark2 Score    ${3dbenchmark_log}
    Should Contain    ${3dbenchmark_log}    glmark2 Score:
    Log    GPU Benchmark Score : ${3D_Score}
    
Extract Glmark2 Score
    [Arguments]    ${glmark_log}
    @{lines}=    Split To Lines    ${glmark_log}
    ${score_line}=      Get From List    ${lines}    -3
    Log    score line:${score_line}
 
    ${score_entity}=       Get Regexp Matches    ${score_line}            \\d{2,}
    ${return_score}=       Convert To String     ${score_entity}

    RETURN    ${return_score}


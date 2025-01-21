*** Settings ***
Resource        ../Resources/Common_Params.robot

*** Variables ***
${SUCCESS_COUNT}    0
${FAILURE_COUNT}    0
${Err_msg_cnt}    0

*** Keywords ***
Camera Probe Issue 
    ${LOOP_TIME}=    Set Variable     11
    FOR    ${counter}    IN RANGE    1    ${LOOP_TIME}
        Log To Console  \n================Test Count:${counter}================\n
        
        Log    Test Count:${counter}
        Log To Console    \n System POWER OFF ......\n
        Device OFF
        Sleep    3
        Device ON
        Log To Console    \n System POWER ON ......\n
        Booting time record and wait for login
        Sleep    10
   

        #Check Camera Device exist or not 
        SerialLibrary.Write Data    dmesg | grep 'Product:TE' | cut -d',' -f1 | sed 's/.*Product: *//'${\n}
        Sleep    1
        ${result}=    Read All Data   UTF-8
        ${camera_match}=    Get Regexp Matches   ${result}    TEV[A-Z]\-AR\\d+

        IF    ${camera_match} 
              ${camera_info}=    Set Variable    ${camera_match[0]}  
               Log To Console    \nCamera device is detected:${camera_info}
               ${SUCCESS_COUNT}=    Evaluate    ${SUCCESS_COUNT} + 1
               Log To Console    --->PASS COUNT : ${SUCCESS_COUNT}
               Sleep    1
               Camera-TEVS-AR0234 
               Sleep    5
               
        ELSE
               Log To Console    \nCamera is not detected.
               ${FAILURE_COUNT}=    Evaluate    ${FAILURE_COUNT} +1
               Log To Console     --->FAIL COUNT : ${FAILURE_COUNT}
               Sleep    1
               SerialLibrary.Write Data    dmesg -T\n 
               ${dmesg_log}=    SerialLibrary.Read Until    ${TERMINATOR}
               Log    ${dmesg_log}
               Run Keyword And Continue On Failure    Should Not Contain    ${dmesg_log}    Failed to read from register
        END
        

    END
    IF    ${FAILURE_COUNT} > 0
        Log To Console    \n=========================
        Log To Console    Final Result: FAIL
        Log    PASS COUNT: ${SUCCESS_COUNT}    console=yes
        Log    FAIL COUNT: ${FAILURE_COUNT}    console=yes
        Log To Console    =========================  
        Fail    Test failed with FAIL COUNT:${FAILURE_COUNT} 
        
    ELSE
        Log To Console    \n=========================
        Log To Console    Final Result: PASS 
        Log    PASS COUNT: ${SUCCESS_COUNT}    console=yes
        Log    FAIL COUNT: ${FAILURE_COUNT}    console=yes
        Log To Console    =========================
    END
    
  



    
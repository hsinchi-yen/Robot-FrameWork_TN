*** Settings ***
Resource        ../Resources/Common_Params.robot

*** Variables ***
${AUDIO_SUCCESS_COUNT}    0
${AUDIO_FAILURE_COUNT}    0
${Err_msg_cnt}    0

*** Keywords ***
Audio Issue with Reboot
    ${LOOP_TIME}=    Set Variable      21
    FOR    ${counter}    IN RANGE    1    ${LOOP_TIME}
        Log To Console  \n================Test Count:${counter}================\n
        
        Log    Test Count:${counter}
        Log To Console    \n System reboot ......\n
        SerialLibrary.Write Data    reboot\n

        Booting time record and wait for login   
        Sleep     5
   

        #Check Audio Device exist or not 
        SerialLibrary.Write Data    aplay -l${\n}
        ${log}=    SerialLibrary.Read Until    ${TERMINATOR}
        Log    ${log}
        Log To Console    ${log}

        ${found_in_var}=    Run Keyword And Return Status    Should Contain    ${log}    wm8960audio 

        IF    ${found_in_var}   
               Log To Console    \nAudio device is detected
               ${AUDIO_SUCCESS_COUNT}=    Evaluate    ${AUDIO_SUCCESS_COUNT} + 1
               Log To Console    --->AUDIO_PASS COUNT : ${AUDIO_SUCCESS_COUNT}
               Sleep    1
                 
        ELSE
               Log To Console    \nAUDIO is not detected.
               ${AUDIO_FAILURE_COUNT}=    Evaluate    ${AUDIO_FAILURE_COUNT} +1
               Log To Console     --->AUDIO_FAIL COUNT : ${AUDIO_FAILURE_COUNT}
               Sleep    1
        END
            #Check error Message
        SerialLibrary.Write Data    dmesg -T\n 
        ${dmesg_log}=    SerialLibrary.Read Until    ${TERMINATOR}
        Log    ${dmesg_log}
        ${Sound_Err}=    Run Keyword And Continue On Failure    Should not Contain    ${dmesg_log}    sound-wm8960 failed with error -22
        IF    ${Sound_Err} 
          Log To Console    No Audio err message found 

        ELSE
          Log To Console    WM8960 error message found ! 
          ${Err_msg_cnt}=    Evaluate    ${Err_msg_cnt} +1 
          Log To Console    --->Error Message count: ${Err_msg_cnt}           
                     
        END
        
        
         

    END

    Log    PASS COUNT: ${AUDIO_SUCCESS_COUNT}
    Log    FAIL COUNT: ${AUDIO_FAILURE_COUNT}
    Log    Error Message count: ${Err_msg_cnt}



    
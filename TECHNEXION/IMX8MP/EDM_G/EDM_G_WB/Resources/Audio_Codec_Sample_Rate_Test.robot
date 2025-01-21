=========================================================================
 Copyright 2024 Technexion Ltd.
 Test Case No      : TNPT-525 Audio Codec Sample Rate Test
 Category          : Functional Test  
 Script name       : Audio_Codec_Sample_Rate_Test.robot
 Author            : Raymond
 Date created      : 20241104
=========================================================================

*** Settings ***
Library    String
Resource          ../Resources/Common_Params.robot



*** Variables ***

${Audio_Codec_SCRIPT}       Audio_codec_test.sh
${DL_SERVER_IP}         10.88.88.229

*** Keywords *** 
Audio Codec Sample Rate Test
    Download Audio Codec Script
    SerialLibrary.Write Data    bash ${Audio_Codec_SCRIPT}${\n}
    
    Read SerialConsole and output
   
Read SerialConsole and output
    WHILE    True
        ${line}=    SerialLibrary.Read Until    ${\n}
        Log     ${line}    console=yes
        IF    '${TERMINATOR}' in '''${line}'''    BREAK
    END
Download Audio Codec Script
    SerialLibrary.Write Data    ifconfig -a | grep -E "${ETH_INF}|wlan" -A 2${\n}
    Sleep    1
    ${chklog}=    SerialLibrary.Read All Data    UTF-8
    Log    ${chklog}

    ${conn_stat}=    Run Keyword And Return Status    Should Match Regexp    ${chklog}    inet\ \\w+.\\w+.\\w+.\\w+

    IF    ${conn_stat} == $True
          SerialLibrary.Write Data    wget -O ${Audio_Codec_SCRIPT} http://${DL_SERVER_IP}/test_scripts/${Audio_Codec_SCRIPT}${\n}
          Sleep    1

          ${dl_log}=    SerialLibrary.Read Until    ${TERMINATOR}
          Log    ${dl_log} 
    ELSE    
        Log    Internal LAN/WLAN Connection is ${conn_stat}
        Fail
    END


        

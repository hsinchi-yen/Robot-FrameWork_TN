=========================================================================
 Copyright 2024 Technexion Ltd.
 Test Case No      : Case TNPT-117
 Category          : Stress 
 Script name       : WIFI_Stresss_12H.robot
 Author            : Raymond 
 Date created      : 20240826
=========================================================================
*** Settings ***
Library           Collections
Library           SeleniumLibrary
Library           Process

Resource       ../Resources/Common_Params.robot
Library        ../Libraries/EnvVariablesReturnLib.py

*** Variables ***

${BROWSER}        Chrome
${DELAY}          0

${URL}      http://127.0.0.1:5000

#netstat -tuln | grep :5000  , to check port is using or not 
*** Keywords ***

Initial Check and Setup server  
      
    # Get Wifi Ip Address
    # ${status}=    Run Keyword And Return Status    Should Not Be Empty    ${wifi_ip_string}
    # Run Keyword If    ${status} == ${TRUE}    Log    WIFI is set: ${wifi_ip_string}
    # ...    ELSE    Run keywords    Wifi Connection test 

    Wifi Connection test       #Force system to connect wifi at beginning
    Get Wifi Ip Address
    Sleep    1
    Run Iperf3 Command in DUT as Server
 
Execute Bandwidth Chart
    
    ${result}=    Start Process    python3   iperf3_chart_rev1.2.py   
    Log    ${result.stdout}
    Log    stderr: ${result.stderr}
    
Open Browser to Bandwidth Chart
    Open Browser    ${URL}    ${BROWSER}
    Set Window Size    1400    950
    #Maximize Browser Window
    Set Selenium Speed    ${DELAY}
    Title Should Be    Bandwidth Chart
    Reload Page
    

Input Test Parameter
  
    Input Text    server_ip       ${wifi_ip_string}
    Input Text    run_times     0   
    Select From List By Value    mode    reverse

Submit Iperf3 
    Click Button    startButton
   
    
Close Process 
    Close Browser
    ${result}=    Run Process    fuser -k 5000/tcp    shell=True
    Log    ${result.stdout}
    Log    stderr: ${result.stderr}
    Terminate Iperf3 Process

Terminate Iperf3 Process
    
    Log To Console    Terminating IPerf3 process with PID: ${iperf3_PID}
    SerialLibrary.Write Data    kill ${iperf3_PID}${\n}
    Sleep    2
    ${output}=    SerialLibrary.Read All Data    UTF-8
    Log    ${output}



Run Iperf3 Command in DUT as Server 
    ${start_time}=    Get Time    epoch
    SerialLibrary.Write Data     iperf3 -s&${\n}
    Sleep    1 
    ${pid}=    SerialLibrary.Read All Data    UTF-8
    ${RE_PID}=       Get Regexp Matches    ${pid}            \\[\\d+\]\\s+(\\d+)    1
    ${iperf3_PID}=    Get From List    ${RE_PID}       0
    Set Global Variable    ${iperf3_PID}      
    RETURN    ${iperf3_PID}


Start WIFI stress 
    Initial Check and Setup server 
    Execute Bandwidth Chart
    Sleep    7
    Open Browser to Bandwidth Chart 
    Input Test Parameter
    Submit Iperf3 
    Sleep    43200
    Capture Page Screenshot    WIFI_ScreenShot.png
    Close Process 
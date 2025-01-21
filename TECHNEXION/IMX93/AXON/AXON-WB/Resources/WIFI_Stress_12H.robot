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


#netstat -tuln | grep :5000  , to check port is using or not 
*** Keywords ***

WIFI Connection Check 
     ${wifi_ip_string}=    Attempt To Get Wifi Ip
        IF    "${wifi_ip_string}" != "${EMPTY}"
            Log To Console    \nExisted WIFI IP is : ${wifi_ip_string}

        ELSE  
            Log To Console    \nWiFi is setting up.....     
            Wifi_Connection_test
            Get Wifi Ip Address
            Log To Console    \nConnected WIFI IP is : ${wifi_ip_string}
        END


Attempt To Get Wifi Ip
    SerialLibrary.Write Data    ifconfig ${WIFI_INF}${\n}
    Sleep    1
    ${wifi_chk_log}=        SerialLibrary.Read All Data    UTF-8
    ${wifi_ip_match}=       Get Regexp Matches    ${wifi_chk_log}    inet 10\.88\.\\d+\.\\d+
    ${wifi_ip_string}=    Set Variable    ${EMPTY}
    IF    ${wifi_ip_match}
          ${wifi_ip_string}=    Strip String    @{wifi_ip_match}    characters=inet${SPACE}
          Set Global Variable    ${wifi_ip_string}
    END
    RETURN    ${wifi_ip_string}
Find TCP port 
    ${PORT_REGEX}=    Set Variable      (?<=Starting server on port )(\\d+)
    #${check_port}=    Run process    sudo netstat -tulnp | grep python    shell=${True}
    ${output}=    OperatingSystem.Get File    stdout.txt
    Log To Console    \n${output}
    Log     ${output}
    ${Find_tcp_port}=    Get Regexp Matches    ${output}    ${PORT_REGEX}
    Log    Found tcp port: ${Find_tcp_port[0]}      console=yes
    ${TCP_PORT}=    Set Variable    ${Find_tcp_port[0]} 
    Set Global Variable    ${TCP_PORT}
  
   
Execute Bandwidth Chart
    ${Process}=    Start Process    python3    iperf3_chart_rev1.5.py    stdout=stdout.txt        
    #The stdout should be set otherwise the graph will stop at run 18 until close the robot process
    Sleep    5
    Find TCP port 
    # ${check_port}=    Run Process   netstat \-tuln \| grep \:5000    shell=True
    # Sleep    1
    # Log    ${check_port.stdout}
    # Should Contain    ${check_port.stdout}    :5000       
   
    
Open Browser to Bandwidth Chart
    ${URL}=    Set Variable    http://127.0.0.1:${TCP_PORT} 
    Open Browser    ${URL}    ${BROWSER}
    Set Window Size    1400    900
    #Maximize Browser Window
    Set Selenium Speed    ${DELAY}
    Title Should Be    Bandwidth Chart
    Reload Page
    

Input Test Parameter
    Input Text    client_ip       ${wifi_ip_string}
    Input Text    server_ip    ${IPERF_SERV}
    #Select From List By Value    server_ip    ${IPERF_SERV} 
    Input Text    run_times     0   
    Select From List By Value    mode    bidir

Submit Iperf3 
    Click Button    startButton
   
    
Close Process 
    Close Browser
    ${result}=    Run Process    fuser -k ${TCP_PORT}/tcp    shell=True
    Log    ${result.stdout}
    Log    stderr: ${result.stderr}
    #Terminate Iperf3 Process

# Terminate Iperf3 Process
    
#     Log To Console    Terminating IPerf3 process with PID: ${iperf3_PID}
#     SerialLibrary.Write Data    kill all ${iperf3_PID}${\n}
#     Sleep    2
#     ${output}=    SerialLibrary.Read All Data    UTF-8
#     Log    ${output}



# Run Iperf3 Command in DUT as Server 
#     ${start_time}=    Get Time    epoch
#     SerialLibrary.Write Data     iperf3 -s&${\n}
#     Sleep    1 
#     ${pid}=    SerialLibrary.Read All Data    UTF-8
#     ${RE_PID}=       Get Regexp Matches    ${pid}            \\[\\d+\]\\s+(\\d+)    1
#     ${iperf3_PID}=    Get From List    ${RE_PID}       0
#     Set Global Variable    ${iperf3_PID}      
#     RETURN    ${iperf3_PID}


Start WIFI stress 
    Eth Ip Address Checker
    
    #Initial Check and Setup server 
    WIFI Connection Check  #if no ip found then create connection
    Execute Bandwidth Chart
    Open Browser to Bandwidth Chart 
    Input Test Parameter
    Sleep    10
    Submit Iperf3 
    Log To Console    Start IPerf3 stress....
    Sleep    43200
    Log To Console    Test Done and take screenshot\n
    Capture Page Screenshot    WIFI_ScreenShot.png
    Close Process 
    Eth Ip Address Resume
    Sleep    10
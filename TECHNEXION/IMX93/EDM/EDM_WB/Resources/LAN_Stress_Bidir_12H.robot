=========================================================================
 Copyright 2024 Technexion Ltd.
 Test Case No      : Case TNPT-386
 Category          : Stress 
 Script name       : LAN_Stresss_12H_Bidir.robot
 Author            : Raymond 
 Date created      : 20240913
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

LAN1 Initial Check and Setup server  
      
    #Wifi Connection test       #Force system to connect wifi at beginning
    Get LAN1 Eth Ip Address
    
    Sleep    1
    #Run Iperf3 Command in DUT as Server

LAN2 Initial Check and Setup server  
      
    #Wifi Connection test       #Force system to connect wifi at beginning
    Get LAN2 Eth Ip Address
    
    Sleep    1
    #Run Iperf3 Command in DUT as Server

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
    
    ${Process}=    Start Process    python3    iperf3_chart_rev1.4.py    stdout=stdout.txt        
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
    Set Window Size    1400    950
    #Maximize Browser Window
    Set Selenium Speed    ${DELAY}
    Title Should Be    Bandwidth Chart
    Reload Page
    
    

LAN1 Input Test Parameter
  
    Input Text    client_ip       ${eth_ip_string1}
    Select From List By Value    server_ip    ${IPERF_SERV}
    Input Text    run_times     0   
    Select From List By Value    mode    bidir  # mode can be normal/reverse/bidir

LAN2 Input Test Parameter
  
    Input Text    client_ip       ${eth_ip_string2}
    Select From List By Value    server_ip    ${IPERF_SERV}
    Input Text    run_times     0   
    Select From List By Value    mode    bidir  # mode can be normal/reverse/bidir
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


Start LAN1 stress Bidir
    Wifi Ip Address Checker
    Log To Console    \nStart LAN1 Stress...
    LAN1 Initial Check and Setup server 
    Log To Console    \nYour LAN1 IP is : ${eth_ip_string1}
    Execute Bandwidth Chart
    Open Browser to Bandwidth Chart 
    LAN1 Input Test Parameter
    Submit Iperf3 
    Log To Console    \nStart Iperf3 Test....
    Sleep    43200
    Log To Console    Test Done and take screenshot\n
    Capture Page Screenshot    LAN1_ScreenShot.png
    Close Process 
    Wifi Ip Address Resume
    Sleep    10

Start LAN2 stress Bidir
    Wifi Ip Address Checker
    Log To Console    \nStart LAN2 Stress...
    LAN2 Initial Check and Setup server 
    Log To Console    \nYour LAN2 IP is : ${eth_ip_string2}
    Execute Bandwidth Chart
    Open Browser to Bandwidth Chart 
    LAN2 Input Test Parameter
    Submit Iperf3 
    Log To Console    \nStart Iperf3 Test....
    Sleep    43200
    Log To Console    Test Done and take screenshot\n
    Capture Page Screenshot    LAN2_ScreenShot.png
    Close Process 
    Wifi Ip Address Resume
    Sleep    10

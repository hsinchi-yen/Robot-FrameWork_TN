=========================================================================
 Copyright 2024 Technexion Ltd.
 Test Case No      : Case TNPT-167
 Category          : Stress 
 Script name       : CPU_MEM_GPU_WIFI_Stresss.robot
 Author            : Raymond 
 Date created      : 20240924
=========================================================================
*** Settings ***
Library           Collections
Library           SeleniumLibrary
Library           Process
Library           OperatingSystem
  

Resource       ../Resources/Common_Params.robot
Library        ../Libraries/EnvVariablesReturnLib.py

*** Variables ***

${BROWSER}        Chrome
${DELAY}          0

${Script_PATH}    /opt/thermal-imx-test/thermal_basic_func.sh
${OLD_String}    3M 
${NEW_String}    400K
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
    RETURN    ${output}
Execute System Monitor
    
    ${Process}=    Start Process    python3    -u   system_monitor_rev0.4.py    stdout=stdout.txt        
    #The stdout should be set otherwise the graph will stop at run 18 until close the robot process
    #-u means pythonunbuffered=x , if not set sdtout will be updated every 15 minutes later
    Sleep    5
    Find TCP port     
   
    
Open Browser to System Monitor
    ${URL}=    Set Variable    http://127.0.0.1:${TCP_PORT} 
    Open Browser    ${URL}    ${BROWSER}
    Set Window Size    1400    960
    #Maximize Browser Window
    Set Selenium Speed    ${DELAY}
    Title Should Be    System Monitoring Chart
    Reload Page
    

Input Test Parameter
  
    Input Text    client_ip       ${wifi_ip_string}
    Input Text    filename     thermal_cpu_mem_gpu_wifi.log   
    

Submit monitor button
    Click Button    startMonitoring
  
   
    
Close Process 
    ${ouput}=    Find TCP port
    Close Browser
    ${result}=    Run Process    fuser -k ${TCP_PORT}/tcp    shell=True
    Log    ${result.stdout}
    Log    stderr: ${result.stderr}
    SerialLibrary.Write Data    \x03${\n}
    Sleep    1
    ${log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${log}


Execute command 

    Log To Console    Running Stress Test.... 
    SerialLibrary.Write Data    /opt/thermal-imx-test/thermal_cpu_mem_gpu_wifi.sh${\n}
    Sleep    1
    ${log}=    SerialLibrary.Read All Data    UTF-8
    Log To Console    ${log}
    Sleep    2
    SerialLibrary.Write Data    ${IPERF_SERV}${\n}
    Sleep    1
    ${log}=    SerialLibrary.Read All Data    UTF-8
    Log To Console    ${log}
Check script file 
    SerialLibrary.Write Data    cat ${Script_PATH}${\n}
    Sleep    1
    ${content}=    SerialLibrary.Read All Data
    Reset Input Buffer
    Reset Output Buffer
    IF    $NEW_String in $content  # Robot framework 4.0 expression for string compare
        Log To Console    \niperf window size is 400K already 
        Execute command 
    ELSE
        Log To Console    \nwrong windows size detect , start to change 
        SerialLibrary.Write Data    sed -i "s\/${OLD_String}\/${NEW_String}\/g" ${Script_PATH}${\n}
        #Take place the wrong iperf window size from 3M to 400K, otherwise iperf fail.
        Sleep    1
        ${content}=    SerialLibrary.Read All Data     
        Execute command 
    END
Start CPU MEM GPU WIFI stress 
    Eth Ip Address Checker
    WIFI Connection Check
    Check script file 
    Execute System Monitor
    Open Browser to System Monitor
    Input Test Parameter
    Sleep    10
    Submit monitor button
    Log To Console    Start Monitoring....
    Sleep    43200
    Log To Console    Test Done and take screenshot\n
    Capture Page Screenshot    Sysmonitor_ScreenShot.png
    Close Process 
    Eth Ip Address Resume
    Sleep    10
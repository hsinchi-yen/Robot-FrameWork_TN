*** Comments ***
=========================================================================
 Copyright 2024 Technexion Ltd.
 DUT               : EDM_G_8MP _ EDM_G_WB
 Purpose           : Regresson Test for Essential Functionality 
 Script name       : EDM_G_8MP_n_EDM_G_WB.robot
 Author            : lancey 
 Date created      : 20240603
=========================================================================
*** Settings ***
Library           Collections
Library           String
Library           Process
 
#include resource
Resource          ../Resources/Common_Params.robot

Suite Setup       Run Keywords     Open Serial Port 
...    AND     SSH Open Connection And Log In  

Suite Teardown    Run Keywords    Close Serial Port       AND     
...    SSH Close All Connections 

*** Variables ***
#${SERIAL_PORT}      /dev/ttyS0
#${TERMINATOR}       root@edm-g-imx8mp:~#

*** Keywords ***
##
Abort Previous Operations 
    Repeat Keyword    2    SerialLibrary.Write Data    ${CTRL_C}
    Reset Input Buffer     ${SERIAL_PORT}
    Reset Output Buffer    ${SERIAL_PORT}
    Repeat Keyword    2    SerialLibrary.Write Data    ${\n}
    Sleep    1
    ${apo_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${apo_log}

*** Test Cases ***
Case TNPT-6
    [Tags]              Test A-System and Function    
    [Documentation]     SOM and baseboard Information
    System Info Check  
    
        
Case TNPT-11 
    [Tags]              Test A-System and Function    
    [Documentation]     Giga LAN - Ethernet Interface UP/DOWN
    ETH Interface DOWN Test
    ETH Interface UP Test

Case TNPT-153 
    [Tags]              Test A-System and Function
    [Documentation]     Watch Dog Timer
    Enable The Watchdog Via Devfs
    Trigger The Watchdog Via Test Commandline

Case TNPT-26
    [Tags]              Test A-System and Function    
    [Documentation]     UART console check
    Check Console State Dmesg
    Check Console ID in virtual filesystem directory

Case TNPT-158
    [Tags]              Test A-System and Function   
    [Documentation]     Software reboot
    Send Reboot command then Check Reboot State And Relogin

Case TNPT-8 and TNPT-160 
    [Tags]              Test A-System and Function     
    [Documentation]     Enter Uboot Mode and Uboot boot Test 
    Enter Uboot Mode then Check Uboot prompt and boot

Case TNPT-408
    [Tags]              Test A-System and Function   
    [Documentation]     GPIO-LED - LED5
    GPIO_LED_Test

Case TNPT-402
    [Tags]              Test A-System and Function   
    [Documentation]     Bluetooth - Interface UP/DOWN
    BT Init State Check
    BT Interface Down Test
    BT Interface Up Test

Case TNPT-444
    [Tags]              Test A-System and Function   
    [Documentation]     GPIO - PINS mapping correctness 
    Dump GPIO Port Mapping info
    
Case TNPT-10
    [Tags]              Test A-System and Function       
    [Documentation]     MAC ID check
    Ethernet MAC Check
    WIFI MAC Check
    BT MAC Check

Case TNPT-24    
    [Tags]              Test A-System and Function       ethcheckwake
    [Documentation]     Suspend/Resume and check ethernet function
    Set Resume DUT from Console And Set DUT to Sleep
    Wake Up DUT from Sleep
    Sleep    3
    Ethernet Interface Check

Case TNPT-12    
    [Tags]              Test A-System and Function       ping
    [Documentation]     Giga LAN - DHCP, ICMP Ping (IPv4)
    IPv4 Ping Test

Case TNPT-13    
    [Tags]              Test A-System and Function       
    [Documentation]     Giga LAN - DHCP, ICMP Ping (IPv6)
    IPv6 Ping Test

Case TNPT-14 and TNPT 31
    [Tags]              Test A-System and Function      
    [Documentation]     Giga LAN - Auto-Negotiation 10/100/1000 Base-T / LED indicators
    Set 10Mb Test
    Set 100Mb Test
    Set 1000Mb Test

Case TNPT-16
    [Tags]              Test A-System and Function     eth
    [Documentation]     Giga LAN - TX Ethernet performance (upload)    
    ETH Iperf3 Tx Test

Case TNPT-367
    [Tags]              Test A-System and Function     eth
    [Documentation]     Giga LAN - RX Ethernet performance (Download)    
    ETH Iperf3 Rx Test

Case TNPT-368
    [Tags]              Test A-System and Function     eth
    [Documentation]     Giga LAN - TX/RX Ethernet performance (Bi-Direction)    
    ETH Iperf3 Bidirection Test

Case TNPT-18
    [Tags]              Test A-System and Function   wol
    [Documentation]     Giga LAN - Wake on LAN 
    ${dut_mac}=    Get DUT MAC
    Set Wake On Lan and Set DUT to Sleep
    Wake Up DUT via Ethernet Magic Packet    ${dut_mac}
    Run Keyword And Continue On Failure    IPv4 Ping Test
    #solve the know issue - after wake on Lan
    Eth Down Workaround
    Sleep    5
    Run Keyword And Continue On Failure    IPv4 Ping Test

Case TNPT-142
    [Tags]              Test A-System and Function   
    [Documentation]     SPI Bus Loopback Test
    Spi Device Test

Case TNPT-100
    [Tags]              Test A-System and Function    
    [Documentation]     I2C bus Scanning 
    I2c Bus Scanning Test

Case TNPT-100 and TNPT 101
    [Tags]              Test A-System and Function    
    [Documentation]     I2C bus Scanning / I2C EEPROM read/write
    I2c Bus Scanning Test
    I2C EEPROM Write All Zero
    I2C EEPROM read
    I2C EEPROM Write All Ones
    I2C EEPROM Value Verification

Case TNPT-34
    [Tags]              Test A-System and Function    
    [Documentation]     Audio Jack
    ...                 Share the same test case TN35, use the headphone set for test
    Audio Jack Test

Case TNPT-525
    [Tags]              Test A-System and Function    
    [Documentation]     Audio Codec Sample Rate Test
    Audio Codec Sample Rate Test

Case TNPT-35
    [Tags]              Test A-System and Function    
    [Documentation]     Speaker headers 
    ...                 Share the same test case TNPT34, use the speaker for test                       
    Audio Jack Test


Case TNPT-68
    [Tags]              Test A-System and Function    
    [Documentation]     HDMI-audio
    HDMI Audio Test

Case TNPT-33 and TNPT-32
    [Tags]              Test A-System and Function    
    [Documentation]     USB2.0/3.0 Host 1/2 , USB Type-C OTG-Peripherial
    USB Devices Read and Write Test 

Case TNPT-432 
    [Tags]              Test A-System and Function    
    [Documentation]     On Board SDCARD Function Test 
    SDCARD Read And Write Test

Case TNPT-129
    [Tags]              Test A-System and Function    
    [Documentation]     Disk Benchmark (eMMC) 
    Emmc Read And Write Test 

Case TNPT-136
    [Tags]              Test A-System and Function   
    [Documentation]     Reset 20 times by Reset button
    ...                 Use the reboot command instaed.
    Repeat Keyword    20    Send Reboot command then Check Reboot State And Relogin

Case TNPT-85
    [Tags]              Test A-System and Function   nvme
    [Documentation]     M.2 PCIE Storage
    ...                 Key B+M Nvme Storage is required
    Nvme Info checker And Dumper
    Nvme Read and Write Test
    
Case TNPT-42
    [Tags]              Test A-System and Function   wifitest
    [Documentation]     Wifi Connectiviy - 11ac (5G BW 20/40/80Mhz) and Channel Test
    Wifi Connection test

Case TNPT-48    
    [Tags]              Test A-System and Function    wifitest
    [Documentation]     WIFI Connection and Performance (TX)
    Wifi Iperf3 Tx Test

Case TNPT-369    
    [Tags]              Test A-System and Function    wifitest
    [Documentation]     WIFI Connection and Performance (RX)
    Wifi Iperf3 Rx Test

Case TNPT-370  
    [Tags]              Test A-System and Function    wifitest
    [Documentation]     WIFI Connection and Performance (Bi-Direction)
    Wifi Iperf3 Bidirection Test

Case TNPT-401
    [Tags]              Test A-System and Function   
    [Documentation]     WLAN - Interface UP/DOWN
    WIFI Init State Check
    WIFI Interface Down Test
    WIFI Interface Up Test

Case TNPT-50
    [Tags]              Test A-System and Function    wifipm
    [Documentation]     WIFI PM suspend/resume test
    Set Resume DUT from Console And Set DUT to Sleep
    Wake Up DUT from Sleep
    Sleep    3
    Wifi Interface Check
    
Case TNPT-127
    [Tags]              Test A-System and Function    cpu
    [Documentation]     CPU Benchmark
    Run CPU benchmark Command  

Case TNPT-130
    [Tags]              Test A-System and Function    mem
    [Documentation]     GPU Benchmark(list GPU Library version)
    3D Glmark Benchmark Test

Case TNPT-774
    [Tags]              Test A-System and Function    mem
    [Documentation]     Memory Test - memtester - fixed mem size
    Memtester Test 
Case TNPT-128
    [Tags]              Test A-System and Function    mem
    [Documentation]     Memory Benchmark
    Run memory benchmark Command 
Case TNPT-172
    [Tags]              Test A-System and Function    mem
    [Documentation]     Memory stress Test - stressapptest 
    Stressapptest Test

Case TNPT-25
    [Tags]              Test A-System and Function    pwr
    [Documentation]     System Boot Time Test 
    Power Cycle And Relogin

Case TNPT-63
    #Refer to Bluetooth_test.robot
    [Tags]              Test A-System and Function    bluetooth
    [Documentation]     Bluetooth A2DP Source/Sink
    Bluetooth Speaker Connect
    Reset Input Buffer
    Reset Output Buffer
    Kernel Check Play
    Purge BT A2DP connection
    
Case TNPT-851
    [Tags]              Test A-System and Function    bluetooth
    [Documentation]     Bluetooth BLE Throughput 1M PHY 
    BLE throughput Test

Case TNPT-159
    #Refer to Power_Cycle_test.robot
    [Tags]              Test A-System and Function    
    [Documentation]     Software Shutdown
    SerialLibrary.Write Data    poweroff${\n}
    #Sleep    1
    ${poweroff_log}=    SerialLibrary.Read Until    ${PWR_DOWN_KEYWORD}
    Log    ${poweroff_log}
    Should Contain    ${poweroff_log}    ${PWR_DOWN_KEYWORD}
    Power Cycle And Relogin

Case TNPT-146
    #Refer to Power_Cycle_test.robot
    [Tags]              Test A-System and Function    restart
    [Documentation]     System Cold Boot (Power Cycle) - 20 times
    Repeat Keyword    20    Power Cycle And Relogin

Case TNPT-56
    #Refer to wifi_Connection_test.robot
    [Tags]              Test A-System and Function    wifiap
    [Documentation]     WIFI AP mode configuration with connmanctl
    Wifi Tether Mode Activate
    sleep    3
    Wifi Client Connect Test
    Verify Remote Connected IP
    #Get Tester Wifi Device Mac Id
    #Get Tester Wifi Connention hashkey
    sleep   5
    Tester Wifi Connection Setting Purge
    Wifi Tether Mode Deactivate
    
Case TNPT-222
    #Refer to IO_operation_on_multi_core_Stress_NG.robot
    [Tags]              Test A-System and Function    stress
    [Documentation]     StressNG for 12hrs 
    StressNG Test  

Case TNPT-176
    #Refer to GPU_Test.robot
    [Tags]              Test A-System and Function    stress
    [Documentation]     GPU Test Glmark2 for 12hrs 
    GLMark2 Test

Case TNPT-196
    [Tags]              Test A-System and Function    stress
    [Documentation]     LAN Interface up / down stress test 
    LAN Interface UP DOWN 500 times
Case TNPT-204
    [Tags]              Test A-System and Function    stress
    [Documentation]     USB device detect stress test 
    Power ON_OFF And USB detection Test 
Case TNPT-735
    [Tags]              Test A-System and Function    camera
    [Documentation]     Camera Test-TEVS-AR0234
    Camera-TEVS-AR0234

Case TNPT-177 
    [Tags]              Test A-System and Function    stress  
    [Documentation]     WIFI Stress 12H
    Start WIFI stress

Case TNPT-167 
    [Tags]              Test A-System and Function    stress  
    [Documentation]     CPU_MEM_GPU_WIFI_Stresss
    Start CPU MEM GPU WIFI stress

Case TNPT-215
    [Tags]              Enhanced rate calculate    stress
    [Documentation]     Full_Device_Power_ON_OFF_Test (rev2)
    Full device ON OFF 
Case TNPT-208
    [Tags]              Enhanced rate calculate    stress
    [Documentation]     SW reboot stress with full device test  (rev2)
    Full device reboot
Case TNPT-216
    [Tags]              Enhanced rate calculate    stress
    [Documentation]     Full_device Suspend Wake Up Test (rev2)
    Full device Suspend Wake Up Test   

Case TNPT-218
    [Tags]              Test D-Miscellanous Functionl Test
    [Documentation]     SSH connection
    SSH connection test
    
Case TNPT-147
    [Tags]              Test A-System and Function
    [Documentation]     CAN BUS - transmission
    #Check CAN Nodes
    Classic Canbus Test

Case TNPT-CAM CSI1 Test
    [Tags]              Periperials    CSITEST
    [Documentation]     TEVS Camera Test For All TEVS/VLS
    CSI Cam Test    CSI1     video0    1-0048    mxc_isi.0
    Vizion Control Test    video0

Case TNPT-CAM CSI2 Test
    [Tags]              Periperials    CSITEST
    [Documentation]     TEVS Camera Test For All TEVS/VLS
    CSI Cam Test    CSI2     video1    4-0048    mxc_isi.1
    Vizion Control Test    video1

Case TNPT-88
    [Tags]              Test A-System and Function
    [Documentation]     Micro-SIM / Nano-SIM detection 
    Check SIM Card 

Case TNPT-86
    [Tags]              Test A-System and Function
    [Documentation]     M.2 PCIE 4G LTE Module 
    LTE Modem test with Ofono

Case TNPT-22
    [Tags]              eMMC Flash Tool Test
    [Documentation]     dd command - Linux
    SerialLibrary.Close Port
    Perform Flash Image Process with dd
    SerialLibrary.Open Port
    
Case TNPT-131
    [Tags]              eMMC Flash Tool Test
    [Documentation]     bmaptool - Linux
    SerialLibrary.Close Port
    Perform Flash Image Process with Bmaptool
    SerialLibrary.Open Port

Case TNPT-70
    [Tags]              Test A-System and Function
    [Documentation]     HDMI EDID 
    Parse HDMI EDID
    Cur Resolution Check
    Stop the weston service
    Color Bar Test
    Sleep    3
    Start the weston service

Case TNPT-423
    [Tags]              Test A-System and Function
    [Documentation]     HDMI LCD Display - Play Video & Glmark 
    GPU Short Test Play
    VPU Short Test Clip Play

Case TNPT-125
    [Tags]              Test A-System and Function    
    [Documentation]     Video Decode
    Video Decode Test
    
Case TNPT-126
    [Tags]              Test A-System and Function    
    [Documentation]     Video Encode
    Video Encode Test

Case TNPT-870 
    [Tags]              Test D-Miscellanous Functional Test 
    [Documentation]     Power Consumption Measurement - idle mode
    Power Consumption with Idle Mode

Case TNPT-871
    [Tags]              Test D-Miscellanous Functional Test 
    [Documentation]     Power Consumption Measurement - Suspend Mode
    Power Consumption with Suspend Mode

Case TNPT-872
    [Tags]              Test D-Miscellanous Functional Test 
    [Documentation]     Power Consumption Measurement - with CPU 100% Load 
    Power Consumption with CPU Load

Case TNPT-873
    [Tags]              Test D-Miscellanous Functional Test 
    [Documentation]     Power Consumption Measurement - - with GPU Load
    Power Consumption with GPU running

Case TNPT-689
    [Tags]              Test D-Miscellanous Functional Test 
    [Documentation]      Check VizionSDK & VizionViewer tools
    Check VizionViewer SDK packages

Case TNPT-56
    #Refer to wifi_Connection_test.robot
    [Tags]              Test A-System and Function    WLANFeature
    [Documentation]     WIFI AP mode configuration with connmanctl
    Wifi Tether Mode Activate
    sleep    3
    Wifi Client Connect Test
    sleep   5
    Tester Wifi Connection Setting Purge
    Wifi Tether Mode Deactivate

Case TNPT-57
    #Refer to wifi_Connection_test.robot
    [Tags]              Test A-System and Function    WLANFeature    
    [Documentation]     WIFI concurrenct mode test with connmanctl
    Disable the Ethernet Connection
    Enable the wifi Connection
    sleep    1
    Wifi Tether Mode Activate
    sleep    10
    Wifi Client Connect Test
    sleep    5
    Tester Wifi Connection Setting Purge
    Wifi Tether Mode Deactivate
    Enable the Ethernet Connection
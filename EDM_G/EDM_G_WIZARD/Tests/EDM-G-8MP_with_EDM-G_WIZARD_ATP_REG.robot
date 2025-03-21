*** Comments ***
=========================================================================
 Copyright 2024 Technexion Ltd.
 DUT               : EDM_G_8MP _ EDM_G_WIZARD
 Purpose           : Regresson Test for Essential Functionality 
 Script name       : EDM-G-8MP_with_EDM-G-WIZARD_APT_REG.robot
 Author            : lancey 
 Date created      : 20250218
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

Test Setup        Run Keywords    Abort Previous Operations  
...    AND    Initial Network Settings    $TEST TAGS

*** Variables ***
#${SERIAL_PORT}      /dev/ttyS0
#${TERMINATOR}       root@edm-g-imx8mp:~#

*** Keywords ***
Abort Previous Operations 
    Repeat Keyword    2    SerialLibrary.Write Data    ${CTRL_C}
    Reset Input Buffer     ${SERIAL_PORT}
    Reset Output Buffer    ${SERIAL_PORT}
    Repeat Keyword    2    SerialLibrary.Write Data    ${\n}
    Sleep    1
    ${apo_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${apo_log}
    

*** Test Cases ***
#Case TNPT-22 and TNPT-670
#    [Tags]              eMMC Flash Tool Test       System
#    [Documentation]     dd command - Linux / Auto resizing filesystem
#    SerialLibrary.Close Port
#    Perform Flash Image Process with dd
#    SerialLibrary.Open Port
    
Case TNPT-131 and TNPT-670
    [Tags]              eMMC Flash Tool Test         System
    [Documentation]     bmaptool - Linux / Auto resizing filesystem
    SerialLibrary.Close Port
    Perform Flash Image Process with Bmaptool
    SerialLibrary.Open Port

Case TNPT-6
    [Tags]              Test A-System and Function    System    
    [Documentation]     SOM and baseboard Information
    System Info Check  
    
Case TNPT-153 
    [Tags]              Test A-System and Function    System
    [Documentation]     Watch Dog Timer
    Enable The Watchdog Via Devfs
    Trigger The Watchdog Via Test Commandline

Case TNPT-159
    #Refer to Power_Cycle_test.robot
    [Tags]              Test A-System and Function    System
    [Documentation]     Software Shutdown
    SerialLibrary.Write Data    poweroff${\n}
    Sleep    1
    ${poweroff_log}=    SerialLibrary.Read Until    ${PWR_DOWN_KEYWORD}
    Log    ${poweroff_log}
    Should Contain    ${poweroff_log}    ${PWR_DOWN_KEYWORD}
    Power Cycle And Relogin

Case TNPT-26
    [Tags]              Test A-System and Function    System   
    [Documentation]     UART console check
    Check Console State Dmesg
    Check Console ID in virtual filesystem directory

Case TNPT-158
    [Tags]              Test A-System and Function    System
    [Documentation]     Software reboot
    Send Reboot command then Check Reboot State And Relogin

Case TNPT-8 and TNPT-160 
    [Tags]              Test A-System and Function    System
    [Documentation]     Enter Uboot Mode and Uboot boot Test 
    Enter Uboot Mode then Check Uboot prompt and boot

Case TNPT-408
    [Tags]              Test A-System and Function    System  
    [Documentation]     GPIO-LED - LED5
    GPIO_LED_Test

Case TNPT-444
    [Tags]              Test A-System and Function    System
    [Documentation]     GPIO - PINS mapping correctness 
    Dump GPIO Port Mapping info

Case TNPT-CAM CSI1 Test
    [Tags]              Periperials    CSI - Camera
    [Documentation]     TEVS Camera Test For All TEVS/VLS
    CSI Cam Test    CSI1     video0    1-0048    mxc_isi.0
    Vizion Control Test    video0

Case TNPT-CAM CSI2 Test
    [Tags]              Periperials    CSI - Camera
    [Documentation]     TEVS Camera Test For All TEVS/VLS
    CSI Cam Test    CSI2     video1    4-0048    mxc_isi.1
    Vizion Control Test    video1

Case TNPT-142
    [Tags]              Test A-System and Function    SPI Interface
    [Documentation]     SPI Bus Loopback Test
    Spi Device Test

Case TNPT-100 and TNPT 101
    [Tags]              Test A-System and Function    I2C Interface
    [Documentation]     I2C bus Scanning / I2C EEPROM read/write
    I2c Bus Scanning Test
    I2C EEPROM Write All Zero
    I2C EEPROM read
    I2C EEPROM Write All Ones
    I2C EEPROM Value Verification

Case TNPT-147
    [Tags]              Test A-System and Function    CAN Interface
    [Documentation]     CAN BUS - transmission
    Check CAN Nodes

Case TNPT-34
    [Tags]              Test A-System and Function    Audio Codec    
    [Documentation]     Audio Jack
    ...                 Share the same test case TN35, use the headphone set for test
    Audio Jack Test

Case TNPT-525
    [Tags]              Test A-System and Function    Audio Codec
    [Documentation]     Audio Codec Sample Rate Test
    Audio Codec Sample Rate Test

Case TNPT-35
    [Tags]              Test A-System and Function    Audio Codec
    [Documentation]     Speaker headers 
    ...                 Share the same test case TNPT34, use the speaker for test                       
    Audio Jack Test

Case TNPT-68
    [Tags]              Test A-System and Function    HDMI 
    [Documentation]     HDMI-audio
    HDMI Audio Test

Case TNPT-33 and TNPT-32
    [Tags]              Test A-System and Function    Periperials-USB
    [Documentation]     USB2.0/3.0 Host 1/2 , USB Type-C OTG-Peripherial
    USB Devices Read and Write Test 

Case TNPT-432 
    [Tags]              Test A-System and Function    Periperials-SDCARD
    [Documentation]     On Board SDCARD Function Test 
    SDCARD Read And Write Test

Case TNPT-129
    [Tags]              Test A-System and Function    EMMC Storage
    [Documentation]     Disk Benchmark (eMMC) 
    Emmc Read And Write Test 

Case TNPT-85
    [Tags]              Test A-System and Function    Periperials-NVME
    [Documentation]     M.2 PCIE Storage
    ...                 Key B+M Nvme Storage is required
    Nvme Info checker And Dumper
    Nvme Read and Write Test

Case TNPT-24    
    [Tags]              Test A-System and Function    System
    [Documentation]     Suspend/Resume and check ethernet function
    Set Resume DUT from Console And Set DUT to Sleep
    Wake Up DUT from Sleep
    Sleep    3
    Ethernet Interface Check
    
Case TNPT-10
    [Tags]              Test A-System and Function    Network   
    [Documentation]     MAC ID check
    Ethernet MAC Check
    WIFI MAC Check
    BT MAC Check

Case TNPT-11 
    [Tags]              Test A-System and Function    Network
    [Documentation]     Giga LAN - Ethernet Interface UP/DOWN
    ETH Interface DOWN Test
    ETH Interface UP Test

Case TNPT-402
    [Tags]              Test A-System and Function    Network
    [Documentation]     Bluetooth - Interface UP/DOWN
    BT Init State Check
    BT Interface Down Test
    BT Interface Up Test

Case TNPT-12    
    [Tags]              Test A-System and Function    Network
    [Documentation]     Giga LAN - DHCP, ICMP Ping (IPv4)
    IPv4 Ping Test

Case TNPT-13    
    [Tags]              Test A-System and Function    Network
    [Documentation]     Giga LAN - DHCP, ICMP Ping (IPv6)
    IPv6 Ping Test

Case TNPT-14 and TNPT 31
    [Tags]              Test A-System and Function    Network   
    [Documentation]     Giga LAN - Auto-Negotiation 10/100/1000 Base-T / LED indicators
    Set 10Mb Test
    Set 100Mb Test
    Set 1000Mb Test

Case TNPT-16
    [Tags]              Test A-System and Function    Network         
    [Documentation]     Giga LAN - TX Ethernet performance (upload)    
    ETH Iperf3 Tx Test

Case TNPT-367
    [Tags]              Test A-System and Function    Network     
    [Documentation]     Giga LAN - RX Ethernet performance (Download)    
    ETH Iperf3 Rx Test

Case TNPT-368
    [Tags]              Test A-System and Function    Network     
    [Documentation]     Giga LAN - TX/RX Ethernet performance (Bi-Direction)    
    ETH Iperf3 Bidirection Test

Case TNPT-18
    [Tags]              Test A-System and Function    Network   
    [Documentation]     Giga LAN - Wake on LAN 
    ${dut_mac}=    Get DUT MAC
    Set Wake On Lan and Set DUT to Sleep
    Wake Up DUT via Ethernet Magic Packet    ${dut_mac}
    Run Keyword And Continue On Failure    IPv4 Ping Test
    #solve the know issue - after wake on Lan
    Eth Down Workaround
    Sleep    5
    Run Keyword And Continue On Failure    IPv4 Ping Test

Case TNPT-42
    [Tags]              Test A-System and Function    Network
    [Documentation]     Wifi Connectiviy - 11ac (5G BW 20/40/80Mhz) and Channel Test
    Wifi Connection test

Case TNPT-48    
    [Tags]              Test A-System and Function    Network
    [Documentation]     WIFI Connection and Performance (TX)
    Wifi Iperf3 Tx Test

Case TNPT-369    
    [Tags]              Test A-System and Function    Network     
    [Documentation]     WIFI Connection and Performance (RX)
    Wifi Iperf3 Rx Test

Case TNPT-370  
    [Tags]              Test A-System and Function    Network     
    [Documentation]     WIFI Connection and Performance (Bi-Direction)
    Wifi Iperf3 Bidirection Test

Case TNPT-401
    [Tags]              Test A-System and Function    Network  
    [Documentation]     WLAN - Interface UP/DOWN
    WIFI Init State Check
    WIFI Interface Down Test
    WIFI Interface Up Test

Case TNPT-50
    [Tags]              Test A-System and Function    Network    
    [Documentation]     WIFI PM suspend/resume test
    Set Resume DUT from Console And Set DUT to Sleep
    Wake Up DUT from Sleep
    Sleep    3
    Wifi Interface Check


    
Case TNPT-25
    [Tags]              Test A-System and Function     System   
    [Documentation]     System Boot Time Test f
    Power Cycle And Relogin

Case TNPT-63
    #Refer to Bluetooth_test.robot
    [Tags]              Test A-System and Function    Bluetooth
    [Documentation]     Bluetooth A2DP Source/Sink
    Kernel Check SW Select
    Bluetooth Speaker Connect
    Kernel Check Play
    Purge BT A2DP connection
    
Case TNPT-851
    [Tags]              Test A-System and Function    Bluetooth
    [Documentation]     Bluetooth BLE Throughput 1M PHY 
    BLE throughput Test

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


Case TNPT-127
    [Tags]              Test A-System and Function    Benchmark
    [Documentation]     CPU Benchmark
    Run CPU benchmark Command  

Case TNPT-130
    [Tags]              Test A-System and Function    Benchmark   
    [Documentation]     GPU Benchmark(list GPU Library version)
    3D Glmark Benchmark Test

Case TNPT-128
    [Tags]              Test A-System and Function    Benchmark
    [Documentation]     Memory Benchmark
    Run memory benchmark Command 

Case TNPT-774
    [Tags]              Test A-System and Function    Memory    
    [Documentation]     Memory Test - memtester - fixed mem size
    Memtester Test 

Case TNPT-172
    [Tags]              Test A-System and Function    Memory
    [Documentation]     Memory stress Test - stressapptest 
    Stressapptest Test
    
Case TNPT-218
    [Tags]              Test D-Miscellanous Functionl Test    Software
    [Documentation]     SSH connection
    SSH connection test

#PSU Test
#    [Tags]              Test A-System and Function    Power Supply
#    [Documentation]     PSU Status
    #Device GPP-1326 OFF
    #Device GPP-1326 ON
    #Sleep    1
    #Get Average Power Reading
    #Get Average Current Reading
#    Set Output Voltage    13.0
#    Get Voltage Reading 
#    Sleep    1
#    Set Output Voltage    11.0
#    Get Voltage Reading

Case TNPT-125
    [Tags]              Test A-System and Function    VPU Decode
    [Documentation]     Video Decode
    Video Decode Test
    
Case TNPT-126
    [Tags]              Test A-System and Function    VPU Encode
    [Documentation]     Video Encode
    Video Encode Test

Case TNPT-70
    [Tags]              Test A-System and Function    Display-HDMI
    [Documentation]     HDMI EDID 
    Parse HDMI EDID
    Cur Resolution Check
    Stop the weston service
    Color Bar Test
    Sleep    3
    Start the weston service

Case TNPT-423
    [Tags]              Test A-System and Function    Display-HDMI
    [Documentation]     HDMI LCD Display - Play Video & Glmark 
    GPU Short Test Play
    VPU Short Test Clip Play

Case TNPT-136
    [Tags]              Test A-System and Function    System 
    [Documentation]     Reset 20 times by Reset button
    ...                 Use the reboot command instaed.
    Repeat Keyword    10    Send Reboot command then Check Reboot State And Relogin

Case TNPT-146
    #Refer to Power_Cycle_test.robot
    [Tags]              Test A-System and Function    System    
    [Documentation]     System Cold Boot (Power Cycle) - 20 times
    Repeat Keyword    10    Power Cycle And Relogin
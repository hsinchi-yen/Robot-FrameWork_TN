*** Comments ***
=========================================================================
 Copyright 2024 Technexion Ltd.
 DUT               : PICO_IMX6UUL _ PICO-PI
 Purpose           : Regresson Test for Essential Functionality 
 Script name       : PICO_IMX6UUL_with_PICO-PI.robot
 Author            : RaymondC
 Date created      : 202408/015
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

*** Test Cases ***

Case TNPT-403 
    [Tags]              Test A-System and Function    
    [Documentation]     10/100M LAN - Interface UP/DOWN
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
    #Sleep    3
    Sleep    10
    Ethernet Interface Check

Case TNPT-447    
    [Tags]              Test A-System and Function       ping
    [Documentation]     10/100Mb LAN - DHCP, ICMP ping (IPv4)
    IPv4 Ping Test

Case TNPT-448    
    [Tags]              Test A-System and Function       
    [Documentation]     10/100Mb LAN - DHCP, ICMP ping (IPv6)
    IPv6 Ping Test

Case TNPT-449 and TNPT 451
    [Tags]              Test A-System and Function      
    [Documentation]     10/100Mb LAN - Auto-Negotiation 10/100 Base-T / LED indicators
    Set 10Mb Test
    Set 100Mb Test
    #Set 1000Mb Test  IMX6UL only support 100M

Case TNPT-17
    [Tags]              Test A-System and Function     eth
    [Documentation]     10/100Mb LAN - TX Ethernet performance (Upload)   
    ETH Iperf3 Tx Test

Case TNPT-446
    [Tags]              Test A-System and Function     eth
    [Documentation]     10/100Mb LAN - RX Ethernet performance (Download)   
    ETH Iperf3 Rx Test

Case TNPT-452
    [Tags]              Test A-System and Function     eth
    [Documentation]     10/100Mb LAN - TX/RX Ethernet performance (Bi-Direction)   
    ETH Iperf3 Bidirection Test

Case TNPT-453
    [Tags]              Test A-System and Function   wol
    [Documentation]     10/100Mb LAN - Wake on LAN 
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

Case TNPT-34
    [Tags]              Test A-System and Function    
    [Documentation]     Audio Jack
    ...                 Share the same test case TN35, use the headphone set for test
    Audio Jack Test

Case TNPT-35
    [Tags]              Test A-System and Function    
    [Documentation]     Speaker headers 
    ...                 Share the same test case TNPT34, use the speaker for test                       
    Audio Jack Test



Case TNPT-33 and TNPT-32
    [Tags]              Test A-System and Function    
    [Documentation]     USB2.0/3.0 Host 1/2 , USB Type-C OTG-Peripherial
    USB Devices Read and Write Test 



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
    Sleep    5
    Wifi Interface Check

Case TNPT-130
    [Tags]              Test A-System and Function    mem
    [Documentation]     GPU Benchmark(list GPU Library version)
    3D Glmark Benchmark Test

Case TNPT-128
    [Tags]              Test A-System and Function    mem
    [Documentation]     Memory performance  (Not Ready)
    #Memory Benchmark

Case TNPT-774
    [Tags]              Test A-System and Function    mem
    [Documentation]     Memory Test - memtester - fixed mem size
    Memtester Test 

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
    Bluetooth A2DP Speaker Play
    Purge BT A2DP connection
    
Case TNPT-159
    #Refer to Power_Cycle_test.robot
    [Tags]              Test A-System and Function    
    [Documentation]     Software Shutdown
    SerialLibrary.Write Data    poweroff${\n}
    Sleep    1
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

Case TNPT-208
    [Tags]              Test A-System and Function    stress
    [Documentation]     SW reboot stress with full device test 
    Reboot full device 500 times

Case TNPT-215
    [Tags]              Test A-System and Function    stress
    [Documentation]     Full_Device_Power_ON_OFF_Test
    Full device Power ON OFF Test 10 times


Case TNPT-216
    [Tags]              Test A-System and Function    stress
    [Documentation]     Full Device suspend / wake up Test
    Full device Suspend Wake Up Test 10 times

Case TNPT-177 
    [Tags]              Test A-System and Function    stress  
    [Documentation]     WIFI Stress 12H
    Start WIFI stress

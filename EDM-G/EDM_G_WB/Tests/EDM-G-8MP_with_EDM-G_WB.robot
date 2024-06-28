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

Suite Setup       Open Serial Port
Suite Teardown    Close Serial Port

*** Variables ***
#${SERIAL_PORT}      /dev/ttyS0
#${TERMINATOR}       root@edm-g-imx8mp:~#

*** Keywords ***
##

*** Test Cases ***
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

Case TNPT-401
    [Tags]              Test A-System and Function   
    [Documentation]     WLAN - Interface UP/DOWN
    WIFI Init State Check
    WIFI Interface Down Test
    WIFI Interface Up Test

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
    [Tags]              Test A-System and Function       
    [Documentation]     Suspend/Resume and check ethernet function
    Set Resume DUT from Console And Set DUT to Sleep
    Wake Up DUT from Sleep
    Sleep    3
    Ethernet Interface Check

Case TNPT-12    
    [Tags]              Test A-System and Function       
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
    [Tags]              Test A-System and Function   
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

Case TNPT-50
    [Tags]              Test A-System and Function    wifipm
    [Documentation]     WIFI PM suspend/resume test
    Set Resume DUT from Console And Set DUT to Sleep
    Wake Up DUT from Sleep
    Sleep    3
    Wifi Interface Check

Case TNPT-130
    [Tags]              Test A-System and Function    mem
    [Documentation]     GPU Benchmark(list GPU Library version)
    3D Glmark Benchmark Test

Case TNPT-774
    [Tags]              Test A-System and Function    mem
    [Documentation]     Memory Test - memtester - fixed mem size
    Memtester Test 

Case TNPT-172
    [Tags]              Test A-System and Function    mem
    [Documentation]     Memory stress Test - stressapptest 
    Stressapptest Test

Case TNPT-18
    [Tags]              Test A-System and Function   wol
    [Documentation]     Giga LAN - Wake on LAN 
    Set Wake On Lan and Set DUT to Sleep

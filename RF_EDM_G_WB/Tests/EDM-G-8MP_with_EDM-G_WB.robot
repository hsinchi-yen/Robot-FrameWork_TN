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
    [Tags]              Test A-System and Function     
    [Documentation]     Giga LAN - TX Ethernet performance (upload)
    ETH Iperf3 Tx Test

Case TNPT-367
    [Tags]              Test A-System and Function     
    [Documentation]     Giga LAN - RX Ethernet performance (Download)
    ETH Iperf3 Rx Test

Case TNPT-368
    [Tags]              Test A-System and Function     
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

Case TNPT-1000        
    [Tags]              Test A-System and Function    
    [Documentation]     GPU Performance Test
    3D Glmark Benchmark Test

Case TNPT-1001     
    [Tags]              Test A-System and Function    
    [Documentation]     Memtester with Fixed memory size
    Memtester Test 
    Stressapptest Test 

Case TNPT-1002      
    [Tags]              Test A-System and Function    wifi
    [Documentation]     Wifi connection test  
    Wifi Connection test  
    #Wifi Connection test
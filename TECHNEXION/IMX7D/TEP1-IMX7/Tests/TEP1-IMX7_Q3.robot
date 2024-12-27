*** Comments ***
=========================================================================
 Copyright 2024 Technexion Ltd.
 DUT               : TEP-IMX7
 Purpose           : Regresson Test for Essential Functionality 
 Script name       : TEP-IMX7.robot
 Author            : lancey 
 Date created      : 20240903
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
${SERIAL_PORT}      /dev/ttyUSB0
${TERMINATOR}       root@tep1-imx7:~#

*** Keywords ***
##

*** Test Cases ***
Case TNPT-127
    [Tags]              Test A-System and Function    benchmark
    [Documentation]     CPU Benchmark
    Run CPU Benchmark Test

Case TNPT-128
    [Tags]              Test A-System and Function    benchmark
    [Documentation]     Memory Benchmark Test
    Run Ramsmp Test for multicore

Case TNPT-129
    [Tags]              Test A-System and Function    
    [Documentation]     Disk Benchmark (eMMC) 
    Emmc Read And Write Test 

Case TNPT-432 
    [Tags]              Test A-System and Function    
    [Documentation]     On Board SDCARD Function Test 
    SDCARD Read And Write Test

Case TNPT-444
    [Tags]              Test A-System and Function   
    [Documentation]     GPIO - PINS mapping correctness 
    Dump GPIO Port Mapping info

Case TNPT-774
    [Tags]              Test A-System and Function   
    [Documentation]     Memory Test - memtester - fixed mem size
    Memtester Test 

Case TNPT-8 and TNPT-160 
    [Tags]              Test A-System and Function     
    [Documentation]     Enter Uboot Mode and Uboot boot Test 
    Enter Uboot Mode then Check Uboot prompt and boot

Case TNPT-10
    [Tags]              Test A-System and Function       
    [Documentation]     MAC ID check
    Ethernet MAC Check    ${ETH_INF1}
    Ethernet MAC Check    ${ETH_INF2}
    WIFI MAC Check
    BT MAC Check

Case TNPT-11 
    [Tags]              Test A-System and Function    
    [Documentation]     Giga LAN - Ethernet Interface UP/DOWN
    ETH Interface DOWN Test
    ETH Interface UP Test

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

Case TNPT-24    
    [Tags]              Test A-System and Function       
    [Documentation]     Suspend/Resume and check ethernet function
    Set Resume DUT from Console And Set DUT to Sleep
    Wake Up DUT from Sleep
    Sleep    3
    Ethernet Interface Check

Case TNPT-25
    [Tags]              Test A-System and Function    
    [Documentation]     System Boot Time Test 
    Power Cycle And Relogin

Case TNPT-26
    [Tags]              Test A-System and Function    
    [Documentation]     UART console check
    Check Console State Dmesg
    Check Console ID in virtual filesystem directory

Case TNPT-33 and TNPT-32
    [Tags]              Test A-System and Function    
    [Documentation]     USB2.0/3.0 Host 1/2 , USB Type-C OTG-Peripherial
    USB Devices Read and Write Test 

Case TNPT-153 
    [Tags]              Test A-System and Function
    [Documentation]     Watch Dog Timer
    Enable The Watchdog Via Devfs
    Trigger The Watchdog Via Test Commandline

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

Case TNPT-63
    #Refer to Bluetooth_test.robot
    [Tags]              Test A-System and Function    bluetooth
    [Documentation]     Bluetooth A2DP Source/Sink
    Bluetooth Speaker Connect
    Bluetooth A2DP Speaker Play
    Purge BT A2DP connection

Case TNPT-76
    [Tags]              Test A-System and Function    
    [Documentation]     RTC - Real-Time clock
    RTC Test

Case TNPT-158
    [Tags]              Test A-System and Function   
    [Documentation]     Software reboot
    Send Reboot command then Check Reboot State And Relogin

Case TNPT-408
    [Tags]              Test A-System and Function  
    #For IMX7D-TEP1 
    [Documentation]     GPIO-LED - D13
    GPIO_LED_Test


Case TNPT-147
    [Tags]              Test A-System and Function    stress
    [Documentation]     CAN BUS - Transsmission

    ${found_cans}=    Check Can Devices

    IF    ${found_cans} == $True
        Set Can Interface Up    ${CAN_DEV_A}
        Set Can Interface Up    ${CAN_DEV_B}
        Classic Can TX Test
        Classic Can RX Test
    ELSE
        Fail    Can bus devices is not up
    END

Case TNPT-402
    [Tags]              Test A-System and Function   
    [Documentation]     Bluetooth - Interface UP/DOWN
    BT Init State Check
    BT Interface Down Test
    BT Interface Up Test
   

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

Case TNPT-18
    [Tags]              Test A-System and Function   
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

Case TNPT-136
    [Tags]              Test A-System and Function   
    [Documentation]     Reset 20 times by Reset button
    ...                 Use the reboot command instaed.
    Repeat Keyword    20    Send Reboot command then Check Reboot State And Relogin

Case TNPT-401
    [Tags]              Test A-System and Function   
    [Documentation]     WLAN - Interface UP/DOWN
    WIFI Init State Check
    WIFI Interface Down Test
    WIFI Interface Up Test

Case TNPT-50
    [Tags]              Test A-System and Function    
    [Documentation]     WIFI PM suspend/resume test
    Set Resume DUT from Console And Set DUT to Sleep
    Wake Up DUT from Sleep
    Sleep    3
    Wifi Interface Check

Case TNPT-130
    [Tags]              Test A-System and Function   
    [Documentation]     GPU Benchmark(list GPU Library version)
    3D Glmark Benchmark Test

Case TNPT-159
    #Refer to Power_Cycle_test.robot
    [Tags]              Test A-System and Function    
    [Documentation]     Software Shutdown
    SerialLibrary.Write Data    poweroff${\n}
    Sleep    1
    ${poweroff_log}=    SerialLibrary.Read Until    ${PWR_DOWN_KEYWORD}
    Log    ${poweroff_log}
    Should Contain    ${poweroff_log}    ${PWR_DOWN_KEYWORD}
    Sleep    3
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

Case TNPT-218
    [Tags]              D-Miscellanous Functional Test    
    [Documentation]     SSH connection
    SSH Connection Test

Case TNPT-144
    [Tags]              Test A-System and Function    IO
    [Documentation]     GPIO
    Check GPIO Pins Info
    GPIO_Pins State Check
    GPIO_Set_Test_Pull_Down
    GPIO_Get_Test_Pull_Down
    GPIO_Set_Test_Pull_Up
    GPIO_Get_Test_Pull_Up

Case TNPT-145
    [Tags]              Test A-System and Function    IO
    [Documentation]     PWM
    Enable PWM Folders


Case TNPT-426
    [Tags]              Test A-System and Function    IO
    [Documentation]     Reserved UART Function Check
    Open Test Serial Port
    DUT Uart TX Test
    DUT Uart RX Test

    
Case TNPT-215
    [Tags]              Test A-System and Function    stress
    [Documentation]     Full_Device_Power_ON_OFF_Test
    Full device Power ON OFF Test 10 times
    
Case TNPT-216
    [Tags]              Test A-System and Function    stress
    [Documentation]     Full Device suspend / wake up Test
    Full device Suspend Wake Up Test 10 times


Case TNPT-172
    [Tags]              Test B-Stress Test
    [Documentation]     Memory stress Test - stressapptest - fixed mem (12 hours)
    StressApptest Loop

#Case TNPT-172
#    [Tags]              Test A-System and Function    
#    [Documentation]     Memory stress Test - stressapptest 
#    Stressapptest Test

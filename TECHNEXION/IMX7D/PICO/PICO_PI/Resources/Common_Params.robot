*** Settings ***
Library    SerialLibrary    encoding=UTF-8
Library    SSHLibrary

Library    String
Library    ../Libraries/EnvVariablesReturnLib.py
Library    ../Libraries/find_serial.py
Library    ../Libraries/FlashImageLibrary.py

# add All test operation robots script
Resource          ../Resources/SystemInfo_Check_Test.robot
Resource          ../Resources/Eth_Inf_Down_Up.robot
Resource          ../Resources/WatchDog_Test.robot
Resource          ../Resources/Console_Check.robot
Resource          ../Resources/SW_Reboot.robot
Resource          ../Resources/Gpio_Led_Test.robot
Resource          ../Resources/Bluetooth_Inf_Up_Down.robot
Resource          ../Resources/Wlan_Inf_Up_Down.robot
Resource          ../Resources/Uboot_Boot_Test.robot
Resource          ../Resources/Gpio_Pin_Mapping_check.robot
Resource          ../Resources/Mac_Id_Check.robot
Resource          ../Resources/Suspend_Resume_Eth_Check.robot
Resource          ../Resources/Eth_Ip_Ping.robot
Resource          ../Resources/Eth_Inf_Down_Up.robot
Resource          ../Resources/Eth_Speed_Change.robot
Resource          ../Resources/Eth_Iperf_test.robot
Resource          ../Resources/Spi_Device_Test.robot
Resource          ../Resources/I2c_Bus_Test.robot
Resource          ../Resources/Audio_Test.robot
Resource          ../Resources/Storage_RW_Test.robot
Resource          ../Resources/Wifi_Iperf_test.robot
Resource          ../Resources/Wifi_Connection_test.robot
Resource          ../Resources/Display_test.robot
Resource          ../Resources/Memory_test.robot
Resource          ../Resources/Power_Cycle_test.robot
Resource          ../Resources/Bluetooth_Test.robot
Resource          ../Resources/IO_operation_on_multi_core_Stress_NG.robot
Resource          ../Resources/GPU_Test.robot
Resource          ../Resources/LAN_Interface_Up_Down_Stress.robot
Resource          ../Resources/USB_device_detect_stress_Test.robot
Resource          ../Resources/SW_reboot_full_device_500_times.robot
Resource          ../Resources/Full_Device_Power_ON_OFF_Test.robot
Resource          ../Resources/TEVS-AR0234.robot
Resource          ../Resources/Full_Device_Suspend_Wake_Up_Test.robot
Resource          ../Resources/WIFI_Stress_12H.robot
Resource          ../Resources/Flash_Image.robot
Resource          ../Resources/SSH_Conn_Test.robot
Resource          ../Resources/Vizionviewer_SDK_Check.robot
Resource          ../Resources/Benchmark_test.robot
#Resource          ../Resources/Memory_Benchmark.robot
Resource          ../Resources/BLE_throughput_test.robot

*** Variables ***
# command share variables between DUT and Test PC
#Required test parameters in DUT
${TERMINATOR}    root@pico-imx7:~#
${SERIAL_PORT}    /dev/ttyUSB0
${ETH_INF}    eth0
${LOGIN_PROMPT}    pico-imx7 login:
${LOGIN_ACC}    root

#iw sdio - mlan , qca9377 - wlan
${WIFI_INF}    wlan0

#your test pc
${CONSOLE_ETH_INF}    enp5s0

#remote iperf server ip
${IPERF_SERV}    10.88.92.1


#power relay IP
${PWR_SW_IP}    10.88.89.105
${PWR_USERID}    root

#Test Images
${TEST_IMAGE_BMAP}    ./imx-image-full-pico-imx7.rootfs-20241227191452.wic.bmap
${TEST_IMAGE}         ./imx-image-full-pico-imx7.rootfs-20241227191452.wic.bz2
@{NXP_DEV_NAME}           Netchip Technology, Inc. Linux-USB File-backed Storage Gadget     
...    \NXP Semiconductors USB download gadget

*** Keywords ***
Open Serial Port
   
    #${SERIAL_PORT}=    find_serial_port
    #Use Serial Port    ${SERIAL_PORT}
    
    Add Port   ${SERIAL_PORT}
    ...        baudrate=115200
    ...        bytesize=8
    ...        parity=N
    ...        stopbits=1
    ...        timeout=60
    Reset Input Buffer     ${SERIAL_PORT}
    Reset Output Buffer    ${SERIAL_PORT}
    #root login everytime while using serial port 
    #SerialLibrary.Write Data    ${LOGIN_ACC}${\n}
    #${loginlog}=    SerialLibrary.Read Until    ${TERMINATOR}
Close Serial Port
    Delete All Ports

SSH Open Connection And Log In          
   SSHLibrary.Open Connection     ${PWR_SW_IP}
   SSHLibrary.Login               ${PWR_USERID}        

SSH Close All Connections
    SSHLibrary.Close Connection

Device ON
    [Documentation]    Device POWER ON
    SSHLibrary.Write    ./DOUT_CTRL.sh ON
    #SSHLibrary.Write    gpioset gpiochip2 16=1\n
    ${read_output}=     SSHLibrary.Read
    Log to Console      ${read_output}
    Sleep    0.5

Device OFF
    [Documentation]    Device POWER OFF
    SSHLibrary.Write    ./DOUT_CTRL.sh OFF
    #SSHLibrary.Write    gpioset gpiochip2 16=0\n
    ${read_output}=     SSHLibrary.Read
    sleep     0.25
    Log to Console      ${read_output}
    Sleep    0.5

#Use Serial Port
#    [Arguments]    ${port}
#    Log    Using serial port: ${port}
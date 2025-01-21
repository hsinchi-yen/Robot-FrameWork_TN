*** Settings ***
Library    SerialLibrary    encoding=UTF-8
Library    SSHLibrary
Library    OperatingSystem
Library    String
Library    ../Libraries/EnvVariablesReturnLib.py
Library    ../Libraries/find_serial.py

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
Resource          ../Resources/TEVS-AR0234.robot
Resource          ../Resources/WIFI_Stress_12H.robot
Resource          ../Resources/LAN_Stress_Bidir_12H.robot
Resource          ../Resources/WIFI_Up_Down_Stress.robot
Resource          ../Resources/CPU_MEM_GPU_WIFI_Stress.robot
Resource          ../Resources/Memory_Benchmark.robot
Resource          ../Resources/Audio_Codec_Sample_Rate_Test.robot
Resource          ../Resources/WIFI_Up_Down_Stress.robot
Resource          ../Resources/BLE_throughput_test.robot
Resource          ../Resources/Full_Device_Power_ON_OFF_Test_rev2.robot
Resource          ../Resources/SW_reboot_full_device_rev2.robot
Resource          ../Resources/Full_Device_Suspend_Wake_Up_Test_rev2.robot
*** Variables ***
# command share variables between DUT and Test PC
#Required test parameters in DUT
${TERMINATOR}    root@edm-imx93:~#
#${SERIAL_PORT}          /dev/ttyUSB1
${ETH1_INF}    eth1
${ETH2_INF}    eth0
${LOGIN_PROMPT}    edm-imx93 login:
${LOGIN_ACC}    root

#iw sdio - mlan , qca9377 - wlan
${WIFI_INF}    mlan0

#your test pc
${CONSOLE_ETH_INF}    ens33

#remote iperf server ip
${IPERF_SERV}    10.88.89.151


#power relay IP
${PWR_SW_IP}    10.88.88.214
${PWR_USERID}    root


*** Keywords ***
Open Serial Port
    ${SERIAL_PORT}=    find_serial_port
  
    Add Port   ${SERIAL_PORT}
    ...        baudrate=115200
    ...        bytesize=8
    ...        parity=N
    ...        stopbits=1
    ...        timeout=60
    Reset Input Buffer     ${SERIAL_PORT}
    Reset Output Buffer    ${SERIAL_PORT}
    # SerialLibrary.Write Data    ${LOGIN_ACC}${\n}
    # ${loginlog}=    SerialLibrary.Read Until    ${TERMINATOR}
    
Close Serial Port
    Delete All Ports

SSH Open Connection And Log In          
   SSHLibrary.Open Connection     ${PWR_SW_IP}
   SSHLibrary.Login               ${PWR_USERID}        

SSH Close All Connections
    SSHLibrary.Close Connection

Device ON
    [Documentation]    Device POWER ON
    #SSHLibrary.Write    ./DOUT_CTRL.sh ON
    SSHLibrary.Write    gpioset gpiochip2 6=1\n
    ${read_output}=     SSHLibrary.Read
    Log to Console      ${read_output}
    Sleep    0.5

Device OFF
    [Documentation]    Device POWER OFF
    #SSHLibrary.Write    ./DOUT_CTRL.sh OFF
    SSHLibrary.Write    gpioset gpiochip2 6=0\n
    ${read_output}=     SSHLibrary.Read
    sleep     0.25
    Log to Console      ${read_output}
    Sleep    0.5
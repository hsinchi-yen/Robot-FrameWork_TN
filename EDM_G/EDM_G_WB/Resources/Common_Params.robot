*** Settings ***
Library    SerialLibrary    encoding=UTF-8
Library    SSHLibrary

Library    String
Library    ../Libraries/EnvVariablesReturnLib.py
Library    ../Libraries/find_serial.py
Library    ../Libraries/FlashImageLibrary.py

# add All test operation robots script
#Resource          ../Resources/SysInfo.robot
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
Resource          ../Resources/Audio_Codec_Sample_Rate_Test.robot
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
#Resource          ../Resources/WIFI_issue.robot
Resource          ../Resources/SW_Reboot_audio_issue.robot
Resource          ../Resources/CPU_MEM_GPU_WIFI_Stress.robot
Resource          ../Resources/CPU_Benchmark.robot
Resource          ../Resources/Full_Device_Power_ON_OFF_Test_rev2.robot
Resource          ../Resources/SW_reboot_full_device_rev2.robot
Resource          ../Resources/Full_Device_Suspend_Wake_Up_Test_rev2.robot
Resource	      ../Resources/Flash_Image.robot
Resource          ../Resources/Memory_Benchmark.robot
Resource          ../Resources/BLE_throughput_test.robot
Resource          ../Resources/SystemInfo_Check_Test.robot
Resource          ../Resources/SSH_Conn_Test.robot
Resource          ../Resources/Can_Bus_Test.robot
Resource          ../Resources/CSI_Camera_Test.robot
Resource          ../Resources/LTE_Modem_Test.robot
Resource          ../Resources/GPP_PSU_Operation.robot
Resource          ../Resources/Video_Decode_Test.robot
Resource          ../Resources/Video_Encode_Test.robot
Resource          ../Resources/Pwr_Consumption_Meas.robot
Resource          ../Resources/Vizionviewer_SDK_Test.robot

*** Variables ***
# command share variables between DUT and Test PC
#Required test parameters in DUT
${TERMINATOR}            root@edm-g-imx8mp:~#
${SERIAL_PORT}           /dev/ttyUSB0
${ETH_INF}               eth0
${LOGIN_PROMPT}          edm-g-imx8mp login:
${LOGIN_ACC}             root

#iw sdio - mlan , qca9377 - wlan
${WIFI_INF}    wlan0

#your test pc
${CONSOLE_ETH_INF}    ens33

#remote iperf server ip
${IPERF_SERV}    10.88.89.66

#power relay IP for BT speaker
${PWR_SW_IP}    10.88.89.105
${PWR_USERID}    root

#GPP-1326 control port
${GPP_CON}      /dev/ttyUSB1

#debug flag for log to print output in console
${DEBUG_LOG}        no

#Test Images
${TEST_IMAGE_BMAP}        imx-image-full-edm-g-imx8mp.rootfs-20250320164337.wic.bmap
${TEST_IMAGE}             imx-image-full-edm-g-imx8mp.rootfs-20250320164337.wic.bz2

@{NXP_DEV_NAME}           Netchip Technology, Inc. Linux-USB File-backed Storage Gadget     
...    \NXP Semiconductors USB download gadget

*** Keywords ***
Open Serial Port
    #${SERIAL_PORT}=    find_serial_port
    
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

    Add Port   ${GPP_CON}
    ...        baudrate=115200
    ...        bytesize=8
    ...        parity=N
    ...        stopbits=1
    ...        timeout=60
    Reset Input Buffer     ${SERIAL_PORT}
    Reset Output Buffer    ${SERIAL_PORT}

Close Serial Port
    Delete All Ports

SSH Open Connection And Log In          
   SSHLibrary.Open Connection     ${PWR_SW_IP}
   SSHLibrary.Login               ${PWR_USERID}        

SSH Close All Connections
    SSHLibrary.Close Connection

#Remote Power Relay Board controller
Device ON
    [Documentation]    Device POWER ON
    SSHLibrary.Write    ./DOUT_CTRL.sh ON
    #SSHLibrary.Write    gpioset gpiochip2 6=1\n
    ${read_output}=     SSHLibrary.Read
    Log to Console      ${read_output}
    Sleep    0.5

#Remote Power Relay Board controller
Device OFF
    [Documentation]    Device POWER OFF
    SSHLibrary.Write    ./DOUT_CTRL.sh OFF
    #SSHLibrary.Write    gpioset gpiochip2 6=0\n
    ${read_output}=     SSHLibrary.Read
    sleep     0.25
    Log to Console      ${read_output}
    Sleep    0.5

Use Serial Port
    [Arguments]    ${port}
    Log    Using serial port: ${port}

Initial Network Settings
    [Documentation]    Configure network settings based on tags
    [Arguments]    ${TEST TAGS}
    IF    'Ethernet' in $TEST_TAGS
        Log    Configuring network settings for Ethernet test
        SerialLibrary.Write Data    connmanctl enable ethernet${\n}
        Sleep    1s
        SerialLibrary.Write Data    connmanctl disable wifi${\n}
        Sleep    1s
        ${output}=    SerialLibrary.Read All Data    UTF-8
        Log    Network configuration output: ${output}

    ELSE IF    'Wireless' in $TEST_TAGS
        Log    Configuring network settings for Wireless test
        SerialLibrary.Write Data    connmanctl disable ethernet${\n}
        Sleep    1s
        SerialLibrary.Write Data    connmanctl enable wifi${\n}
        Sleep    1s
        ${output}=    SerialLibrary.Read All Data    UTF-8
        Log    Network configuration output: ${output}

    ELSE 
        SerialLibrary.Write Data    connmanctl enable ethernet${\n}
        Sleep    1s
        SerialLibrary.Write Data    connmanctl enable wifi${\n}
        Sleep    1s
        ${output}=    SerialLibrary.Read All Data    UTF-8
        Log    Network configuration output: ${output}
    END
    Sleep    5
    Reset Input Buffer
    Reset Output Buffer

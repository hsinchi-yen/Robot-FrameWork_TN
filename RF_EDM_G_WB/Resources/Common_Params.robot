*** Settings ***
Library    SerialLibrary    encoding=UTF-8
Library    SSHLibrary

Library    String
Library    ../Libraries/EnvVariablesReturnLib.py


# add All test operation robots script
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


*** Variables ***
# command share variables between DUT and Test PC
#Required test parameters in DUT
${TERMINATOR}           root@edm-g-imx8mp:~#
${SERIAL_PORT}          /dev/ttyS0
${ETH_INF}              eth0
${LOGIN_PROMPT}         edm-g-imx8mp login:
${LOGIN_ACC}            root

#iw sdio - mlan , qca9377 - wlan
${WIFI_INF}             wlan0

#your test pc
${CONSOLE_ETH_INF}      enp5s0

#remote iperf server ip
${IPERF_SERV}           10.88.93.1


#power relay IP
${PWR_SW_IP}    10.88.88.206
${PWR_USERID}     root  


*** Keywords ***
Open Serial Port
    Add Port   ${SERIAL_PORT}
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

Device ON
    [Documentation]    Device POWER ON
    SSHLibrary.Write    ./DOUT_CTRL.sh ON
    ${read_output}=     SSHLibrary.Read
    Log to Console      ${read_output}
    Sleep    0.5

Device OFF
    [Documentation]    Device POWER OFF
    SSHLibrary.Write    ./DOUT_CTRL.sh OFF
    ${read_output}=    SSHLibrary.Read
    sleep     0.25
    Log to Console      ${read_output}
    Sleep    0.5
*** Settings ***
Library    SerialLibrary    encoding=UTF-8
Library    String


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
Resource          ../Resources/Display_test.robot
Resource          ../Resources/Memory_test.robot

*** Variables ***
# command share variables between DUT and Test PC
${TERMINATOR}           root@edm-g-imx8mm:~#
${SERIAL_PORT}          /dev/ttyUSB0
${ETH_INF}              eth0
${LOGIN_PROMPT}         edm-g-imx8mm login:
${LOGIN_ACC}            root

#your test pc
${CONSOLE_ETH_INF}      enp6s0

#remote iperf server ip
${IPERF_SERV}           10.88.88.138

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
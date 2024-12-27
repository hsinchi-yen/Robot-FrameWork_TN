*** Settings ***
Library           SerialLibrary    encoding=UTF-8
Library           Collections
Library           String
Library           OperatingSystem

Suite Setup       Open Serial Port
Suite Teardown    Close Serial Port

*** Variables ***
${SERIAL_PORT}      /dev/ttyUSB1
${TERMINATOR}       ~#
${IPER_SERV}        10.88.88.82
${ETH}              eth0
${IPV6_SERV}        fe80::fbbb:b1ae:fc18:9dcf
${MEM_SIZE}         1000
${MEM_T_TIME}       2 hours
#PL2
${UART_5}           /dev/ttymxc4
${UART_6}           /dev/ttymxc5
#PL3
${UART_3}           /dev/ttymxc2
${UART_7}           /dev/ttymxc6

#PL15
${UART_RS485}        /dev/ttymxc1
#PL16
${UART_RS232}        /dev/ttymxc3

#UART_PATTERN
${UART_STRING_OUT}    8nm6D448f9J72iOeI4vpXGMye1U0k4LNa24drVUKPNWjP2asE2ysfi5oTJmyLWfijHOSNbNPjRmZjjBO
${UART_STRING_IN}     hthmaIwVZH5M7RRvyolTmmR01uIsisEkBaNBFhTt7Ht6RYWueYRXg6H35FNdEa2X6pRdPZxfk75WdxgQ

#emmc
${EMMC}    mmcblk1

#Iperf
${IPER_SERV}        10.88.88.82

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


Version PIN OUTPUT Verifier
    [Arguments]    ${ctrl_pin_log}   ${cmp_val}
    @{lines}=    Split To Lines    ${ctrl_pin_log}
    ${output_line}=    Get From List    ${lines}    -2
    Log    ${output_line}
    ${output_line}=    Get Regexp Matches    ${output_line}    \\d
    ${output_line}=    Convert To Integer    @{output_line}
    Should Be Equal As Integers    ${output_line}    ${cmp_val}

4G Modem Enable
    [Timeout]    60
    Write Data    lsusb\n 
    ${4g_modem_log}=    Read Until    ${TERMINATOR}
    #${is_modem_boolean}=    Get Lines Containing String    ${4g_modem_log}    EC21 LTE modem
    ${is_modem_bool}=    Run Keyword And Return Status    Should Contain    ${4g_modem_log}     EC21 LTE modem 
    
    Log     ${is_modem_bool}

    IF    ${is_modem_bool} == ${TRUE}
        Log To Console    \nModem is existed\n
        Log    ${4g_modem_log}
    ELSE
        Write Data    gpioset${space}1${space}0=0\ngpioset${space}1${space}2=0\ngpioset${space}1${space}1=1\n
        Sleep    15
        ${4g_modem_log}=    Read All Data    UTF-8
        Set Global Variable    ${4g_modem_log}
        Log    ${4g_modem_log}
        Write Data    modprobe qcserial\n
        ${4g_modem_log}=    Read Until    ${TERMINATOR}
        Sleep    1
    END

UART_PATTERN Verifier
    [Arguments]    ${uart_port}
    Write Data    stty -F ${uart_port} 115200 -echo igncr -icanon onlcr\n
    ${uart_log}=    Read Until    ${TERMINATOR}
    Write Data    cat ${uart_port}&\n
    ${uart_log}=    Read Until    ${TERMINATOR}

    FOR    ${counter}    IN RANGE    1    5
        Write Data    echo "${UART_STRING_OUT}" > ${uart_port}\n
        Sleep    1
    END
    ${uart_log}=    Read All Data    UTF-8
    Log    ${uart_log}  
    Set Global Variable    ${uart_log}
    sleep    0.25

DOUT Verifier
    [Arguments]    ${diolog}    ${cmp_val}
    @{lines}=    Split To Lines    ${diolog}
    ${dio_result}=    Get From List    ${lines}    -2
    Log    last_line_content:${dio_result}
    Should Be Equal As Strings   ${dio_result}    ${cmp_val}

GPIO Output Verifier
    [Arguments]    ${plx_gpiolog}    ${cmp_val}
    @{lines}=    Split To Lines    ${plx_gpiolog}
    ${gpio_result}=    Get From List    ${lines}    -2
    Log    last_line_content:${gpio_result}
    Should Be Equal As Strings   ${gpio_result}    ${cmp_val}

Check Iperf3 Bitrate
    [Arguments]    ${iperf_output}    ${speed}
    @{lines}=    Split To Lines    ${iperf_output}
    ${last_line}=    Get From List    ${lines}    -4
    ${second_last_line}=    Get From List    ${lines}    -5
    Log    last_line_content:${last_line}
    Log    Sec_last_line_content:${second_last_line} 
    ${receiver_bitrate}=    Get Regexp Matches    ${last_line}    \\d+\\sKbits/sec
    ${sender_bitrate}=    Get Regexp Matches    ${second_last_line}    \\d+\\sKbits/sec

    ${receiver_bitrate}=    Convert To String    ${receiver_bitrate} 
    ${sender_bitrate}=    Convert To String    ${sender_bitrate}

    ${receiver_bitrate_digi}=    Get Regexp Matches     ${receiver_bitrate}    \\d+
    ${sender_bitrate_digi}=    Get Regexp Matches     ${sender_bitrate}    \\d+

    ${receiver_bitrate_digi}=    Convert To Integer    @{receiver_bitrate_digi}
    ${sender_bitrate_digi}=      Convert To Integer   @{sender_bitrate_digi}

    Should Be True    ${receiver_bitrate_digi} > ${speed}
    Should Be True    ${sender_bitrate_digi} > ${speed}

Console Pause
    [Arguments]    ${ethport}
    Log To Console    \nEthernet ${ethport} is connected ? .. Press any key continue \n    UTF-8
    Run    echo -ne "Ethernet ${ethport} is connected ? .." && read ignore

Close Serial Port
    Delete All Ports

*** Test cases ***
HW Version Control Pins
    Log to Console     \nPIN - REV_0 - State Check\n
    Write Data     gpioget 1 27\n
    ${ctrl_pin_log}=    Read Until    ${TERMINATOR}
    Log    ${ctrl_pin_log}
    sleep     0.5
    Version PIN OUTPUT Verifier     ${ctrl_pin_log}    1

    Log to Console     \nPIN - REV_1 - State Check\n
    Write Data     gpioget 1 26\n
    ${ctrl_pin_log}=    Read Until    ${TERMINATOR}
    Log    ${ctrl_pin_log}
    sleep     0.5
    Version PIN OUTPUT Verifier     ${ctrl_pin_log}    0

    Log to Console     \nPIN - REV_2 - State Check\n
    Write Data     gpioget 1 25\n
    ${ctrl_pin_log}=    Read Until    ${TERMINATOR}
    Log    ${ctrl_pin_log}
    sleep     0.5
    Version PIN OUTPUT Verifier     ${ctrl_pin_log}    0

    Log to Console     \nPIN - REV_3 - State Check\n
    Write Data     gpioget 1 24\n
    ${ctrl_pin_log}=    Read Until    ${TERMINATOR}
    Log    ${ctrl_pin_log}
    sleep     0.5
    Version PIN OUTPUT Verifier    ${ctrl_pin_log}    0

I2C1 Bus Check - PMIC
    Write Data     i2cdetect -y -r 0\n
    ${i2c1_log}=    Read Until    ${TERMINATOR}
    Set Global Variable    ${i2c1_log}
    Should Contain    ${i2c1_log}    00:${SPACE * 25}UU

I2C1 Bus Check - TPM
    Should Contain    ${i2c1_log}    20: -- -- -- -- -- -- -- -- -- -- -- -- -- -- 2e --

I2C1 Bus Check - RTC
    Should Contain    ${i2c1_log}    60: -- -- -- -- -- -- -- -- UU -- -- -- -- -- -- --
    Log     ${i2c1_log}


I2C2 Bus Check - EEPROM
    Write Data     i2cdetect -y -r 1\n
    ${i2c2_log}=    Read Until    ${TERMINATOR}
    Log    ${i2c2_log}
    Should Contain    ${i2c2_log}    50: 50 51 52 53 

I2C3 Bus Check - EEPROM
    Write Data     i2cdetect -y -r 2\n
    ${i2c3_log}=    Read Until    ${TERMINATOR}
    Log    ${i2c3_log}
    Should Contain    ${i2c3_log}    50: 50 51 52 53


USB 2.0 Port Test
    Write Data    fdisk${space}-l${space}\|${space}${space}grep${space}"\/dev\/sda"${space}-A${space}6\n
    ${usb2_log}=    Read Until    ${TERMINATOR}
    Log    ${usb2_log}
    Sleep    1
    Should Contain    ${usb2_log}    Disk model
USB 4G Modem Test
    4G Modem Enable
    Write Data    lsusb\n
    ${4g_modem_log}=    Read Until    ${TERMINATOR}
    sleep    1
    Log    ${4g_modem_log}
    Should Contain    ${4g_modem_log}    EC21 LTE modem

SIM CARD Check
    Write Data   /usr/lib/ofono/test/list-modems\n
    ${sim_log}=    Read Until    ${TERMINATOR}
    Sleep    1
    Log    ${sim_log}
    Should Contain    ${sim_log}    CardIdentifier${space}=${space}89886920042541729963


PL2_UART5
    UART_PATTERN Verifier    ${UART_5}
    Should Contain    ${uart_log}     ${UART_STRING_IN}
    Write Data    killall cat\n
    Sleep    0.25
    ${uart_log}=    Read Until    ${TERMINATOR}
    Sleep    3

PL2_UART6
    UART_PATTERN Verifier    ${UART_6}
    Should Contain    ${uart_log}     ${UART_STRING_IN}
    Write Data    killall cat\n
    Sleep    0.25
    ${uart_log}=    Read Until    ${TERMINATOR}
    Sleep    3


PL3_UART3
    UART_PATTERN Verifier    ${UART_3}
    Should Contain    ${uart_log}     ${UART_STRING_IN}
    Write Data    killall cat\n
    Sleep    0.25
    ${uart_log}=    Read Until    ${TERMINATOR}
    Sleep    3

PL3_UART7
    UART_PATTERN Verifier    ${UART_7}
    Should Contain    ${uart_log}     ${UART_STRING_IN}
    Write Data    killall cat\n
    Sleep    0.25
    ${uart_log}=    Read Until    ${TERMINATOR}
    Sleep    3

PL15_UART_RS485
    UART_PATTERN Verifier    ${UART_RS485}
    Should Contain    ${uart_log}     ${UART_STRING_IN}
    Write Data    killall cat\n
    Sleep    0.25
    ${uart_log}=    Read Until    ${TERMINATOR}
    Sleep    3

PL16_UART1_RS232
    UART_PATTERN Verifier    ${UART_RS232}
    Should Contain    ${uart_log}     ${UART_STRING_IN}
    Write Data    killall cat\n
    Sleep    0.25
    ${uart_log}=    Read Until    ${TERMINATOR}
    Sleep    3


PL2_GPIO Pins 
    #Pair GPIO1_1 - GPIO1_0
    Log To Console    PL2_Pair GPIO1_0 - GPIO1_1 _ Pull High
    Write Data    gpioset 0 1=1\n
    sleep    0.1
    Write Data    gpioget 0 2\n
    Sleep    0.1
    ${pl2_gpiolog}=    Read All Data    UTF-8
    Log    ${pl2_gpiolog}
    GPIO Output Verifier    ${pl2_gpiolog}    1
    Log To Console    PL2_Pair GPIO1_0 - GPIO1_1 _ Pull Low
    Write Data    gpioset 0 1=0\n
    sleep    0.1
    Write Data    gpioget 0 2\n
    Sleep    0.1
    ${pl2_gpiolog}=    Read All Data    UTF-8
    Log    ${pl2_gpiolog}
    GPIO Output Verifier    ${pl2_gpiolog}    0

    #Pair GPIO1_3 - GPIO1_4
    Log To Console    PL2_Pair GPIO1_3 - GPIO1_4 _ Pull High
    Write Data    gpioset 5 17=1\n
    sleep    0.1
    Write Data    gpioget 5 16\n
    Sleep    0.1
    ${pl2_gpiolog}=    Read All Data    UTF-8
    Log    ${pl2_gpiolog}
    GPIO Output Verifier    ${pl2_gpiolog}    1
    Log To Console    PL2_Pair GPIO1_3 - GPIO1_4 _ Pull Low
    Write Data    gpioset 5 17=0\n
    sleep    0.1
    Write Data    gpioget 5 16\n
    Sleep    0.1
    ${pl2_gpiolog}=    Read All Data    UTF-8
    Log    ${pl2_gpiolog}
    GPIO Output Verifier    ${pl2_gpiolog}    0

    #Pair GPIO1_5 - GPIO1_6
    Log To Console    PL2_Pair GPIO1_5 - GPIO1_6 _ Pull High
    Write Data    gpioset 1 7=1\n
    sleep    0.1
    Write Data    gpioget 1 19\n
    Sleep    0.1
    ${pl2_gpiolog}=    Read All Data    UTF-8
    Log    ${pl2_gpiolog}
    GPIO Output Verifier    ${pl2_gpiolog}    1

    Log To Console    PL2_Pair GPIO1_5 - GPIO1_6 _ Pull Low
    Write Data    gpioset 1 7=0\n
    sleep    0.1
    Write Data    gpioget 1 19\n
    Sleep    0.1
    ${pl2_gpiolog}=    Read All Data    UTF-8
    Log    ${pl2_gpiolog}
    GPIO Output Verifier    ${pl2_gpiolog}    0

    #Pair GPIO1_7 - GPIO1_8
    Log To Console    PL2_Pair GPIO1_7 - GPIO1_8 _ Pull High
    Write Data    gpioset 1 18=1\n
    sleep    0.1
    Write Data    gpioget 1 17\n
    Sleep    0.1
    ${pl2_gpiolog}=    Read All Data    UTF-8
    Log    ${pl2_gpiolog}
    GPIO Output Verifier    ${pl2_gpiolog}    1

    Log To Console    PL2_Pair GPIO1_7 - GPIO1_8 _ Pull Low
    Write Data    gpioset 1 18=0\n
    sleep    0.1
    Write Data    gpioget 1 17\n
    Sleep    0.1
    ${pl2_gpiolog}=    Read All Data    UTF-8
    Log    ${pl2_gpiolog}
    GPIO Output Verifier    ${pl2_gpiolog}    0



PL3_GPIO Pins 
    #Pair GPIO1_1 - GPIO1_0
    Log To Console    PL3_Pair GPIO1_0 - GPIO1_1 _ Pull High
    Write Data    gpioset 0 4=1\n
    sleep    0.1
    Write Data    gpioget 0 5\n
    Sleep    0.1
    ${pl3_gpiolog}=    Read All Data    UTF-8
    Log    ${pl3_gpiolog}
    GPIO Output Verifier    ${pl3_gpiolog}    1
    Log To Console    PL3_Pair GPIO1_0 - GPIO1_1 _ Pull Low
    Write Data    gpioset 0 4=0\n
    sleep    0.1
    Write Data    gpioget 0 5\n
    Sleep    0.1
    ${pl3_gpiolog}=    Read All Data    UTF-8
    Log    ${pl3_gpiolog}
    GPIO Output Verifier    ${pl3_gpiolog}    0

    #Pair GPIO1_3 - GPIO1_4
    Log To Console    PL3_Pair GPIO1_3 - GPIO1_4 _ Pull High
    Write Data    gpioset 4 5=1\n
    sleep    0.1
    Write Data    gpioget 4 6\n
    Sleep    0.1
    ${pl3_gpiolog}=    Read All Data    UTF-8
    Log    ${pl3_gpiolog}
    GPIO Output Verifier    ${pl3_gpiolog}    1
    Log To Console    PL3_Pair GPIO1_3 - GPIO1_4 _ Pull Low
    Write Data    gpioset 4 5=0\n
    sleep    0.1
    Write Data    gpioget 4 6\n
    Sleep    0.1
    ${pl3_gpiolog}=    Read All Data    UTF-8
    Log    ${pl3_gpiolog}
    GPIO Output Verifier    ${pl3_gpiolog}    0

    #Pair GPIO1_5 - GPIO1_6
    Log To Console    PL3_Pair GPIO1_5 - GPIO1_6 _ Pull High
    Write Data    gpioset 1 10=1\n
    sleep    0.1
    Write Data    gpioget 1 20\n
    Sleep    0.1
    ${pl3_gpiolog}=    Read All Data    UTF-8
    Log    ${pl3_gpiolog}
    GPIO Output Verifier    ${pl3_gpiolog}    1

    Log To Console    PL3_Pair GPIO1_5 - GPIO1_6 _ Pull Low
    Write Data    gpioset 1 10=0\n
    sleep    0.1
    Write Data    gpioget 1 20\n
    Sleep    0.1
    ${pl3_gpiolog}=    Read All Data    UTF-8
    Log    ${pl3_gpiolog}
    GPIO Output Verifier    ${pl3_gpiolog}    0

    #Pair GPIO1_7 - GPIO1_8
    Log To Console    PL3_Pair GPIO1_7 - GPIO1_8 _ Pull High
    Write Data    gpioset 1 21=1\n
    sleep    0.1
    Write Data    gpioget 4 4\n
    Sleep    0.1
    ${pl3_gpiolog}=    Read All Data    UTF-8
    Log    ${pl3_gpiolog}
    GPIO Output Verifier    ${pl3_gpiolog}    1

    Log To Console    PL3_Pair GPIO1_7 - GPIO1_8 _ Pull Low
    Write Data    gpioset 1 21=0\n
    sleep    0.1
    Write Data    gpioget 4 4\n
    Sleep    0.1
    ${pl3_gpiolog}=    Read All Data    UTF-8
    Log    ${pl3_gpiolog}
    GPIO Output Verifier    ${pl3_gpiolog}    0

    #Pair GPIO1_2 
    Log To Console    PL3_Pair GPIO1_2 Pull High
    Write Data    gpioset 0 6=1\n
    sleep    3
    ${pl3_gpiolog}=    Read All Data    UTF-8
    Log To Console    PL3_Pair GPIO1_2 Pull Low
    Write Data    gpioset 0 6=0\n
    sleep    3
    Log To Console    PL3_Pair GPIO1_2 LED ON
    Write Data    gpioset 0 6=1\n
    sleep    5

eMMC Verification
    Write Data    lsblk | grep ${EMMC}\n
    sleep     0.5
    ${eMMClog}=    Read All Data    UTF-8
    Log    ${eMMClog}
    Log To Console    EMMC Read Test
    Write Data     dd if=/dev/${EMMC} of=/dev/null bs=1M count=100\n
    sleep     1
    ${eMMClog}=    Read Until    ${TERMINATOR}
    Log    ${eMMClog}
    Write Data    cat /sys/kernel/debug/mmc1/ios\n
    sleep    0.5
    ${eMMClog}=    Read All Data    UTF-8
    Log    ${eMMClog}

1-Wire Test
    Write Data    cat /sys/devices/w1_bus_master1/??-????????????/temperature\n
    sleep    1
    ${onewirelog}=    Read All Data    UTF-8
    Log    ${onewirelog}
    @{lines}=    Split To Lines    ${onewirelog}
    ${val_a}=    Get From List    ${lines}    1
    ${val_b}=    Get From List    ${lines}    2
    Log Many    ${val_a}    ${val_b}
    Convert To Integer    ${val_a}
    Convert To Integer    ${val_b}
    ${val_delta}=    Evaluate   abs(${val_a} - ${val_b})
    Log    ${val_delta}
    IF    ${val_delta} <= 1000
      Log To Console    Accuracy measurement
      ${result}=    Set Variable        $True
    ELSE
        ${result}=    Set Variable        $False
    END
    Should Be True    ${result}    $True

DOUT PL17 and DIN PL6
    Log To Console    OUTPUT=1, INPUT Should be 0    UTF-8
    Write Data    gpioset 1 3=1\n
    Sleep    0.25
    Write Data    gpioget 1 5\n
    Sleep    0.25
    ${diolog}=    Read All Data    UTF-8
    Log    ${diolog}
    DOUT Verifier    ${diolog}    0

    Log To Console    OUTPUT=0, INPUT Should be 1    UTF-8
    Write Data    gpioset 1 3=0\n
    Sleep    0.25
    Write Data    gpioget 1 5\n
    Sleep    0.25
    ${diolog}=    Read All Data    UTF-8
    Log    ${diolog}
    DOUT Verifier    ${diolog}    1


DOUT PL18 and DIN PL12
    Log To Console    OUTPUT=1, INPUT Should be 0    UTF-8
    Write Data    gpioset 1 4=1\n
    Sleep    0.25
    Write Data    gpioget 1 6\n
    Sleep    0.25
    ${diolog}=    Read All Data    UTF-8
    Log    ${diolog}
    DOUT Verifier    ${diolog}    0

    Log To Console    OUTPUT=0, INPUT Should be 1    UTF-8
    Write Data    gpioset 1 4=0\n
    Sleep    0.25
    Write Data    gpioget 1 6\n
    Sleep    0.25
    ${diolog}=    Read All Data    UTF-8
    Log    ${diolog}
    DOUT Verifier    ${diolog}    1

ADC_PL2 Board ID1
    Write Data    gpioset 0 6=0\n
    Write Data    cat /sys/bus/iio/devices/iio\:device0/in_voltage0_raw\n
    Sleep    0.5
    Write Data    gpioset 0 6=1\n
    Write Data    cat /sys/bus/iio/devices/iio\:device0/in_voltage0_raw\n
    Sleep    0.5
    ${pl2_bid1}=    Read All Data    UTF-8
    Log    ${pl2_bid1}

ADC PL3 Board ID2
    Write Data    gpioset 0 6=0\n
    Write Data    cat /sys/bus/iio/devices/iio\:device0/in_voltage1_raw\n
    Sleep    0.5
    Write Data    gpioset 0 6=0\n
    Write Data    cat /sys/bus/iio/devices/iio\:device0/in_voltage1_raw\n
    Sleep    0.5
    ${pl3_bid2}=    Read All Data    UTF-8
    Log    ${pl3_bid2}

Other ADCs in PL2 and PL3
    Write Data    cat /sys/bus/iio/devices/iio\:device0/in_voltage2_raw\n
    Sleep    0.5
    ${adc_val}=    Read All Data    UTF-8
    Log    ADC1_IN_PMIC_VIN_ADC : ${adc_val} 

    Write Data    cat /sys/bus/iio/devices/iio\:device0/in_voltage3_raw\n
    Sleep    0.5
    ${adc_val}=    Read All Data    UTF-8
    Log    3V3_PERI_ADC : ${adc_val} 

#pl3
    Write Data    cat /sys/bus/iio/devices/iio\:device1/in_voltage0_raw\n
    Sleep    0.5
    ${adc_val}=    Read All Data    UTF-8
    Log    3V3_MEM_ADC : ${adc_val} 

    Write Data    cat /sys/bus/iio/devices/iio\:device1/in_voltage1_raw\n
    Sleep    0.5
    ${adc_val}=    Read All Data    UTF-8
    Log    MODBUS_CURRENT : ${adc_val} 

    Write Data    cat /sys/bus/iio/devices/iio\:device1/in_voltage2_raw\n
    Sleep    0.5
    ${adc_val}=    Read All Data    UTF-8
    Log    1W_CURRENT : ${adc_val} 

    Write Data    cat /sys/bus/iio/devices/iio\:device1/in_voltage3_raw\n
    Sleep    0.5
    ${adc_val}=    Read All Data    UTF-8
    Log    VDD_ARM_SOC_IN_ADC : ${adc_val} 

Check Ethernet Devices
    Write Data     ifconfig -a\n
    ${ethlog}=       Read Until    ${TERMINATOR} 
    Should Contain    ${ethlog}    eth0:
    Should Contain    ${ethlog}    port1:
    Should Contain    ${ethlog}    port2:
    Should Contain    ${ethlog}    port3:
    Sleep          1
    Log            ${ethlog} 
   
Eth 100M BaseT Test for Port 1   
    Console Pause    Port 1
    Sleep    5
    ${speed}=    Set Variable    90000
    Write Data     iperf3 -c ${IPER_SERV} -p 5201 -f k\n
    ${iperflog}=    Read Until    ${TERMINATOR}
    Sleep    10
    Log    ${iperflog}
    Check Iperf3 Bitrate    ${iperflog}     ${speed}
    sleep    1

Eth 100M BaseT Test for Port 2   
    Console Pause    Port 2
    Sleep    5
    ${speed}=    Set Variable    90000
    Write Data     iperf3 -c ${IPER_SERV} -p 5201 -f k\n
    ${iperflog}=    Read Until    ${TERMINATOR}
    Sleep    10
    Log    ${iperflog}
    Check Iperf3 Bitrate    ${iperflog}     ${speed}
    sleep    1

Eth 100M BaseT Test for Port 3   
    Console Pause    Port 3
    Sleep    5
    ${speed}=    Set Variable    90000
    Write Data     iperf3 -c ${IPER_SERV} -p 5201 -f k\n
    ${iperflog}=    Read Until    ${TERMINATOR}
    Sleep    10
    Log    ${iperflog}
    Check Iperf3 Bitrate    ${iperflog}     ${speed}
    sleep    1

LED10 - Green Power LED OFF and ON
    Write Data    echo 0 > /sys/class/leds/green\:power/brightness\n
    Sleep    2
    Write Data    echo 1 > /sys/class/leds/green\:power/brightness\n
    ${led_testlog}=    Read Until    ${TERMINATOR}
    Log    ${led_testlog}
    Sleep    2

LED11 - Green Status LED OFF and ON 
    Write Data    echo 0 > /sys/class/leds/green\:status/brightness\n
    Sleep    2
    Write Data    echo 1 > /sys/class/leds/green\:status/brightness\n
    ${led_testlog}=    Read Until    ${TERMINATOR}
    Log    ${led_testlog}
    Sleep    2

LED12 - Green Comm LED OFF and ON
    Write Data    echo 0 > /sys/class/leds/green\:wan/brightness\n
    Sleep    2
    Write Data    echo 1 > /sys/class/leds/green\:wan/brightness\n
    ${led_testlog}=    Read Until    ${TERMINATOR}
    Log    ${led_testlog}
    Sleep    2

ALL Green LEDs OFF
    Write Data    echo 0 > /sys/class/leds/green\:power/brightness\n
    Write Data    echo 0 > /sys/class/leds/green\:status/brightness\n
    Write Data    echo 0 > /sys/class/leds/green\:wan/brightness\n
    ${led_testlog}=    Read Until    ${TERMINATOR}
    Log    ${led_testlog}
    Sleep    2

LED10 - Red Power LED OFF and ON
    Write Data    echo 0 > /sys/class/leds/red\:power/brightness\n
    Sleep    2
    Write Data    echo 1 > /sys/class/leds/red\:power/brightness\n
    ${led_testlog}=    Read Until    ${TERMINATOR}
    Log    ${led_testlog}
    Sleep    2

LED11 - Red Status LED OFF and ON 
    Write Data    echo 0 > /sys/class/leds/red\:status/brightness\n
    Sleep    2
    Write Data    echo 1 > /sys/class/leds/red\:status/brightness\n
    ${led_testlog}=    Read Until    ${TERMINATOR}
    Log    ${led_testlog}
    Sleep    2

LED12 - Red Comm LED OFF and ON
    Write Data    echo 0 > /sys/class/leds/red\:wan/brightness\n
    Sleep    2
    Write Data    echo 1 > /sys/class/leds/red\:wan/brightness\n 
    ${led_testlog}=    Read Until    ${TERMINATOR}
    Log    ${led_testlog}
    Sleep    2

ALL Red LEDs OFF
    Write Data    echo 0 > /sys/class/leds/red\:power/brightness\n
    Sleep    1
    Write Data    echo 0 > /sys/class/leds/red\:status/brightness\n
    Sleep    1
    Write Data    echo 0 > /sys/class/leds/red\:wan/brightness\n
    ${led_testlog}=    Read Until    ${TERMINATOR}
    Log    ${led_testlog}
    Sleep    1

ALL Orange LEDs ON
    Write Data    echo 1 > /sys/class/leds/red\:power/brightness\n
    Sleep    0.25
    Write Data    echo 1 > /sys/class/leds/red\:status/brightness\n
    Sleep    0.25
    Write Data    echo 1 > /sys/class/leds/red\:wan/brightness\n
    Sleep    0.25
    Write Data    echo 1 > /sys/class/leds/green\:power/brightness\n
    Sleep    0.25
    Write Data    echo 1 > /sys/class/leds/green\:status/brightness\n
    Sleep    0.25
    Write Data    echo 1 > /sys/class/leds/green\:wan/brightness\n
    Sleep    0.25
    Write Data    \n
    ${led_testlog}=    Read Until    ${TERMINATOR}
    Log    ${led_testlog}
    Sleep    1

    

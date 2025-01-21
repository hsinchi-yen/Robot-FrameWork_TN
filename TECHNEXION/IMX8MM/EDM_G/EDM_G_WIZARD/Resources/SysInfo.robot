=========================================================================
 Copyright 2024 Technexion Ltd.
 Test Case No      : Case TNPT-6
 Category          : Test A-System and Function
 Script name       : Sysinfo.robot
 Author            : Raymond 
 Date created      : 20240830
=========================================================================
*** Settings ***
Library           Collections
Library           Process
Library            String

Resource       ../Resources/Common_Params.robot
Library        ../Libraries/EnvVariablesReturnLib.py


*** Variables ***
#Board Info
${BOARDINFO}=    cat /sys/devices/soc0/machine
${SOCFAMILY}=    cat /sys/devices/soc0/family
${SOCREV}=    cat /sys/devices/soc0/revision
${SOCID}=    cat /sys/devices/soc0/soc_id
${SOC_SN}=    cat /sys/devices/soc0/serial_number

#CPU Info
${CPUS}=    grep "processor" /proc/cpuinfo | wc -l
#get the CPU current speed
${CPU_CUR_CLK}=    cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq | awk '{$1=$1/1000; print $1;}'
${CPU_MAX_CLK}=    cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq | awk '{$1=$1/1000; print $1;}'
${CPU_MIN_CLK}=    cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq | awk '{$1=$1/1000; print $1;}'
# get the current temperature of CPU
${CPU_TEMP_Z1}=    cat /sys/class/thermal/thermal_zone0/temp| awk '{$1=$1/1000; print $1;}'
${CPU_TEMP_Z2}=    cat /sys/class/thermal/thermal_zone1/temp | awk '{$1=$1/1000; print $1;}'

#Memory Info
${MEMSIZE}=     free -h | grep 'Mem:' | awk -F ' ' '{print $2}'
${used_MEMSIZE}=    free -h | grep 'Mem:' | awk -F ' ' '{print $3}'
${free_MEMSIZE}=    free -h | grep 'Mem:' | awk -F ' ' '{print $4}'
${CMASIZE}=    cat /proc/meminfo | grep CmaTotal | awk -F ' ' '{$2=$2/1000; print $2}'
${free_CMASIZE}=    cat /proc/meminfo | grep CmaFree | awk -F ' ' '{$2=$2/1000; print $2}'

${eMMCID}=    2
${EMMC_NAME}=    dmesg | grep "mmcblk${eMMCID}" | grep GiB | head -1 | awk -F ' ' '{print $5}'
${EMMC_SIZE}=    dmesg | grep "mmcblk${eMMCID}" | grep GiB | head -1 | awk -F ' ' '{print $6 $7}'
${EMMC_freespace}=    df -h | grep "/dev/root" | awk -F ' ' '{print $4}'
#eMMC version, life , operation state
${EMMC_VER}=    mmc extcsd read /dev/mmcblk${eMMCID} | grep "Extended CSD rev" | sed 's/^ *//'
${EMMC_LIFE}=    mmc extcsd read /dev/mmcblk${eMMCID} | grep "eMMC Life"
${EMMC_PEOL}=    mmc extcsd read /dev/mmcblk${eMMCID} | grep "eMMC Pre EOL"
${EMMC_OP_State}=    cat "/sys/kernel/debug/mmc${eMMCID}/ios"


#GPU info , module, working Clock
${GPU_INFO}=    cat /sys/kernel/debug/gc/info
${GPU_M_INFO}=    cat /sys/kernel/debug/gc/meminfo

#Network , eth name, wifi chip name, btchip name , bt version, wifi chip temp
${ETH_MACID}=    ifconfig eth0 | grep -E "\w\w:\w\w:\w\w:\w\w:\w\w:\w\w" | awk -F ' ' '{print $2}'
${ETH_INF_N}=    ifconfig eth0 | grep "eth0" | awk -F ':' '{print $1}'
${ETH_CHIP_ID}=    dmesg | grep eth | grep driver | awk -F '[' '{print $4}' | awk -F ']' '{print $1}'
${WIFI_MACID}=    ifconfig wlan0 | grep -E "\w\w:\w\w:\w\w:\w\w:\w\w:\w\w"  | awk -F ' ' '{print $2}'
${WIFI_INF_N}=    ifconfig wlan0 | grep "wlan0" | awk -F ':' '{print $1}'
${WIFI_CHIPID}=    cat /sys/bus/mmc/devices/mmc?\:0001/mmc?\:0001\:1/device
${WIFI_FWINFO}=    dmesg | grep "HW:" | awk -F ']' '{print $2}'


${BT_MACID}=    hciconfig -a | grep -E "\w\w:\w\w:\w\w:\w\w:\w\w:\w\w" | awk -F ' ' '{print $3}'
${BT_VER}=    hciconfig -a | grep "HCI Version" | awk -F ' ' '{print $3}'
${BT_INF_N}=    hciconfig -a | grep hci | awk -F ':' '{print $1}'

${WIFI_CHIP_INFO}=    iwpriv wlan0 get_temp
${WIFI_CHIP_INF}=    echo "${WIFI_CHIP_INFO}" | cut -d ' ' -f 1
${WIFI_CHIP_TEMP}=    echo "${WIFI_CHIP_INFO}" | cut -d ':' -f 2

# get the U-boot info.
${UBoot_INFO}=    dd if=/dev/mmcblk${eMMCID} skip=32 bs=1k count=1200 2>/dev/null | strings | grep 'U-Boot' | head -1
*** Keywords ***
Board Info
   Seriallibrary.Write Data    ${BOARDINFO};${SOCFAMILY};${SOCREV};${SOCID};${SOC_SN}${\n}  
   Sleep    1
   ${info}=    Seriallibrary.Read All Data        UTF-8
   Log    ${info}
   @{lines}=    Split To Lines    ${info}
    # ${Board}=    Get Slice From List    ${lines}[3:8]
    # Log    ${Board}
    ${Boardinfo1}=    Get From List    ${lines}    3
    ${Boardinfo2}=    Get From List    ${lines}    4
    ${Boardinfo3}=    Get From List    ${lines}    5
    ${Boardinfo4}=    Get From List    ${lines}    6
    ${Boardinfo5}=    Get From List    ${lines}    7
    Log To Console    \n================Board Info=================     
    Log To Console    Board informaion: ${Boardinfo1} 
    Log To Console    SOC FAMILY: ${Boardinfo2} 
    Log To Console    SOC Revision: ${Boardinfo3} 
    Log To Console    SOC ID: ${Boardinfo4} 
    Log To Console    SOC SN: ${Boardinfo5} 
    Log     Board informaion: ${Boardinfo1}\nSOC FAMILY: ${Boardinfo2}\nSOC Revision: ${Boardinfo3}\nSOC ID: ${Boardinfo4} \nSOC SN: ${Boardinfo5} 
  
CPU Info
   Seriallibrary.Write Data    ${CPUS};${CPU_CUR_CLK};${CPU_MAX_CLK};${CPU_MIN_CLK};${CPU_TEMP_Z1};${CPU_TEMP_Z2}${\n}  
   Sleep    1
   ${info}=    Seriallibrary.Read All Data        UTF-8
   Log    ${info}
   @{lines}=    Split To Lines    ${info}
   
    ${CPUinfo1}=    Get From List    ${lines}    7
    ${CPUinfo2}=    Get From List    ${lines}    8
    ${CPUinfo3}=    Get From List    ${lines}    9
    ${CPUinfo4}=    Get From List    ${lines}    10
    ${CPUinfo5}=    Get From List    ${lines}    11
    ${CPUinfo6}=    Get From List    ${lines}    12
    Log To Console    ================CPU Info=================    
    Log To Console    CPU core: ${CPUinfo1} 
    Log To Console    CPU Current Speed (MHz): ${CPUinfo2} 
    Log To Console    CPU Maximun clock (Mhz): ${CPUinfo3} 
    Log To Console    CPU Minimun clock (Mhz): ${CPUinfo4} 
    Log To Console    CPU temperature,Zone0: ${CPUinfo5} °C
    Log To Console    CPU temperature,Zone1: ${CPUinfo6} °C
    Log    CPU core: ${CPUinfo1}\nCPU Current Speed (MHz): ${CPUinfo2}\nCPU Maximun clock (Mhz): ${CPUinfo3}\nCPU Minimun clock (Mhz): ${CPUinfo4}\nCPU temperature,Zone0: ${CPUinfo5} °C\nCPU temperature,Zone1: ${CPUinfo6} °C

Memory Info
   Seriallibrary.Write Data    ${MEMSIZE};${used_MEMSIZE};${free_MEMSIZE};${CMASIZE};${free_CMASIZE}${\n}  
   Sleep    1
   ${info}=    Seriallibrary.Read All Data        UTF-8
   Log    ${info}
   @{lines}=    Split To Lines    ${info}

    ${Meminfo1}=    Get From List    ${lines}    5
    ${Meminfo2}=    Get From List    ${lines}    6
    ${Meminfo3}=    Get From List    ${lines}    7
    ${Meminfo4}=    Get From List    ${lines}    8
    ${Meminfo5}=    Get From List    ${lines}    9
    Log To Console    ================Memory Info================= 
    Log To Console    Total Memory Capacity: ${Meminfo1} 
    Log To Console    Total Used: ${Meminfo2} 
    Log To Console    Total Free: ${Meminfo3} 
    Log To Console    CMA: ${Meminfo4} 
    Log To Console    CMA Free: ${Meminfo5} 
    Log     Total Memory Capacity: ${Meminfo1}\nTotal Used: ${Meminfo2}\nTotal Free: ${Meminfo3}\nCMA: ${Meminfo4}\nCMA Free: ${Meminfo5} 
eMMC Info
   Seriallibrary.Write Data    ${EMMC_NAME};${EMMC_SIZE};${EMMC_freespace};${EMMC_VER};${EMMC_LIFE};${EMMC_PEOL}${\n}  
   Sleep    1
   ${info}=    Seriallibrary.Read All Data        UTF-8
   Log    ${info}
   @{lines}=    Split To Lines    ${info}
   
    ${eMMCinfo1}=    Get From List    ${lines}    6
    ${eMMCinfo2}=    Get From List    ${lines}    7
    ${eMMCinfo3}=    Get From List    ${lines}    8
    ${eMMCinfo4}=    Get From List    ${lines}    9
    ${eMMCinfo5}=    Get Slice From List    ${lines}[10:12]
    ${eMMCinfo6}=    Get From List    ${lines}    12
    Seriallibrary.Write Data    ${EMMC_OP_State}${\n}  
    Sleep    1
    ${eMMCinfo7}=    Seriallibrary.Read All Data        UTF-8
   
    Log    ${eMMCinfo7}
    Log To Console    ================eMMC Info================= 
    Log To Console    eMMC Name: ${eMMCinfo1} 
    Log To Console    eMMC Size: ${eMMCinfo2} 
    Log To Console    eMMC Free: ${eMMCinfo3} 
    Log To Console    eMMC Version: ${eMMCinfo4} 
    Log To Console    eMMC Life: ${eMMCinfo5} 
    Log To Console    eMMC PEOL: ${eMMCinfo6} 
    Log To Console    eMMC OP State: ${eMMCinfo7} 
    Log    eMMC Name: ${eMMCinfo1}\neMMC Size: ${eMMCinfo2}\neMMC Free: ${eMMCinfo3}\neMMC Version: ${eMMCinfo4}\neMMC Life: ${eMMCinfo5}\neMMC PEOL: ${eMMCinfo6}\neMMC OP State: ${eMMCinfo7} 

GPU Info
   Seriallibrary.Write Data    ${GPU_INFO}${\n}  
   #Sleep    1
   ${GPUinfo1}=    Seriallibrary.Read Until   ${TERMINATOR}     
   
   Log    ${GPUinfo1}
       
   Seriallibrary.Write Data    ${GPU_M_INFO}${\n}  
   Sleep    1
   ${GPUinfo2}=    Seriallibrary.Read All Data        UTF-8
   Log    ${GPUinfo2}
  
 
    Log To Console    ================GPU Info================= 
    Log To Console    GPU info1: ${GPUinfo1} 
    Log To Console    GPU info2: ${GPUinfo2} 
    Log     GPU info1: ${GPUinfo1}\nGPU info2: ${GPUinfo2} 
    


Network Info
   Seriallibrary.Write Data    ${ETH_MACID};${ETH_INF_N};${ETH_CHIP_ID};${WIFI_MACID};${WIFI_INF_N};${WIFI_CHIPID};${WIFI_FWINFO};${BT_MACID};${BT_VER};${BT_INF_N};${WIFI_CHIP_INFO}${\n}  

   Sleep    1
   ${info}=    Seriallibrary.Read All Data        UTF-8
   Log    ${info}
   @{lines}=    Split To Lines    ${info}
   ${eth_mac}=    Ethernet MAC Check
   ${wifi_mac}=    WIFI MAC Check
   ${bt_mac}=    BT MAC Check

    ${Netinfo1}=    Get From List    ${eth_mac}  0
    ${Netinfo2}=    Get From List    ${lines}    9
    ${Netinfo3}=    Get From List    ${lines}    10
    ${Netinfo4}=    Get From List    ${wifi_mac}  0
    ${Netinfo5}=    Get From List    ${lines}    11
    ${Netinfo6}=    Get From List    ${lines}    12
    ${Netinfo7}=    Get From List    ${lines}    13
    ${Netinfo8}=    Get From List    ${bt_mac}   0
    ${Netinfo9}=    Get From List    ${lines}    14
    ${Netinfo10}=    Get From List    ${lines}    15
    ${Netinfo11}=    Get From List    ${lines}    16
    #${wifi_ip_string}=    Strip String    @{Netinfo11}    characters=wlan0
    Log To Console    ================Network Info================= 
    Log To Console    MAC Address: ${Netinfo1} 
    Log To Console    Interface: ${Netinfo2} 
    Log To Console    Ethernet Chip ID: ${Netinfo3} 
    Log To Console    WIFI MAC Address: ${Netinfo4} 
    Log To Console    WIFI Interface: ${Netinfo5} 
    Log To Console    WIFI Chip ID: ${Netinfo6} 
    Log To Console    WIFI FW Info: ${Netinfo7} 
    Log To Console    BT MAC Address: ${Netinfo8}
    Log To Console    BT VER: ${Netinfo9} 
    Log To Console    BT Info: ${Netinfo10} 
    Log To Console    WIFI CHIP TEMP : ${Netinfo11} °C


Uboot Info
   Seriallibrary.Write Data    ${Uboot_INFO}${\n}  
   Sleep    1
   ${Ubootinfo1}=    Seriallibrary.Read All Data        UTF-8
   Log    ${Ubootinfo1}
   
  Seriallibrary.Write Data    cat /etc/os-release${\n}
  Sleep    1
  ${Ubootinfo2}=    Seriallibrary.Read All Data        UTF-8
   Log    ${Ubootinfo2}
   Log To Console    ================Uboot Info================= 
   Log To Console    Uboot info1: ${Ubootinfo1} 
   Log To Console    ================Image Info================= 
   Log To Console    Image Info: ${Ubootinfo2} 
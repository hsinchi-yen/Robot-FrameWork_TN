*** Settings ***
Resource          ../Resources/Common_Params.robot
Library         Collections

*** Variables ***
${TEST_SIZE}=        200m
${CHK_WORD}=         Disk stats (read/write):
#sd mmc in imx8mm mmc1
${SDCARD_LOC}=       /dev/mmcblk1
${SDCARD_BUSINFO}=   /sys/kernel/debug/mmc1/ios 

#emmc in imx8mm mmc2
${EMMC_FILE_LOC}=    /home/root/testfile.tmp
${EMMC_BUSINFO}=     /sys/kernel/debug/mmc2/ios 

#Nvme storage in imx8mp
${NVME_LOC}=         /dev/nvme0n1

*** Keywords ***
USB Devices Read And Write Test 
    @{test_blks}=    Get Mounted USB Devices
    
    FOR    ${test_blk}    IN    @{test_blks}
        Execute Fio Read Test    ${test_blk}
        Sleep    1
        Execute Fio Write Test   ${test_blk}
        Sleep    1
        Get USB Device Info    ${test_blk}
    END

SDCARD Read And Write Test
    SDCARD Sdio Bus Info Check
    Execute Fio Read Test    ${SDCARD_LOC}
    Execute Fio Write Test   ${SDCARD_LOC}

Emmc Read And Write Test
    Emmc Sdio Bus Info Check
    Execute Fio File Read Test     ${EMMC_FILE_LOC}
    Execute Fio File Write Test    ${EMMC_FILE_LOC}

Nvme Read and Write Test
    Execute Fio Read Test    ${NVME_LOC}
    Execute Fio Write Test   ${NVME_LOC}
    
Get Mounted USB Devices
    [Documentation]    Get a list of mounted USB storage devices.
    @{blks}=    Create List
    #SerialLibrary.Write Data   lsblk | grep -E 'sd'${\n}
    SerialLibrary.Write Data    fdisk -l | grep -E 'Disk /dev/sd\\w' | sort | uniq${\n}
    Sleep    1
    ${lsblk_log}=    SerialLibrary.Read All Data    UTF-8
    ${blk_que}=      Get Regexp Matches     ${lsblk_log}    [\/]dev[\/]sd\\w
    
    FOR    ${element}    IN    @{blk_que}
        ${new_element}=    Replace String    ${element}    \n    /dev/
        Log    ${new_element}
        Append To List    ${blks}    ${new_element}   
    END

    RETURN    ${blks}

Execute Fio Read Test
    [Arguments]    ${location}
    SerialLibrary.Write Data    fio --loops=1 --size=${TEST_SIZE} --filename=${location} --stonewall --ioengine=libaio --direct=1 --name=Seqread --bs=1m --rw=read${\n}
    #${Seq_read_log}=    SerialLibrary.Read Until    ${TERMINATOR}
    WHILE    True
        ${Seq_read_log}=    SerialLibrary.Read Until    ${TERMINATOR}
        Log     ${Seq_read_log}    console=yes
        IF    '${TERMINATOR}' in '''${Seq_read_log}'''    BREAK
    END
    Log    ${Seq_read_log}
    Should Contain    ${Seq_read_log}    ${CHK_WORD}
    Sleep    1


Execute Fio Write Test
    [Arguments]    ${location}
    SerialLibrary.Write Data    fio --loops=1 --size=${TEST_SIZE} --filename=${location} --stonewall --ioengine=libaio --direct=1 --name=Seqwrite --bs=1m --rw=write --allow_mounted_write=1${\n}
    #${Seq_write_log}=    SerialLibrary.Read Until    ${TERMINATOR}
    WHILE    True
        ${Seq_write_log}=    SerialLibrary.Read Until    ${TERMINATOR}
        Log     ${Seq_write_log}    console=yes
        IF    '${TERMINATOR}' in '''${Seq_write_log}'''    BREAK
    END
    Log    ${Seq_write_log}
    Should Contain    ${Seq_write_log}    ${CHK_WORD}
    Should Contain    ${Seq_write_log}    ${CHK_WORD}
    Sleep    1

Get USB Device Info
    [Arguments]    ${location}
    SerialLibrary.Write Data    udevadm info --query=all --name=${location} | grep -E "DEV|ID_USB" ${\n}
    Sleep    2
    ${usb_info}=    Seriallibrary.Read All Data    UTF-8
    Log    ${usb_info}

Execute Fio File Read Test
    [Arguments]    ${location}
    SerialLibrary.Write Data    fio --loops=1 --size=${TEST_SIZE} --filename=${location} --stonewall --ioengine=libaio --direct=1 --name=Seqread --bs=1m --rw=read${\n}
    ${Seq_read_log}=    SerialLibrary.Read Until    ${TERMINATOR}
    Log    ${Seq_read_log}
    Should Contain    ${Seq_read_log}    ${CHK_WORD}
    Sleep    1

Execute Fio File Write Test
    [Arguments]    ${location}
    SerialLibrary.Write Data    fio --loops=1 --size=${TEST_SIZE} --filename=${location} --stonewall --ioengine=libaio --direct=1 --name=Seqwrite --bs=1m --rw=write --allow_mounted_write=1${\n}
    ${Seq_write_log}=    SerialLibrary.Read Until    ${TERMINATOR}
    Log    ${Seq_write_log}
    Should Contain    ${Seq_write_log}    ${CHK_WORD}

SDCARD Sdio Bus Info Check
    SerialLibrary.Write Data    cat ${SDCARD_BUSINFO}${\n}
    Sleep    2
    ${sd_businfo_log}=    SerialLibrary.Read All Data    UTF-8
    #check bus clock - modify for pico-wizard
    Run Keyword And Continue On Failure    Should Contain    ${sd_businfo_log}    50000000 Hz
    #check spec. comply with SDR50
    Run Keyword And Continue On Failure    Should Contain    ${sd_businfo_log}    2 (sd high-speed)
    #check singnal voltage 3.3
    Run Keyword And Continue On Failure    Should Contain    ${sd_businfo_log}    21 (3.3 ~ 3.4 V)

Emmc Sdio Bus Info Check
    SerialLibrary.Write Data    cat ${EMMC_BUSINFO}${\n}
    Sleep    2
    ${sd_businfo_log}=    SerialLibrary.Read All Data    UTF-8
    #check bus clock    
    Run Keyword And Continue On Failure    Should Contain    ${sd_businfo_log}    52000000 Hz
    #check spec. comply with SDR104
    Run Keyword And Continue On Failure    Should Contain    ${sd_businfo_log}    8 (mmc DDR52)
    #check singnal voltage 1.8
    Run Keyword And Continue On Failure    Should Contain    ${sd_businfo_log}    21 (3.3 ~ 3.4 V)

Nvme Info checker And Dumper
    SerialLibrary.Write Data    /usr/sbin/lspci${\n}
    Sleep    1
    ${nvme_chk_log}=    SerialLibrary.Read All Data    UTF-8
    Should Contain    ${nvme_chk_log}    Non-Volatile memory

    ${fetch_id}=    Get Regexp Matches    ${nvme_chk_log}g    ..+\\sNon-Volatile memory
    ${pcie_id}=    Strip String   @{fetch_id}    characters=Non-Volatile memory
    SerialLibrary.Write Data    /usr/sbin/lspci -s ${pcie_id} -vvv${\n}
    Sleep    3     
    ${pcie_chk_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${pcie_chk_log}
    Should Contain   ${pcie_chk_log}    LnkSta:	Speed 8GT/s (ok), Width x1
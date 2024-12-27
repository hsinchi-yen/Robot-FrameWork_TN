=========================================================================
 Copyright 2024 Technexion Ltd.
 Test Case No      : Case TNPT-210
 Category          : Function Test  
 Script name       : Dual_Display_HDMI_LVDS.robot
 Author            : Raymond 
 Date created      : 20240813
=========================================================================
*** Settings ***
Library        Collections
Resource          ../Resources/Common_Params.robot



*** Variables ***
@{COLORS}    r    g    b
@{FREQUENCIES}    2    0

${FILE_PATH}    /run/media/boot-mmcblk2p1/uEnv.txt
${OLD_VIDEO}    video=mxcfb0:dev=hdmi,1280x720M@60,if=RGB24 fbmem=28M
${NEW_VIDEO}    video=mxcfb0:dev=hdmi,1280x720M@60,if=RGB24 video=mxcfb1:dev=ldb,1024x600@60,if=RGB24
*** Keywords ***


Set_DualDisplay
    
    SerialLibrary.Write Data    sed -i "s\/${OLD_VIDEO}\/${NEW_VIDEO}\/g" ${FILE_PATH}${\n}
    Sleep    1
    ${content}=    SerialLibrary.Read All Data   
    Send Reboot command then Check Reboot State And Relogin
    Sleep    10

FBTEST
    SerialLibrary.Write Data    echo 0 > /sys/class/graphics/fb2/blank${\n}
    Sleep    3
    FOR    ${freq}    IN    @{FREQUENCIES}
        FOR    ${color}    IN    @{COLORS}
            SerialLibrary.Write Data    fb-test -f ${freq} -${color}${\n}
            Sleep    3
        END
    END

HDMI+LVDS
    SerialLibrary.Write Data    cat ${FILE_PATH}${\n}
    Sleep    1
    ${content}=    SerialLibrary.Read All Data
    IF    $NEW_VIDEO in $content  # Robot framework 4.0 expression for string compare
        Log    DualDisplay Already set 
        FBTEST
    ELSE
        Log    Start to set Dual Display
        Set_DualDisplay 
        FBTEST
    END
  


    

=========================================================================
 Copyright 2024 Technexion Ltd.
 Test Case No      : Case TNPT-63
 Category          : Stress Test  
 Script name       : Bluetooth_Test.robot
 Author            : Lance 
 Date created      : 20240830
=========================================================================
History 
Date    20250109    Combined Pipewire and PulseAudio services 

*** Settings ***
Library        Collections
Resource       ../Resources/Common_Params.robot
Library        ../Libraries/EnvVariablesReturnLib.py
Library        String


*** Variables ***
#A2DP Speaker info.
${A2DP_DEV_MAC}            E8:07:BF:6F:B4:99
${A2DP_DEV_NAME}           Mi Bluetooth Speaker

*** Keywords ***

Bluetooth Software Pipewire
    SerialLibrary.Write Data    dpkg -l | grep 'pipewire.*1\.0\.5-r[0-9]*'${\n}
    ${bt_sw_log}=    SerialLibrary.Read Until        ${TERMINATOR}
    Log    ${bt_sw_log}    
    Should Contain    ${bt_sw_log}    pipewire
    SerialLibrary.Write Data     systemctl --user restart wireplumber pipewire pipewire-pulse${\n}
    Sleep    3
Bluetooth Software PulseAudio
    SerialLibrary.Write Data    export DISPLAY=:0; killall pulseaudio; pulseaudio -D${\n}
    Sleep    3

Kernel Check SW Select   # To judge software use Pipewire or Pulseaudio based on kernel ver.
     SerialLibrary.Write Data    uname -r | cut -d'.' -f1-2${\n}
     Sleep    1
     ${data}=    SerialLibrary.Read All Data    UTF-8
     @{lines}=    Split To Lines    ${data}
     ${Kernelver}=      Get From List    ${lines}    1
     Log    \nKernel Version is ${Kernelver}    console=yes
     
     
     IF    ${Kernelver} < 6.6        
          Run Keywords
          ...    Log    \nUse PulseAudio for connection    console=yes
          ...  AND    Bluetooth Software PulseAudio

     ELSE    
         Run Keywords
          ...    Log    \nUse Pipewire for connection    console=yes
          ...  AND    Bluetooth Software Pipewire
     END

    
Bluetooth Speaker Device Scan
    SerialLibrary.Write Data    scan on${\n}
    ${bt_devs_log}=    SerialLibrary.Read Until        ${A2DP_DEV_NAME}
    Log    ${bt_devs_log}
    #Should Contain    ${bt_devs_log}    ${A2DP_DEV_NAME}

    ${dev_state}=    Run Keyword And Return Status    Should Contain    ${bt_devs_log}    ${A2DP_DEV_NAME}

    IF    ${dev_state} == $True
        Log    ${A2DP_DEV_NAME} is found    console=yes
    ELSE
        Log    ${A2DP_DEV_NAME} not found    console=yes
        SerialLibrary.Write Data    exit${\n}
        Sleep    1
        Fail    Device is not found
    END


Bluetooth Speaker Connect

    Kernel Check SW Select 

    SerialLibrary.Write Data    bluetoothctl${\n}
    Sleep    0.5
    SerialLibrary.Write Data    default-agent${\n}
    Sleep    0.5
    SerialLibrary.Write Data    agent on${\n}
    Sleep    0.5
    
    #search BT Speaker
    Bluetooth Speaker Device Scan

    
    SerialLibrary.Write Data    pair ${A2DP_DEV_MAC}${\n}
    Sleep    5
    SerialLibrary.Write Data    connect ${A2DP_DEV_MAC}${\n}
    Sleep    5
    ${bt_connect_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${bt_connect_log}
    Should Contain    ${bt_connect_log}    [${A2DP_DEV_NAME}]
    Sleep    1
    SerialLibrary.Write Data    scan off${\n}
    Sleep    5
    SerialLibrary.Write Data    exit${\n}
    Sleep    1
    ${bluez_card_log}=        SerialLibrary.Read All Data        UTF-8
    Log    ${bluez_card_log}    

    
Kernel Check Play   # To judge software use Pipewire or Pulseaudio based on kernel ver.
     SerialLibrary.Write Data    uname -r | cut -d'.' -f1-2${\n}
     Sleep    1
     ${data}=    SerialLibrary.Read All Data    UTF-8
     @{lines}=    Split To Lines    ${data}
     ${Kernelver}=      Get From List    ${lines}    1
     Log    \nKernel Version is ${Kernelver} 
     
     
     IF    ${Kernelver} < 6.6        
          Run Keywords
          ...    Log    \nPlay sound file with PulseAudio service    console=yes
          ...  AND    Bluetooth A2DP Speaker Play for PulseAudio

     ELSE    
         Run Keywords
          ...    Log    \nPlay sound file with Pipewire service     console=yes
          ...  AND    Bluetooth A2DP Speaker Play for Pipewire
     END
Bluetooth A2DP Speaker Play for PulseAudio
    SerialLibrary.Write Data    paplay -p --device=$(pacmd list-sinks | grep -e 'name: <bluez' | cut -c9-46) /usr/share/sounds/alsa/Front_Center.wav${\n}
    Sleep    5
    SerialLibrary.Write Data    echo $?${\n}
    Sleep    1
    ${bt_speaker_play_log}=    SerialLibrary.Read All Data    UTF-8
    Should Contain    ${bt_speaker_play_log}    0
    Log    ${bt_speaker_play_log}

    #check the result
    @{lines}=    Split To Lines    ${bt_speaker_play_log}
    ${return_result}=      Get From List    ${lines}    -2
    Should Be Equal     ${return_result}    0


Bluetooth A2DP Speaker Play for Pipewire
    SerialLibrary.Write Data    pw-play /usr/share/sounds/alsa/Front_Center.wav${\n}
    Sleep    5
    SerialLibrary.Write Data    echo $?${\n}
    Sleep    1
    ${bt_speaker_play_log}=    SerialLibrary.Read All Data    UTF-8
    Should Contain    ${bt_speaker_play_log}    0
    Log    ${bt_speaker_play_log}

    #check the result
    @{lines}=    Split To Lines    ${bt_speaker_play_log}
    ${return_result}=      Get From List    ${lines}    -2
    Should Be Equal     ${return_result}    0
Purge BT A2DP connection
    SerialLibrary.Write Data    bluetoothctl remove ${A2DP_DEV_MAC}${\n}
    Sleep    1
    ${a2dp_clear_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${a2dp_clear_log}
    Should Contain    ${a2dp_clear_log}    DEL
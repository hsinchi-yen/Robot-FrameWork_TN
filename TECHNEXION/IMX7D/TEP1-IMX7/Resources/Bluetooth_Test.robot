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
Bluetooth Speaker Device Scan
    SerialLibrary.Write Data    scan on${\n}
    ${bt_devs_log}=    SerialLibrary.Read Until        ${A2DP_DEV_NAME}
    Log    ${bt_devs_log}
    ${dev_scanned}=    Run Keyword And Return Status       Should Contain    ${bt_devs_log}    ${A2DP_DEV_NAME}
    RETURN    ${dev_scanned}
    

Bluetooth Speaker Connect
    #Clear existing PulseAudio service
    SerialLibrary.Write Data    while true; do pulseaudio -k; pulseaudio > /dev/null 2>&1 & PID=$! && sleep 1; ( ps -p $PID > /dev/null ) && break; done${\n}
    Sleep    3

    SerialLibrary.Write Data    bluetoothctl${\n}
    Sleep    0.5
    SerialLibrary.Write Data    default-agent${\n}
    Sleep    0.5
    SerialLibrary.Write Data    agent on${\n}
    Sleep    0.5
    
    #search BT Speaker
    ${btspk_found}=    Bluetooth Speaker Device Scan

    IF    ${btspk_found} == $True
        SerialLibrary.Write Data    pair ${A2DP_DEV_MAC}${\n}
        Sleep    5
        SerialLibrary.Write Data    connect ${A2DP_DEV_MAC}${\n}
        Sleep    5
        ${bt_connect_log}=    SerialLibrary.Read All Data    UTF-8
        Log    ${bt_connect_log}
        Should Contain    ${bt_connect_log}    [${A2DP_DEV_NAME}]
        Sleep    1
        SerialLibrary.Write Data    scan off${\n}
        Sleep    1
        SerialLibrary.Write Data    exit${\n}
        Sleep    1
        ${bluez_card_log}=        SerialLibrary.Read All Data        UTF-8
        Log    ${bluez_card_log} 
    ELSE
        Log    BT Speaker is not found , Result ${btspk_found}
            SerialLibrary.Write Data    scan off${\n}
        Sleep    1
        SerialLibrary.Write Data    exit${\n}
        Sleep    1
        ${bluez_card_log}=        SerialLibrary.Read All Data        UTF-8
        Log    ${bluez_card_log}
        Fail
    END

Bluetooth A2DP Speaker Play
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

Purge BT A2DP connection
    SerialLibrary.Write Data    bluetoothctl remove ${A2DP_DEV_MAC}${\n}
    Sleep    1
    ${a2dp_clear_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${a2dp_clear_log}
    Should Contain    ${a2dp_clear_log}    DEL

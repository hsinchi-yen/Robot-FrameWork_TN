*** Settings ***
Library         String
Library         DateTime
Library         Collections
Resource        ../Resources/Common_Params.robot


*** Variables ***
${SND_CARD_DEV}=    wm8960audio [wm8960-audio]
#${SND_CARD_DEV}=    tlv320aic3xaudi [tlv320aic3x-audio]
${HDMI_AUD_DEV}=    audiohdmi [audio-hdmi]

${CTRL_C}=                 \x03 
${PLAY_BACK_ERROR}=    Playback open error:
${PLAY_TIME}=    20

*** Keywords ***
Audio Jack Test
    ${_}    ${snd_card_id}=    Sound Card ID Checker
    #play audio
    SerialLibrary.Write Data    speaker-test -t wav -c 2 -D plughw:${snd_card_id}${\n}
    Sleep    ${PLAY_TIME}
    SerialLibrary.Write Data    ${CTRL_C}${CTRL_C}
    ${aud_test_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${aud_test_log}
    Should Not Contain    ${aud_test_log}    ${PLAY_BACK_ERROR}

HDMI Audio Test
    ${snd_card_id}=    HDMI Audio ID Checker
    #play audio
    SerialLibrary.Write Data    speaker-test -t wav -c 2 -D plughw:${snd_card_id}${\n}
    Sleep    ${PLAY_TIME}
    SerialLibrary.Write Data    ${CTRL_C}${CTRL_C}
    ${aud_test_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${aud_test_log}
    Should Not Contain    ${aud_test_log}    ${PLAY_BACK_ERROR}


Sound Card ID Checker
    SerialLibrary.Write Data    aplay -l${\n}
    Sleep    1
    ${snd_card_log}=    SerialLibrary.Read All Data    UTF-8
    Should Contain    ${snd_card_log}    ${SND_CARD_DEV}
    ${cardid_fetch}=    Get Regexp Matches    ${snd_card_log}    card\\s\\d: wm8960audio    
    ${cardid_1st}=    Set Variable    ${cardid_fetch}[0]
    ${return_cardid}=    Get Regexp Matches    ${cardid_1st}    ([^\\w+])\\d
    ${return_cardid}=    Convert To Integer    @{return_cardid}
    RETURN    ${cardid_1st}    ${return_cardid}   

HDMI Audio ID Checker
    SerialLibrary.Write Data    aplay -l${\n}
    Sleep    1
    ${snd_card_log}=    SerialLibrary.Read All Data    UTF-8
    Should Contain    ${snd_card_log}    ${HDMI_AUD_DEV}
    ${cardid_fetch}=    Get Regexp Matches    ${snd_card_log}    card\\s\\d:\\saudiohdmi    
    ${cardid_1st}=    Set Variable    ${cardid_fetch}[0]
    ${return_cardid}=    Get Regexp Matches    ${cardid_1st}    ([^\\w+])\\d
    ${return_hdmiaudid}=    Convert To Integer    @{return_cardid}
    RETURN    ${return_hdmiaudid}

    



    


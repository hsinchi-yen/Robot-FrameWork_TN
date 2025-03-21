=========================================================================
 Copyright 2025 Technexion Ltd.
 Test Case No      : TNPT-86 M.2 PCIE 4G LTE Module , TNPT-88 Micro-SIM / Nano SIM detection
 Category          : Functional Test  
 Script name       : LTE_Modem_Test.robot
 Author            : Lance
 Date created      : 20250220
=========================================================================
Initial date : 20250220 , current applicable for all M.2 PCIE interfaces
=========================================================================

*** Settings ***
Library        Collections
Resource       ../Resources/Common_Params.robot
Library        ../Libraries/EnvVariablesReturnLib.py
Library        String


*** Variables ***
${WWW_TEST_SITE}             www.google.com
@{VERIFIED_MODEMS}=          Sierra Wireless    Telit    Quectel
${PING_CHECK_VERIFY_WORD}    5 received, 0% packet loss
${LN920}=                    ${False}

*** Keywords *** 
Check 4G Modem
    SerialLibrary.Write Data    lsusb${\n}
    Sleep    1
    ${lsusb_log}=    SerialLibrary.Read All Data    UTF-8
    ${modem_up_status}=    Run Keyword And Return Status    Should Contain Any    ${lsusb_log}    @{verified_modems}
    ${ln920}=         Run Keyword And Return Status    Should Contain    ${lsusb_log}    LN920
    ${LN920}    Set Global Variable    ${ln920}
    Log    ${lsusb_log}
    RETURN    ${modem_up_status}    ${LN920}

Check SIM Card 
    SerialLibrary.Write Data    /usr/lib/ofono/test/list-modems | grep -iE "\\[ org.ofono.SimManager \\]" -A 14${\n}
    Sleep    1
    ${simlog}=    SerialLibrary.Read All Data    UTF-8
    Log    ${simlog}    console=True
    Should Contain    ${simlog}    Present = 1

Disconnect Eth and wlan via connmanctl
    SerialLibrary.Write Data    connmanctl disable ethernet${\n}
    SerialLibrary.Write Data    connmanctl disable wifi${\n}
    Sleep    1
    SerialLibrary.Write Data    ifconfig -a | grep -iE "eth\\w+:|wlan\\w:|ppp\\w:" -A 6${\n}
    Sleep    2
    ${infs_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${infs_log}    console=True

Reconnect Eth and wlan via connmanctl
    SerialLibrary.Write Data    connmanctl enable ethernet${\n}
    SerialLibrary.Write Data    connmanctl enable wifi${\n}
    Sleep    1
    SerialLibrary.Write Data    ifconfig -a | grep -iE "eth\\w+:|wlan\\w:|ppp\\w:" -A 6${\n}
    Sleep    2
    ${infs_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${infs_log}    console=True


Modem Ping Test
#${MODEM_INF}=                wwan0
#${PPP_INF}=                  ppp0
    IF    ${LN920} == ${True}
        ${MODEM_INF}    Set Variable    ppp0
        SerialLibrary.Write Data    ifconfig ${MODEM_INF}${\n}
    ELSE
        ${MODEM_INF}    Set Variable    wwan0
        SerialLibrary.Write Data    ifconfig ${MODEM_INF}${\n}
    END

    #SerialLibrary.Write Data    ifconfig wwan0${\n}

    Sleep    1
    ${modem_up_log}=    SerialLibrary.Read All Data    UTF-8
    Log    ${modem_up_log}    console=True
    SerialLibrary.Write Data    ping -c 5 -I ${MODEM_INF} ${WWW_TEST_SITE}${\n}
    ${modem_ping_log}=    SerialLibrary.Read Until    ${TERMINATOR}
    Log    ${modem_ping_log}    console=True
    Run Keyword And Continue On Failure    Should Contain    ${modem_ping_log}    5 received, 0% packet loss
    

LTE Modem test with Ofono
    ${modem_status}    ${LN920}=    Check 4G Modem

    IF    ${modem_status} == ${False}

        Fail    Modem is not available or attached to the board

    ELSE
        #List 4g modem
        SerialLibrary.Write Data    /usr/lib/ofono/test/list-modems${\n}
        ${modem_list_log}=    SerialLibrary.Read Until    ${TERMINATOR}
        Log    ${modem_list_log}    console=True

        SerialLibrary.Write Data    /usr/lib/ofono/test/enable-modem${\n}
        Sleep    0.5
        SerialLibrary.Write Data    /usr/lib/ofono/test/create-internet-context internet${\n}
	    Sleep    0.5
        SerialLibrary.Write Data    /usr/lib/ofono/test/online-modem${\n}
        Sleep    0.5
        SerialLibrary.Write Data    /usr/lib/ofono/test/activate-context${\n}
        Sleep    3
	    ${setonlinelog}=    SerialLibrary.Read All Data    UTF-8
        Log     ${setonlinelog}   

        SerialLibrary.Write Data    /usr/lib/ofono/test/list-modems${\n}
        ${modem_list_log}=    SerialLibrary.Read Until    ${TERMINATOR} 
        Log    ${modem_list_log}    console=True

        Disconnect Eth and wlan via connmanctl

        Modem Ping Test

        Reconnect Eth and wlan via connmanctl
    END
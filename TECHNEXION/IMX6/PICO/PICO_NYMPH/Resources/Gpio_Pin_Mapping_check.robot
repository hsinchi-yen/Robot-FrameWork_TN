*** Settings ***
Resource        ../Resources/Common_Params.robot

*** Variables ***


*** Keywords ***
Dump GPIO Port Mapping info
   SerialLibrary.Write Data    gpiodetect${\n}
   Sleep    1
   ${gpiodetectinfo}=    Seriallibrary.Read All Data    UTF-8
   GPIO Port Mapping Checker    ${gpiodetectinfo}
   Log    ${gpiodetectinfo}
   
   SerialLibrary.Write Data    gpioinfo${\n}
   ${gpioinfolog}=    Seriallibrary.Read Until    ${TERMINATOR}
    Log     ${gpioinfolog}

GPIO Port Mapping Checker
    [Arguments]    ${gpiodetectinfo}
    #Log to Console    ${gpiodetectinfo}
    #Log    ${gpiodetectinfo}
    
    #gpipinfo in edm-g-8mp - WB

    @{gpio_list}=    Create List   
    ...    gpiochip0 [209c000.gpio] (32 lines) 
    ...    gpiochip1 [20a0000.gpio] (32 lines)
    ...    gpiochip2 [20a4000.gpio] (32 lines)
    ...    gpiochip3 [20a8000.gpio] (32 lines)
    ...    gpiochip4 [20ac000.gpio] (32 lines)
    ...    gpiochip5 [20b0000.gpio] (32 lines)
    ...    gpiochip6 [20b4000.gpio] (32 lines)

    FOR    ${gpio_element}    IN    @{gpio_list}
        Run Keyword And Continue On Failure    Should Contain    ${gpiodetectinfo}   ${gpio_element}
    END
    
   
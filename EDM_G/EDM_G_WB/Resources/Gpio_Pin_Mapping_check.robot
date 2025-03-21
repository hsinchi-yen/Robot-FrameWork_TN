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
    ...    gpiochip0 [30200000.gpio] (32 lines) 
    ...    gpiochip1 [30210000.gpio] (32 lines)
    ...    gpiochip2 [30220000.gpio] (32 lines)
    ...    gpiochip3 [30230000.gpio] (32 lines)
    ...    gpiochip4 [30240000.gpio] (32 lines)
    ...    gpiochip5 [1-0021] (16 lines)
    ...    gpiochip6 [1-0023] (16 lines)
    
    FOR    ${gpio_element}    IN    @{gpio_list}
        Run Keyword And Continue On Failure    Should Contain    ${gpiodetectinfo}   ${gpio_element}
    END
    
   
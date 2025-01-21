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
    ...    gpiochip0 [43810000.gpio] (32 lines)
    ...    gpiochip1 [43820000.gpio] (32 lines)
    ...    gpiochip2 [43830000.gpio] (32 lines)
    ...    gpiochip3 [47400000.gpio] (32 lines)
    ...    gpiochip4 [1-0022] (24 lines)
    ...    gpiochip5 [adp5585-gpio] (10 lines)
    ...    gpiochip6 [1-0021] (16 lines) 
    ...    gpiochip7 [1-0023] (16 lines)    


    
    FOR    ${gpio_element}    IN    @{gpio_list}
        Run Keyword And Continue On Failure    Should Contain    ${gpiodetectinfo}   ${gpio_element}
    END
    
   
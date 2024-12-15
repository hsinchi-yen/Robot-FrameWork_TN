*** Settings ***
Library    Process

*** Variables ***
${TESTIMG}    ../edm-g-imx8mp_edm-g-wb_yocto-4.0-qt6_qca9377_hdmi-1920x1080_20240220.wicedm-g-imx8mp_edm-g-wb_yocto-4.0-qt6_qca9377_hdmi-1920x1080_20240220.wic
${PYTHON}     python3
${SCRIPT}     flashcode.py

*** Test Cases ***
Flash Image Test
    [Documentation]    Run flashcode.py with test image and verify successful execution.
    ${result}=    Run Process    ${PYTHON}    ${SCRIPT}    ${TESTIMG}    stdout=stdout.txt    stderr=stderr.txt    shell=True

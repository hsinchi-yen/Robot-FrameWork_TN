#!/bin/bash

#${1} : test case
echo "${1}"
#robot -d Result -t "${1}" Tests/EDM-G-8MP_with_EDM-G_WIZARD.robot
robot -d Result -t "${1}" Tests/EDM-G-8MP_with_EDM-G_WIZARD_APT_REG.robot

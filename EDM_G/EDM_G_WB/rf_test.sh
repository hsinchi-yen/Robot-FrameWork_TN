#!/bin/bash

#${1} : test case
#${2} : test suite
#echo "${1}"

if [[ -n "${1}" ]]; then
    echo "Running Test case: ${1}"
    robot -d ./Result/ -t "${1}" ./Tests/EDM-G-8MP_with_EDM-G_WB_APT_REG.robot
else
    echo "No case provided, running all tests"
    robot -d ./Result/ ./Tests/EDM-G-8MP_with_EDM-G_WB_APT_REG.robot
fi


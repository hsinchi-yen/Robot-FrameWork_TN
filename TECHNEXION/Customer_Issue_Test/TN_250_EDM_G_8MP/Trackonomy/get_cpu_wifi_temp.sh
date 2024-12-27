#!/bin/bash

CPU_TEMP=$(cat /sys/class/thermal/thermal_zone0/temp | awk '{$1=$1/1000; print $1;}')
WIFI_TEMP=$(iwpriv wlan0 get_temp | awk -F ':' '{print $2}')



echo cpu temp.:${CPU_TEMP}
echo wifi_temp.: ${WIFI_TEMP}

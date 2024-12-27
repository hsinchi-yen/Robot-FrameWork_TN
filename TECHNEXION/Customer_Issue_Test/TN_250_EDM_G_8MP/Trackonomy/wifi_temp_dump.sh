#!/bin/bash
Avg_wifi_temp()
{
  local wifi_temp_sum
  local wifi_avg

wifi_temp_sum=0

i=0

while [[ $i -lt 10 ]]; do
  CUR_WIFI_TEMP=$(iwpriv wlan0 get_temp | awk -F ':' '{print $2}' | sed 's/ //g')
  if [ ${CUR_WIFI_TEMP} -lt 115 ] && [ ${CUR_WIFI_TEMP} -gt 25 ]; then
    wifi_temp_sum=$((${wifi_temp_sum}+${CUR_WIFI_TEMP}))
    i=$((${i}+1))
    sleep 0.2
  else
    sleep 0.2
  fi
done
  wifi_avg=$(($wifi_temp_sum/10))

echo   ${wifi_avg}
}

wifi_avg_temp=$(Avg_wifi_temp)
echo "wifi_avg_temp=${wifi_avg_temp}"
sleep 1
CUR_WIFI_TEMP=$(iwpriv wlan0 get_temp | awk -F ':' '{print $2}' | sed 's/ //g')
echo "wifi_cur_temp=${CUR_WIFI_TEMP}"

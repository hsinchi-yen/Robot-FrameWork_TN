#!/bin/bash

#1 load rate

SERV=10.88.88.138

cpu_usage()
{
  c_rate=$(top -b -d1 -n1 | grep -i "Cpu(s)" | head -c21 | awk '{print $2}')
  echo $c_rate
}

#add load with stress-ng
echo "Add cpu loading : ${1}%"
stress-ng -c 4 -l ${1}&
sleep 1

#add load for wifi chip
echo "Add wifi loading :"
#iperf3 -c ${SERV} -t 600 -p 5204&
bash iperf_test.sh&

#dump wifi and cpu temps
while :
do
  bash wifi_temp_dump.sh
  CPU_TEMP=$(cat /sys/class/thermal/thermal_zone0/temp | awk '{$1=$1/1000; print $1;}')
  echo "CPU_TEMP=${CPU_TEMP}, cur cpu rate:$(cpu_usage), test_cpu_rate: ${1}"
  sleep 5
done

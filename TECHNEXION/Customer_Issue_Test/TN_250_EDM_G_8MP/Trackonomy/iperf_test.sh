#!/bin/bash


SERV=10.88.88.138
LOOP=10


ip_up_checker()
{
  for (( i = 0; i < 10; i++ )); do
    ip_entity=$(ifconfig wlan0 | grep inet | head -1)
    if [[ ! -z "${ip_entity}" ]]; then
      sleep 3
      echo 0
      exit
    else
      sleep 1
    fi
  done
  echo 1
}

ip_stat=$(ip_up_checker)

if [[ ${ip_stat} -eq 0 ]]; then
  for (( i = 1; i <=${LOOP}; i++ )); do
    iperf3 -c ${SERV} -t 60
    sleep 2
    echo "${i} tx test is done"
  done
else
  echo "IP is not up"
  ifconfig wlan0
  sleep 1
fi

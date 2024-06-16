: '
************************************************************************
 Project           : SIT team Test script for Yocto
 Purpose           : Test Ethernet functions
 Script name       : ETH_LAN_test.sh with iperf 3 and search available ip and port for test.
 Author            : lancey
 Date created      : 20220816
 Applied platform  : Yocto 4.2 / IMX93
-----------------------------------------------------------------------
 Revision History  :
 Date        Author      Ref    Revision (Date in YYYYMMDD format)
-----------------------------------------------------------------------
 20240527    lancey      1      Initial draft for test
************************************************************************
'

#!/bin/bash

#pre define parameters
ETH_TESTLOG=/tmp/ETH_Testlog.txt

TX_LOG=/tmp/TXlog.txt
RX_LOG=/tmp/RXlog.txt
TXRX_LOG=/tmp/TXRXlog.txt

IPERF_SER_IP="10.88.88.229"
IPERF_SER_IPv6="fe80::fbbb:b1ae:fc18:9dcf"
IPERF_PORT="5205"

TEST_DNS="www.google.com.tw"
ETH_INF="eth0"
IPERF_TESTTIME=10
BR_LIMIT=900

#display dhcp ip for eth0

#IPs ques
IPADDRS=("10.88.88.138" "10.88.88.82" "10.88.88.229")
IP6_ADDRS=("fe80::7a5f:f169:cf6c:4139","fe80::712c:72c3:aa37:183a","fe80::fbbb:b1ae:fc18:9dcf")
# Port range
start_port=5201
end_port=5205

ip4_port_finder()
{
  local ip
  local port

  for ip in "${IPADDRS[@]}"; do
      for port in $(seq $start_port $end_port); do
          timeout 3 iperf3 -c ${ip} ${port} -t 1 > /dev/null 2>&1
          if [ $? -eq 0 ]; then
              echo "Available: ${ip}:${port}"

              IPERF_SER_IP="${ip}"
              IPERF_PORT="${port}"
              break 2
          fi
      done
  done
}

ip6_port_finder()
{
  local ip
  local port

  for ip in "${IPADDRS[@]}"; do
      for port in $(seq $start_port $end_port); do
          timeout 3 iperf3 -6 -c ${ip}%${ETH_INF} ${port} -t 1 > /dev/null 2>&1
          if [ $? -eq 0 ]; then
              echo "Available: ${ip}:${port}"

              IPERF_SER_IPv6="${ip}"
              IPERF_PORT="${port}"
              break 2
          fi
      done
  done
}

#display routing table
show_ip_add()
{
  #local variable
  local ip_chk
  local ip_v4
  local ip_v6
  #local variable

  ip_que=$(ifconfig ${ETH_INF} | grep -E "inet|inet6")

  if [[ -z "${ip_que}" ]]; then
    ip_v4="no IP is assigned"
    ip_v6="no IP is assigned"
    ip_chk=1
  else
    ip_v4=$(echo "${ip_que}" | head -1 | awk -F ' ' '{print $2}')
    ip_v6=$(echo "${ip_que}" | tail -1 | awk -F ' ' '{print $2}')
    ip_chk=0
  fi

  echo "IP address informations"
  echo "IPv4 = ${ip_v4}"
  echo "IPv6 = ${ip_v6}"

  if [[ ${ip_chk} -eq 0 ]]; then
    echo "Please check you DHCP setting or router connections"
  fi
  sleep 1

  return ${ip_chk}
}

link_up_event()
{
  for i in {1..30}; do
    isLinkup=$(dmesg | tail -1 | grep "link becomes ready")
    if [[ ! -z $isLinkup ]]; then
      return 0
      break
    else
      sleep 0.5
    fi
  done
  return 1
}

if_down_up()
{
  echo "set ${ETH_INF} interface is down"
  ifconfig  ${ETH_INF} down

  echo "set ${ETH_INF} interface is up"
  ifconfig  ${ETH_INF} up

  #check the link up event
  link_up_event
  is_up=$?

  if [[ ${is_up} -eq 0 ]]; then
    return 0
  else
    return 1
  fi
}

ETH_speed_sw()
{
  # $1 , eth0
  # $2 , speed
  # $3 , event
  ethtool -s $1 speed $2 duplex full
  link_up_event
  sleep 3
}

ETH_speed_reset_autoneg()
{
  ethtool -s ${ETH_INF} autoneg on
  link_up_event
}

TX_test()
{
  #$1 = $IPERF_SERV
  #$2 = $IPERF_TESTTIME
  #$3 = $IPER_PORT
  iperf3 -c ${1} -i 2 -t ${2} -p ${3}
  sleep 1&
  wait $!
}

RX_test()
{
  #$1 = $IPERF_SERV
  #$2 = $IPERF_TESTTIME
  #$3 = $IPER_PORT
  iperf3 -c ${1} -i 2 -t ${2} -p ${3} -R
  sleep 1&
  wait $!
}

TXRX_test()
{
  #$1 = $IPERF_SERV
  #$2 = $IPERF_TESTTIME
  #$3 = $IPER_PORT
  iperf3 -c ${1} -i 2 -t ${2} -p ${3} --bidir
  sleep 1&
  wait $!
}

#--ipv6
IP6_TX_test()
{
  #$1 = $IPERF_SERV
  #$2 = $IPERF_TESTTIME
  #$3 = $IPER_PORT
  iperf3 -6 -c ${1}%${ETH_INF} -i 2 -t ${2} -p ${3}
  sleep 1&
  wait $!
}

IP6_RX_test()
{
  #$1 = $IPERF_SERV
  #$2 = $IPERF_TESTTIME
  #$3 = $IPER_PORT
  iperf3 -6 -c ${1}%${ETH_INF} -i 2 -t ${2} -p ${3} -R
  sleep 1&
  wait $!
}

IP6_TXRX_test()
{
  #$1 = $IPERF_SERV
  #$2 = $IPERF_TESTTIME
  #$3 = $IPER_PORT
  iperf3 -6 -c ${1}%${ETH_INF} -i 2 -t ${2} -p ${3} --bidir
  sleep 1&
  wait $!
}

TX_Result_Chk()
{
  #$1 : sender rx_result
  bitrate=$(cat ${1} | grep "sender" | awk '{print $7}')

  # check bitrate if below 900
  for br in $bitrate ; do

    if [[ ${br} -gt ${BR_LIMIT} ]]; then
      :
    else
      return 1
    fi
  done

  return 0

}

#check if wlan ip is up
wlan_stat_chk()
{
  isIP=$(ifconfig ${1} | grep inet)

  if [[ ! -z ${isIP} ]]; then
    return 0
  else
    return 1
  fi
}

wwan_stat_chk()
{
  isIP=$(ifconfig ${1} | grep inet)

  if [[ ! -z ${isIP} ]]; then
    return 0
  else
    return 1
  fi
}

wlan_stat_chk wlan0
isWLAN=$?
if [[ ${isWLAN} -eq 0 ]]; then
  ifconfig wlan0 down
  sleep 1
fi

wwan_stat_chk wwan0
isWWAN=$?
if [[ ${isWWAN} -eq 0 ]]; then
  ifconfig wwan0 down
  sleep 1
fi

show_ip_add
isIP=$?

if [[ $isIP -eq 1 ]]; then
  #do nothing
  :
else
  # interface up and down
  if_down_up
  sleep 3
  #look for ipv4 ip for test
  ip4_port_finder

  if [[ $? -eq 0 ]]; then
    # ping_v4 test
    echo "IPv4 ping test with DNS:${TEST_DNS}"
    ping -c 5 ${TEST_DNS}
    echo ""

    # ping_v6 test
    echo "IPv6 ping test with local server : ${IPERF_SER_IPv6}"
    ping6 -c 5 ${IPERF_SER_IPv6}%${ETH_INF}
    echo ""

    # led 10/100/1000 and autonego test

    #10 mpbs testing
    echo "${ETH_INF} - Speed - 10 mbps test, the Right LED of RJ45 shall be OFF, the Left LED of RJ45 shall be flashing"
    ETH_speed_sw ${ETH_INF} 10
    TX_test ${IPERF_SER_IP} ${IPERF_TESTTIME} ${IPERF_PORT}

    #100 mpbs testing
    echo "${ETH_INF} - Speed - 100 mbps test,the Right LED of RJ45 shall be GREEN, the Left LED of RJ45 shall be flashing"
    ETH_speed_sw ${ETH_INF} 100
    TX_test ${IPERF_SER_IP} ${IPERF_TESTTIME} ${IPERF_PORT}

    #1000 mpbs testing
    echo "${ETH_INF} - Speed - 1000 mbps test, the Right LED of RJ45 shall be RED, , the Left LED of RJ45 shall be flashing"
    ETH_speed_sw ${ETH_INF} 1000
    TX_test ${IPERF_SER_IP} ${IPERF_TESTTIME} ${IPERF_PORT}

    #reset eth setting to default
    echo "resume eth0 setting to default"
    ETH_speed_reset_autoneg

    # ethernet ipv4 - TX/RX/bidirect iperf3 test
    echo ""
    echo "${ETH_INF} - IPv4 Transmission - TX direction test ..."
    TX_test ${IPERF_SER_IP} 30 ${IPERF_PORT} | tee ${TX_LOG}
    TX_Result_Chk ${TX_LOG}
    Tr_Result=$?

    if [[ ${Tr_Result} -eq 0 ]]; then
      echo "${ETH_INF} - IPv4 Transmission - TX direction : PASS"
    else
      echo "${ETH_INF} - IPv4 Transmission - TX direction : FAIL"
    fi

    echo ""
    echo "${ETH_INF} - IPv4 Transmission - RX direction test ..."
    RX_test ${IPERF_SER_IP} 30 ${IPERF_PORT} | tee ${RX_LOG}
    TX_Result_Chk ${RX_LOG}
    Tr_Result=$?

    if [[ ${Tr_Result} -eq 0 ]]; then
      echo "${ETH_INF} - IPv4 Transmission - RX direction : PASS"
    else
      echo "${ETH_INF} - IPv4 Transmission - RX direction : FAIL"
    fi

    echo ""
    echo "${ETH_INF} - Transmission - Bi-direction test ..."
    TXRX_test ${IPERF_SER_IP} 30 ${IPERF_PORT} | tee ${TXRX_LOG}
    TX_Result_Chk ${TXRX_LOG}
    Tr_Result=$?

    if [[ ${Tr_Result} -eq 0 ]]; then
      echo "${ETH_INF} - Transmission - Bi-direction : PASS"
    else
      echo "${ETH_INF} - Transmission - Bi-direction : FAIL"
    fi

#---------------------------------------------------------------------
    # ethernet ipv6 - TX/RX/bidirect iperf3 test
    echo ""
    echo "${ETH_INF} - IPv6 Transmission - TX direction test ..."
    IP6_TX_test ${IPERF_SER_IPv6} 30 ${IPERF_PORT} | tee ${TX_LOG}
    TX_Result_Chk ${TX_LOG}
    Tr_Result=$?

    if [[ ${Tr_Result} -eq 0 ]]; then
      echo "${ETH_INF} - IPv6 Transmission - TX direction : PASS"
    else
      echo "${ETH_INF} - IPv6 Transmission - TX direction : FAIL"
    fi

    echo ""
    echo "${ETH_INF} - IPv6 Transmission - RX direction test ..."
    IP6_RX_test ${IPERF_SER_IPv6} 30 ${IPERF_PORT} | tee ${RX_LOG}
    TX_Result_Chk ${RX_LOG}
    Tr_Result=$?

    if [[ ${Tr_Result} -eq 0 ]]; then
      echo "${ETH_INF} - IPv6 Transmission - RX direction : PASS"
    else
      echo "${ETH_INF} - IPv6 Transmission - RX direction : FAIL"
    fi

    echo ""
    echo "${ETH_INF} - IPv6 Transmission - Bi-direction test ..."
    IP6_TXRX_test ${IPERF_SER_IPv6} 30 ${IPERF_PORT} | tee ${TXRX_LOG}
    TX_Result_Chk ${TXRX_LOG}
    Tr_Result=$?

    if [[ ${Tr_Result} -eq 0 ]]; then
      echo "${ETH_INF} - IPv6 - Transmission - Bi-direction : PASS"
    else
      echo "${ETH_INF} - IPv6 - Transmission - Bi-direction : FAIL"
    fi


  else
    echo "No IP address available, FAIL"

  fi
fi

wlan_stat_chk wlan0
isWLAN=$?
if [[ ${isWLAN} -eq 1 ]]; then
  ifconfig wlan0 up
  sleep 1
fi

wwan_stat_chk wwan0
isWWAN=$?
if [[ ${isWWAN} -eq 1 ]]; then
  ifconfig wwan0 up
  sleep 1
fi

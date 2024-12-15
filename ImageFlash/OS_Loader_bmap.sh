#!/bin/bash
: '
OS loader

the utility install in ubuntu is requred
sudo apt-get install hwinfo

'
CONSOLE_PORT=/dev/ttyUSB0
CONSOLE_tmp=/tmp/console.log
CONSOLE_PROMPT="Hit any key to stop autoboot:"

#check console reading
con_wait_for()
{
  local raw_data
  raw_data=$(cat ${CONSOLE_tmp} | grep "${1}")
  if [[ ! -z ${raw_data} ]]; then
    #echo ${raw_data}
    return 0
  else
    return 1
  fi
}

send_key()
{
  echo -e "${1}" > ${CONSOLE_PORT}
}

send_ctrl_c()
{
  echo $'\cc' > ${CONSOLE_PORT}
}

#cat process and return
console_pid()
{
  local con_pid
  cat ${CONSOLE_PORT} > ${CONSOLE_tmp} &
  con_pid=$!
  #sleep 1
  echo "${con_pid}"
}

#find the ums device
usb_dev_detect()
{
  local count=0
  mount_dev_name="Netchip Technology"

  while :
  do
      usb_dev=$(lsusb | grep "${mount_dev_name}")
      if [[ ! -z ${usb_dev} ]]; then
        #echo "USB device is found : ${usb_dev}"
        sleep 1
        return 0

      else
        if [[ ${count} -lt 30 ]]; then
          count=$((${count}+1))
          sleep 0.5
        else
          break
        fi
      fi
  done
  return 1
}

mounted_dev()
{
  local ums_dev
  ums_dev=$(hwinfo --disk | grep -A 8 "Linux UMS disk 0" | grep "Device File:" | awk -F ' ' '{print $3}')
  echo "${ums_dev}"
}

search_os_img()
{
  local os_img_name
  os_img_name=$(ls -1 | grep -E '*.wic$')

  if [[ ! -z ${os_img_name} ]]; then
    echo "${os_img_name}"
    return 0
  else
    echo "NULL"
    return 1
  fi
}

find_emmc_id()
{
  local con_pid
  local ret_emmc_id
  con_pid=$(console_pid)
  send_key "mmc list\n"
  sleep 0.5
  kill -9 ${con_pid}
  sync
  con_wait_for "eMMC"

  if [[ $? -eq 0 ]]; then
    ret_emmc_id=$(cat ${CONSOLE_tmp} | grep "eMMC" | tail -1 | awk -F ' ' '{print $2}')
    echo "${ret_emmc_id}"
  fi
}

fs_ext_check()
{
  fs_ext_event="Resizing task completes."

  local con_pid
  local count=0

  while :
  do
    con_pid=$(console_pid)
    #echo ${con_pid}
    echo -ne '.'
    sleep 3
    kill -9 "${con_pid}"
    con_wait_for ${fs_ext_event}

    if [[ $? -eq 0 ]]; then
      echo "File system extention is done."
      sleep 1
      killall cat
      return 0
      break
    else
      count=$((${count+1}))
      if [[ ${count} -gt 20 ]]; then
        killall cat
        break
      fi
    fi
  done

  return 1
}

very_first_login_check()
{
  local login_prompt="edm-g-imx8mp login:"

  local con_pid
  local count=0

  while :
  do
    con_pid=$(console_pid)
    #echo ${con_pid}
    echo -ne '.'
    sleep 2
    kill -9 "${con_pid}"
    con_wait_for ${login_prompt}

    if [[ $? -eq 0 ]]; then
      echo "Very Fisrt Login prompt is found."
      sleep 1
      killall cat
      return 0
      break
    else
      count=$((${count}+1))
      if [[ ${count} -gt 10 ]]; then
        killall cat
        break
      fi
    fi
  done

  return 1
}

secondary_login_check()
{
  local login_prompt="edm-g-imx8mp login:"

  local con_pid
  local count=0

  while :
  do
    con_pid=$(console_pid)
    #echo ${con_pid}
    echo -ne '.'
    sleep 1
    kill -9 "${con_pid}"
    con_wait_for ${login_prompt}

    if [[ $? -eq 0 ]]; then
      echo "Secondary Login prompt is found."
      sleep 0.5
      killall cat
      return 0
      break
    else
      count=$((${count}+1))
      if [[ ${count} -gt 20 ]]; then
        killall cat
        break
      fi
    fi
  done

  return 1
}

umount_dev()
{
  local trim_dev
  trim_dev=$(echo "${1}" | sed 's/\/dev\///')
  dev_arr=$(lsblk | grep -E "${trim_dev}\w" | awk -F ' ' '{print $1}' | cut -c 7-11)
  for dev in ${dev_arr}; do
    sudo umount /dev/${dev}
    sleep 0.5
    echo "${dev} is ejected!"
    sleep 0.5
  done
}


stty -F ${CONSOLE_PORT} 115200

send_key "\n"
sleep 0.5&
wait $!
send_key "sudo reboot\n"
sleep 3&
wait $!

send_key "\n"
sleep 0.5&
wait $!

#test
#console_pid
send_key "ubuntu\n"

while :
do

  con_pid=$(console_pid)
  #echo ${con_pid}
  echo -ne '.'
  sleep 1
  kill -9 "${con_pid}"
  con_wait_for ${CONSOLE_PROMPT}

  if [[ $? -eq 0 ]]; then
    send_key "\n"
    sleep 0.5
    killall cat
    break
  fi

done

send_key "\n"
sleep 1

emmc_id=$(find_emmc_id)
sleep 2&
#exit 0

wait $!

send_key "ums 0 $emmc_id"
send_key "\n"
sleep 2

if [[ -z "${1}" ]]; then
  os_img=$(search_os_img)

  if [[ $? -eq 0 ]]; then
    echo "OS Img is found :${os_img}"
  else
    echo "OS Img is not found"
  fi

else
  os_img="${1}"
fi


#sleep 5
usb_dev_detect
if [[ $? -eq 0 ]]; then
    load_dev=$(mounted_dev)
    sleep 2&
    wait $!
    #sudo umount /dev/sde2
    #sleep 0.5
    umount_dev ${load_dev}

    start_s=$(date +'%s')
    echo "Running bmaptool command to dump os image to device :"
    #echo "dd if=${os_img} of=${load_dev} conv=noerror bs=1M oflag=dsync status=progress"
    #sudo dd if=${os_img} of=${load_dev} conv=noerror bs=1M oflag=dsync status=progress
    sudo bmaptool copy --bmap ${os_img}.bmap ${os_img} ${load_dev}
    sleep 3
    sync
    end_s=$(date +'%s')
    bootup_time=$((${end_s}-${start_s}))
    echo "Image flash time: ${bootup_time} (s)"

    sleep 5&
    wait $!

    send_ctrl_c
    sleep 3&
    wait $!
    send_key "boot\n"
    echo "The OS image is loaded."

    #check file system partition extention.
    fs_ext_check
    if [[ $? -eq 0 ]]; then
      echo "file system extenstion check is pass"
    else
      echo "file system extension check is fail"
    fi

    # check very first login prompt
    very_first_login_check

    if [[ $? -eq 0 ]]; then
      start_s=$(date +'%s')
      secondary_login_check

      end_s=$(date +'%s')

      bootup_time=$((${end_s}-${start_s}))
      echo "boot time: ${bootup_time} secs"
    fi

else
    echo "Device is not found, please check if OTG cable is connected"
fi

import argparse
import serial
import sys
import time
import re
import os
from os.path import exists
import cursor
from datetime import date
import subprocess

class SerialCom:
    def __init__(self, comport="/dev/ttyUSB0"):
        self.comport = comport
        self.ser = serial.Serial()
        self.ser.port = self.comport

        # 115200,N,8,1
        self.ser.baudrate = 115200
        self.ser.bytesize = serial.EIGHTBITS  # number of bits per bytes
        self.ser.parity = serial.PARITY_NONE  # set parity check
        self.ser.stopbits = serial.STOPBITS_ONE  # number of stop bits
        self.ser.timeout = 0.5
        self.ser.writeTimeout = 0.5
        self.ser.xonxoff = False  # disable software flow control
        self.ser.rtscts = False  # disable hardware (RTS/CTS) flow control
        self.ser.dsrdtr = False  # disable hardware (DSR/DTR) flow control

    def cmdsend(self, command):
        self.command = command
        self.ser.write(self.command.encode('UTF-8', errors='ignore'))

    def cmdsenddly(self, command, secs=0.5):
        self.command = command
        self.secs = secs
        self.ser.write(self.command.encode('UTF-8', errors='ignore'))
        time.sleep(self.secs)

    def cmdread(self, waitstring="\r\n"):
        self.waitstring = waitstring
        response = self.ser.read_until(self.waitstring).decode('UTF-8', errors='ignore')
        lastline = waitstring
        fmtresponse = response.strip(lastline)
        return fmtresponse

def msg_readuntil(desiremsg, secs = 0.5):
    global serctrl
    global Reboot_keyword

    testmsg = serctrl.cmdread()
    while desiremsg not in testmsg:
        if Reboot_keyword in testmsg:
            print(testmsg)
            return False
        testmsg = serctrl.cmdread()
        time.sleep(secs)

    print(testmsg)
    return True

def bootmsg_readuntil(desiremsg, secs = 0.1):
    global serctrl
    global Reboot_keyword

    testmsg = serctrl.cmdread()
    while desiremsg not in testmsg:
        print(testmsg)
        testmsg = serctrl.cmdread()
        time.sleep(secs)
    print(testmsg)
    return  True

def check_usb_device(desired_string):
    try:
        result = subprocess.run(['lsusb'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        output = result.stdout

        print("Output of lsusb:")
        print(output)

        if desired_string in output:
            print(f"Found device: {desired_string}")
            return True
        else:
            print(f"Device not found: {desired_string}")
            return False
    except Exception as e:
        print(f"Error executing lsusb: {e}")
        return False

def UMS_finder():
    command=f"hwinfo --disk | grep 'Linux UMS disk 0' -A 7 | grep 'Device File' | awk -F ' ' '{{print $3}}'"
    try:
        result = subprocess.run(command, shell=True, check=True, text=True, capture_output=True)
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        return f"Command failed with error: {e.stderr}"

def flash_image(image, device):
    command=f"sudo dd if={image} of={device} bs=1M oflag=dsync status=progress"
    try:
        result = subprocess.run(command, shell=True, check=True, text=True, capture_output=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        return f"Command failed with error: {e.stderr}"

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Flash an image to a device using serial communication.")
    parser.add_argument("testimg", help="Path to the image file to be flashed")
    args = parser.parse_args()

    Reboot_keyword = "Normal Boot"
    waitstring = "~# "
    testimg = args.testimg

    serctrl = SerialCom("/dev/ttyS0")

    try:
        serctrl.ser.open()

        serctrl.ser.reset_input_buffer()
        serctrl.ser.reset_output_buffer()
        time.sleep(1)

        print("Com port is connected ...")

        serctrl.cmdsend("reboot\n")
        time.sleep(1)

        autobootlog = bootmsg_readuntil(Reboot_keyword, 1)

        if autobootlog == True:
            serctrl.cmdsenddly("\n\n")
            serctrl.cmdsenddly("\n")
            print("enter uboot mode")
            time.sleep(2)
            serctrl.cmdsend("ums 0 2\n")
            print("send ums commandline")
            time.sleep(7)
            desired_string = "NXP Semiconductors USB download gadget"
            is_devfound = check_usb_device(desired_string)

            if is_devfound == True:
                print("ums finder")
                device_loc = UMS_finder()
                print("flash image...")
                flash_image(testimg, device_loc)
    except Exception as ex:
        print("2communicating error or the port is occupied" + str(ex))
        sys.exit()
    finally:
        serctrl.ser.close()

import serial
import sys
import time
import subprocess
import re

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
    
    def ums_break_key(self, stopkey=b'\0x03'):
        self.stopkey = stopkey
        self.ser.write(self.stopkey)
    
def msg_readuntil(serctrl, desiremsg, secs=0.5, reboot_keyword="Normal Boot"):
    testmsg = serctrl.cmdread()
    while desiremsg not in testmsg:
        if reboot_keyword in testmsg:
            print(testmsg)
            return False
        testmsg = serctrl.cmdread()
        time.sleep(secs)
    print(testmsg)
    return True

def bootmsg_readuntil(serctrl, desiremsg, secs=0.1, reboot_keyword="Normal Boot"):
    testmsg = serctrl.cmdread()
    while desiremsg not in testmsg:
        print(testmsg)
        testmsg = serctrl.cmdread()
        time.sleep(secs)
    print(testmsg)
    return True

def check_usb_device():
    try:
        result = subprocess.run(['lsusb'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        output = result.stdout
        print("Output of lsusb:")
        print(output)
        #if desired_string in output:
        #    print(f"Found device: {desired_string}")
        #    return True
        #else:
        #    print(f"Device not found: {desired_string}")
        #    return False
        return output 
    except Exception as e:
        print(f"Error executing lsusb: {e}")
        return False
    
def UMS_finder():
    command = f"hwinfo --disk | grep 'Linux UMS disk 0' -A 7 | grep 'Device File' | awk -F ' ' '{{print $3}}'"
    try:
        result = subprocess.run(command, shell=True, check=True, text=True, capture_output=True)
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        return f"Command failed with error: {e.stderr}"

def flash_image_dd(image, device):
    #command = f"sudo dd if={image} of={device} bs=1M oflag=dsync status=progress"
    command = f"bunzip2 -c {image} | sudo dd of={device} bs=1M oflag=dsync status=progress"
    try:
        result = subprocess.run(command, shell=True, check=True, text=True, capture_output=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        return f"Command failed with error: {e.stderr}"
    
def flash_image_bmaptool(imgmap, image, device):
    command = f"sudo bmaptool copy --bmap {imgmap} {image} {device}"
    try:
        result = subprocess.run(command, shell=True, check=True, text=True, capture_output=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        return f"Command failed with error: {e.stderr}"

class FlashImageLibrary:
    def __init__(self):
        self.serctrl = None

    def connect_serial(self, port="/dev/ttyS0"):
        self.serctrl = SerialCom(port)
        self.serctrl.ser.open()
        self.serctrl.ser.reset_input_buffer()
        self.serctrl.ser.reset_output_buffer()
        time.sleep(1)
        print("Com port is connected ...")

    def disconnect_serial(self):
        if self.serctrl and self.serctrl.ser.is_open:
            self.serctrl.ser.close()
        print("Com port is disconnected ...")

    def send_reboot_command(self):
        self.serctrl.cmdsend("reboot\n")
        time.sleep(1)

    def wait_for_boot_message(self, reboot_keyword="Normal Boot"):
        return bootmsg_readuntil(self.serctrl, reboot_keyword, 1)

    def send_ums_command(self):
        self.serctrl.cmdsenddly("\n\n")
        self.serctrl.cmdsenddly("\n")
        print("Enter U-Boot mode")
        time.sleep(2)
        self.serctrl.cmdsend("ums 0 2\n")
        print("Send UMS command line")
        time.sleep(7)

    def check_usb_device_connected(self):
        return check_usb_device()

    def find_ums_device(self):
        return UMS_finder()

    def dd_flash_image_to_device(self, image, device):
        return flash_image_dd(image, device)
        
    def bmaptool_flash_image_to_device(self, imgmap, image, device):
        return flash_image_bmaptool(imgmap, image, device)
    
    def send_ums_break_key(self):
        return self.serctrl.ums_break_key()

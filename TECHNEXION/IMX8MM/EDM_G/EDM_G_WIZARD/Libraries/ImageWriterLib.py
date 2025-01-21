import serial
import sys
import time
import subprocess

def check_usb_device(desired_string):
    command = f'lsusb'
    try:
        #result = subprocess.run(['lsusb'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        result = subprocess.run(command, shell=True, check=True, text=True, capture_output=True)
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
    command = f"hwinfo --disk | grep 'Linux UMS disk 0' -A 7 | grep 'Device File' | awk -F ' ' '{{print $3}}'"
    try:
        result = subprocess.run(command, shell=True, check=True, text=True, capture_output=True)
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        return f"Command failed with error: {e.stderr}"

def dd_flash_image(image, device):
    command = f"sudo dd if={image} of={device} bs=1M oflag=dsync status=progress"
    try:
        result = subprocess.run(command, shell=True, check=True, text=True, capture_output=True)
        output = result.stdout
        print(command)
        print(output)
        return result.stdout
    except subprocess.CalledProcessError as e:
        return f"Command failed with error: {e.stderr}"

def bmaptool_flash_image(image, device):
    command = f"sudo bmaptool copy --bmap {image}.bmap {image}.wic"
    try:
        result = subprocess.run(command, shell=True, check=True, text=True, capture_output=True)
        output = result.stdout
        print(command)
        print(output)
        return result.stdout
    except subprocess.CalledProcessError as e:
        return f"Command failed with error: {e.stderr}"

class ImageWriterLib:
    def __init__(self):
        self.serctrl = None

    def check_usb_device_connected(self, desired_string="NXP Semiconductors USB download gadget"):
        return check_usb_device(desired_string)

    def find_ums_device(self):
        return UMS_finder()

    def dd_flash_image_to_device(self, image, device):
        return dd_flash_image(image, device)

    def bmaptool_flash_image_to_device(self, image, device):
        return bmaptool_flash_image(image, device)
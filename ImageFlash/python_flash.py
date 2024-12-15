import os
import time
import subprocess
import serial
import psutil

# Constants
CONSOLE_PORT = '/dev/ttyS0'
CONSOLE_TMP = '/tmp/console.log'
CONSOLE_PROMPT = 'Hit any key to stop autoboot:'
MOUNT_DEV_NAME = 'Netchip Technology'

# Helper functions
def con_wait_for(pattern, timeout=30):
    start_time = time.time()
    while time.time() - start_time < timeout:
        with open(CONSOLE_TMP, 'r') as file:
            if pattern in file.read():
                return True
        time.sleep(1)
    return False

def send_key(port, key):
    port.write(key.encode())

def send_ctrl_c(port):
    port.write(b'\x03')

def console_pid(port):
    with open(CONSOLE_TMP, 'w') as tmp_file:
        process = subprocess.Popen(['cat', port.name], stdout=tmp_file)
    return process

def usb_dev_detect():
    count = 0
    while count < 30:
        result = subprocess.run(['lsusb'], capture_output=True, text=True)
        if MOUNT_DEV_NAME in result.stdout:
            time.sleep(1)
            return True
        count += 1
        time.sleep(0.5)
    return False

def mounted_dev():
    result = subprocess.run(['hwinfo', '--disk'], capture_output=True, text=True)
    for line in result.stdout.split('\n'):
        if 'Linux UMS disk 0' in line:
            return line.split(':')[1].strip()
    return None

def search_os_img():
    for file in os.listdir('.'):
        if file.endswith('.wic'):
            return file
    return None

def find_emmc_id(port):
    process = console_pid(port)
    send_key(port, 'mmc list\n')
    time.sleep(0.5)
    process.kill()
    if con_wait_for('eMMC'):
        with open(CONSOLE_TMP, 'r') as file:
            lines = file.readlines()
            for line in reversed(lines):
                if 'eMMC' in line:
                    return line.split()[1]
    return None

def fs_ext_check(port):
    fs_ext_event = 'Resizing task completes.'
    count = 0
    while count < 20:
        process = console_pid(port)
        time.sleep(3)
        process.kill()
        if con_wait_for(fs_ext_event):
            print('File system extension is done.')
            return True
        count += 1
    return False

def login_check(port, prompt, max_retries=10, sleep_time=2):
    count = 0
    while count < max_retries:
        process = console_pid(port)
        time.sleep(sleep_time)
        process.kill()
        if con_wait_for(prompt):
            return True
        count += 1
    return False

def umount_dev(device):
    device_base = device.split('/')[-1]
    partitions = [p.device for p in psutil.disk_partitions(all=True) if device_base in p.device]
    for part in partitions:
        subprocess.run(['sudo', 'umount', part])
        time.sleep(0.5)
        print(f'{part} is ejected!')

# Main function
def main(os_img=None):
    port = serial.Serial(CONSOLE_PORT, baudrate=115200, timeout=1)

    send_key(port, '\n')
    time.sleep(0.5)
    send_key(port, 'reboot\n')
    time.sleep(3)
    #send_key(port, '\n')
    #time.sleep(0.5)
    #send_key(port, 'ubuntu\n')

    while True:
        process = console_pid(port)
        time.sleep(1)
        process.kill()
        if con_wait_for(CONSOLE_PROMPT):
            send_key(port, '\n')
            break

    emmc_id = find_emmc_id(port)
    if not emmc_id:
        print('eMMC ID not found')
        return

    time.sleep(2)
    send_key(port, f'ums 0 {emmc_id}\n')
    time.sleep(2)

    if not os_img:
        os_img = search_os_img()
        if not os_img:
            print('OS image not found')
            return
    print(f'OS Image found: {os_img}')

    if not usb_dev_detect():
        print('Device not found, please check if OTG cable is connected')
        return

    load_dev = mounted_dev()
    if not load_dev:
        print('No UMS device found')
        return

    umount_dev(load_dev)

    start_time = time.time()
    subprocess.run(['sudo', 'bmaptool', 'copy', '--bmap', f'{os_img}.bmap', os_img, load_dev])
    subprocess.run(['sync'])
    end_time = time.time()

    print(f'Image flash time: {end_time - start_time} seconds')

    time.sleep(5)
    send_ctrl_c(port)
    time.sleep(3)
    send_key(port, 'boot\n')
    print('The OS image is loaded.')

    if fs_ext_check(port):
        print('File system extension check passed')
    else:
        print('File system extension check failed')

    if login_check(port, 'edm-g-imx8mp login:', max_retries=10, sleep_time=2):
        start_time = time.time()
        login_check(port, 'edm-g-imx8mp login:', max_retries=20, sleep_time=1)
        end_time = time.time()
        print(f'Boot time: {end_time - start_time} seconds')
    else:
        print('First login prompt not found')

if __name__ == '__main__':
    main()

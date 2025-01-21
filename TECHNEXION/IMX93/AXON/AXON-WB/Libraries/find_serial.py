import re
import serial
import time
import os


def find_variables():
    # Find path /Resources/Common_Params.robot
    test_dir = os.path.dirname(__file__)
    parent_dir = os.path.dirname(test_dir)
    common_params_path = os.path.join(parent_dir, "Resources", "Common_Params.robot")
    
    if os.path.exists(common_params_path):
        within_variables_section = False
        login_prompt_value = {}
        terminator_value = {}

        with open(common_params_path, 'r') as file:
            for line in file:
                stripped_line = line.strip()

                # Stop reading until *** Keywords *** part
                if stripped_line.startswith("*** Keywords ***"):
                    break

                # Check whether *** Variables *** section starts
                if stripped_line.startswith("*** Variables ***"):
                    within_variables_section = True
                    continue

                # If *** Variables *** section found, handle stripped lines
                if within_variables_section:
                    # Ignore comments
                    if stripped_line.startswith("#"):
                        continue
                    
                    # Find variable values with regex
                    match1 = re.match(r'^\$\{LOGIN_PROMPT\}\s*(.+)', stripped_line)
                    match2 = re.match(r'^\$\{TERMINATOR\}\s*(.+)', stripped_line)
                    if match1:
                        login_prompt_value = match1.group(1)
                        print("LOGIN_PROMPT is found:",login_prompt_value)
                        
                    if match2:
                        terminator_value = match2.group(1)
                        print("TERMINATOR is found:",terminator_value)
                              
        return login_prompt_value, terminator_value
    else:
        print(f"File not found: {common_params_path}")
        return None
    
#Find all SerialPort 
def list_usb_serial_ports():
 
    return [f"/dev/{f}" for f in os.listdir('/dev') if f.startswith('ttyUSB')]

def find_serial_port(baud_rate=115200, timeout=1):
    
   
    login_prompt_value,terminator_value=find_variables()
    ports = list_usb_serial_ports()
    for port in ports:
        try:
            # Open port
            with serial.Serial(port, baud_rate, timeout=timeout) as ser:
                # reset buffer
                ser.reset_input_buffer()
                
                # Send a break key 
                # wait for response
                ser.write(b'\n')
                time.sleep(0.2)
                response = ser.read(ser.in_waiting).decode('utf-8', errors='ignore')
               
                
                if login_prompt_value in response:
                    ser.write(b'root\n')
                    time.sleep(0.2) 
                    response = ser.read(ser.in_waiting).decode('utf-8', errors='ignore')
                    return port 
                elif terminator_value in response:
                    ser.write(b'\n')
                    time.sleep(0.2)
                    response = ser.read(ser.in_waiting).decode('utf-8', errors='ignore')
                    return port 
              
        except (OSError, serial.SerialException):
            
            continue
    
   
    return None


#Use function
serial_port = find_serial_port()
if serial_port:
    print(f"Found matching serial port: {serial_port}")
else:
    print("No matching serial port found")

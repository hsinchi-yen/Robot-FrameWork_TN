import paramiko
import datetime
import time
import os
import paramiko
import re
from flask import Flask, render_template, request
from flask_socketio import SocketIO, emit
from flask_cors import CORS
import socket

app = Flask(__name__)
CORS(app)  # for fixing the issue "ERR_BLOCKED_BY_RESPONSE.NotSameOrigin"
app.config['SECRET_KEY'] = 'secret!'
socketio = SocketIO(app, async_mode='threading')

# Get script execution under current folder
script_dir = os.path.dirname(os.path.abspath(__file__))

log_file_path = os.path.join(script_dir, "iperf.txt")

# Check log file exist or not
if os.path.exists(log_file_path):
    os.remove(log_file_path)

run_count = 1  # initial counter


@app.route('/', methods=['GET', 'POST'])
def index():
    wifi_data = {
        'essid': 'N/A',
        'frequency': 'N/A',
        'bitrate': 'N/A',
        'signal_level': 'N/A'
    }
    if request.method == 'POST':
        client_ip = request.form['client_ip']
        server_ip = request.form['server_ip']
        mode = request.form['mode']
        socketio.emit('start_iperf3', {'client_ip': client_ip, 'server_ip': server_ip, 'mode': mode})
        return render_template('index.html', data=wifi_data)
    return render_template('index.html', data=wifi_data)

def parse_throughput(line):
    parts = line.split()
    throughput = float(parts[5])
    #['[SUM][TX-C]', '0.00-10.00', 'sec', '1.10', 'GBytes', '941', 'Mbits/sec', '3', 'sender']
    #Start index from 0, the bandwidth index is 5 
    unit = parts[6]
    if unit == 'Mbits/sec':
        return throughput  # Already in Mbits/sec
    elif unit == 'Gbits/sec':
        return throughput * 1000  # Convert Gbits/sec to Mbits/sec
    return 0
def parse_iwconfig_output(client_ip, client):
    try:
        #interface = check_network_interface (server_ip, client)
        stdin, stdout, stderr = client.exec_command(f'/sbin/iwconfig {interface}')
        output = stdout.read().decode('utf-8')  
        #print ("debug:",output)
        essid_match = re.search(r'ESSID[:=]\"(.*?)\"', output)
        frequency_match = re.search(r'Frequency[:=](\S+ GHz)', output)
        bitrate_match = re.search(r'Bit Rate[:=](\S+ Mb/s)', output)
        signal_match = re.search(r'Signal level[:=](-\d+ dBm)', output)

        #essid = essid_match.group(1) if essid_match else "N/A"
        essid = essid_match.group(1) if (essid_match and essid_match.group(1)) else "N/A"
        frequency = frequency_match.group(1) if frequency_match else "N/A"
        bitrate = bitrate_match.group(1) if bitrate_match else "N/A"
        signal_level = signal_match.group(1) if signal_match else "N/A"

      
        wifi_info = {
            'essid': essid,
            'frequency': frequency,
            'bitrate': bitrate,
            'signal_level': signal_level
        }
        
        socketio.emit('wifi_info', wifi_info)
        
        print(f"ESSID={essid}, Frequency={frequency}, Bitrate={bitrate}, Signal Level={signal_level}")
        return wifi_info
    except Exception as e:
        print(f"Error parsing iwconfig output: {e}")
        return None
   
        
def check_network_interface(client_ip,client):

    try:
        global  interface
        stdin, stdout, stderr = client.exec_command('ifconfig')
        output = stdout.read().decode('utf-8')
        
        interface = None
        lines = output.splitlines()
        for index, line in enumerate(lines):
            line = line.strip()
            
            if ":" in line and not line.startswith(" "):
                current_interface = line.split(":")[0]
            
            if "inet " in line and client_ip in line:
                interface = current_interface
                break

        if interface:
            print(f"\nThe IP {client_ip} matched network interface: {interface}")
            return interface
        else:
            print(f"No network interface found for IP {client_ip}")
            return None
    except Exception as e:
        print(f"Error checking network interface on {client_ip}: {e}")
        return None
def run_iperf3(client_ip, server_ip, mode, client):
    global run_count
    
    # try:
    #     client = paramiko.SSHClient()
    #     client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    #     client.connect(client_ip, username='root', password='', allow_agent=False, look_for_keys=False) 
    
    if mode == 'normal':
        cmd = f"iperf3 -c {server_ip} -P 4"
    elif mode == 'reverse':
        cmd = f"iperf3 -c {server_ip} -P 4 -R"
    elif mode == 'bidir':
        cmd = f"iperf3 -c {server_ip} -P 4 --bidir"
    else:
        print(f"Invalid mode: {mode}")
        return 0, 0, 0, 0  # Return zeros for invalid mode
    try:        
        #Chk_Channel= "iwconfig mlan0"
        
        print(f"Run {run_count}...")
        
        # stdin, stdout, stderr = client.exec_command(Chk_Channel)
        # chk_log = stdout.read().decode()
        
        iwconfig_result = parse_iwconfig_output(client_ip, client)
        stdin, stdout, stderr = client.exec_command(cmd)
        result = stdout.read().decode()
        error = stderr.read().decode()
        
        print("Command executed:",cmd)
        print("stdout:", result)
        print("stderr:", error)

        # Save raw data to file
        with open(log_file_path, 'a') as log_file:
            log_file.write(f"{datetime.datetime.now()}\n")
            log_file.write(f"===========Run {run_count}====================\n")
            log_file.write(str(iwconfig_result))
            log_file.write("\n")
            log_file.write(result)
            log_file.write(error)
            log_file.write("\n")
            
        
        
        
        run_count += 1  # Increase counter

        data = result.split('\n')
        if mode == 'normal':
            tx_sender_throughput = 0
            tx_receiver_throughput = 0
            for line in data:
                if 'SUM' in line and 'sender' in line:
                    tx_sender_throughput = parse_throughput(line)
                elif 'SUM' in line and 'receiver' in line:
                    tx_receiver_throughput = parse_throughput(line)
            return tx_sender_throughput, tx_receiver_throughput, 0, 0
        elif mode == 'reverse':
            rx_sender_throughput = 0
            rx_receiver_throughput = 0
            for line in data:
                if 'SUM' in line and 'sender' in line:
                    rx_sender_throughput = parse_throughput(line)
                elif 'SUM' in line and 'receiver' in line:
                    rx_receiver_throughput = parse_throughput(line)
            return rx_sender_throughput, rx_receiver_throughput, 0, 0
        elif mode == 'bidir':
            tx_sender_throughput = 0
            tx_receiver_throughput = 0
            rx_sender_throughput = 0
            rx_receiver_throughput = 0
            for line in data:
                if 'SUM' in line and '[TX-C]' in line and 'sender' in line:
                    tx_sender_throughput = parse_throughput(line)
                elif 'SUM' in line and '[TX-C]' in line and 'receiver' in line:
                    tx_receiver_throughput = parse_throughput(line)
                elif 'SUM' in line and '[RX-C]' in line and 'sender' in line:
                    rx_sender_throughput = parse_throughput(line)
                elif 'SUM' in line and '[RX-C]' in line and 'receiver' in line:
                    rx_receiver_throughput = parse_throughput(line)
            return tx_sender_throughput, tx_receiver_throughput, rx_sender_throughput, rx_receiver_throughput

    except Exception as e:
        print(f"An error occurred: {e}")
   
    return 0, 0, 0, 0

@socketio.on('start_iperf3')
def handle_start_iperf3(data):
    client_ip = data['client_ip']
    server_ip = data['server_ip']
    mode = data['mode']
    run_times = data.get('run_times', 4000)
    try:
        # The old code to call client (ssh) in run_iperf3 function is not working, the SOCKET.IO only pass data. 
            # Use SSH function in this pool:
                # parse_iwconfig_output(client)
                # check_network_interface(server_ip,client)
                # run_iperf3(server_ip, mode, client)
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect(client_ip, username='root', password='', allow_agent=False, look_for_keys=False)
        
      
        
        # To check interface with SSH 
        network_interface = check_network_interface(client_ip, client)
        if run_times == 0:
            print("Running indefinitely...")
        
            while True:  #Use for infinite loop
                if mode == 'normal':
                    tx_sender_throughput, tx_receiver_throughput, _, _ = run_iperf3(client_ip, server_ip, mode, client)
                    emit('update_chart', {'tx_sender_throughput': tx_sender_throughput, 'tx_receiver_throughput': tx_receiver_throughput})
                elif mode == 'reverse':
                    rx_sender_throughput, rx_receiver_throughput, _, _ = run_iperf3(client_ip, server_ip, mode, client)
                    emit('update_chart', {'rx_sender_throughput': rx_sender_throughput, 'rx_receiver_throughput': rx_receiver_throughput})
                elif mode == 'bidir':
                    tx_sender_throughput, tx_receiver_throughput, rx_sender_throughput, rx_receiver_throughput = run_iperf3(client_ip, server_ip, mode, client)
                    emit('update_chart', {
                        'tx_sender_throughput': tx_sender_throughput,
                        'tx_receiver_throughput': tx_receiver_throughput,
                        'rx_sender_throughput': rx_sender_throughput,
                        'rx_receiver_throughput': rx_receiver_throughput
                    })
        else:
            print(f"Test Run Set to {run_times} times...")
            
            for _ in range(run_times):
        
                if mode == 'normal':
                    tx_sender_throughput, tx_receiver_throughput, _, _ = run_iperf3(client_ip, server_ip, mode, client)
                    emit('update_chart', {'tx_sender_throughput': tx_sender_throughput, 'tx_receiver_throughput': tx_receiver_throughput})
                elif mode == 'reverse':
                    rx_sender_throughput, rx_receiver_throughput, _, _ = run_iperf3(client_ip, server_ip, mode, client)
                    emit('update_chart', {'rx_sender_throughput': rx_sender_throughput, 'rx_receiver_throughput': rx_receiver_throughput})
                elif mode == 'bidir':
                    tx_sender_throughput, tx_receiver_throughput, rx_sender_throughput, rx_receiver_throughput = run_iperf3(client_ip, server_ip, mode, client)
                    emit('update_chart', {
                        'tx_sender_throughput': tx_sender_throughput,
                        'tx_receiver_throughput': tx_receiver_throughput,
                        'rx_sender_throughput': rx_sender_throughput,
                        'rx_receiver_throughput': rx_receiver_throughput
                    })
                
                time.sleep(1)  # Optional: add delay between runs
            print("Test finished")    
            emit('stop_timer')  # Stop the timer when done
    
    finally:
        client.close()
def find_free_port():
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind(('', 0))
        s.listen(1)
        port = s.getsockname()[1]
    return port

if __name__ == '__main__':
    #print("Current working directory:", os.getcwd())
    port = find_free_port()
    print(f"Starting server on port {port}")
    #socketio.run(app, debug=False, port=5000)  #Fix TCP port 
    socketio.run(app, debug=False, port=port)   #Random TCP port

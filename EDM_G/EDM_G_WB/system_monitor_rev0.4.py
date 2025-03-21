from flask import Flask, render_template ,request
from flask_socketio import SocketIO
import re
import time
import os
import sys
import threading
import paramiko
import socket

app = Flask(__name__)
socketio = SocketIO(app, cors_allowed_origins="*")

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        client_ip = request.form['client_ip']
        
        socketio.emit('start_iperf3', {'client_ip': client_ip})
        return render_template('index_monitor.html')
    return render_template('index_monitor.html')

def read_data_from_file(filename, client_ip):
    user = 'root'
    #host = '10.88.90.172'
    
    remote_file_path = f"/{filename}"
   
    
    try:
        
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        #ssh.connect(client_ip, username=user, password='')
        ssh.connect(client_ip, username='root', password='', allow_agent=False, look_for_keys=False) 
        # Check file exist
        stdin, stdout, stderr = ssh.exec_command(f'test -e {remote_file_path} && echo EXISTS || echo MISSING')
        result = stdout.read().decode().strip()
        
        if result == "MISSING":
            print(f"Remote File: '{remote_file_path}' not exist")
            return []
       
        stdin, stdout, stderr = ssh.exec_command(f'tail -f {remote_file_path}')
        
        while True:
            line = stdout.readline()
            if not line:
                break
            yield line.strip()
        
    except Exception as e:
        print(f"Error: {e}")
    finally:
        ssh.close()

def parse_throughput(line):
    parts = line.split()
    throughput = float(parts[5])
    unit = parts[6]
    if unit == 'Mbits/sec':
        return throughput  # Already in Mbits/sec
    elif unit == 'Gbits/sec':
        return throughput * 1000  # Convert Gbits/sec to Mbits/sec
    return 0

def parse_data(lines):
    data = {}
    time_pattern = re.compile(r'Elapsed time: (\d+-\d{2}:\d{2}:\d{2}|\d{2}:\d{2}:\d{2}|\d{2}:\d{2})') #3 types of time format 

    for line in lines:
        
        if 'Elapsed time:' in line:
            match = time_pattern.search(line)
            if match:
                if data:
                    print(data)
                    yield data
            
            data = {'elapsed_time': match.group(1)}
        elif 'CPU usage:' in line:
            data['cpu_usage'] = float(re.search(r'CPU usage: ([\d.]+)%', line).group(1))
        elif 'Temperature:' in line:
            data['temperature'] = int(re.search(r'Temperature: (-?\d+) degree', line).group(1))  ## -? means to get minus values of temperature
        elif 'Memory test failure:' in line:
            data['memory_test_failure'] = int(re.search(r'Memory test failure: (\d+)', line).group(1))
        elif '[SUM]' in line:
            if 'sender' in line:
                data['tx_sender_throughput'] = parse_throughput(line)
            elif 'receiver' in line:
                data['rx_receiver_throughput'] = parse_throughput(line)
    if data:
        yield data
        
    
def background_task(filename, client_ip):
    lines = read_data_from_file(filename, client_ip)
    print(lines, flush=True) #Debugging
    sys.stdout.flush()  #Debugging
    for data in parse_data(lines):
        socketio.emit('update_chart', data)
        time.sleep(1)  
        

# @app.route('/')
# def index():
#     return render_template('index.html')

@socketio.on('start_monitoring')
def handle_start_monitoring(data):
    client_ip = data['client_ip']
    filename = data.get('filename')
    print(f"Starting monitoring with file: {filename} for client IP: {client_ip}")
    
    thread = threading.Thread(target=background_task, args=(filename, client_ip))
    thread.daemon = True
    thread.start()
    
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
    socketio.run(app, debug=False, port=port)

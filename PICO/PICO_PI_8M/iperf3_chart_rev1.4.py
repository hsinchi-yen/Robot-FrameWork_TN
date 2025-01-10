import paramiko
import datetime
import time
import os
from flask import Flask, render_template, request
from flask_socketio import SocketIO, emit
from flask_cors import CORS 

app = Flask(__name__)
CORS(app) # for fixing the issue "ERR_BLOCKED_BY_RESPONSE.NotSameOrigin"
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
    if request.method == 'POST':
        client_ip = request.form['client_ip']
        server_ip = request.form['server_ip']
        mode = request.form['mode']
        socketio.emit('start_iperf3', {'client_ip': client_ip, 'server_ip': server_ip, 'mode': mode})
        return render_template('index.html')
    return render_template('index.html')

def parse_throughput(line):
    parts = line.split()
    throughput = float(parts[5])
    unit = parts[6]
    if unit == 'Mbits/sec':
        return throughput  # Already in Mbits/sec
    elif unit == 'Gbits/sec':
        return throughput * 1000  # Convert Gbits/sec to Mbits/sec
    return 0

def run_iperf3(client_ip, server_ip, mode):
    global run_count
    
    try:
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect(client_ip, username='root', password='', allow_agent=False, look_for_keys=False) 
    
        if mode == 'normal':
            cmd = f"iperf3 -c {server_ip} -t 60 -P 4"
        elif mode == 'reverse':
            cmd = f"iperf3 -c {server_ip} -t 60 -P 4 -R"
        elif mode == 'bidir':
            cmd = f"iperf3 -c {server_ip} -t 60 -P 4 --bidir"
        else:
            print(f"Invalid mode: {mode}")
            return 0, 0, 0, 0  # Return zeros for invalid mode
        
        #Chk_Channel= "iwconfig mlan0"
        
        print(f"Run {run_count}...")
        
        # stdin, stdout, stderr = client.exec_command(Chk_Channel)
        # chk_log = stdout.read().decode()
        
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
            #log_file.write(chk_log)
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
    finally:
        client.close()
    return 0, 0, 0, 0

@socketio.on('start_iperf3')
def handle_start_iperf3(data):
    client_ip = data['client_ip']
    server_ip = data['server_ip']
    mode = data['mode']
    run_times = data.get('run_times', 4000)
    if run_times == 0:
        print("Running indefinitely...")
       
        while True:  #Use for infinite loop
         if mode == 'normal':
            tx_sender_throughput, tx_receiver_throughput, _, _ = run_iperf3(client_ip, server_ip, mode)
            emit('update_chart', {'tx_sender_throughput': tx_sender_throughput, 'tx_receiver_throughput': tx_receiver_throughput})
         elif mode == 'reverse':
            rx_sender_throughput, rx_receiver_throughput, _, _ = run_iperf3(client_ip, server_ip, mode)
            emit('update_chart', {'rx_sender_throughput': rx_sender_throughput, 'rx_receiver_throughput': rx_receiver_throughput})
         elif mode == 'bidir':
            tx_sender_throughput, tx_receiver_throughput, rx_sender_throughput, rx_receiver_throughput = run_iperf3(client_ip, server_ip, mode)
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
            tx_sender_throughput, tx_receiver_throughput, _, _ = run_iperf3(client_ip, server_ip, mode)
            emit('update_chart', {'tx_sender_throughput': tx_sender_throughput, 'tx_receiver_throughput': tx_receiver_throughput})
         elif mode == 'reverse':
            rx_sender_throughput, rx_receiver_throughput, _, _ = run_iperf3(client_ip, server_ip, mode)
            emit('update_chart', {'rx_sender_throughput': rx_sender_throughput, 'rx_receiver_throughput': rx_receiver_throughput})
         elif mode == 'bidir':
            tx_sender_throughput, tx_receiver_throughput, rx_sender_throughput, rx_receiver_throughput = run_iperf3(client_ip, server_ip, mode)
            emit('update_chart', {
                'tx_sender_throughput': tx_sender_throughput,
                'tx_receiver_throughput': tx_receiver_throughput,
                'rx_sender_throughput': rx_sender_throughput,
                'rx_receiver_throughput': rx_receiver_throughput
            })
            
         time.sleep(1)  # Optional: add delay between runs
        print("Test finished")    
        emit('stop_timer')  # Stop the timer when done
    

if __name__ == '__main__':
    socketio.run(app, debug=True, host='0.0.0.0')

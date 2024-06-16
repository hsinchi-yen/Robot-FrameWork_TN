import sys
import time
import subprocess


def find_ipv4_addr(loc_inf):
    command = f"ifconfig {loc_inf} | grep 'inet\ ' | awk -F ' ' '{{print $2}}'"
    try:
        result = subprocess.run(command, shell=True, check=True, text=True, capture_output=True)
        output = result.stdout
        print(f"Console INF:{loc_inf} Found IPv4 IP:{output}")
        return result.stdout.strip()        
       
    except Exception as e:
        print(f"Error executing lsusb: {e}")
        return f"Command failed with error: {e.stderr}"
    

def find_ipv6_addr(loc_inf):
    command = f"ifconfig {loc_inf} | grep 'inet6\ ' | awk -F ' ' '{{print $2}}'"
    try:
        result = subprocess.run(command, shell=True, check=True, text=True, capture_output=True)
        output = result.stdout
        print(f"Console INF:{loc_inf} Found IPv6 IP:{output}")
        return result.stdout.strip()     
        
    except Exception as e:
        print(f"Error executing lsusb: {e}")
        return f"Command failed with error: {e.stderr}"
    

class EnvVariablesReturnLib:
    def __init__(self):
        None

    def ip4_addr_finder(self, desired_ethinf):
        return find_ipv4_addr(desired_ethinf)

    def ip6_addr_finder(self, desired_ethinf):
        return find_ipv6_addr(desired_ethinf)



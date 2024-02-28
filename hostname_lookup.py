import socket
import ipaddress
import concurrent.futures


def nslookup(ip):
        try:
            host_name, _, _ = socket.gethostbyaddr(str(ip))
            print(f"IP: {ip}, Hostname: {host_name}")
        except Exception as e:
            return 0
def nslookup_subnet(subnet, num_threads=5):
    network = ipaddress.IPv4Network(subnet, strict=False)

    with concurrent.futures.ThreadPoolExecutor(max_workers=num_threads) as executor:
        executor.map(nslookup, network.hosts())

if __name__ == "__main__":
    subnet = input("Enter the subnet (e.g., x.x.x.0./24): ")
    num_threads = int(input("Enter the number of Threads: "))


    nslookup_subnet(subnet, num_threads)
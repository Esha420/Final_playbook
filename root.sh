#!/bin/bash

# Ensure the inventory file exists
if [ ! -f /tmp/machine.yml ]; then
  echo "Inventory file not found!"
  exit 1
fi

# Extract IPs from the inventory file and create host.txt
awk '/ansible_host:/ {print $2}' /tmp/machine.yml > /tmp/host.txt

# Generate SSH key on 172.25.204.49 and fetch the public key
KEY_IP="172.25.204.49"
REMOTE_TMP_FILE="/home/kube-spray/id_rsa_49.pub"

ssh -T kube-spray@$KEY_IP << 'EOF'
  sudo su - << 'EOSU'
    cd /root
    yes y | ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa
    if [ $? -ne 0 ]; then
      echo "Failed to generate SSH key" >&2
      exit 1
    fi
    cat /root/.ssh/id_rsa.pub > /home/kube-spray/id_rsa_49.pub
    if [ $? -ne 0 ]; then
      echo "Failed to write public key to temporary file" >&2
      exit 1
    fi
EOSU
EOF

# Fetch the public key from the remote machine
scp kube-spray@$KEY_IP:$REMOTE_TMP_FILE /tmp/id_rsa_49.pub
if [ $? -ne 0 ]; then
  echo "Failed to fetch the public key from $KEY_IP"
  exit 1
fi

# Check if the public key was fetched successfully
if [ ! -s /tmp/id_rsa_49.pub ]; then
  echo "Public key file is empty or not found: /tmp/id_rsa_49.pub"
  exit 1
fi

# Function to validate IP addresses
function valid_ip() {
  local ip=$1
  local stat=1

  echo "Validating IP: $ip"

  if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    OIFS=$IFS
    IFS='.'
    ip=($ip)
    IFS=$OIFS
    if [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]; then
      stat=0
    fi
  fi
  return $stat
}

# Loop through each IP and add id_rsa_49.pub to authorized_keys
while IFS= read -r IP; do
  echo "Processing IP: $IP"
  if valid_ip "$IP"; then
    echo "Valid IP: $IP"
    cat /tmp/id_rsa_49.pub | ssh -T kube-spray@$IP "sudo tee -a /root/.ssh/authorized_keys > /dev/null"
    if [ $? -ne 0 ]; then
      echo "Failed to add public key to $IP"
    fi
  else
    echo "Invalid IP address: $IP"
  fi
done < /tmp/host.txt

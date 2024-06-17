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

PUBLIC_KEY="/tmp/id_rsa_49.pub"

# Function to add the public key to the authorized_keys file on a node
add_public_key() {
    echo "Adding public key to $1"
    cat "$PUBLIC_KEY" | ssh "$1" "sudo sh -c 'mkdir -p /root/.ssh && cat >> /root/.ssh/authorized_keys'"
}

# Read IPs from host.txt and add them to the NODES array
NODES=()
while IFS= read -r line; do
    NODES+=("$line")
done < /tmp/host.txt

# Loop through nodes and add public key
for NODE in "${NODES[@]}"; do
    add_public_key "$NODE"
done

#!/bin/bash

# Ensure the inventory file exists
if [ ! -f /tmp/machine.yml ]; then
  echo "Inventory file not found!"
  exit 1
fi

# Extract IPs from the inventory file and create host.txt
awk '/ansible_host:/ {print $2}' /tmp/machine.yml > /tmp/host.txt

 KEY_IP=$(awk 'NR==1 {gsub(/[[:space:]]/, ""); print; exit}' host.txt)

# Generate SSH key on 172.25.204.49 and fetch the public key

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

# Check if the public key was fetched successfully
if [ ! -s /home/kube-spray/id_rsa_49.pub ]; then
  echo "Public key file is empty or not found: /home/kube-spray/id_rsa_49.pub"
  exit 1
fi

PUBLIC_KEY="/home/kube-spray/id_rsa_49.pub"

# Read IPs from host.txt and add them to the NODES array
NODES=()
while IFS= read -r line; do
    # Remove spaces from the node name
    clean_line=$(echo "$line" | tr -d '[:space:]')
    NODES+=("$clean_line")
done < /tmp/host.txt

echo "Nodes to add the public key:"
for node in "${NODES[@]}"; do
    echo "$node"
done

# Loop through nodes and add public key
for NODE in "${NODES[@]}"; do
  echo "Adding public key to $NODE"
  ssh kube-spray@$NODE "sudo sh -c 'mkdir -p /root/.ssh && cat $PUBLIC_KEY >> /root/.ssh/authorized_keys'"
done


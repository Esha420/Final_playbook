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
ssh -T kube-spray@$KEY_IP << 'EOF'
  sudo su << 'EOSU'
    cd /root
    yes y | ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa
    cat /root/.ssh/id_rsa.pub
EOSU
EOF > /tmp/id_rsa_49.pub

# Loop through each IP and add id_rsa_49.pub to authorized_keys
while IFS= read -r IP; do
  cat /tmp/id_rsa_49.pub | ssh -T kube-spray@$IP "sudo tee -a /root/.ssh/authorized_keys > /dev/null"
done < /tmp/host.txt

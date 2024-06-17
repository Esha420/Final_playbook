#!/bin/bash

# Ensure the machine.yml file exists
if [ ! -f /tmp/host.txt ]; then
  echo "host.txt file not found!"
  exit 1
fi

# Read IPs from the file generated by the Ansible playbook
IPS=$(cat /tmp/host/host.txt)

# Loop through each IP and run the SSH commands
for IP in $IPS; do
  ssh -T kube-spray@$IP << 'EOF'
    sudo su << 'EOSU'
      cd /root
      yes y | ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa
      cat /root/.ssh/id_rsa.pub
      cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
EOSU
EOF
done

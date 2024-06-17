#!/bin/bash

# Ensure the host.txt file exists
if [ ! -f /tmp/host.txt ]; then
  echo "host.txt file not found!"
  exit 1
fi

# Read IPs from the file
IPS=$(cat /tmp/host.txt)

# Generate SSH key on 172.25.204.48 and fetch the public key
KEY_IP="172.25.204.48"
ssh -T kube-spray@$KEY_IP << 'EOF'
  sudo su << 'EOSU'
    cd /root
    yes y | ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa
    cat /root/.ssh/id_rsa.pub
EOSU
EOF

# Save the public key locally
ssh -T kube-spray@$KEY_IP "sudo cat /root/.ssh/id_rsa.pub" > /tmp/id_rsa_48.pub

# Loop through each IP and run the SSH commands
for IP in $IPS; do
  if [ "$IP" == "172.25.204.49" ] || [ "$IP" == "172.25.204.50" ]; then
    ssh -T kube-spray@$IP << 'EOF'
      sudo su << 'EOSU'
        cd /root
        cat /tmp/id_rsa_48.pub >> /root/.ssh/authorized_keys
EOSU
EOF
  else
    ssh -T kube-spray@$IP << 'EOF'
      sudo su << 'EOSU'
        cd /root
        yes y | ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa
        cat /root/.ssh/id_rsa.pub
        cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
EOSU
EOF
  fi
done

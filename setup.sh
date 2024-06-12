#!/bin/bash

# Define the inventory file path
INVENTORY_FILE="/tmp/kubespray/inventory/my-cluster/hosts.yml"

# Execute the Ansible playbook for cluster setup
ANSIBLE_ROLES_PATH=/tmp/kubespray/roles ansible-playbook -i "$INVENTORY_FILE" --become --become-user=root /tmp/kubespray/cluster.yml

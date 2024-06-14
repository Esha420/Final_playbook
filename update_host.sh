#!/bin/bash

hosts_file="/tmp/kubespray/inventory/my-cluster/hosts.yml"

# Remove node2 from the block
remove_node2() {
    sed -i '/kube_control_plane:/,/kube_node:/{
            /node2:/d
        }' $hosts_file
}
remove_node2

# Print the updated file
cat $hosts_file
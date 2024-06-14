#!/bin/bash

hosts_file="tmp/kubespray/inventory/my-cluster/hosts.yml"

# Remove node2 from the block
remove_node2() {
    sed -i '/node2:/,/node3:/d' $hosts_file
}

# Print the updated file
cat $hosts_file

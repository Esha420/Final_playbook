import yaml

# Load the YAML file
with open('/tmp/kubespray/inventory/my-cluster/hosts.yml', 'r') as file:
    data = yaml.safe_load(file)

# Remove node2 from the kube_control_plane group
if 'children' in data and 'kube_control_plane' in data['children']:
    kube_control_plane = data['children']['kube_control_plane']
    if 'hosts' in kube_control_plane and 'node2' in kube_control_plane['hosts']:
        del kube_control_plane['hosts']['node2']

# Save the updated YAML file
with open('/tmp/kubespray/inventory/my-cluster/hosts.yml', 'w') as file:
    yaml.dump(data, file, default_flow_style=False)

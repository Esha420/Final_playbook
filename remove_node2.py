# import yaml

# # Load the YAML file
# with open('/tmp/kubespray/inventory/my-cluster/hosts.yml', 'r') as file:
#     data = yaml.safe_load(file)

# # Remove node2 from the kube_control_plane group
# if 'children' in data and 'kube_control_plane' in data['children']:
#     kube_control_plane = data['children']['kube_control_plane']
#     if 'hosts' in kube_control_plane and 'node2' in kube_control_plane['hosts']:
#         del kube_control_plane['hosts']['node2']

# # Save the updated YAML file
# with open('/tmp/kubespray/inventory/my-cluster/hosts.yml', 'w') as file:
#     yaml.dump(data, file, default_flow_style=False)

# import yaml

# def remove_node2(inventory_file):
#   """
#   Removes node2 from the kube_control_plane block in the inventory file.

#   Args:
#     inventory_file (str): Path to the inventory YAML file.
#   """
#   with open(inventory_file, 'r') as f:
#     data = yaml.safe_load(f)

#   data['all']['children']['kube_control_plane']['hosts'].pop('node2', None)

#   with open(inventory_file, 'w') as f:
#     yaml.dump(data, f, default_flow_style=False)

# # Example usage
# inventory_file = "/tmp/kubespray/inventory/my-cluster/hosts.yml"  # Replace with your actual inventory file path
# remove_node2(inventory_file)

# print(f"Node2 removed from kube_control_plane block in {inventory_file}")


import yaml

def remove_node2(inventory_file):
  """
  Removes node2 from the kube_control_plane block in the inventory file,
  preserving existing data in other sections.

  Args:
    inventory_file (str): Path to the inventory YAML file.
  """
  with open(inventory_file, 'r') as f:
    data = yaml.safe_load(f)

  # Check if 'kube_control_plane' exists and has 'hosts' before modification
  if 'kube_control_plane' in data['all']['children'] and 'hosts' in data['all']['children']['kube_control_plane']:
    data['all']['children']['kube_control_plane']['hosts'].pop('node2', None)

  with open(inventory_file, 'w') as f:
    yaml.dump(data, f, default_flow_style=False)

# Example usage
inventory_file = "/tmp/kubespray/inventory/my-cluster/hosts.yml"  # Replace with your actual inventory file path
remove_node2(inventory_file)

print(f"Node2 removed from kube_control_plane block in {inventory_file}")

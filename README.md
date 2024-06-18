# Kubespray Setup Using Ansible
This guide provides step-by-step instructions to set up a Kubernetes cluster using KubeSpray and Ansible on three EC2 instances.
## Requirements
- Three EC2 instances with the following IP addresses
    - 172.25.204.49 
    - 172.25.204.50
    - 172.25.204.51

    Here all three instances has username 'kube-spray'.
    You can have a ansible host server but ensure that the ansible server is connected to you node servers.
## Steps
- Clone the repository and navigate into it:
git clone https://github.com/Esha420/Final_playbook.git
cd Final_playbook

- Edit the machine.ini file to reflect the IP addresses of your nodes. Ensure the IP addresses of node1, node2,and node3 are correctly configured.

- Run the playbook to first transfer the keys:
   ansible-playbook -i machine.yml key_handle.yml

## Now we need to run the main file for cluster setup
- goto your control plane node
- Run the main playbook to deploy the cluster
    ansible-playbook -i machine.yml main.yml
    (This step may require some time to run all the steps)
- Check the nodes with the command
    '''kubectl get nodes'''


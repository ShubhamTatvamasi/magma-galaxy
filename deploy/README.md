# Deploy Magma Orchestrator

Install Dependant Collections
```bash
ansible-galaxy collection install -U shubhamtatvamasi.magma
ansible-galaxy collection list
```

Copy your public SSH key to the host:
```bash
ssh-keygen -R 192.168.5.70
ssh-copy-id ubuntu@192.168.5.70
```

Add more IPs to the host:
```bash
ssh ubuntu@192.168.5.70
sudo vim /etc/netplan/50-cloud-init.yaml
sudo netplan apply
```

Deploy Magma orchestrator:
```bash
ansible-playbook deploy-orc8r.yml
```

### Ubuntu 20.04 LTS Setup

Setup Ansible:
```bash
sudo apt install -y ansible
ansible-galaxy collection install shubhamtatvamasi.magma --force-with-deps
```

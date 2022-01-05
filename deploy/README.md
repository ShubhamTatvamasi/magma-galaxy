# Deploy Magma Orchestrator

Install Magma Collection
```bash
ansible-galaxy collection install shubhamtatvamasi.magma --upgrade
```

Copy your public SSH key to the host:
```bash
ssh-copy-id ubuntu@192.168.5.70
```

Deploy Magma orchestrator:
```bash
ansible-playbook deploy-orc8r.yml
```

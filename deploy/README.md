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
> Note: update your values in `hosts.yml` file before running the playbook.

Create new user:
```bash
ORC_POD=$(kubectl get pod -l app.kubernetes.io/component=orchestrator -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it ${ORC_POD} -- envdir /var/opt/magma/envdir /var/opt/magma/bin/accessc \
  add-existing -admin -cert /var/opt/magma/certs/admin_operator.pem admin_operator

NMS_POD=$(kubectl get pod -l app.kubernetes.io/component=magmalte -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it ${NMS_POD} -- yarn setAdminPassword master admin admin
kubectl exec -it ${NMS_POD} -- yarn setAdminPassword magma-test admin admin
```

### Ubuntu 20.04 LTS Setup

Setup Ansible:
```bash
sudo apt install -y ansible
ansible-galaxy collection install shubhamtatvamasi.magma --force-with-deps
```

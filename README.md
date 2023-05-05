# Venko's Deploy for Magma Orchestrator



# Fixed Versions:

- Calico: v3.24.1
- CoreDNS: 1.8.6
- Metrics Server: v0.6.2
- Rancher Kubernetes Engine: v1.25.6-rancher4
- MetalLB: v0.13.9
- OpenEBS Local Provisioner: 3.4.0
- OpenEBS Disk Manager: 2.1.0
- ElasticSearch Container: 7.17.3
- FluentD: v2.4.0
- HA Proxy Alpine: 2.6.9
- Magma Containers: 666a3f3
- Nginx: latest
- Alert Manager: v0.18.0
- Alert Manager Configurer: 1.0.4
- Orc8r Prometheus: v2.27.1
- Orc8r Cache: 1.1.0
- Orc8r Cache Configurer: 1.0.4
- Grafana: 6.7.6
- PostgreSQL: 15.2.0-debian-11-r16


Create an Ubuntu VM, with the following requirements:

- Ubuntu Server 22.04
- CPU 8 cores
- 16GB RAM
- 100GB or greater SSD storage
- Static IP 


Quick Install:
```bash
sudo bash -c "$(curl -sL https://github.com/venko-networks/magma-galaxy/raw/master/deploy-orc8r.sh)"
```

Switch to `magma` user after deployment has finsished:
```bash
sudo su - magma
```

Once all pods are ready, setup NMS login:
```bash
cd ~/magma-galaxy
ansible-playbook config-orc8r.yml
```

You can get your `rootCA.pem` file from the following location:
```bash
cat ~/magma-galaxy/secrets/rootCA.pem
```

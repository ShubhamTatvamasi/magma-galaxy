# Deploy Magma Orchestrator

Create a Ubuntu Focal VM


Quick Install:
```bash
sudo bash -c "$(curl -sL https://github.com/ShubhamTatvamasi/magma-galaxy/raw/master/deploy-orc8r.sh)"
```

Switch to `magma` user after deployment has finsished:
```bash
sudo su - magma
```

Once all pods are ready, setup NMS login:
```bash
cd magma-galaxy
ansible-playbook config-orc8r.yml
```
> Defaults: ID: `admin`, Password: `admin`, Organization: `magma-test`

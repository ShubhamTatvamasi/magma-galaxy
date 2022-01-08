# Multipass Setup

Start a new multipass instance with the following command:
```bash
multipass launch focal \
  --name orc8r \
  --disk 100G \
  --mem 8G \
  --cpus 4
```

Check if instance has started:
```bash
multipass ls
```

Get access to the shell:
```bash
multipass shell orc8r
```

Add your public SSH key to the instance:
```bash
vim .ssh/authorized_keys
```

Test your connection and add more IPs to the instance:
```bash
ssh ubuntu@192.168.64.14
sudo vim /etc/netplan/50-cloud-init.yaml
```

Update your network file:
```yaml
network:
    ethernets:
        enp0s2:
            addresses:
            - 192.168.64.14/24
            - 192.168.64.15/24
            - 192.168.64.16/24
            - 192.168.64.17/24
            - 192.168.64.18/24
            gateway4: 192.168.64.1
            nameservers:
                addresses:
                - 8.8.8.8
                - 8.8.4.4
            match:
                macaddress: 66:bb:1e:2e:e5:92
            set-name: enp0s2
    version: 2
```

Apply changes:
```bash
sudo netplan apply
```

### Uninstall

Delete Instance
```bash
multipass delete orc8r
multipass purge
```

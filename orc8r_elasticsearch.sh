#!/usr/bin/env bash
set -e

cat <<EOT >> /home/magma/magma-galaxy/check_pod_status.sh
#!/bin/bash

# Verifica o status do pod Elasticsearch
pod_status=$(kubectl get pod elasticsearch-master-0 --no-headers | awk '{print $2}')

# Verifica se o pod está pronto
if [[ "$pod_status" == "0/1" ]]; then
    echo "O pod Elasticsearch não está pronto. Executando playbook Ansible..."
    ansible-playbook /home/magma/magma-galaxy/fix-elasticsearch.yml
else
    echo "O pod Elasticsearch está pronto."
fi
EOT
chmod +x /home/magma/magma-galaxy/check_pod_status.sh

sudo cat <<EOT >> /etc/systemd/system/check_elasticsearch.service
[Unit]
Description=Verificar status do pod Elasticsearch e executar playbook Ansible
After=network.target

[Service]
Type=simple
ExecStart=/home/magma/magma-galaxy/check_pod_status.sh

[Install]
WantedBy=multi-user.target
EOT

sudo systemctl daemon-reload
sudo systemctl enable check_elasticsearch.service
sudo systemctl start check_elasticsearch.service
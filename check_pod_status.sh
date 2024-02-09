#!/bin/bash

# Verifica o status do pod Elasticsearch
pod_status="$(kubectl get pod elasticsearch-master-0 --no-headers | awk '{print $2}')"

# Verifica se o pod está pronto
if [[ "$pod_status" != "1/1" ]]; then
    echo "O pod Elasticsearch não está pronto. Executando playbook Ansible..."
    ansible-playbook /home/magma/magma-galaxy/fix-elasticsearch.yml
else
    echo "O pod Elasticsearch está pronto."
fi
exit 0
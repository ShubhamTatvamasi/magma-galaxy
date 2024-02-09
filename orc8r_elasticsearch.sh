#!/usr/bin/env bash
set -e

curl -sL https://raw.githubusercontent.com/venko-networks/magma-galaxy/1.8.2/check_pod_status.sh > /home/magma/magma-galaxy/check_pod_status.sh
chmod 770 /home/magma/magma-galaxy/check_pod_status.sh

sudo curl -sL https://raw.githubusercontent.com/venko-networks/magma-galaxy/1.8.2/check_elasticsearch.service
 > /etc/systemd/system/check_elasticsearch.service
 
sudo systemctl daemon-reload
sudo systemctl enable check_elasticsearch.service
sudo systemctl start check_elasticsearch.service
exit 0
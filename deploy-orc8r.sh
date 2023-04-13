#!/usr/bin/env bash

set -e

# Check if the system is Linux
if [ $(uname) != "Linux" ]; then
  echo "This script is only for Linux"
  exit 1
fi

# Run as root user
if [ $(id -u) != 0 ]; then
  echo "Please run as root user"
  exit 1
fi

ORC8R_DOMAIN="magma.local"
NMS_ORGANIZATION_NAME="magma-test"
NMS_EMAIL_ID_AND_PASSWORD="admin"
ORC8R_IP=$(ip a s $(ip r | head -n 1 | awk '{print $5}') | awk '/inet/ {print $2}' | cut -d / -f 1 | head -n 1)
GITHUB_USERNAME="ShubhamTatvamasi"
MAGMA_ORC8R_REPO="magma-galaxy"
MAGMA_USER="magma"
HOSTS_FILE="hosts.yml"

# Take input from user
read -rp "Your Magma Orchestrator domain name: " -ei "${ORC8R_DOMAIN}" ORC8R_DOMAIN
read -rp "NMS organization(subdomain) name you want: " -ei "${NMS_ORGANIZATION_NAME}" NMS_ORGANIZATION_NAME
read -rp "Set your email ID for NMS: " -ei "${NMS_EMAIL_ID_AND_PASSWORD}" NMS_EMAIL_ID
read -rp "Set your password for NMS: " -ei "${NMS_EMAIL_ID_AND_PASSWORD}" NMS_PASSWORD
read -rp "Do you wish to install latest Orc8r build: " -ei "Yes" LATEST_ORC8R
read -rp "Set your LoadBalancer IP: " -ei "${ORC8R_IP}" ORC8R_IP

case ${LATEST_ORC8R} in
  [yY]*)
    ORC8R_VERSION="latest"
    ;;
  [nN]*)
    ORC8R_VERSION="stable"
    ;;
esac

# Add repos for installing yq and ansible
add-apt-repository --yes ppa:rmescandon/yq
add-apt-repository --yes ppa:ansible/ansible

# Install yq and ansible
apt install yq ansible -y

# Create magma user and give sudo permissions
useradd -m ${MAGMA_USER} -s /bin/bash -G sudo
echo "${MAGMA_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# switch to magma user
su - ${MAGMA_USER} -c bash <<_

# Genereta SSH key for magma user
ssh-keygen -t rsa -f ~/.ssh/id_rsa -N ''
cp ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys 

# Clone Magma Galaxy repo
git clone https://github.com/${GITHUB_USERNAME}/${MAGMA_ORC8R_REPO} --depth 1
cd ~/${MAGMA_ORC8R_REPO}

# Depoly latest Orc8r build
if [ "${ORC8R_VERSION}" == "latest" ]; then
  sed "s/# magma_docker/magma_docker/g" -i ${HOSTS_FILE}
  sed "s/# orc8r_helm_repo/orc8r_helm_repo/" -i ${HOSTS_FILE}
fi

# export variables for yq
export ORC8R_IP=${ORC8R_IP}
export MAGMA_USER=${MAGMA_USER}
export ORC8R_DOMAIN=${ORC8R_DOMAIN}
export NMS_ORGANIZATION_NAME=${NMS_ORGANIZATION_NAME}
export NMS_EMAIL_ID=${NMS_EMAIL_ID}
export NMS_PASSWORD=${NMS_PASSWORD}

# Update values to the config file
yq e '.all.hosts = env(ORC8R_IP)' -i ${HOSTS_FILE}
yq e '.all.vars.ansible_user = env(MAGMA_USER)' -i ${HOSTS_FILE}
yq e '.all.vars.orc8r_domain = env(ORC8R_DOMAIN)' -i ${HOSTS_FILE}
yq e '.all.vars.nms_org = env(NMS_ORGANIZATION_NAME)' -i ${HOSTS_FILE}
yq e '.all.vars.nms_id = env(NMS_EMAIL_ID)' -i ${HOSTS_FILE}
yq e '.all.vars.nms_pass = env(NMS_PASSWORD)' -i ${HOSTS_FILE}

# Deploy Magma Orchestrator
ansible-playbook deploy-orc8r.yml
_

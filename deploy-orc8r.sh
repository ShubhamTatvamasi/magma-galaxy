#!/usr/bin/env bash

set -e

# Check if the system is Linux
if [ $(uname) != "Linux" ]; then
  echo "This script is only for Linux"
  exit 1
fi

# Check if the system is Ubuntu Focal
if [ $(lsb_release -cs) != "focal" ]; then
  echo "This script will only work on Ubuntu Focal"
  exit 1
fi

# Run as root user
if [ $(id -u) != 0 ]; then
  echo "Please run as root user"
  exit 1
fi

DEFAULT_ORC8R_DOMAIN="magma.local"
DEFAULT_NMS_ORGANIZATION_NAME="magma-test"
DEFAULT_NMS_EMAIL_ID="admin"
DEFAULT_NMS_PASSWORD="admin"
ORC8R_IP=$(hostname -I | awk '{print $1}')
GITHUB_USERNAME="ShubhamTatvamasi"
MAGMA_ORC8R_REPO="magma-galaxy"
MAGMA_USER="magma"
HOSTS_FILE="hosts.yml"

# Set Magma Orchestrator domain name
read -p "Your Magma Orchestrator domain name? [${DEFAULT_ORC8R_DOMAIN}]: " ORC8R_DOMAIN
ORC8R_DOMAIN="${ORC8R_DOMAIN:-${DEFAULT_ORC8R_DOMAIN}}"

read -p "Which NMS subdomain organization name you want? [${DEFAULT_NMS_ORGANIZATION_NAME}]: " NMS_ORGANIZATION_NAME
NMS_ORGANIZATION_NAME="${NMS_ORGANIZATION_NAME:-${DEFAULT_NMS_ORGANIZATION_NAME}}"

read -p "Set your email ID for NMS? [${DEFAULT_NMS_EMAIL_ID}]: " NMS_EMAIL_ID
NMS_EMAIL_ID="${NMS_EMAIL_ID:-${DEFAULT_NMS_EMAIL_ID}}"

read -p "Set your password for NMS? [${DEFAULT_NMS_PASSWORD}]: " NMS_PASSWORD
NMS_PASSWORD="${NMS_PASSWORD:-${DEFAULT_NMS_PASSWORD}}"

# Do you wish to install latest Orc8r build?
# read -p "Do you wish to install latest Orc8r build? [y/N]: " LATEST_ORC8R
LATEST_ORC8R="${LATEST_ORC8R:-N}"

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
useradd -m ${MAGMA_USER} -s /bin/bash -p $(echo ${MAGMA_USER} | openssl passwd -1 -stdin) -G sudo
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

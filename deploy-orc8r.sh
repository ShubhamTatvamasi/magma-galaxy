#!/usr/bin/env bash

set -e

# Check if the system is Linux
if [ "$(uname)" != "Linux" ]; then
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
ORC8R_IP=$(hostname -I | awk '{print $1}')
GITHUB_USERNAME="ShubhamTatvamasi"
MAGMA_ORC8R_REPO="magma-galaxy"
MAGMA_USER="magma"
HOSTS_FILE="hosts.yml"

# Set Magma Orchestrator domain name
read -p "Your Magma Orchestrator domain name? [${DEFAULT_ORC8R_DOMAIN}]: " ORC8R_DOMAIN
ORC8R_DOMAIN="${ORC8R_DOMAIN:-${DEFAULT_ORC8R_DOMAIN}}"

# Do you wish to install latest Orc8r build?
read -p "Do you wish to install latest Orc8r build? [y/N]: " LATEST_ORC8R
LATEST_ORC8R="${LATEST_ORC8R:-N}"

case ${LATEST_ORC8R} in
  [yY][eE][sS]|[yY])
    ORC8R_VERSION="latest"
    ;;
  [nN][oO]|[nN])
    ORC8R_VERSION="stable"
    ;;
esac

# Add repos for installing ansible and yq
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CC86BB64
add-apt-repository --yes ppa:rmescandon/yq
add-apt-repository --yes ppa:ansible/ansible

# Install ansible and yq
apt update
apt install ansible yq -y

# Create magma user and give sudo permissions
useradd -m ${MAGMA_USER} -s /bin/bash -p $(echo ${MAGMA_USER} | openssl passwd -1 -stdin) -G sudo
echo "${MAGMA_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# switch to magma user
su - ${MAGMA_USER} -c bash <<_

# Genereta SSH key for magma user
ssh-keygen -t rsa -f /home/${MAGMA_USER}/.ssh/id_rsa -N ''
cp /home/${MAGMA_USER}/.ssh/id_rsa.pub /home/${MAGMA_USER}/.ssh/authorized_keys 

# Download dependent collection
ansible-galaxy collection install shubhamtatvamasi.magma

# Clone Magma Galaxy repo
git clone https://github.com/${GITHUB_USERNAME}/${MAGMA_ORC8R_REPO} /home/${MAGMA_USER}/${MAGMA_ORC8R_REPO}
cd /home/${MAGMA_USER}/${MAGMA_ORC8R_REPO}

# export variables for yq
export ORC8R_IP=${ORC8R_IP}
export MAGMA_USER=${MAGMA_USER}
export ORC8R_DOMAIN=${ORC8R_DOMAIN}

# Updated values to the config file
yq e '.all.hosts = env(ORC8R_IP)' -i ${HOSTS_FILE}
yq e '.all.vars.ansible_user = env(MAGMA_USER)' -i ${HOSTS_FILE}
yq e '.all.vars.orc8r_domain = env(ORC8R_DOMAIN)' -i ${HOSTS_FILE}

# Depoly latest Orc8r build
if [ "${ORC8R_VERSION}" == "latest" ]; then
  for var in magma_docker_registry magma_docker_tag orc8r_helm_repo
  do
    sed "s/# ${var}/${var}/g" -i ${HOSTS_FILE}
  done
fi

# Deploy Magma Orchestrator
ansible-playbook deploy-orc8r.yml
_

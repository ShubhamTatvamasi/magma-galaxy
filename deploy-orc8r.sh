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

# Add repos for installing yq and ansible
add-apt-repository --yes ppa:rmescandon/yq
add-apt-repository --yes ppa:ansible/ansible

# Install yq and ansible
apt install ansible yq -y

# Create magma user and give sudo permissions
useradd -m ${MAGMA_USER} -s /bin/bash -p $(echo ${MAGMA_USER} | openssl passwd -1 -st

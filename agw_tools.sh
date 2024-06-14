#!/usr/bin/env bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${PURPLE}Parando os serviços do magma...${NC}"
systemctl stop magma@*
echo -e "${GREEN}Serviços parados com sucesso${NC}"
sleep 3
clear


downgradePkts_() {
    wget https://ftp.debian.org/debian/pool/main/g/gcc-10/liblsan0_10.2.1-6_amd64.deb -O /tmp/liblsan0.deb
    wget https://ftp.debian.org/debian/pool/main/g/gcc-10/gcc-10-base_10.2.1-6_amd64.deb -O /tmp/gcc10.deb
    sudo dpkg -i /tmp/gcc10.deb /tmp/liblsan0.deb
    apt-mark hold gcc-10-base liblsan0
}


configureMagma() {

    MAGMA_DIR=/var/opt/magma
    read -rp "Insira o IP do Orc8r: " ORC8R_IP
    read -rp "Insira a porta do Orc8r (Default 443): " -ei 443 ORC8R_SERVICE_PORT
    read -rp "Insira o dominio a ser utilizado: " DOMAIN
    IP_ETH0=$(ip a s eth0 | awk '/inet/ {print $2}' | head -n 1)
    CONFIG_DIR=/etc/magma

    # Cria diretórios e arquivos necessários.

    sudo mkdir -p $MAGMA_DIR/configs

    # Cria os arquivos necessários
    
    sudo cat <<EOT >> /etc/hosts
$ORC8R_IP api.$DOMAIN
$ORC8R_IP magma.nms.$DOMAIN
$ORC8R_IP host.nms.$DOMAIN
$ORC8R_IP fluentd.$DOMAIN
$ORC8R_IP controller.$DOMAIN
$ORC8R_IP bootstrapper-controller.$DOMAIN
EOT

    sudo cat <<EOT >> $MAGMA_DIR/configs/control_proxy.yml
cloud_address: controller.$DOMAIN
cloud_port: $ORC8R_SERVICE_PORT
bootstrap_address: bootstrapper-controller.$DOMAIN
bootstrap_port: $ORC8R_SERVICE_PORT
fluentd_address: fluentd.$DOMAIN
fluentd_port: $ORC8R_SERVICE_PORT

rootca_cert: /var/opt/magma/certs/rootCA.pem
EOT
    
    echo -e "\n\n############\t\tArquivos criados"
    cat $MAGMA_DIR/configs/control_proxy.yml
    cat /etc/hosts
    mv ~/rootCA.pem $MAGMA_DIR/certs/

    # Define the files in the /etc/magma folder

    sed -i 's/s1ap_ipv6_enabled: true/s1ap_ipv6_enabled: false/' $CONFIG_DIR/mme.yml
    sed -i 's/s1_ipv6_enabled: true/s1_ipv6_enabled: false/' $CONFIG_DIR/spgw.yml
    sed -i '/ipv6_solicitation/d' $CONFIG_DIR/pipelined.yml
    echo "sgi_management_iface_ip_addr: '$IP_ETH0'" >> $CONFIG_DIR/pipelined.yml

    # Perform additional corrections in the installation
    sudo sed -i 's/^\(.*\)APT::Periodic::Update-Package-Lists\(.*\)$/#\1APT::Periodic::Update-Package-Lists\2/' /etc/apt/apt.conf.d/20auto-upgrades
    sudo systemctl restart unattended-upgrades

    
}

installSmokePing() {
    apt install docker.io docker-compose speedtest-cli -y
    DIR=/root/smokeping/
    sudo mkdir -p $DIR
    sudo mkdir -p $DIR/config
    sudo mkdir -p $DIR/certs
    files_to_download=(
    "https://raw.githubusercontent.com/venko-networks/magma-galaxy/1.8.2/docker-compose.yml"
    "https://raw.githubusercontent.com/venko-networks/magma-galaxy/1.8.2/Targets"
    "https://raw.githubusercontent.com/venko-networks/magma-galaxy/1.8.2/Probes"
    )

    destination_paths=(
    "$DIR/docker-compose.yml"
    "$DIR/config/Targets"
    "$DIR/config/Probes"
    )

    for ((i = 0; i < ${#files_to_download[@]}; i++)); do
        curl -sL "${files_to_download[i]}" >> "${destination_paths[i]}"
    done
    systemctl stop docker
    sed "s/containerd.sock/containerd.sock --iptables=false/" -i /lib/systemd/system/docker.service
    sudo systemctl daemon-reload
    systemctl start docker
    cd /root/smokeping && docker-compose up -d
}

# Menu
echo -e "${GREEN}Escolha uma opção:${NC}"
echo -e "${GREEN}1. Configurar Magma (para novas instalações) ${NC}"
echo -e "${GREEN}2. Instalar SmokePing (para instalações onde o AGW já está configurado) ${NC}"
echo -e "${GREEN}3. Downgrade dos pacotes (bugs relacionados a pacotes quebrados) ${NC}"
read -p "$(echo -e ${CYAN}Digite o número da opção desejada: ${NC})" choice

case $choice in
    1)
        configureMagma
        installSmokePing   
        systemctl start magma@magmad
        exit 0
        ;;
    2)
        apt-mark unhold gcc-10-base liblsan0
        apt update
        apt --fix-broken install -y
	rm -rf /root/smokeping
        installSmokePing
        systemctl start magma@magmad
        exit 0
        ;;
    3)
        systemctl stop magma@*
        downgradePkts_
        systemctl start magma@magmad
        exit 0
        ;;
    *)
        echo "Opção inválida. Saindo."
        exit 1
        ;;
esac

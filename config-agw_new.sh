#!/usr/bin/env bash
set -e

configureMagma() {

    echo -e "\n\n############\t\tArquivos criados"
    cat $MAGMA_DIR/configs/control_proxy.yml
    cat /etc/hosts
    mv ~/rootCA.pem $MAGMA_DIR/certs

    # Define the files in the /etc/magma folder

    sed -i 's/s1ap_ipv6_enabled: true/s1ap_ipv6_enabled: false/' $CONFIG_DIR/mme.yml
    sed -i 's/s1_ipv6_enabled: true/s1_ipv6_enabled: false/' $CONFIG_DIR/spgw.yml
    sed -i '/ipv6_solicitation/d' $CONFIG_DIR/pipelined.yml
    echo "sgi_management_iface_ip_addr: '$IP_ETH0'" >> $CONFIG_DIR/pipelined.yml

    # Perform additional corrections in the installation

    cat <<EOT >> requirements.txt
    jsonschema==3.1.0
    Jinja2==3.0.3
    prometheus_client==0.3.1
    setuptools==49.6.0
EOT

    pip3 install -r requirements.txt

    wget https://ftp.debian.org/debian/pool/main/g/gcc-10/liblsan0_10.2.1-6_amd64.deb
    wget https://ftp.debian.org/debian/pool/main/g/gcc-10/gcc-10-base_10.2.1-6_amd64.deb 
    sudo dpkg -i gcc-10-base_10.2.1-6_amd64.deb liblsan0_10.2.1-6_amd64.deb
    apt-mark hold gcc-10-base
    apt-mark hold liblsan0

    sudo sed -i 's/^\(.*\)APT::Periodic::Update-Package-Lists\(.*\)$/#\1APT::Periodic::Update-Package-Lists\2/' /etc/apt/apt.conf.d/20auto-upgrades
    sudo systemctl restart unattended-upgrades

    systemctl start magma@magmad

    exit 0
}

installSmokePing() {
    apt install docker.io docker-compose -y
    DIR=/root/smokeping/
    sudo mkdir -p $DIR
    sudo mkdir -p $DIR/config
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


    exit 0
}

# Menu
echo "Escolha uma opção:"
echo "1. Configurar Magma"
echo "2. Instalar SmokePing"
read -p "Digite o número da opção desejada: " choice

case $choice in
    1)
        configureMagma
        installSmokePing
        ;;
    2)
        apt-mark unhold gcc-10-base liblsan0
        apt --fix-broken install -y
        installSmokePing
        wget https://ftp.debian.org/debian/pool/main/g/gcc-10/liblsan0_10.2.1-6_amd64.deb
        wget https://ftp.debian.org/debian/pool/main/g/gcc-10/gcc-10-base_10.2.1-6_amd64.deb
        sudo dpkg -i gcc-10-base_10.2.1-6_amd64.deb liblsan0_10.2.1-6_amd64.deb
        apt-mark hold gcc-10-base liblsan0
        cd /root/smokeping && docker-compose up -d
        ;;
    *)
        echo "Opção inválida. Saindo."
        exit 1
        ;;
esac

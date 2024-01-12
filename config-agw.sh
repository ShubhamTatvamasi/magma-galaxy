
#!/bin/bash

#Script para configuraçao do AGW
#Definir as variáveis abaixo para configuração:


MAGMA_DIR=/var/opt/magma/
read -rp "Insira o IP do Orc8r" ORC8R_IP
read -rp "Insira a portado Orc8r (Default 443)" -ei 443 ORC8R_SERVICE_PORT
read -rp "Insira o dominio a ser utilizado" DOMAIN
IP_ETH0=$(ip a s eth0 | awk '/inet/ {print $2}' | head -n 1)
CONFIG_DIR=/etc/magma


systemctl stop magma@*


apt install docker.io docker-compose -y
# Cria diretórios e arquivos necessários.

sudo mkdir -p $MAGMA_DIR/configs
sudo mkdir -p /root/smokeping
sudo mkdir -p /root/smokeping/config

# Cria os arquivos necessários
sudo cat <<EOT >> /etc/hosts
$ORC8R_IP api.$DOMAIN
$ORC8R_IP magma.nms.$DOMAIN
$ORC8R_IP host.nms.$DOMAIN
$ORC8R_IP fluentd.$DOMAIN
$ORC8R_IP controller.$DOMAIN
$ORC8R_IP bootstrapper-controller.$DOMAIN
EOT


sudo cat <<EOT >> /root/smokeping/docker-compose.yml
version: '3'

services:
  smokeping:
    image: linuxserver/smokeping
    container_name: smokeping
    restart: always
    environment:
      - PUID=0  # substitua pelo seu UID
      - PGID=0  # substitua pelo seu GID
      - TZ=America/Sao_Paulo  # substitua pelo seu fuso horário
    ports:
      - "80:80"
    volumes:
      - ./config:/config
EOT

sudo cat <<EOT >> /root/smokeping/config/Targets
*** Targets ***

probe = FPing

menu = Top
title = Network Latency Grapher
remark = Welcome to the SmokePing website of xxxxx.

+ Local
menu = Local
title = My Servers
++ localhost
menu = localhost
title = This host
host = localhost

+ External
menu = Radio
title = Radio
host = 10.0.2.100
EOT

sudo cat <<EOT >> /root/smokeping/config/Probes
*** Probes ***

+ FPing

binary = /usr/sbin/fping
step = 300
timeout = 15
pings = 20
EOT


# Insere as informações de configuração

sudo cat <<EOT >> $MAGMA_DIR/configs/control_proxy.yml
cloud_address: controller.$DOMAIN
cloud_port: $ORC8R_SERVICE_PORT
bootstrap_address: bootstrapper-controller.$DOMAIN
bootstrap_port: $ORC8R_SERVICE_PORT
fluentd_address: fluentd.$DOMAIN
fluentd_port: $ORC8R_SERVICE_PORT

rootca_cert: /var/opt/magma/certs/rootCA.pem
EOT


echo "\n\n############\t\tArquivos criados"
cat $MAGMA_DIR/configs/control_proxy.yml
cat /etc/hosts
mv ~/rootCA.pem $MAGMA_DIR/certs

#Define os arquivos da pasta /etc/magma

sed -i 's/s1ap_ipv6_enabled: true/s1ap_ipv6_enabled: false/' $CONFIG_DIR/mme.yml
sed -i 's/s1_ipv6_enabled: true/s1_ipv6_enabled: false/' $CONFIG_DIR/spgw.yml
sed -i '/ipv6_solicitation/d' $CONFIG_DIR/pipelined.yml
echo "sgi_management_iface_ip_addr: '$IP_ETH0'" >> $CONFIG_DIR/pipelined.yml


#Realiza algumas correções na instalação

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
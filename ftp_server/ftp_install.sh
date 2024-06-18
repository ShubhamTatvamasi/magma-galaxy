#!/usr/bin/env bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

download_files() {
	files_to_download=(
		"https://raw.githubusercontent.com/venko-networks/magma-galaxy/1.8.2/ftp_server/docker-compose.yml"
		"https://raw.githubusercontent.com/venko-networks/magma-galaxy/1.8.2/ftp_server/log_delete.sh"	
		"https://raw.githubusercontent.com/venko-networks/magma-galaxy/1.8.2/ftp_server/ftp_server.service"
		"https://raw.githubusercontent.com/venko-networks/magma-galaxy/1.8.2/ftp_server/log_delete.service"
		"https://raw.githubusercontent.com/venko-networks/magma-galaxy/1.8.2/ftp_server/log_delete.timer"
	)
	mkdir -p /home/magma/ftp_server/
	DIR=/home/magma
	destination_paths=(
		"$DIR/ftp_server/docker-compose.yml"
		"$DIR/ftp_server/log_delete.sh"
		"/etc/systemd/system/ftp_server.service"
		"/etc/systemd/system/log_delete.service"
		"/etc/systemd/system/log_delete.timer"
	)
	for ((i = 0; i < ${#files_to_download[@]}; i++)); do
		curl -sL "${files_to_download[i]}" >> "${destination_paths[i]}"
	done
	sudo systemctl daemon-reload
	sudo systemctl enable ftp_server.service
	sudo systemctl enable log_delete.service
	echo -e "${GREEN} Arquivos baixados com sucesso!! ${NC}"

}



echo -e "${GREEN}Baixando arquivos:${NC}"
download_files

sudo systemctl start ftp_server
sudo systemctl start log_delete

exit 0






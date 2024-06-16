#!/bin/bash

log_file="/home/magma/ftp-server/log_delete.log"

# Encontre os arquivos antigos e remova-os, registrando cada um no arquivo de log
find /home/magma/ftp-server/log/ -type f -mtime +30 -exec sh -c '
    rm "$1" &&
    echo "File $1 removed at $(date +"%Y-%m-%d %H:%M:%S")" >> "$2"
' sh {} "$log_file" \;
exit 0

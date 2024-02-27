#!/usr/bin/env bash

set -e
SUCCESS_MESSAGE="ok"
PACKAGE_LIST=("magma" "magma-cpp-redis" "magma-libfluid" "libopenvswitch" "openvswitch-datapath-dkms" "openvswitch-common" "openvswitch-switch")
MAGMA_DIRS=("/etc/magma" "/var/opt/magma")
INSTALLED_PKGS=()



for pkg in "${PACKAGE_LIST[@]}"; do
        PACKAGE_INSTALLED=$(dpkg-query -W -f='${Status}' "$pkg"  > /dev/null 2>&1 && echo "$SUCCESS_MESSAGE")
        if [ "$PACKAGE_INSTALLED" == "$SUCCESS_MESSAGE" ]; then
                INSTALLED_PKGS+=("$pkg")
        fi
done

magma_is_installed() {
        if [[ ${#INSTALLED_PKGS[@]} > 0 ]]; then
                return 0
        else
                return 1
        fi

}

remove_conf_files() {
        for dir in "${MAGMA_DIRS[@]}"; do
                rm -rf "$dir"
        done
}


remove_pkgs() {
        for pkg in "${INSTALLED_PKGS[@]}";do
                sudo apt remove "$pkg" -y
        done

}

if [[ magma_is_installed -eq 0 ]]; then
        echo "Removendo arquivos do magma"
        sleep 5
        remove_conf_files
        remove_pkgs
else
        echo "Magma is not installed"
        exit 1
fi

exit 0
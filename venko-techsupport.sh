#!/bin/bash

check_sudo() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "  ${RED}${BOLD}Error:${FUNCNAME[0]}:$LINENO:${RESET} This script requires root privileges."
        exit 1
    fi
}

GET_CONFIGURATION_FILE="/tmp/venko-techsupport.txt"

get_configuration() {
    if [[ ! -f "$GET_CONFIGURATION_FILE" ]]; then
      touch "$GET_CONFIGURATION_FILE"
    fi

    echo "Command: date" >> "$GET_CONFIGURATION_FILE"
    date >> "$GET_CONFIGURATION_FILE"
    echo -e "\n" >> "$GET_CONFIGURATION_FILE"

    echo "Command: uptime" >> "$GET_CONFIGURATION_FILE"
    uptime >> "$GET_CONFIGURATION_FILE"
    echo -e "\n" >> "$GET_CONFIGURATION_FILE"

    echo "Command: uname -a" >> "$GET_CONFIGURATION_FILE"
    uname -a >> "$GET_CONFIGURATION_FILE"
    echo -e "\n" >> "$GET_CONFIGURATION_FILE"

    echo "Command: top -b -n 1" >> "$GET_CONFIGURATION_FILE"
    top -b -n 1 >> "$GET_CONFIGURATION_FILE"
    echo -e "\n" >> "$GET_CONFIGURATION_FILE"

    exit 1
    echo "Command: pip3 freeze" >> "$GET_CONFIGURATION_FILE"
    pip3 freeze >> "$GET_CONFIGURATION_FILE"
    echo -e "\n" >> "$GET_CONFIGURATION_FILE"

    echo "Command: apt list --installed" >> "$GET_CONFIGURATION_FILE"
    apt list --installed >> "$GET_CONFIGURATION_FILE"
    echo -e "\n" >> "$GET_CONFIGURATION_FILE"

    echo "Command: df -kh" >> "$GET_CONFIGURATION_FILE"
    df -kh >> "$GET_CONFIGURATION_FILE"
    echo -e "\n" >> "$GET_CONFIGURATION_FILE"

    echo "Command: dpkg -l magma*" >> "$GET_CONFIGURATION_FILE"
    dpkg -l magma* >> "$GET_CONFIGURATION_FILE"
    echo -e "\n" >> "$GET_CONFIGURATION_FILE"

    echo "Command: dpkg -l *openvswitch*" >> "$GET_CONFIGURATION_FILE"
    dpkg -l *openvswitch* >> "$GET_CONFIGURATION_FILE"
    echo -e "\n" >> "$GET_CONFIGURATION_FILE"

    echo "Command: ovs-vsctl show" >> "$GET_CONFIGURATION_FILE"
    ovs-vsctl show >> "$GET_CONFIGURATION_FILE"
    echo -e "\n" >> "$GET_CONFIGURATION_FILE"

    echo "Command: ovs-ofctl show gtp_br0" >> "$GET_CONFIGURATION_FILE"
    ovs-ofctl show gtp_br0 >> "$GET_CONFIGURATION_FILE"
    echo -e "\n" >> "$GET_CONFIGURATION_FILE"

    echo "Command: ovs-ofctl dump-flows gtp_br0" >> "$GET_CONFIGURATION_FILE"
    ovs-ofctl dump-flows gtp_br0 >> "$GET_CONFIGURATION_FILE"
    echo -e "\n" >> "$GET_CONFIGURATION_FILE"

    echo "Command: apt show magma" >> "$GET_CONFIGURATION_FILE"
    apt show magma >> "$GET_CONFIGURATION_FILE"
    echo -e "\n" >> "$GET_CONFIGURATION_FILE"

    echo "Command: service magma@* status" >> "$GET_CONFIGURATION_FILE"
    service magma@* status >> "$GET_CONFIGURATION_FILE"
    echo -e "\n" >> "$GET_CONFIGURATION_FILE"

    echo "Command: service sctpd status" >> "$GET_CONFIGURATION_FILE"
    service sctpd status >> "$GET_CONFIGURATION_FILE"
    echo -e "\n" >> "$GET_CONFIGURATION_FILE"

    echo "Command: service openvswitch-switch status" >> "$GET_CONFIGURATION_FILE"
    service openvswitch-switch status >> "$GET_CONFIGURATION_FILE"
    echo -e "\n" >> "$GET_CONFIGURATION_FILE"

    echo "Command: show_gateway_info.py" >> "$GET_CONFIGURATION_FILE"
    show_gateway_info.py >> "$GET_CONFIGURATION_FILE"
    echo -e "\n" >> "$GET_CONFIGURATION_FILE"

    echo "Command: checkin_cli.py" >> "$GET_CONFIGURATION_FILE"
    checkin_cli.py >> "$GET_CONFIGURATION_FILE"
    echo -e "\n" >> "$GET_CONFIGURATION_FILE"

    echo "Command: mobility_cli.py get_subscriber_table" >> "$GET_CONFIGURATION_FILE"
    mobility_cli.py get_subscriber_table >> "$GET_CONFIGURATION_FILE"
    echo -e "\n" >> "$GET_CONFIGURATION_FILE"

    echo "Command: pipelined_cli.py debug display_flows" >> "$GET_CONFIGURATION_FILE"
    pipelined_cli.py debug display_flows >> "$GET_CONFIGURATION_FILE"
    echo -e "\n" >> "$GET_CONFIGURATION_FILE"

    echo "Command: enodebd_cli.py get_all_status" >> "$GET_CONFIGURATION_FILE"
    enodebd_cli.py get_all_status >> "$GET_CONFIGURATION_FILE"
    echo -e "\n" >> "$GET_CONFIGURATION_FILE"

    echo "Command: ip addr" >> "$GET_CONFIGURATION_FILE"
    ip addr >> "$GET_CONFIGURATION_FILE"
    echo -e "\n" >> "$GET_CONFIGURATION_FILE"

    echo "Command: ping google.com -I eth0 -c 5" >> "$GET_CONFIGURATION_FILE"
    ping google.com -I eth0 -c 5 >> "$GET_CONFIGURATION_FILE"
    echo -e "\n" >> "$GET_CONFIGURATION_FILE"

    echo "Command: ip route" >> "$GET_CONFIGURATION_FILE"
    ip route >> "$GET_CONFIGURATION_FILE"
    echo -e "\n" >> "$GET_CONFIGURATION_FILE"

    echo "Command: iptables -L" >> "$GET_CONFIGURATION_FILE"
    iptables -L >> "$GET_CONFIGURATION_FILE"
    echo -e "\n" >> "$GET_CONFIGURATION_FILE"

    echo "Command: iptables -L -v -n" >> "$GET_CONFIGURATION_FILE"
    iptables -L -v -n >> "$GET_CONFIGURATION_FILE"
    echo -e "\n" >> "$GET_CONFIGURATION_FILE"

    echo "Command: iptables -t nat -L -v -n" >> "$GET_CONFIGURATION_FILE"
    iptables -t nat -L -v -n >> "$GET_CONFIGURATION_FILE"
    echo -e "\n" >> "$GET_CONFIGURATION_FILE"

    echo "Command: iptables -t mangle -L -v -n" >> "$GET_CONFIGURATION_FILE"
    iptables -t mangle -L -v -n >> "$GET_CONFIGURATION_FILE"
    echo -e "\n" >> "$GET_CONFIGURATION_FILE"

    echo "Command: iptables -t raw -L -v -n" >> "$GET_CONFIGURATION_FILE"
    iptables -t raw -L -v -n >> "$GET_CONFIGURATION_FILE"
    echo -e "\n" >> "$GET_CONFIGURATION_FILE"

    echo "Command: iptables -t security -L -v -n" >> "$GET_CONFIGURATION_FILE"
    iptables -t security -L -v -n >> "$GET_CONFIGURATION_FILE"
    echo -e "\n" >> "$GET_CONFIGURATION_FILE"
}

check_sudo
get_configuration

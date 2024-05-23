#!/bin/bash

tcpdump -eni eth0 -w eth0.pcap &
tcpdump -eni eth1 -w eth1.pcap &
tcpdump -eni gtpu_sys_2152 -w gtpu.pcap &
tcpdump -eni gtp_br0 -Q in -w gtp_in.pcap &
tcpdump -eni gtp_br0 -Q out -w gtp_out.pcap &

sleep 60
pkill -3 tcpdump
exit 0


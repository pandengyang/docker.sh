#!/bin/bash

mkdir -p /var/run/netns

ip link show dockersh0
if test $? != 0; then
	ip link add name dockersh0 type bridge
	ip address add 172.31.0.1/24 dev dockersh0
	ip link set dockersh0 up
fi

ip link show dockersh1
if test $? != 0; then
	ip link add name dockersh1 type bridge
	ip address add 172.31.1.1/24 dev dockersh1
	ip link set dockersh1 up
fi

iptables -t nat -n -v -L POSTROUTING | grep dockersh0
if test $? != 0; then
	echo 1 > /proc/sys/net/ipv4/ip_forward
	iptables -t nat -I POSTROUTING 1 -s 172.31.0.1/24 ! -o dockersh0 -j MASQUERADE
	iptables -t nat -I POSTROUTING 2 -s 172.31.1.1/24 ! -o dockersh1 -j MASQUERADE

	iptables -t filter -N DOCKERSH-ISOLATION-STAGE-1
	iptables -t filter -N DOCKERSH-ISOLATION-STAGE-2

	iptables -t filter -I DOCKERSH-ISOLATION-STAGE-1 1 -i dockersh0 ! -o dockersh0 -j DOCKERSH-ISOLATION-STAGE-2
	iptables -t filter -I DOCKERSH-ISOLATION-STAGE-1 2 -i dockersh1 ! -o dockersh1 -j DOCKERSH-ISOLATION-STAGE-2
	iptables -t filter -I DOCKERSH-ISOLATION-STAGE-1 3 -j RETURN

	iptables -t filter -I DOCKERSH-ISOLATION-STAGE-2 1 -o dockersh0 -j DROP
	iptables -t filter -I DOCKERSH-ISOLATION-STAGE-2 2 -o dockersh1 -j DROP
	iptables -t filter -I DOCKERSH-ISOLATION-STAGE-2 3 -j RETURN

	iptables -t filter -I FORWARD 1 -j DOCKERSH-ISOLATION-STAGE-1
fi


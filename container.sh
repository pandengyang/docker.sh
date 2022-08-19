#!/bin/bash

hostname $container

mkdir -p /sys/fs/cgroup/memory/$container
echo $$ > /sys/fs/cgroup/memory/$container/cgroup.procs
echo $memory > /sys/fs/cgroup/memory/$container/memory.limit_in_bytes

mkdir -p $container/rwlayer
mount -t aufs -o dirs=$container/rwlayer:./images/$image none $container

mkdir -p $container/old_root
cd $container
pivot_root . ./old_root

mount -t proc proc /proc
umount -l /old_root

if test "$network" = bridge; then
	while true
	do
		ip link show veth1-$container
		if test $? != 0; then
			sleep 1
		else
			break
		fi
	done

	ip addr add $addr/24 dev veth1-$container
	ip link set dev veth1-$container up
	ip route add default via 172.31.0.1 dev veth1-$container
fi

exec $program

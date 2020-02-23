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

exec $program

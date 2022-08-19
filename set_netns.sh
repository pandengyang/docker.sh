#!/bin/bash

while true
do
	ip netns exec $2 true
	if test $? = 0; then
		ip link set dev $1 netns $2

		break
	else
		sleep 1
	fi
done

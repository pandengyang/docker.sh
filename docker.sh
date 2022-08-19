#!/bin/bash


usage () {
	echo -e "\033[31mIMPORTANT: Run As Root\033[0m"
	echo ""
	echo "Usage:	docker.sh [OPTIONS]"
	echo ""
	echo "A docker written by shell"
	echo ""
	echo "Options:"
	echo "		-c string	docker command"
	echo "				(\"run\")"
	echo "		-m		memory"
	echo "				(\"100M, 200M, 300M...\")"
	echo "		-C string	container name"
	echo "		-I string	image name"
	echo "		-V string	volume"
	echo "		-P string	program to run in container"
	echo "		-n string	network"

	return 0
}

if test "$(whoami)" != root
then
	usage
	exit -1
fi

while getopts c:m:C:I:V:P:n: option
do
	case "$option"
	in
		c) cmd=$OPTARG;;
		m) memory=$OPTARG;;
		C) container=$OPTARG;;
		I) image=$OPTARG;;
		V) volume=$OPTARG;;
		P) program=$OPTARG;;
		n) network=$OPTARG;;
		\?) usage
		    exit -2;;
	esac
done

export cmd=$cmd
export memory=$memory
export container=$container
export image=$image
export volume=$volume
export network=$network
export program=$program

if test "$network" = host; then
	unshare --uts --mount --pid --fork ./container.sh

elif test "$network" = none; then
	if [ -e /var/run/netns/$container ]; then
		echo Abort: netns $container exists
		exit -1
	fi

	touch /var/run/netns/$container
	unshare --uts --mount --pid --net=/var/run/netns/$container --fork ./container.sh

elif test "$network" = bridge; then
	if [ -e /var/run/netns/$container ]; then
		echo Abort: netns $container exists
		exit -1
	fi

	touch /var/run/netns/$container

	ip link add veth1-$container type veth peer name veth2-$container
	ip link set dev veth2-$container master dockersh0
	ip link set dev veth2-$container up

	./set_netns.sh veth1-$container $container &

	addr=unknown
	for i in {2..254}
	do
		ping -c 3 172.31.0.$i;

		if test $? != 0; then
			export addr=172.31.0.$i

			break
		fi
	done

	unshare --uts --mount --pid --net=/var/run/netns/$container --fork ./container.sh

fi

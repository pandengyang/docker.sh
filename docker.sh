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

	return 0
}

if test "$(whoami)" != root
then
	usage
	exit -1
fi

while getopts c:m:C:I:V:P: option
do
	case "$option"
	in
		c) cmd=$OPTARG;;
		m) memory=$OPTARG;;
		C) container=$OPTARG;;
		I) image=$OPTARG;;
		V) volume=$OPTARG;;
		P) program=$OPTARG;;
		\?) usage
		    exit -2;;
	esac
done

export cmd=$cmd
export memory=$memory
export container=$container
export image=$image
export volume=$volume
export program=$program

unshare --uts --mount --pid --fork ./container.sh

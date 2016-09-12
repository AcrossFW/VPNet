#!/bin/sh
#
# VPNet.io - Virtual Private Network Essential Toolbox
#
# https://github.com/acrossfw/vpnet
#
IMAGE="vpnet"

[ "$1" = "build" -o "$1" = "" ] && {
	docker build -t $IMAGE .
	[ "$?" = 0 ] && {
		echo '############################################'
		echo "Build succeed for image $IMAGE"
		echo '############################################'
	}
	exit
}

exec docker run -ti --rm --privileged $IMAGE $@
exit $?
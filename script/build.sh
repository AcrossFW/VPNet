#!/bin/sh
#
# VPNet.io - Virtual Private Network Essential Toolbox
#
# https://github.com/acrossfw/vpnet
#
IMAGE="vpnet"

[ "$1" = "build" -o "$1" = "" ] && {
	docker build -t $IMAGE .
	ERR_CODE=$?
	[ "$ERR_CODE" = 0 ] && {
		echo '############################################'
		echo "Build succeed for image $IMAGE"
		echo '############################################'
		exit
	}
	echo '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
	echo "ERROR: Build FAIL with exit code $ERR_CODE"
	echo '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
	exit $ERR_CODE
}

[ "$1" = "run" ] && {
	exec docker run -ti --rm --privileged --net=host \
  		-p 1723:1723 \
  		-p 2222:2222 \
  		-p 3128:3128 \
  		-p 8388:8388 \
  		$IMAGE
	exit $?
}

[ "$1" = "ssh" ] && {
	exec ssh -p 2222 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@localhost
	exit $?
}

exec docker run -ti --rm --privileged $IMAGE $@
exit $?

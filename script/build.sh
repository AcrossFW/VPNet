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

NET_MODE=host
[ "$1" = "run" ] && {
	exec docker run -ti --rm --privileged --net=$NET_MODE \
  		-p   22:2222 \
  		-p 1723:1723 \
  		-p 3128:3128 \
  		-p 8388:8388 \
  		$IMAGE
	exit $?
}

[ "$1" = "ssh" ] && {
	[ "$NET_MODE" = "host" ] 	&& HOST=localhost
	[ "$NET_MODE" = "bridge" ] && HOST=$(docker ps | grep vpnet | awk '{print $1}' | xargs docker inspect | grep IPAddress | grep 172 | awk -F\" '{print $4}' | head -1)
	echo "SSHing to $HOST in $NET_MODE mode ... "
	exec ssh -q -p 2222 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "root@$HOST"
	exit $?
}

exec docker run -ti --rm --privileged $IMAGE $@
exit $?

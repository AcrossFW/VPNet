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

[ "$1" = "run" ] && {
	exec docker run -ti --rm --privileged --net=host \
  		-p 22:22 \
  		-p 1723:1723 \
  		-p 3128:3128 \
  		-p 8388:8388 \
  		$IMAGE
	exit $?
}

exec docker run -ti --rm --privileged $IMAGE $@
exit $?

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
		echo
		echo '############################################'
		echo "Build succeed for image $IMAGE"
		echo '############################################'
		echo
		exit
	}
	echo '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
	echo "ERROR: Build FAIL with exit code $ERR_CODE"
	echo '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
	exit $ERR_CODE
}

NET_MODE=bridge
[ "$1" = "run" ] && {
	# http://stackoverflow.com/a/1655389/1123955
	read -r docker_run<<-CMD
		docker run -ti --rm --privileged --net=$NET_MODE \
  		-p 2222:22 \
  		-p 1723:1723 \
  		-p 3128:3128 \
  		-p 8388:8388 \
  		$IMAGE
CMD
	echo
	echo $docker_run
	exec $docker_run

	err_code=$?
	echo "ERROR: exec docker fail with error code $err_code"
	exit $err_code
}

[ "$1" = "ssh" ] && {
	[ "$NET_MODE" = "host" ] 		&& PORT=2222	&& HOST=localhost
	[ "$NET_MODE" = "bridge" ]	&& PORT=22		&& HOST=$(docker ps | grep vpnet | awk '{print $1}' | xargs docker inspect | grep IPAddress | grep 172 | awk -F\" '{print $4}' | head -1)
	
	echo "SSHing to $HOST:$PORT in $NET_MODE mode ... "
	read -r ssh_run<<-CMD
		ssh -p $PORT -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$HOST
CMD
	echo
	echo $ssh_run
	echo
	exec $ssh_run
	
	err_code=$?
	echo "ERROR: exec ssh fail with error code $err_code"
	exit $err_code
}

exec docker run -ti --rm --privileged $IMAGE $@
exit $?

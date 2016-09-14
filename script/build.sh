#!/bin/sh
#
# VPNet.io - Virtual Private Network Essential Toolbox
#
# https://github.com/acrossfw/vpnet
#
docker_image="vpnet"
net_mode=bridge

arg1=${1:-build}

case "$arg1" in
	build|'')
		docker build -t $docker_image .
		err_code=$?
		if [ "$err_code" = 0 ]; then
			echo
			echo
			echo
			echo '############################################'
			echo "Build succeed for docker_image $docker_image"
			echo '############################################'
			echo
			echo
			echo
			exit
		else
			echo
			echo
			echo
			echo '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
			echo "ERROR: Build FAIL with exit code $err_code"
			echo '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
			echo
			echo
			echo
		fi
		
		exit $err_code
		;;

	run)
		# http://stackoverflow.com/a/1655389/1123955
		read -r docker_run<<-CMD
			docker run -ti --rm --privileged --net=$net_mode \
	  		-p 2222:22 \
	  		-p 1723:1723 \
	  		-p 3128:3128 \
	  		-p 8388:8388 \
	  		$docker_image
CMD
		echo
		echo "$docker_run"
		exec "$docker_run"
		echo "ERROR: exec docker fail with error code $"
		exit -1
		;;

	exec)
		container_id=$(docker ps | grep vpnet | awk '{print $1}' | head -1)
		read -r docker_exec<<-CMD
			docker exec -ti $container_id /bin/bash
CMD
		echo
		echo "$docker_exec"
		echo
		exec "$docker_exec"
		echo "ERROR: exec docker fail: $?"
		exit -1
		;;
		
	ssh)
		[ "$net_mode" = "host" ] 		&& ssh_port=2222	&& ssh_host=localhost
		[ "$net_mode" = "bridge" ]	&& ssh_port=22		&& ssh_host=$(docker ps | grep vpnet | awk '{print $1}' | xargs docker inspect | grep IPAddress | grep 172 | awk -F\" '{print $4}' | head -1)
		
		echo "SSHing to $ssh_host:$ssh_port in $net_mode mode ... "
		read -r ssh_run<<-CMD
			ssh -p $ssh_port -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@${ssh_host}
CMD
		echo
		echo "$ssh_run"
		echo
		exec "$ssh_run"
		echo "ERROR: exec ssh fail with error code $?"
		exit -1
		;;
	
	lint)
		local ret_code
		for file in $(find . -type f -name "*.sh" -o -name "run"); do
			shellcheck --exclude SC2093,SC2078 "$file" || $ret_code=$?
			bash -n "$file" || $ret_code=$?
		done
		exit $ret_code
		;;
		
	*)
		exec docker run --name vpnet -ti --rm --privileged $docker_image "$@"
		echo "ERROR: exec docker fail with error code $?"
		exit -1
esac

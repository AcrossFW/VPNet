#!/usr/bin/env bash
#
# VPNet.io - Virtual Private Network Essential Toolbox
#
# https://github.com/acrossfw/vpnet
#
# Build Tool
#
source "/acrossfw/vpnet-functions.sh"
vpnet::init_bash "${BASH_SOURCE[0]}" # set all the magic

main() {
  local arg1=${1:-build}

  local docker_image='vpnet'
  local net_mode='bridge'

  case "$arg1" in
    build|'')
      builder::lint
      builder::build "$docker_image"						|| echo "ERROR: builder::build FAIL"
      ;;

    run)
      builder::run "$docker_image" "$net_mode"	|| echo "ERROR: builder::run FAIL"
      ;;

    exec)
      builder::exec "$docker_image" 						|| echo "ERROR: builder::exec FAIL"
      ;;

    ssh)
      builder::ssh "$docker_image" "$net_mode"	|| echo "ERROR: builder::ssh FAIL"
      ;;

    test)
      builder::test $docker_image								|| echo "ERROR: builder::test FAIL"
      ;;

    lint)
      builder::lint 														|| echo "ERROR: builder::lint FAIL"
      ;;

    *)
      docker_run_cmd="docker run --name vpnet -ti --rm --privileged $docker_image $*"

      echo
      echo "$docker_run_cmd"
      echo

      $docker_run_cmd 													|| echo "ERROR: docker run fail with error code $?"
      ;;
  esac

  exit
}

builder::build() {
  local docker_image=$1

  docker build -t "$docker_image" . || {
    echo
    echo
    echo
    echo '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    echo "ERROR: Build FAIL with exit code $?"
    echo '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    echo
    echo
    echo
    return -1
  }

  echo
  echo
  echo
  echo '############################################'
  echo "Build succeed for docker_image $docker_image"
  echo '############################################'
  echo
  echo
  echo

  return 0
}

builder::run() {
  local docker_image=$1
  local net_mode=$2

  # http://stackoverflow.com/a/1655389/1123955
  read -r docker_run<<-CMD
    docker run -ti --rm --privileged --net=$net_mode \
      -p 1723:1723 \
      -p 2222:10022 \
      -p 3128:13128 \
      -p 8388:18388 \
      $docker_image
CMD
  echo
  echo "$docker_run"

  $docker_run || {
    echo "ERROR: docker run fail with error code $?"
    return -1
  }

  return 0
}

builder::exec() {
  local docker_image=$1

  local container_id

  container_id=$(docker ps | grep vpnet | awk '{print $1}' | head -1)
  docker_exec="docker exec -ti $container_id /bin/bash"

  echo
  echo "$docker_exec"
  echo

  $docker_exec || {
    echo "ERROR: docker exec fail: $?"
    return -1
  }
  return 0
}

builder::test() {
  local docker_image=$1

  local docker_run_cmd="docker run -ti --rm --privileged $docker_image test"

  echo
  echo "$docker_run_cmd"
  echo

  $docker_run_cmd || {
    echo "ERROR: docker run test fail with error code $?"
    return -1
  }

  return 0
}

builder::ssh() {
  local docker_image=$1
  local net_mode=$2

  local ssh_host
  local ssh_port

  ssh_port=10022

  case "$net_mode" in
    host)
      ssh_host='localhost'
      ;;
    bridge|*)
      ssh_host=$(docker ps | grep vpnet | awk '{print $1}' | xargs docker inspect | grep IPAddress | grep 172 | awk -F\" '{print $4}' | head -1)
      ;;
  esac

  echo "SSHing to $ssh_host:$ssh_port in $net_mode mode ... "
  ssh_cmd="ssh -p $ssh_port -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@${ssh_host}"

  echo
  echo "$ssh_cmd"
  echo

  $ssh_cmd || {
    echo "ERROR: exec ssh fail with error code $?"
    return -1
  }
  return 0
}

builder::lint() {
  local ret_code
  local file_list
  local file

  ret_code=0
  file_list=$(find . -type f -name "*.sh" -o -name "run")
  for file in $file_list; do
    [[ "$file" =~ node_modules ]] && continue
    shellcheck "$file" || ret_code=$?
    bash -n "$file" || ret_code=$?
  done

  if [[ "$ret_code" = 0 ]]; then
    echo
    echo "Linting PASS"
    echo
  fi

  return $ret_code
}

main "$@"

#!/usr/bin/env bash
#
# VPNet.io - Virtual Private Network Essential Toolbox
#
# https://github.com/acrossfw/vpnet
#

source /acrossfw/vpnet-module.sh
vpnet::init_bash "${BASH_SOURCE[0]}" # set all the magic

main() {
  local arg1=${1:-}
  
  echo
  echo "Starting VPNet Docker ..."
  echo
  
  vpnet::check_env
  
  vpnet::init_system
  vpnet::init_network
  # vpnet::init_service
  
  case "$arg1" in
    start)
      # Use baseimage-docker's init system.
      # CMD ["/sbin/my_init"]
      echo -n "Getting my IP... "
      curl -sS ifconfig.io
      
      exec my_init
      
      err_code=$?
      echo "ERROR: my_init exit with error code $err_code"
      sleep 1
      exit $err_code
      ;;
    test)
      bats __root/test/*.bats
      if [ $? -eq 0 ]; then
        echo "Test PASS"
      else
        echo "ERROR: Test FAIL"
      fi
      exit -1
      ;;
    bash|sh|shell)
      echo "Creating shell..."
      exec /bin/bash -s
      exit $?
      ;;
    *)
      echo "ERROR: Unsupport arg $arg1"
      exit -1
      ;;
  esac

  echo "ERROR: Should not run to here!"
  exit -1
}

main "$@"

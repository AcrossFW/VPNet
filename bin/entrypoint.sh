#!/usr/bin/env bash
#
# VPNet.io - Virtual Private Network Essential Toolbox
#
# https://github.com/acrossfw/vpnet
#

# shellcheck disable=SC1090
source "$ACROSSFW_HOME/vpnet-functions.sh"
vpnet::init_bash "${BASH_SOURCE[0]}" # set all the magic

declare __root

main() {
  local arg1=${1:-}

  vpnet::init_env_var

  echo
  echo "Starting VPNet Docker v$(head -1 "${__root}/VERSION") #${VERSION_HASH}"
  echo
  echo "  https://github.com/acrossfw/vpnet"
  echo
  echo "  "
  echo "  Build by $BUILD_HOST($BUILD_IP) on $BUILD_DATE"
  echo "  Run as $(hostname -f) with IP $WANIP"
  echo

  vpnet::check_env

  vpnet::init_system
  vpnet::init_network
  # vpnet::init_service

  case "$arg1" in
    start)
      # Use baseimage-docker's init system.
      # CMD ["/sbin/my_init"]

      exec my_init

      err_code=$?
      echo "ERROR: my_init exit with error code $err_code"
      sleep 1
      exit $err_code
      ;;

    test)
      bats_cmd="bats ${__root}/test/*.bats"

      echo
      echo "Start testing ... "
      echo

      if ! $bats_cmd && (cd service/vpnet && npm test && cd -); then
        echo
        echo "ERROR: Test FAIL"
        echo

        exit -1
      fi

      echo
      echo "Test PASS"
      echo

      exit 0
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

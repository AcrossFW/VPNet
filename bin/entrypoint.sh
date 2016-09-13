#!/usr/bin/env bash
#
# VPNet.io - Virtual Private Network Essential Toolbox
#
# https://github.com/acrossfw/vpnet
#

source /acrossfw/vpnet-module.sh
vpnet::init_bash ${BASH_SOURCE[0]} # set all the magic

main() {
  local arg1=$1
  
  echo
  echo "Starting VPNet Docker ..."
  echo
  
  vpnet::check_env
  
  vpnet::init_system
  vpnet::init_network
  # vpnet::init_service
  
  vpnet::run "${arg1}"
}

main "$@"

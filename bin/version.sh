#!/usr/bin/env bash
#
# VPNet.io - Virtual Private Network Essential Toolbox
#
# https://github.com/acrossfw/vpnet
#
# CLI version.sh
#

# shellcheck disable=SC1091
source "/acrossfw/vpnet-functions.sh"
vpnet::init_bash "${BASH_SOURCE[0]}" # set all the magic
declare __root

main() {
  local arg1=${1:-''}

  local version
  local hash

  case $arg1 in
    hash)
      hash=$(head -1 .git/logs/HEAD | awk '{print $2}')
      echo "${hash:0:7}"
      ;;

    *)
      version=$(head -1 "${__root}/VERSION")
      echo "$version"
      ;;
  esac
}

main "$@"

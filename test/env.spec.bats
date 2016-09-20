#!/usr/bin/env bats
#
# VPNet.io - Virtual Private Network Essential Toolbox
#
# https://github.com/acrossfw/vpnet
#
# Unit Test by BATS/TAP
#
source /acrossfw/vpnet-functions.sh
vpnet::init_bash ${BASH_SOURCE[0]} # set all the magic
#set +o errexit
#set +o pipefail
set +o nounset # bats need this to run correctly

@test "Docker ENV Variables should be set" {
  [[ -d "$ACROSSFW_HOME" ]]
  
  [[ "$ADMIN_NAME" ]]
  [[ "$ADMIN_PASS" ]]
  [[ "$DNS" ]]
}

@test "Docker ENV Variables of PORT_XXX should be valid" {
  [[ "$PORT_SSH"          =~ ^-?[0-9]+$ ]] #   22
  [[ "$PORT_OPENVPN"      =~ ^-?[0-9]+$ ]] # 1194
  [[ "$PORT_SQUID"        =~ ^-?[0-9]+$ ]] # 3128
  [[ "$PORT_SHADOWSOCKS"  =~ ^-?[0-9]+$ ]] # 8388
}

@test "Build ENV Variables should be set" {
  [[ -f "${__root}/ENV.build" ]]
  source "${__root}/ENV.build"
  
  [[ "$BUILD_DATE" ]]
  [[ "$BUILD_HOST" ]]
  [[ "$BUILD_IP" ]]
  [[ "$VERSION_HASH" ]]
}

@test "Dynamic ENV Variables should be set" {
  [[ "$WANIP" ]]
}
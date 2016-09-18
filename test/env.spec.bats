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

@test "Docker ENV Variables" {
  [[ -d "$ACROSSFW_HOME" ]]
  
  [[ "$ADMIN_NAME" ]]
  [[ "$ADMIN_PASS" ]]
  [[ "$DNS" ]]
  
  [[ "$PORT_SSH"          =~ ^-?[0-9]+$ ]]
  [[ "$PORT_SQUID"        =~ ^-?[0-9]+$ ]]
  [[ "$PORT_SHADOWSOCKS"  =~ ^-?[0-9]+$ ]]
  [[ "$PORT_OPENVPN"      =~ ^-?[0-9]+$ ]]
}

@test "Build ENV Variables" {
  [[ -f "${__root}/ENV.build" ]]
  source "${__root}/ENV.build"
  
  [[ "$BUILD_DATE" ]]
  [[ "$BUILD_HOST" ]]
  [[ "$BUILD_IP" ]]
  [[ "$VERSION_HASH" ]]
}

@test "Dynamic ENV Variables" {
  [[ "$WANIP" ]]
}
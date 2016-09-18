#!/usr/bin/env bats
#
# VPNet.io - Virtual Private Network Essential Toolbox
#
# https://github.com/acrossfw/vpnet
#
# Unit Test by BATS/TAP
#
source "$ACROSSFW_HOME/vpnet-functions.sh"
vpnet::init_bash ${BASH_SOURCE[0]} # set all the magic
#set +o errexit
#set +o pipefail
set +o nounset # bats need this to run correctly

@test "vpnet::init_bash magic" {
  [[ ${__dir} ]]
  [[ ${__file} ]]
  [[ ${__base} ]]
  [[ ${__root} ]]
}

@test "vpnet::get_user_home with 1 args" {
  local path=$(vpnet::get_user_home root)
  [[ "$path" = "/root" ]]

  local error_code
  path=$(vpnet::get_user_home _not_exist_user_) || error_code=$?
  [[ $error_code != 0 ]]
  [[ "$path" =~ ^~ ]]
}

@test "vpnet::get_user_home with 2 args" {
  vpnet::get_user_home root path
  [[ "$path" = "/root" ]]

  local err_code    
  vpnet::get_user_home _not_exist_user_ path || error_code=$?
  [[ $err_code != 0 ]]
  [[ "$path" =~ ^~ ]]
}

@test "vpnet::get_user_home with <1 || >2 args" {
  local err_code
  local empty=$(vpnet::get_user_home) || err_code=$?
  [[ $err_code != 0 ]]
  [[ -z "$empty" ]]

  local empty=$(vpnet::get_user_home 1 2 3) || err_code=$?
  [[ $err_code != 0 ]]
  [[ -z "$empty" ]]
}

@test "vpnet::set_var_value" {
  local resultvar="xxx"
  local expected_value="expected"
  vpnet::set_var_value "resultvar" "$expected_value"
  
  [[ "$resultvar" = "$expected_value" ]]
}
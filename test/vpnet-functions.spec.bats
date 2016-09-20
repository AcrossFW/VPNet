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

@test "vpnet::init_bash magic should all be set" {
  [[ ${__dir} ]]
  [[ ${__file} ]]
  [[ ${__base} ]]
  [[ ${__root} ]]
}

@test "vpnet::get_user_home with 1 args should echo result to stdout" {
  local path=$(vpnet::get_user_home root)
  [[ "$path" = "/root" ]]

  local error_code
  path=$(vpnet::get_user_home _not_exist_user_) || error_code=$?
  [[ $error_code != 0 ]]
  [[ "$path" =~ ^~ ]]
}

@test "vpnet::get_user_home with 2 args should use the second value as var name of return value" {
  vpnet::get_user_home root user_home
  [[ "$user_home" = "/root" ]]

  local err_code    
  vpnet::get_user_home not_exist_user user_home || error_code=$?
  [[ $err_code != 0 ]]
  [[ "$user_home" =~ ^~ ]]
}

@test "vpnet::get_user_home with <1 || >2 args should return error, and without any stdout output" {
  local err_code
  local empty=$(vpnet::get_user_home) || err_code=$?
  [[ $err_code != 0 ]]
  [[ -z "$empty" ]]

  local empty=$(vpnet::get_user_home 1 2 3) || err_code=$?
  [[ $err_code != 0 ]]
  [[ -z "$empty" ]]
}

@test "vpnet::set_var_value should set var value right" {
  local resultvar="xxx"
  local expected_value="expected"
  vpnet::set_var_value "resultvar" "$expected_value"
  
  [[ "$resultvar" = "$expected_value" ]]
}

@test "vpnet::log should log to stderr" {
  local output
  output=$(vpnet::log test)
  [[ -z "$output" ]]
  
  output=$(vpnet::log test 2>&1)
  [[ -n "$output" ]]
}
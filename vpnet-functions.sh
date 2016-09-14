#!/usr/bin/env bash
#
# VPNet - Virtual Private Network Essential Toolbox
#
# https://github.com/acrossfw/vpnet
#

vpnet::init_bash() {
  #
  # Bash3 Boilerplate. Copyright (c) 2014, kvz.io
  # http://kvz.io/blog/2013/11/21/bash-best-practices/
  #
  set -o errexit
  set -o pipefail
  set -o nounset
  # set -o xtrace

  local source=$1
  if [[ -z "$source" ]]; then
    echo "ERROR: vpnet::init_bash must have BASH_SOURCE[0] as arg1"
    return -1
  fi

  # Set magic variables for current file & dir
  declare -gx __dir="$(cd "$(dirname "$source}")" && pwd)"
  declare -gx __file="${__dir}/$(basename "${source}")"
  declare -gx __base="$(basename "${__file}" .sh)"
  declare -gx __root="${ACROSSFW_HOME:-/acrossfw}" # "$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app
}

vpnet::init_config() {
  config_file=$1
  [[ "$config_file" =~ ^/ ]] || {
    echo "ERROR: vpnet::init_config need absolute filename start with '/'"
    return -1
  }
  
  template_file="${__dir}/root${config_file}"
  [ -f "$template_file" ] || {
    echo "ERROR: vpnet::init_config cant find '$template_file'! must run in 'service/SRV/run'"
    return -1
  }
  
  vpnet::is_docker || {
    echo "ERROR: vpnet::init_config can only run inside docker(or it will overwrite root filesystem)"
    exit -1
  }
  
  echo "vpnet::init_config initing $config_file from $template_file ..."
  # Templating with Linux in a Shell Script
  # http://serverfault.com/a/699377/276381
  template="$(cat "${template_file}")"
  eval "echo \"${template}\"" > "$config_file"
}
 
vpnet::is_docker() {
  # XXX simulate docker for test
  # return 0
  
  # http://stackoverflow.com/a/20012536/1123955
  if [[ $(head -1 /proc/1/cgroup) =~ /$ ]]; then
    # end with '/', should be the host
    return -1
  else
    # end with container string, should insdie docker
    return 0
  fi
}

vpnet::check_env() {
  [[ "$(id -u)" = 0 ]] || {
    echo "ERROR: must run as root"
    return -1
  }
}

#
# System & Networking Initialization
#
vpnet::init_system() {
  echo "Setting hostname to $HOSTNAME ..."
  # XXX: this will not work in --net=host mode
  # https://github.com/docker/docker/issues/5708
  hostname "$HOSTNAME"
  
  echo "Disabling coredump ..."
  sysctl fs.suid_dumpable=0 
  ulimit -S -c 0 
  echo "* hard core 0" >> /etc/security/limits.conf
}

vpnet::init_network() {
  echo "Setting ip forwarding to 1 ..."
  sysctl net.ipv4.ip_forward=1
  sysctl net.ipv4.conf.all.forwarding=1
  sysctl net.ipv6.conf.all.forwarding=1
  sysctl net.ipv6.conf.all.proxy_ndp=1
  echo 1 > /proc/sys/net/ipv4/route/flush
  
  # XXX does there always be `eth0` in docker ???
  echo "Setting network filter ..."
  iptables -t nat -A POSTROUTING -s 10.0.0.0/8      -o eth0 -j MASQUERADE
  iptables -t nat -A POSTROUTING -s 172.16.0.0/12   -o eth0 -j MASQUERADE
  iptables -t nat -A POSTROUTING -s 192.168.0.0/16  -o eth0 -j MASQUERADE
  
  # ip6tables -t nat -A POSTROUTING -s 2a00:1450:400c:c05::/64 -o eth0 -j MASQUERADE

  # XXX no need ? iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
}

vpnet::get_user_home() {
  local __user_name=$1
  local __resultvar=${2:-''}

  local __user_home
  
  case "${#@}" in
    1)
      __user_home=$(eval echo ~"${__user_name}")
      echo "$__user_home"
      ;;
    2)
      # http://www.linuxjournal.com/content/return-values-bash-functions
      __user_home=$(eval echo ~"${__user_name}")

      # declare global variable http://stackoverflow.com/q/9871458/1123955
      eval "$__resultvar='$__user_home'"

      ;;
    *)
      return -1
      ;;
  esac
  
  # non-exist user will not resolve and keep the origin string, which has a leading '~'
  if [[ "$__user_home" =~ ^~ ]]; then
    return -1
  else
    return 0
  fi
}


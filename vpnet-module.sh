#!/usr/bin/env bash
#
# VPNet.io - Virtual Private Network Essential Toolbox
#
# https://github.com/acrossfw/vpnet
#

#
# Bash3 Boilerplate. Copyright (c) 2014, kvz.io
# http://kvz.io/blog/2013/11/21/bash-best-practices/
#
vpnet::init_bash() {
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
  __dir="$(cd "$(dirname "$source}")" && pwd)"
  __file="${__dir}/$(basename "${source}")"
  __base="$(basename ${__file} .sh)"
  __root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app
}

# [Templating with Linux in a Shell Script](http://serverfault.com/a/699377/276381)
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
  
  echo "initing $config_file from $template_file ..."
  template="$(cat ${template_file})"
  eval "echo \"${template}\"" > $config_file
}
 
vpnet::is_docker() {
  # XXX simulate docker for test
  return 0
  
  # http://stackoverflow.com/a/20012536/1123955
  if [[ $(head -1 /proc/1/cgroup) =~ /$ ]]; then
    # end with '/', out docker
    return -1
  else
    # end with container string, insdie docker
    return 0
  fi
}

vpnet::check_env() {
  [[ "$(id -u)" = 0 ]] || {
    echo "ERROR: must run as root"
    exit -1
  }
}

#
# System & Networking Initialization
#
vpnet::init_system() {
  echo "Setting hostname to $HOSTNAME ..."
  # XXX: this will not work in --net=host mode
  # https://github.com/docker/docker/issues/5708
  hostname $HOSTNAME
  
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
  local n=${#@}
  local user_name
  local user_home
  local __resultvar
  
  case "$n" in
    1)
      user_name=$1
      user_home=$(eval echo ~${user_name})
      echo $user_home
      ;;
    2)  # http://www.linuxjournal.com/content/return-values-bash-functions
      user_name=$1
      __resultvar=$2
      user_home=$(eval echo ~${user_name})
      # echo $__resultvar="'$user_home'"
      eval $__resultvar="'$user_home'"
      ;;
    *)
      return -1
      ;;
  esac
  
  # non-exist user will not resolve and keep the origin string, which has a leading '~'
  if [[ "$user_home" =~ ^~ ]]; then
    return -1
  else
    return 0
  fi
}

#
# Process Args
#
vpnet::run() {
  local arg1=$1
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
      echo "test ok!"
      exit $?
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

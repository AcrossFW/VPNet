#!/bin/sh
#
# VPNet.io - Virtual Private Network Essential Toolbox
#
# https://github.com/acrossfw/vpnet
#
set -e

echo
echo "Starting VPNet Docker ..."
echo

#
# System & Networking Initialization
#

echo "Setting hostname to $HOSTNAME ..."
hostname $HOSTNAME

echo "Disabling coredump ..."
sysctl fs.suid_dumpable=0 
ulimit -S -c 0 
echo "* hard core 0" >> /etc/security/limits.conf

echo "Set ip forwarding to 1 ..."
sysctl net.ipv4.ip_forward=1
sysctl net.ipv4.conf.all.forwarding=1
sysctl net.ipv6.conf.all.forwarding=1
echo 1 > /proc/sys/net/ipv4/route/flush

# XXX does there always be `eth0` in docker ???
echo "Setting network filter ..."
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
# XXX no need ? iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# setup ssh keys
[ "$SSH_AUTHORIZED_KEYS" ] && {
  echo "Writing SSH authorized_keys ..."
  USERHOME=/home/$USERNAME
  [ -d "$USERHOME/.ssh" ] || mkdir $USERHOME/.ssh && chmod 700 $USERHOME/.ssh
  [ -d "root/.ssh" ] || mkdir root/.ssh && chmod 700 root/.ssh
  echo $SSH_AUTHORIZED_KEYS >> /home/$USERNAME/.ssh/authorized_keys
  echo $SSH_AUTHORIZED_KEYS >> /root/.ssh/authorized_keys
  chmod 600 /home/$USERNAME/.ssh/authorized_keys
  chmod 600 /root/.ssh/authorized_keys
}

#
# Process Args
#

if [ "$1" = "start" ]; then
  # Use baseimage-docker's init system.
  # CMD ["/sbin/my_init"]
  
  echo -n "Getting my IP... "
  curl ifconfig.io
  
  exec my_init
  ERR_CODE=$?
  echo "ERROR: my_init exit with error code $ERR_CODE"
  exit $ERR_CODE
fi

if [ "$1" = "test" ]; then
  echo "test ok!"
  exit $?
fi

if [ "$1" = "shell" ] || \
  [ "$1" = "sh" ] || \
  [ "$1" = "bash" ]; 
then
  echo "Creating shell..."
  exec /bin/bash -s
  exit $?
fi

echo "UNSUPPORT PARAM: $@"
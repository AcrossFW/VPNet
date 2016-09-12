#!/bin/sh
#
# VPNet.io - Virtual Private Network Essential Toolbox
#
# https://github.com/acrossfw/vpnet
#

iptables -A INPUT -p esp -j ACCEPT
iptables -A INPUT -p ah -j ACCEPT
#!/bin/sh
#
# VPNet.io - Virtual Private Network Essential Toolbox
# https://github.com/acrossfw/vpnet
#
# ShadowSocks
#
CMD=ss-server
exec $CMD -s 0.0.0.0 \
	-p 8388 \
	-k "${PASSWORD:-$(hostname)}" \
	-m ${SHADOWSOCKS_ENCRYPT_METHOD:-aes-256-cfb} \
	-t 300 \
	--fast-open \
	-d ${DNS:-8.8.8.8} \
	-u


ERR_RET=$?
echo "$CMD error with exit code $ERR_RET"
sleep 1
exit $ERR_RET

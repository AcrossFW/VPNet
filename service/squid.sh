#!/bin/sh
#
# VPNet.io - Virtual Private Network Essential Toolbox
#
# https://github.com/acrossfw/vpnet
#
# squid
#

[ -d /etc/squid ] || mkdir /etc/squid

SQUID_CONF=/etc/squid/squid.conf
SQUID_PASSWD=/etc/squid/htpasswd

htpasswd -b -c $SQUID_PASSWD ${USERNAME:-vpnet} ${PASSWORD:-vpnet.io}

cat << SQUID_CONF > $SQUID_CONF
http_port 3128 transparent
visible_hostname $HOSTNAME
cache_mgr ${EMAIL:-webmaster@localhost}
dns_nameservers ${DNS:-8.8.8.8}
acl QUERY urlpath_regex cgi-bin \?
cache deny QUERY
cache_mem 16 MB
cache_dir ufs /var/spool/squid 100 16 256
access_log /var/log/squid/access.log squid
cache_store_log none
auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/passwd
auth_param basic children 1
refresh_pattern ^ftp:           1440    20%     10080
refresh_pattern ^gopher:        1440    0%      1440
refresh_pattern .               0       20%     4320
acl ncsa_users proxy_auth REQUIRED
#acl password proxy_auth REQUIRED
#acl all src 0.0.0.0/0.0.0.0
#acl manager proto cache_object
#acl localhost src 127.0.0.1/32
acl privatenet8 src 10.0.0.0/8
acl privatenet12 src 172.16.0.0/12
acl privatenet16 src 192.168.0.0/16
acl linklocal src 169.254.0.0/16
acl CONNECT method CONNECT

forwarded_for off
http_access allow manager localhost
http_access deny manager
http_access allow localhost
http_access allow privatenet8
http_access allow privatenet12
http_access allow privatenet16
http_access allow linklocal
#http_access allow password
http_access allow ncsa_users
http_access deny all

#
# transparent cache to domain my.domain.com
#
acl my_domain_acl dstdomain my.domain.com
always_direct deny my_domain_acl
cache_peer ghs.google.com parent 80 0 no-query originserver no-digest no-netdb-exchange allow-miss name=ghs
cache_peer_access ghs allow my_domain_acl

# MUST after all "always_direct deny ..."
always_direct allow all

# end
http_reply_access allow all
icp_access deny all
coredump_dir /tmp
shutdown_lifetime 10

SQUID_CONF

ulimit -n 65535
squid -z
exec squid -N -d 1 -YC

ERR_CODE = $?
echo "ERROR: squid exit code $ERR_CODE"
exit $ERR_CODE
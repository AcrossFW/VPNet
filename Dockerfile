#
# VPNet.io - Virtual Private Network Essential Toolbox
#
# https://github.com/acrossfw/vpnet
#
# Use phusion/baseimage as base image. To make your builds
# reproducible, make sure you lock down to a specific version, not
# to `latest`! See
# https://github.com/phusion/baseimage-docker/blob/master/Changelog.md
# for a list of version numbers.
FROM phusion/baseimage:latest
MAINTAINER AcrossFW <dev@acrossfw.com>

#
#
# START HEADER - VPNet.io System Init
#
#

#	module-init-tools \ operation not permitted inside docker
RUN apt-get update -qq && apt-get -qqy install \
    	apt-utils \
    	curl \
    	inetutils-ping \
    	inetutils-traceroute \
    	iperf \
    	iptables \
    	iptraf \
    	net-tools \
    	netcat \
    	screen \
    	shellcheck \
    	tcpdump \
    	tinc \
      \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV BATS_VERSION 0.4.0
RUN curl -s -o "/tmp/v${BATS_VERSION}.tar.gz" -L \
      "https://github.com/sstephenson/bats/archive/v${BATS_VERSION}.tar.gz" \
    && tar -xzf "/tmp/v${BATS_VERSION}.tar.gz" -C /tmp/ \
    && bash "/tmp/bats-${BATS_VERSION}/install.sh" /usr/local \
    \
    && rm -rf /tmp/*

ENV ADMIN_NAME vpnet
ENV ADMIN_PASS vpnet.io
# TODO
ENV USERS "user:pass"
ENV HOSTNAME vpnet.io
ENV EMAIL dev@acrossfw.com

ENV DNS 8.8.8.8
ENV DNS2 8.8.4.4

ENV ACROSSFW_HOME /acrossfw
ENTRYPOINT [ "/acrossfw/bin/entrypoint.sh" ]
CMD [ "start" ]

WORKDIR $ACROSSFW_HOME
RUN ln -s /etc/service /service \
  && ln -s ${ACROSSFW_HOME}/service/vpnet /service/vpnet \
  && echo 'export WANIP=`curl -Ss ifconfig.io`' >> /etc/profile \
  && echo 'cd # fix $PWD=/acrossfw right after login bug? do not know why yet.' >> /root/.bashrc \
  && echo '[[ "$PS1" =~ WANIP ]] || PS1=${PS1//@\\\\h/@\\\\h(\$WANIP:-unknown-wan-ip)}' >> /root/.bashrc \
  && echo '[[ "$PS1" =~ WANIP ]] || PS1=${PS1//@\\\\h/@\\\\h(\$WANIP)}' >> /etc/skel/.bashrc

#
# Node.JS
#
# RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - \
#	&& apt-get install -qqy nodejs

#
#
# END HEADER - VPNet.io
#
#

#
# START SSH
#

# to prevent conflict with host ssh standard port when run in --net=host mode
# EXPOSE 22/tcp 
ENV PORT_SSH 10022
EXPOSE $PORT_SSH/tcp

# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
# RUN /etc/my_init.d/00_regen_ssh_host_keys.sh
RUN rm -f /etc/service/sshd/down \
    && ln -s ${ACROSSFW_HOME}/service/ssh /service/ssh
    
ENV SSH_AUTHORIZED_KEYS "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6GRsnNc1judMmIFeYzu02KbkkWW0mkrOusAe1kdEW9MeXIgq4cOjMMYHGHLxQR+WU4/yexpKdBlDUNSJiw7uSTyGl0ORwwKZfAeMlaFWRCtIrPh1DBugjZQKcAxoKaMeH2lzHIj5H/tCrgyjmQ6foUG70cKFQFtp6+aSURr1Oj12mQGD/JsfTRw2nnLdDA7TEV9SmhThliu7voq/u50doZjutFmASQVJJ+QD2jISyc7DGudVoQWNqsy6fJyHqnFKWpvlLMw22MgXOJEKpGS616jHGLqwvCCFghSl2+Dh3XVkhtL5WV9mU0dyqcesr347TH7FtVwufhI7yArU7+qin dev@acrossfw.com"

#
# END SSH
#

#
# START IPSEC
# 

# Inspired by https://github.com/gaomd/docker-ikev2-vpn-server/blob/master/Dockerfile
#
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install \
      iptables \
      ndppd \
      openssl \
      strongswan \
      uuid-runtime \
    && rm /etc/ipsec.secrets \
    && ln -s ${ACROSSFW_HOME}/service/ipsec /service/ipsec \
    \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# IPSec Port must be standard(should not change?)
EXPOSE 500/udp 4500/udp

#
# END IPSEC
#

#
# START PPTP
#

# https://groups.google.com/forum/#!topic/docker-user/dC6aIr4R1hY
#
# inspired by https://github.com/vimagick/dockerfiles/tree/master/pptpd
#
# `rm pptpd.postinst` is a workaround of `no bus` error with systemd 
RUN apt-get update -qq && apt-get install -qqy \
      pptpd \
      || true \
    && rm -f rm /var/lib/dpkg/info/pptpd.postinst \
    && ln -s ${ACROSSFW_HOME}/service/pptp /service/pptp \
    \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# PPTP Port must be standard(should not change?)
EXPOSE 1723/tcp

#
# END PPTP
#

#
# START SQUID
#
ENV PORT_SQUID 13128
EXPOSE $PORT_SQUID/tcp

RUN apt-get update -qq && apt-get install -qqy \
      apache2-utils \
      squid \
    && ln -s ${ACROSSFW_HOME}/service/squid /service/squid \
    \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#
# END SQUID
#

#
# START SHADOWSOCKS
#

# do not use the standard port
ENV PORT_SHADOWSOCKS 18388
EXPOSE $PORT_SHADOWSOCKS/tcp $PORT_SHADOWSOCKS/udp

ENV SHADOWSOCKS_ENCRYPT_METHOD aes-256-cfb

# inspired by https://hub.docker.com/r/vimagick/shadowsocks-libev/
#
RUN curl -s http://shadowsocks.org/debian/1D27208A.gpg | apt-key add - \
	  && echo "deb http://shadowsocks.org/debian wheezy main" > /etc/apt/sources.list.d/shadowsocks.list \
	  && apt-get update -qq && apt-get install -qqy \
      shadowsocks-libev \
    && ln -s ${ACROSSFW_HOME}/service/shadowsocks /service/shadowsocks \
    \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#
# END SHADOWSOCKS
#

#
# START KCPTUN
# TBD

# inspired by vimagick/kcptun
#

#
# END KCPTUN
#

#
# START OPENVPN
# TBD

# do not use the standard port
ENV PORT_OPENVPN 11194
EXPOSE $PORT_OPENVPN/tcp $PORT_OPENVPN/udp


# inspired by https://github.com/gaomd/docker-openvpn-static

#
# END OPENVPN
#

#
# TODO:
#   L2TP
#   Tinc
#   Avahi
#


#
#
# START FOOTER - VPNet.io
#
#

# put COPY . . the end of Dockerfile for speedup build time by maximum cache usage
COPY . .
RUN cat /dev/null                                      > ${ACROSSFW_HOME}/ENV.build \
  && echo "BUILD_HOST=\"$(hostname -f)\""             >> ${ACROSSFW_HOME}/ENV.build \
  && echo "BUILD_IP=\"$(curl -Ss ifconfig.io)\""      >> ${ACROSSFW_HOME}/ENV.build \
  && echo "BUILD_DATE=\"$(date)\""                    >> ${ACROSSFW_HOME}/ENV.build \
  && echo "VERSION_HASH=\"$(./bin/version.sh hash)\"" >> ${ACROSSFW_HOME}/ENV.build

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#
#
# END FOOTER - VPNet.io
#
#
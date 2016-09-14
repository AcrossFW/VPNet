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
# START: VPNet.io
#
#

#	module-init-tools \ operation not permitted inside docker
RUN apt-get update -qq && apt-get -qqy install \
    	apt-utils \
    	curl \
    	iperf \
    	iptables \
    	iptraf \
    	net-tools \
    	netcat \
    	shellcheck \
    	tcpdump \
    	tinc

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
ENV HOSTNAME docker.vpnet.io
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
  && echo '[[ "$PS1" =~ WANIP ]] || PS1=${PS1/\\h/\\h(\$WANIP)}' >> /etc/skel/.bashrc

#
# Node.JS
#
# RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - \
#	&& apt-get install -qqy nodejs

#
# SSH
#
# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
# RUN /etc/my_init.d/00_regen_ssh_host_keys.sh
RUN rm -f /etc/service/sshd/down \
    && ln -s ${ACROSSFW_HOME}/service/ssh /service/ssh
ENV SSH_AUTHORIZED_KEYS "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6GRsnNc1judMmIFeYzu02KbkkWW0mkrOusAe1kdEW9MeXIgq4cOjMMYHGHLxQR+WU4/yexpKdBlDUNSJiw7uSTyGl0ORwwKZfAeMlaFWRCtIrPh1DBugjZQKcAxoKaMeH2lzHIj5H/tCrgyjmQ6foUG70cKFQFtp6+aSURr1Oj12mQGD/JsfTRw2nnLdDA7TEV9SmhThliu7voq/u50doZjutFmASQVJJ+QD2jISyc7DGudVoQWNqsy6fJyHqnFKWpvlLMw22MgXOJEKpGS616jHGLqwvCCFghSl2+Dh3XVkhtL5WV9mU0dyqcesr347TH7FtVwufhI7yArU7+qin dev@acrossfw.com"
EXPOSE 22/tcp

#
# IPsec
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
    && ln -s ${ACROSSFW_HOME}/service/ipsec /service/ipsec
EXPOSE 500/udp 4500/udp

#
# PPTP
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
    && ln -s ${ACROSSFW_HOME}/service/pptp /service/pptp
EXPOSE 1723/tcp

#
# Squid
#
RUN apt-get update -qq && apt-get install -qqy \
      apache2-utils \
      squid \
    && ln -s ${ACROSSFW_HOME}/service/squid /service/squid
EXPOSE 3128/tcp

#
# ShadowSocks
#
# inspired by https://hub.docker.com/r/vimagick/shadowsocks-libev/
#
RUN curl -s http://shadowsocks.org/debian/1D27208A.gpg | apt-key add - \
	  && echo "deb http://shadowsocks.org/debian wheezy main" > /etc/apt/sources.list.d/shadowsocks.list \
	  && apt-get update -qq && apt-get install -qqy \
      shadowsocks-libev \
    && ln -s ${ACROSSFW_HOME}/service/shadowsocks /service/shadowsocks
ENV SHADOWSOCKS_ENCRYPT_METHOD aes-256-cfb
EXPOSE 8388/tcp 8388/udp

#
#
# END - VPNet.io
#
#

# put COPY . . the end of Dockerfile for speedup build time by maximum cache usage
COPY . .
RUN cat /dev/null                          > ${ACROSSFW_HOME}/ENV \
  && echo "BUILD_HOST=\"$(hostname -f)\"" >> ${ACROSSFW_HOME}/ENV \
  && echo "BUILD_DATE=\"$(date)\""        >> ${ACROSSFW_HOME}/ENV \
  && echo "BUILD_VERSION=\"UNKNOWN\""     >> ${ACROSSFW_HOME}/ENV

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

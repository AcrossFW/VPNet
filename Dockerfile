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
FROM phusion/baseimage:0.9.19
MAINTAINER AcrossFW <dev@acrossfw.com>

ENV DEBIAN_FRONTEND noninteractive

#
#
# START HEADER - VPNet.io System Init
#
#

#	module-init-tools \ operation not permitted inside docker
RUN apt-get update -qq && apt-get -qqy install \
      apt-utils \
    	curl \
    	dnsmasq \
    	dnsutils \
    	inetutils-ping \
    	inetutils-traceroute \
    	iperf \
    	iptables \
    	jq \
    	lsof \
    	lua5.1 \
    	man \
    	net-tools \
    	netcat \
    	nload \
    	screen \
    	shellcheck \
    	speedtest-cli \
    	tcpdump \
    	tinc \
    	vim \
    	wget \
      \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#    && sed -i 's/files dns/files/g' /etc/nsswitch.conf \

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
  && echo 'export WANIP=`curl -Ss v4.ifconfig.co`' >> /etc/profile \
  && echo 'cd # fix $PWD=/acrossfw right after login bug? do not know why yet.' >> /root/.bashrc \
  && echo '[[ "$PS1" =~ WANIP ]] || PS1=${PS1//@\\\\h/@\\\\h(\$WANIP)}' >> /root/.bashrc \
  && echo '[[ "$PS1" =~ WANIP ]] || PS1=${PS1//@\\\\h/@\\\\h(\$WANIP)}' >> /etc/skel/.bashrc

#
# Node.JS
#
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash - \
  && apt-get install -qqy nodejs

ENV PORT_WEB 10080
EXPOSE ${PORT_WEB}/tcp

COPY service/vpnet/package.json service/vpnet/

RUN cd service/vpnet \
  && npm install

#
#
# END HEADER - VPNet.io
#
#

#
# 22: START SSH
#

# to prevent conflict with host ssh standard port when run in --net=host mode
ENV PORT_SSH 10022
EXPOSE ${PORT_SSH}/tcp

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
# 500: START IPSEC
#

# Inspired by https://github.com/gaomd/docker-ikev2-vpn-server/blob/master/Dockerfile
#
RUN apt-get update && apt-get -y install \
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
# 1723: START PPTP
#

# PPTP Port must be standard(should not change?)
EXPOSE 1723/tcp

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


#
# END PPTP
#

#
# 3128: START SQUID
#
ENV PORT_SQUID 13128
EXPOSE ${PORT_SQUID}/tcp

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
# 8388: START SHADOWSOCKS
#

# do not use the standard port
ENV PORT_SHADOWSOCKS 18388
EXPOSE ${PORT_SHADOWSOCKS}/tcp ${PORT_SHADOWSOCKS}/udp

ENV SHADOWSOCKS_ENCRYPT_METHOD salsa20

RUN echo 'deb http://archive.ubuntu.com/ubuntu yakkety main universe' > /etc/apt/sources.list \
      && apt-get update -qq \
      && apt-get install -qqy shadowsocks-libev \
      && ln -s ${ACROSSFW_HOME}/service/shadowsocks /service/shadowsocks \
      \
      && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#
# END SHADOWSOCKS
#

#
# 554: START KCPTUN
#
ENV PORT_KCPTUN 10554
EXPOSE ${PORT_KCPTUN}/udp

# Non-Defaults
ENV KCPTUN_CRYPT salsa20
ENV KCPTUN_DATASHARD 0
ENV KCPTUN_PARITYSHARD 0

# Defaults
ENV KCPTUN_MODE fast
ENV KCPTUN_MTU 1350
ENV KCPTUN_NOCOMP 1
ENV KCPTUN_RCVWND 1024
ENV KCPTUN_SNDWND 1024

RUN URL=$(curl -s https://api.github.com/repos/xtaci/kcptun/releases/latest | jq -r '.assets[] | select(.name | contains("linux-amd64")) .browser_download_url') \
      && wget --quiet -O /tmp/kcptun.tgz "$URL" \
      && [ -e "${ACROSSFW_HOME}/service/kcptun/bin/" ] || mkdir -p ${ACROSSFW_HOME}/service/kcptun/bin/ \
      && tar zxvf /tmp/kcptun.tgz -C ${ACROSSFW_HOME}/service/kcptun/bin/ \
      && ln -s ${ACROSSFW_HOME}/service/kcptun /service/kcptun \
      && rm -f /tmp/kcptun.tgz

#
# END KCPTUN
#

#
# 1194: START OPENVPN
# TBD

# do not use the standard port
ENV PORT_OPENVPN 11194
EXPOSE ${PORT_OPENVPN}/tcp ${PORT_OPENVPN}/udp

# inspired by https://github.com/gaomd/docker-openvpn-static

#
# END OPENVPN
#


#
# TODO:
#   L2TP
#   Tinc
#   Avahi
#   OpenConnect VPN Server - https://lvii.gitbooks.io/outman/content/ocserv.html
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

RUN ./bin/entrypoint.sh test

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#
#
# END FOOTER - VPNet.io
#
#

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
	iptables \
	net-tools \
	netcat

ENV USERNAME vpnet
ENV PASSWORD vpnet.io
# TODO
# ENV USERS "user,pass;?"
ENV HOSTNAME docker.vpnet.io
ENV EMAIL dev@acrossfw.com

ENV DNS 8.8.8.8
ENV DNS2 8.8.4.4

WORKDIR /vpnet
COPY bin/entrypoint.sh entrypoint.sh
ADD service/vpnet.sh /etc/service/vpnet/run
ENTRYPOINT [ "/vpnet/entrypoint.sh" ]
CMD [ "start" ]


#
# Node.JS
#
# RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - \
#	&& apt-get install -qqy nodejs

#
# ShadowSocks
#
RUN curl -s http://shadowsocks.org/debian/1D27208A.gpg | apt-key add - \
	&& echo "deb http://shadowsocks.org/debian wheezy main" > /etc/apt/sources.list.d/shadowsocks.list \
	&& apt-get update -qq && apt-get install -qqy \
	    shadowsocks-libev
ADD service/shadowsocks.sh /etc/service/shadowsocks/run
ENV SHADOWSOCKS_ENCRYPT_METHOD aes-256-cfb
EXPOSE 8388/tcp
EXPOSE 8388/udp

#
# PPTP
#
# https://groups.google.com/forum/#!topic/docker-user/dC6aIr4R1hY
#
RUN apt-get update -qq && apt-get install -qqy \
    pptpd || true \
    && rm -f rm /var/lib/dpkg/info/pptpd.postinst # a workaround of `no bus` error with systemd
ADD service/pptp.sh /etc/service/pptp/run
EXPOSE 1723/tcp

#
# Squid
#
RUN apt-get update -qq && apt-get install -qqy \
    apache2-utils \
    squid
ADD service/squid.sh /etc/service/squid/run
EXPOSE 3128/tcp

#
# SSH
#
RUN rm -f /etc/service/sshd/down

# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
# RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

ENV SSH_AUTHORIZED_KEYS "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6GRsnNc1judMmIFeYzu02KbkkWW0mkrOusAe1kdEW9MeXIgq4cOjMMYHGHLxQR+WU4/yexpKdBlDUNSJiw7uSTyGl0ORwwKZfAeMlaFWRCtIrPh1DBugjZQKcAxoKaMeH2lzHIj5H/tCrgyjmQ6foUG70cKFQFtp6+aSURr1Oj12mQGD/JsfTRw2nnLdDA7TEV9SmhThliu7voq/u50doZjutFmASQVJJ+QD2jISyc7DGudVoQWNqsy6fJyHqnFKWpvlLMw22MgXOJEKpGS616jHGLqwvCCFghSl2+Dh3XVkhtL5WV9mU0dyqcesr347TH7FtVwufhI7yArU7+qin dev@acrossfw.com"
RUN adduser --quiet --disabled-password -shell /bin/bash --home /home/$USERNAME --gecos $USERNAME $USERNAME \
    && echo "root:$PASSWORD\n$USERNAME:$PASSWORD" | chpasswd && echo "root:$PASSWORD\n$USERNAME:$PASSWORD" > /log

EXPOSE 22/tcp

#
# IpSec
#

EXPOSE 500/udp
EXPOSE 4500/udp

#
#
# END - VPNet.io
#
#

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# VPNet

VPNet(Very Powerful Network Encryption Toolbox) is a modern, open source, strong encryption and easy to use docker image for bypassing the censorship circumvention systems, which helps people gain access to the global internet free of censorship, without knowledge of what is being blocked or the underlying technical.

We believe that the right of visiting free and open global internet is right that all people should enjoy – both technic and the non-technic people.

## Story

**U.S. Consulate request quotation for International Internet access service on Aug 2016.**

> U.S. Consulate General Shanghai  
> Date: Aug 10, 2016  
> To: Prospective Bidders  
> Subject: Request for Quotation for Internet access solution  

![U.S. Consulate Weibo](https://raw.githubusercontent.com/AcrossFW/vpnet/master/image/vpn-against-gfw-us-consulate-weibo.jpg)

![U.S. Consulate Quotation](https://raw.githubusercontent.com/AcrossFW/vpnet/master/image/internet-access-solution-quotation-from-us-consulate-shanghai.jpg)

## Goal

The Goal of VPNet is to satisfy those needs in above story, with the following highlights.

1. Professional  
    1. Stable Connection
    2. Strong Cryption
    3. Decentralized
3. All in One
    5. SSH Tunnel
    3. PPTP
    6. Squid Proxy
    1. ShadowSocks
    2. OpenVPN
    4. IPsec
2. Extreme Easy to Setup
    1. Pick a VPS
    2. Run via Docker
    3. Use it
    4. 
5. 

Being an Anti-Censorship Technology, VPNet has to try the best to adapt.

> “Every time censors try a new technique, the tool developers adapt, keeping thousand of users connected to the global internet.”  
>  
>   Malinowski, _Assistant Secretary of State for Democracy, Human Rights and Labor_  

## Quick Start

VPNet is extreme easy to deploy by only one command, because it was built & shiped by docker:

```shell
$ docker run -d --privileged acrossfw/vpnet \
  -p 22:22 \
  -p 1723:1724 \
  -p 3128:3128 \
  -p 8388:8388 \
```

You are set. Cheers!

### Defaults



## Out-of-the-box Features

### 1. SSH

### 2. PPTP

### 3. Squid

### 4. ShadowSocks

### 5. IPsec

### 6. OpenVPN


## Cloud Hosting

### 1. System Requirement

The follow requirements is just for suggestion, because VPNet can run in anywhere which has docker installed. If you already have a server, use it as well.

1. Location: HongKong / Koera / Japan / Singapore
1. Operation System: 64-bit Debian 8 Jessie
1. CPU / Ram / Disk: Smallest(Cheapest)

### 2. Service Provider

1. [Linode](https://www.linode.com/)
1. [DigitalOcean](https://www.digitalocean.com/)

## Docker Installation

Here's how to install docker in 64-bit Debian 8.

```shell
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo debian-jessie main" > /etc/apt/sources.list.d/docker.list
apt-get update && apt-get install docker-engine
service enable docker
docker run hello-world
```

If you want to install docker for other linux distribution, documents can be found on docker.com at [Install Docker Engine](https://docs.docker.com/engine/installation/#installation).

## Reference

* [Getting everything right: baseimage-docker](phusion.github.io/baseimage-docker/)
* [Templating with Linux in a Shell Script](http://serverfault.com/a/699377/276381)

## See Also

1. [Internet Freedom](www.state.gov/e/eb/cip/netfreedom/index.htm) - Our goal is to ensure that any child, born anywhere in the world, has access to the global Internet as an open platform on which to innovate, learn, organize, and express herself free from undue interference or censorship.
1. [US Government Is Investing Millions in Internet Freedom Technologies](motherboard.vice.com/read/why-the-us-government-is-investing-millions-in-internet-freedom-technologies)
1. [The Leading Internet Freedom Technology (LIFT) Initiative: Scaling Up U.S. Leadership to Promote Human Rights Online](https://blogs.state.gov/stories/2015/10/12/leading-internet-freedom-technology-lift-initiative-scaling-us-leadership-promote)

## License

VPNet is licensed under the Apache License, Version 2.0. See LICENSE for the full license text.

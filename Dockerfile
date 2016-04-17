# GGCOM - Docker - hubiC v201604161440
# Louis T. Getterman IV (@LTGIV)
# www.GotGetLLC.com | www.opensour.cc/ggcom/docker/hubic
#
# Thanks:
#
# opensour.cc - hubiC
# https://www.opensour.cc/hubic
#
################################################################################

FROM		ubuntu:latest
MAINTAINER	GotGet, LLC <contact+docker@gotgetllc.com>

ENV			DEBIAN_FRONTEND	noninteractive
	
RUN			apt-get -y update && apt-get -y install \
				curl \
				duply \
				encfs \
				gcc \
				git \
				libcurl4-openssl-dev \
				libfuse-dev \
				libjson-c-dev \
				libmagic-dev \
				libssl-dev \
				libxml2-dev \
				make \
				nano \
				pkg-config \
				rsnapshot \
				rsync \
				sshfs

USER		root
WORKDIR		/root

ENV			HOME	/root

RUN			mkdir -p /tmp/hubicfuse
RUN			git clone https://github.com/TurboGit/hubicfuse /tmp/hubicfuse

# Compile HubicFuse
WORKDIR		/tmp/hubicfuse
RUN			./configure

# Install HubicFuse
RUN			make && make install

# Create mountpoint and bin
RUN			mkdir -p /mnt/hubic/

# Move token config to bin
RUN			mv /tmp/hubicfuse/hubic_token /usr/local/bin

# Easy Hubic access
RUN			ln -s /mnt/hubic/default $HOME/hubic
RUN			ln -s /mnt/hubic/default /hubic

# Clean-up after ourselves
RUN			apt-get -y purge \
				gcc \
				git \
				make \
				pkg-config
RUN			apt-get -y autoremove
RUN			rm -rf /tmp/*
################################################################################

# Load helper program
ADD			bin/init.bash /usr/local/bin/init.bash
WORKDIR		/usr/local/bin
RUN			chmod 755 init.bash

WORKDIR		$HOME
ENTRYPOINT	[ "/bin/bash", "/usr/local/bin/init.bash" ]

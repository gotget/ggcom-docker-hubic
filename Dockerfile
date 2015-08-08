# GGCOM - Docker - hubiC v201508081132
# Louis T. Getterman IV (@LTGIV)
# www.GotGetLLC.com | www.opensour.cc/ggcom/docker/hubic
#
# Example usage:
#
# Build:
# $] docker build --tag=hubic .
#
# Run:
# $] docker run --cap-add SYS_ADMIN --device /dev/fuse --interactive --tty --volume="$HOME/ggcom/ggcom-docker-hubic/config:/hubic" hubic
#
# $] docker run --cap-add SYS_ADMIN --device /dev/fuse --interactive --tty --volume="$HOME/ggcom/ggcom-docker-hubic/config:/hubic" hubic "config; hubic; ls -l hubic/; uhubic;"
#
# Thanks:
#
# opensour.cc - hubiC
# https://www.opensour.cc/hubic
#
################################################################################
FROM		ubuntu:14.04.2
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

ENV			HOME			/root

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

# Link configuration
RUN			ln -s /hubic/credentials.txt $HOME/.hubicfuse

# Easy Hubic access
RUN			ln -s /mnt/hubic/default $HOME/hubic

# Clean-up after ourselves
RUN			apt-get -y purge \
				gcc \
				git \
				make \
				pkg-config
RUN			apt-get -y autoremove
RUN			rm -rf /tmp/*
################################################################################

ADD			bin/hubic.bash /usr/local/bin/hubic
ADD			bin/uhubic.bash /usr/local/bin/uhubic
ADD			bin/config.bash /usr/local/bin/config
ADD			bin/init.bash /usr/local/bin/init.bash
WORKDIR		/usr/local/bin
RUN			chmod 755 hubic_token hubic uhubic config init.bash

WORKDIR		/root
ENTRYPOINT	[ "/bin/bash", "/usr/local/bin/init.bash" ]

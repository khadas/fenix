# use --build-arg VERSION=20.04 to override this if you wish
ARG _VERSION='18.04'
FROM ubuntu:$_VERSION

ENV DEBIAN_FRONTEND=noninteractive

# install some dev tools to help us out and basic functionality
RUN apt-get update &&  apt-get install -y \
	vim \
	nano \
	gdb \
	git \
	locales \
	sudo \
	make

RUN locale-gen en_US.UTF-8

ARG _LANG='en_US'
ARG _CHARSET='UTF-8'

ENV LANG=$_LANG.$_CHARSET
#keep just the language, drop the charaterset
ENV LANGUAGE=$_LANG
ENV LC_ALL=$_LANG.$_CHARSET
ENV TERM=screen

WORKDIR /opt/fenix-tools

# see dockerignore
COPY . .

# setup the host
RUN make prepare_host

# setup up the toochain
RUN make prepare_toolchains


# Switch to normal user
ARG _USER='khadas'
ARG _GROUP='khadas'
ARG _UID='1000'
ARG _GID='1000'

RUN groupadd --gid $_GID $_GROUP
RUN useradd -c $_USER --uid $_UID --gid $_GID -m -d /home/$_USER -s /bin/bash $_USER
RUN sed -i -e '/\%sudo/ c \%sudo ALL=(ALL) NOPASSWD: ALL' /etc/sudoers
RUN usermod -aG sudo $_USER

USER $_USER

WORKDIR /home/$_USER/fenix

ENTRYPOINT [ "/bin/bash" ]

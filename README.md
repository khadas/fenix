[![Release Build](https://github.com/khadas/fenix/actions/workflows/release-build.yml/badge.svg)](https://github.com/khadas/fenix/actions/workflows/release-build.yml)
[![Test Build Ubuntu](https://github.com/khadas/fenix/actions/workflows/test-build-ubuntu.yml/badge.svg?branch=master)](https://github.com/khadas/fenix/actions/workflows/test-build-ubuntu.yml)
[![Test Build Debian](https://github.com/khadas/fenix/actions/workflows/test-build-debian.yml/badge.svg)](https://github.com/khadas/fenix/actions/workflows/test-build-debian.yml)
[![Remove Old Artifacts](https://github.com/khadas/fenix/actions/workflows/remove-old-artifacts.yml/badge.svg?branch=master)](https://github.com/khadas/fenix/actions/workflows/remove-old-artifacts.yml)

# Fenix script set to build Ubuntu/Debian images

[![Documentation](https://img.shields.io/badge/Documentation-Reference-blue.svg)](https://docs.khadas.com/vim1/FenixScript.html)
[![Licence](https://img.shields.io/badge/Licence-GPL--2.0-brightgreen.svg)](https://github.com/khadas/fenix/blob/master/LICENSE)
[![Version](https://img.shields.io/badge/Version-v1.0.2-blue.svg)](https://github.com/khadas/fenix/tree/v1.0.2)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/khadas/fenix/pulls)

Supported build host:

* `Ubuntu 18.04 Bionic x64`
  * `Building Ubuntu 18.04 Bionic image`
* `Ubuntu 20.04 Focal x64`
  * `Building Ubuntu 18.04 Bionic image`
  * `Building Ubuntu 20.04 Focal image`
  * `Building Debian 10 Buster image`
* `Docker`

## How to use

### Install essential packages

```bash
$ sudo apt-get install git make lsb-release qemu-user-static
```

### Clone Fenix repository

```bash
$ mkdir -p ~/project/khadas
$ cd ~/project/khadas
$ git clone --depth 1 https://github.com/khadas/fenix
$ cd fenix
```

### Setup build environment

* Setup environment manually.

```bash
$ source env/setenv.sh
```

* Or you can load environment configuration from file.

```bash
$ source env/setenv.sh config config-template.conf
```

You need to edit `config-template.conf` file to correct variables.

### Build image

```bash
$ make
```
For Chinese users, it's better to use mirror from China:

```bash
$ DOWNLOAD_MIRROR=china make
```

## Somethings with Redhat series

### Disable SELinux

```bash
$ vim /etc/selinux/config
$ SELINUX=enforcing --> SELINUX=disabled
$ sudo reboot
```

## Build in Docker

### Get Docker image

```bash
$ cd fenix
$ docker pull numbqq/fenix:latest
```

### Build image in Docker

Run fenix in docker.

```bash
$ docker run -it --name fenix -v $(pwd):/home/khadas/fenix \
             -v /etc/localtime:/etc/localtime:ro \
             -v /etc/timezone:/etc/timezone:ro \
             -v $HOME/.ccache:/home/khadas/.ccache --privileged \
             --device=/dev/loop-control:/dev/loop-control \
             --device=/dev/loop0:/dev/loop0 --cap-add SYS_ADMIN \
             numbqq/fenix
```

We are in Docker container now, start to build.

```bash
khadas@919cab43f66d:~/fenix$ source env/setenv.sh
khadas@919cab43f66d:~/fenix$ make
```

For Chinese users, it's better to use mirror from China:

```bash
khadas@919cab43f66d:~/fenix$ DOWNLOAD_MIRROR=china make
```


To restart the Docker container a second time.

```bash
$ docker start fenix
$ docker exec -ti fenix bash
```

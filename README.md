# Fenix script set to build Ubuntu/Debian images

[![Documentation](https://img.shields.io/badge/Documentation-Reference-blue.svg)](https://docs.khadas.com/vim1/FenixScript.html)
[![Licence](https://img.shields.io/badge/Licence-GPL--2.0-brightgreen.svg)](https://github.com/khadas/fenix/blob/master/LICENSE)
![Version](https://img.shields.io/badge/Version-v0.8.3-blue.svg)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/khadas/fenix/pulls)

Supported build host:

* `Ubuntu Bionic 18.04 x64`
* `Docker`

## How to use

* Install essential packages

```bash
$ sudo apt-get install git make lsb-release qemu-user-static
```

* Clone Fenix repository

```bash
$ mkdir -p ~/project/khadas
$ cd ~/project/khadas
$ git clone --depth 1 https://github.com/khadas/fenix
$ cd fenix
```

* Setup build environment

```bash
$ source env/setenv.sh
```

* Build image

```bash
$ make
```

## Somethings with Redhat series

* Close SELinux

```bash
$ vim /etc/selinux/config
$ SELINUX=enforcing --> SELINUX=disabled
$ sudo reboot
```

## Build in Docker

* Build Docker image

```bash
$ cd fenix
$ docker build -t fenix .
```

* Build image in Docker

 Run fenix in docker.

```bash
$ docker run -it --name fenix -v $(pwd):/home/khadas/fenix -v /etc/localtime:/etc/localtime:ro -v /etc/timezone:/etc/timezone:ro --privileged --device=/dev/loop0:/dev/loop0 --cap-add SYS_ADMIN fenix
```

 We are in Docker container now, start to build.

```bash
khadas@919cab43f66d:~/fenix$ source env/setenv.sh
khadas@919cab43f66d:~/fenix$ make
```

To restart the Docker container a second time.

```bash
$ docker start fenix
$ docker exec -ti fenix bash
```

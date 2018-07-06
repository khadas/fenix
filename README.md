# Fenix script set to build Ubuntu/Debian images

[![Documentation](https://img.shields.io/badge/Documentation-Reference-blue.svg)](https://docs.khadas.com/vim1/FenixScript.html)
[![Licence](https://img.shields.io/badge/Licence-GPL--2.0-brightgreen.svg)](https://github.com/khadas/fenix/blob/master/LICENSE)
![Version](https://img.shields.io/badge/Version-v0.3-blue.svg)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/khadas/fenix/pulls)

Supported build host:
* `Ubuntu Xenial 16.04 x64` - Recommend & Fully tested.
* `Ubuntu Artful 17.10 x64` - Need to be tested.
* `Ubuntu Bionic 18.04 x64` - Need to be tested.
* `Docker` - Need to be tested.

## How to use?
- Install essential packages
```
$ sudo apt-get install git make lsb-release
```

- Clone Fenix repository
```
$ mkdir -p ~/project/khadas
$ cd ~/project/khadas
$ git clone https://github.com/khadas/fenix
$ cd fenix
```

- Setup build environment
```
$ source env/setenv.sh
```
- Build image
```
$ make
```

## Build in Docker

- Build Docker image
```
$ cd fenix
$ docker build -t fenix .
```
- Build image in Docker

 Run fenix in docker.

```
$ docker run -it -v $(pwd):/home/khadas/fenix --privileged fenix
```

 We are in Docker container now, start to build.

```
khadas@919cab43f66d:~/fenix$ source env/setenv.sh
khadas@919cab43f66d:~/fenix$ make
```

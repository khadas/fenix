# Fenix script set to build Ubuntu/Debian image

Supported build host:
* `Ubuntu Xenial 16.04 x64` - Recommend & Fully tested.
* `Ubuntu Artful 17.10 x64` - Need to be tested.
* `Ubuntu Bionic 18.04 x64` - Need to be tested.

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

# New Developing fenix branch

    git branch dev

NOTE: experimental branch for testers developing and other things !!!

## Generic images

New simple generic image. one image for any devices

+ at this moment generic image have only one minimal type
  easy to make any other configuration from minimal image via `setup`
+ boot-less image ( without u-boot ) u-boot must be localted on SPI flash
  or special emmc boot areas
+ uefi works (have some problems but already usable)
+ extlinux works [default]
+ post config script ( simple flexible powerfull - `setup` script )
+ new gpt partionning - ready ( migrate from dos partioning )
+ added new targets and host => hirsute + bullseye
+ ...
+ flexible system users configuration

NOTE: pure ubuntu and debian system provided as is - without customization and other tricks!

NOTE: original distros linux kernel replaced to another workable variant!


## Ubuntu hirsute and Debian bullseye support

    # host    | target   | status
    # --------------------------------
    # hirsute | hirsute  | OK
    # hirsute | bullseye | OK
    # hirsute | focal    | OK
    # hirsute | buster   | OK
    # focal   | hirsute  | FAIL
    # focal   | bullseye | FAIL

## New env make image parameters

```
+ USER_NAME                   # user name
                              # default USER_NAME=khadas
+ USER_SHELL                  # user shell
+ HOST_NAME                   # system host name
                              # default HOST_NAME=$USER_NAME
+ USER_PASSWORD               # user password
  USER_PASSWORD=-             # empty user password
                              # password will be empty if not defined and
                              # USER_NAME != default USER_NAME (khadas)
+ USER_PASSWORD_ENCRYPTED     # root encrypted password check next examples
+ ROOT_PASSWORD               # root password
  ROOT_PASSWORD=-             # empty root password
                              # default ROOT_PASSWORD=khadas
+ ROOT_PASSWORD_ENCRYPTED     # root encrypted password check next examples
+ SSH_KEYS                    # file source for ssh pub keys
+ SSH_PUBS                    # define raw ssh pub keys 
+ IMAGE                       # define image for `make write` if board not configured
+ WRITE_DST                   # define image write destination for `make write`
+ NO_HOST_CHECK               # disable build host checks
```

## EMPTY PASSWORD NOTE

    empty password for both user and root users its more friendly and safety
    ssh reject empty password user by default .... 

## Make images example

    USER_NAME=hyphop ROOT_PASSWORD=- SSH_KEYS=-:~/.ssh/id_ed25519.pub make

    ROOT_PASSWORD_ENCRYPTED='$5$qU2aqyCav1zR4RzI$70w8tEE/9tNJQ9T3th1TuECrIZKDj3YAzzKULgvGky7'
    # or how to generate it ...
    ROOT_PASSWORD_ENCRYPTED=$(echo -n my_password | openssl passwd -5 -stdin)

## Write image

New easy way write image via Krescue directly to device (any destination),
krescue must be started on device and connected to same network

    [WRITE_DST=mmc|nvme|sd|usb] make write

### Write image examples

    WRITE_DST=mmc make write
    # os same result becouse mmc is default destination
    make write

    # write any other image
    IMAGE=build/images/Generic_Ubuntu-minimal-hirsute_Linux-5.12_arm64_SD-USB_V1.0.6-210706-develop.img make write
    # write compressed image
    IMAGE=build/images/Generic_Ubuntu-minimal-hirsute_Linux-5.12_arm64_SD-USB_V1.0.6-210706-develop.img.xz make write
    # write image to nvme
    # WRITE_DST=nvme IMAGE=~/khadas/img/FreeBSD-aarch64-13.0-RELEASE-Khadas-EDGE-20210702.img.xz make write

NOTE: `make write` can write any compressed image by gzip zstd lzma/xz 
 same as simple raw images without decompression

### Uboot write

U-boot(mainline only) must be writed separately

+ https://dl.khadas.com/Firmware/uboot/mainline/

### Uboot write example

Another easy way write/update uboot for any khadas boards via Krescue
always update via internet by actual last uboot version

    make write-boot-online           # write uboot to eMMC + special boot areas
    make write-boot-spi-online-apply # write uboot to SPI flash (VIM2 VIM3 VIM3L Edge)

NOTE: VIM1 VIM3 VIM3L have special eMMC boot areas and eMMC storage can be rewriten
 and device will be still bootable

NOTE: VIM2 and Edge eMMC boot areas not works 

## Setup script

Setup system from command line by `setup` script 
`setup` can exec in any time ( not only in chroot POST_CONFIG image stage )
All tweaks splited as separate actions.

### Setup usage

```
setup help
USAGE: setup [ACTIONS|...]
Setup system script

 help                	 print help
 ethernet            	 setup ethernet
 resize              	 resize rootfs
 lvm-migrate         	 migrate to lvm 
 gnome               	 gnome install
 default             	 default setup
 extlinux            	 extlinux setup
 distro              	 print distro name
 grub-update         	 grub update
 grub                	 grub install
 network             	 setup network-manager
 connect             	 connect wifi
 tasksel             	 Tasksel Ubuntu/Debian software select
 self-update         	 setup script self update
 u-boot              	 update/write uboot to emmc by online
 ...

```

### LVM how-to

Easy migrate to LVM https://en.wikipedia.org/wiki/Logical_Volume_Manager_(Linux)

    sudo setup lvm-migrate && reboot

NOTE: old ROOTFS renamed to ROOTFS_BACKUP and possible to remove after if no need it!

```
root@hyphop:~# df /
Filesystem             1K-blocks   Used Available Use% Mounted on
/dev/mapper/vg0-rootfs   6342440 971352   5225272  16% /

root@hyphop:~# pvs
  PV             VG  Fmt  Attr PSize   PFree
  /dev/mmcblk1p3 vg0 lvm2 a--  <12.86g 6.68g

root@hyphop:~# lvs
  LV     VG  Attr       LSize Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  rootfs vg0 -wi-ao---- 6.17g                                                    

root@hyphop:~# blkid /dev/mapper/vg0-rootfs 
/dev/mapper/vg0-rootfs: LABEL="ROOTFS" UUID="9267e0dc-def4-11eb-8367-1d0061025229" TYPE="ext4"

root@hyphop:~# blkid | grep ROOTFS
/dev/mapper/vg0-rootfs: LABEL="ROOTFS" UUID="9267e0dc-def4-11eb-8367-1d0061025229" TYPE="ext4"
/dev/mmcblk1p2: LABEL="ROOTFS_BACKUP" UUID="99c25336-2b73-42df-acdf-0cf4ad8b46d8" TYPE="ext4" PARTLABEL="system" PARTUUID="2368e44e-02a7-ee41-8d94-38018e4d64ab"

```

..WIP..

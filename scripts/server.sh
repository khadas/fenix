#!/bin/bash

install -d ~/project/khadas/ubuntu/{linux,rootfs,archives/{ubuntu-base,debs,hwpacks},images,scripts}
cd ~/project/khadas/ubuntu/

## Build U-Boot
cd u-boot/
make kvim_defconfig
make -j8 CROSS_COMPILE=aarch64-linux-gnu-

## Build Linux
cd ../linux/
make ARCH=arm64 kvim_defconfig
make -j8 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Image kvim.dtb modules

## Rootfs
cd ~/project/khadas/ubuntu/
dd if=/dev/zero of=images/rootfs.img bs=1M count=0 seek=384
sudo mkfs.ext4 -F -L ROOTFS images/rootfs.img 
rm -rf rootfs && install -d rootfs
sudo mount -o loop images/rootfs.img rootfs
sudo rm -rf rootfs/lost+found
# ubuntu-base
sudo tar -xzf archives/ubuntu-base/ubuntu-base-16.04.2-base-arm64.tar.gz -C rootfs/
# use the backup debs
sudo cp -r archives/debs/*.deb rootfs/var/cache/apt/archives
# linux modules
sudo make -C linux/ -j8 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- modules_install INSTALL_MOD_PATH=../rootfs/
# initramfs
sudo cp -r archives/filesystem/etc/initramfs-tools/ rootfs/etc/
# WIFI
sudo mkdir rootfs/lib/firmware
sudo cp -r archives/hwpacks/wlan-firmware/brcm/ rootfs/lib/firmware/
# Bluetooth
sudo cp -r archives/hwpacks/bluez/brcm_patchram_plus rootfs/usr/local/bin/
sudo cp -r archives/hwpacks/bluez/bluetooth-khadas.service rootfs/lib/systemd/system/
sudo cp -r archives/hwpacks/bluez/bluetooth-khadas.sh rootfs/usr/local/bin/
# rc.local
sudo cp -r archives/filesystem/etc/rc.local rootfs/etc/
# firstboot initialization: for 'ROOTFS' partition resize
sudo touch rootfs/etc/default/FIRSTBOOT

## script executing on chroot
sudo cp -r archives/filesystem/RUNME.sh rootfs/

## Chroot
sudo cp -a /usr/bin/qemu-aarch64-static rootfs/usr/bin/
echo
echo "NOTE: YOU ARE NOW IN THE VIRTUAL TARGET, SETUP ANYTHING YOU WANT."
echo "      TYPE 'exit' TO CONTINUE IF FINISHED."
echo
sudo mount -o bind /proc rootfs/proc
sudo mount -o bind /sys rootfs/sys
sudo mount -o bind /dev rootfs/dev
sudo mount -o bind /dev/pts rootfs/dev/pts
sudo chroot rootfs/

## Generate ramdisk.img
cp rootfs/boot/initrd.img images/initrd.img
./utils/mkbootimg --kernel linux/arch/arm64/boot/Image --ramdisk images/initrd.img -o images/ramdisk.img

## Backup the debs for rebuilding
cp -r rootfs/var/cache/apt/archives/*.deb archives/debs

## Clean up
sudo rm rootfs/var/cache/apt/archives/*.deb
sudo rm rootfs/boot/initrd.img

## Unmount to get the rootfs.img
sudo sync
sudo umount rootfs/dev/pts
sudo umount rootfs/dev
sudo umount rootfs/proc
sudo umount rootfs/sys
sudo umount rootfs

## Pack the images to update.img
./utils/aml_image_v2_packer -r images/upgrade/package.conf images/upgrade/ images/update.img

echo -e "\nDone."

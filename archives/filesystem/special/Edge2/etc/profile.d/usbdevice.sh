#!/bin/bash
#
# The configuration for usb mass storage function.
#
# @ USE: Use usbdevice or not. 0->not use, 1->use
# @ USB_FUNCS: Set USB gadget function, only ums function had been verified.
# @ UMS_MOUNT: /sys/kernel/config/usb_gadget/rockchip/functions/mass_storage.$UMS_MOUNT
# @ UMS_NUM: The number of mount point.
# @ UMS_FILES: The list of files to be mounted. Usually be a partition or a .img file.
# @ UMS_MOUNTPOINTS: The list of mount points.
# @ UMS_RO: The flag of read only. 0->Read & Write, 1->Read Only.

export USE=0
export USB_FUNCS="ums"
export UMS_MOUNT=0
export UMS_NUM=1
export UMS_FILES=(/dev/mmcblk0p8)
export UMS_MOUNTPOINTS=(/mnt)
export UMS_RO=0

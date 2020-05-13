MAINLINE-UBOOT
==============

one uboot source for krescue / debian / ubuntu / openwrt and any other distros

## Features ( patches )

+ univeral series for VIM1 VIM2 VIM3 VIM3L EDGE boards
+ suitable for SPI - SD - MMC
+ spi flash - read / write / bootup
+ usb kbd + storages
+ HDMI output
+ embed LOGO splash - easy customize
+ extra commands like `script` `kbi`
+ boot seq SPI => USB => SD => MMC => PXE => DHCP
+ fully stand-alone
+ auto store uboot env to first fat partition uboot.env file to booted source
+ some other small improves ...

VIMx status
=============

+ all problem fixed

EDGE status
=============

+ usb not works
+ HDMI video output scrabled screen (patch disabled 0400-edge_hdmi_display.patch )
+ 0022-reserve-memory-for-BL32.patch - this patch broke normal uboot behaviour 
    for $loadaddr usage for many commands
    becouse not possible to write into $loadaddr - its reserved
    *** trying to overwrite reserved memory... *** 
+ not complited
+ not full tested


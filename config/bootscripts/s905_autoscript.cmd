setenv kernel_loadaddr "0x11000000"
setenv initrd_loadaddr "0x13000000"
setenv condev "console=ttyS0,115200n8 console=tty0 no_console_suspend consoleblank=0"
setenv hdmiargs "logo=osd1,loaded,0x3d800000,${hdmimode} vout=${hdmimode},enable"
setenv bootargs "root=LABEL=ROOTFS rootflags=data=writeback rw ${condev} ${hdmiargs} fsck.repair=yes net.ifnames=0 ddr_size=${ddr_size} wol_enable=${wol_enable} jtag=disable"
setenv boot_start booti ${kernel_loadaddr} ${initrd_loadaddr} ${dtb_mem_addr}


## Import environment from env.txt
if fatload usb 0 ${kernel_loadaddr} /boot/env.txt || fatload usb 0 ${kernel_loadaddr} env.txt; then echo "Import env.txt"; env import -t ${kernel_loadaddr} ${filesize}; fi
if fatload usb 1 ${kernel_loadaddr} /boot/env.txt || fatload usb 1 ${kernel_loadaddr} env.txt; then echo "Import env.txt"; env import -t ${kernel_loadaddr} ${filesize}; fi
if fatload usb 2 ${kernel_loadaddr} /boot/env.txt || fatload usb 2 ${kernel_loadaddr} env.txt; then echo "Import env.txt"; env import -t ${kernel_loadaddr} ${filesize}; fi
if fatload usb 3 ${kernel_loadaddr} /boot/env.txt || fatload usb 3 ${kernel_loadaddr} env.txt; then echo "Import env.txt"; env import -t ${kernel_loadaddr} ${filesize}; fi
if fatload mmc 0 ${kernel_loadaddr} /boot/env.txt || fatload mmc 0 ${kernel_loadaddr} env.txt; then echo "Import env.txt"; env import -t ${kernel_loadaddr} ${filesize}; fi

### Check custom ethernet mac address
if test "X${custom_ethmac}" != "X"; then echo "Found custom ethmac: ${custom_ethmac}, overwrite eth_mac!"; setenv eth_mac ${custom_ethmac}; fi
setenv bootargs ${bootargs} mac=${eth_mac} androidboot.mac=${eth_mac}

## Boot
if fatload usb 0 ${initrd_loadaddr} uInitrd; then if fatload usb 0 ${kernel_loadaddr} zImage; then if fatload usb 0 ${dtb_mem_addr} dtb.img; then run boot_start; else store dtb read ${dtb_mem_addr}; run boot_start;fi;fi;fi;
if fatload usb 1 ${initrd_loadaddr} uInitrd; then if fatload usb 1 ${kernel_loadaddr} zImage; then if fatload usb 1 ${dtb_mem_addr} dtb.img; then run boot_start; else store dtb read ${dtb_mem_addr}; run boot_start;fi;fi;fi;
if fatload usb 2 ${initrd_loadaddr} uInitrd; then if fatload usb 2 ${kernel_loadaddr} zImage; then if fatload usb 2 ${dtb_mem_addr} dtb.img; then run boot_start; else store dtb read ${dtb_mem_addr}; run boot_start;fi;fi;fi;
if fatload usb 3 ${initrd_loadaddr} uInitrd; then if fatload usb 3 ${kernel_loadaddr} zImage; then if fatload usb 3 ${dtb_mem_addr} dtb.img; then run boot_start; else store dtb read ${dtb_mem_addr}; run boot_start;fi;fi;fi;
if fatload mmc 0 ${initrd_loadaddr} uInitrd; then if fatload mmc 0 ${kernel_loadaddr} zImage; then if fatload mmc 0 ${dtb_mem_addr} dtb.img; then run boot_start; else store dtb read ${dtb_mem_addr}; run boot_start;fi;fi;fi;

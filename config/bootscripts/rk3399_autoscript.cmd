echo "Run Khadas boot script"

kbi boarddetect

if test ${board_type} = 1; then
	setenv boot_dtb "rk3399-khadas-edge-linux.dtb";
else if test ${board_type} = 2; then
	setenv boot_dtb "rk3399-khadas-edgev-linux.dtb";
else if test ${board_type} = 3; then
	setenv boot_dtb "rk3399-khadas-captain-linux.dtb";
else if test ${board_type} = 0; then
	setenv boot_dtb;
	echo "Unsupported board detected! Stop here. Reboot...";
	sleep 5;
	reset;
fi;fi;fi;fi

if test ${devnum} = 0; then
	setenv boot_dtb "/boot/dtb/${boot_dtb}"
else if test ${devnum} = 1; then
	setenv boot_dtb "/dtb/${boot_dtb}"
fi;fi;

echo boot_dtb: ${boot_dtb}

setenv condev "earlyprintk console=ttyFIQ0,1500000n8 console=tty0"
setenv bootargs "${bootargs} ${condev} rw root=/dev/mmcblk1p7 rootfstype=ext4 init=/sbin/init rootwait board_type=${board_type} board_type_name=${board_type_name}"

setenv boot_start booti ${kernel_addr_r} ${ramdisk_addr_r} ${fdt_addr_r}

for distro_bootpart in ${devplist}; do
	echo "Scanning ${devtype} ${devnum}:${distro_bootpart}..."

	if load ${devtype} ${devnum}:${distro_bootpart} ${ramdisk_addr_r} uInitrd; then
		if load ${devtype} ${devnum}:${distro_bootpart} ${kernel_addr_r} zImage; then
			if load ${devtype} ${devnum}:${distro_bootpart} ${fdt_addr_r} ${boot_dtb}; then
				run boot_start;
			fi;
		fi;
	fi;

done

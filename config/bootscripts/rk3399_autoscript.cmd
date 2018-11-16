echo "Run Khadas boot script"

kbi boarddetect

if test ${board_type} = 0; then
	echo "Unsupported board detected! Stop here. Reboot...";
	sleep 5;
	reset;
fi

setenv emmc_root_part 7
setenv emmc_boot_part 7
setenv sd_root_part   2
setenv sd_boot_part   1

if test ${devnum} = 0; then
	echo "Uboot loaded from eMMC.";
	setenv boot_env_part ${emmc_boot_part};
	setenv root_part ${emmc_root_part}
	setenv mark_prefix "boot/"
	setenv default_rootdev "/dev/mmcblk1p${emmc_root_part}"
else if test ${devnum} = 1; then
	echo "Uboot loaded from SD.";
	setenv boot_env_part ${sd_boot_part};
	setenv root_part ${sd_root_part}
	setenv mark_prefix ""
	setenv default_rootdev "/dev/mmcblk0p${sd_root_part}"
fi;fi;

# Import environment from env.txt
if load ${devtype} ${devnum}:${boot_env_part} ${ramdisk_addr_r} /boot/env.txt || load ${devtype} ${devnum}:${boot_env_part} ${ramdisk_addr_r} env.txt; then
	echo "Import env.txt";
	env import -t ${ramdisk_addr_r} ${filesize}
fi

# Check root part filesystem UUID
fsuuid ${devtype} ${devnum}:${root_part} root_uuid
if test "UUID=${root_uuid}" != "${rootdev}"; then
	echo "Rootfs UUID mismatch! Set rootfs part to default: ${default_rootdev}"
	setenv rootdev ${default_rootdev}
fi

# Check MIPI
if test "${mipi_lcd_enabled}" = "true"; then
	setenv dtb_suffix "-mipi";
else
	setenv dtb_suffix "";
fi

if test -e mmc ${devnum}:${boot_env_part} ${mark_prefix}.next; then
	if test ${board_type} = 1; then
		setenv boot_dtb "rk3399-khadas-edge.dtb";
	else if test ${board_type} = 2; then
		setenv boot_dtb "rk3399-khadas-edgev${dtb_suffix}.dtb";
	else if test ${board_type} = 3; then
		setenv boot_dtb "rk3399-khadas-captain${dtb_suffix}.dtb";
	fi;fi;fi
else
	if test ${board_type} = 1; then
		setenv boot_dtb "rk3399-khadas-edge-linux.dtb";
	else if test ${board_type} = 2; then
		setenv boot_dtb "rk3399-khadas-edgev${dtb_suffix}-linux.dtb";
	else if test ${board_type} = 3; then
		setenv boot_dtb "rk3399-khadas-captain${dtb_suffix}-linux.dtb";
	fi;fi;fi
fi

if test ${devnum} = 0; then
	if test -e mmc ${devnum}:${boot_env_part} ${mark_prefix}.next; then
		setenv dtb_prefix "/boot/dtb/rockchip/";
	else
		setenv dtb_prefix "/boot/dtb/";
	fi
else if test ${devnum} = 1; then
	if test -e mmc ${devnum}:${boot_env_part} ${mark_prefix}.next; then
		setenv dtb_prefix "/dtb/rockchip/";
	else
		setenv dtb_prefix "/dtb/";
	fi
fi;fi;

echo DTB: ${dtb_prefix}${boot_dtb}

if test -e mmc ${devnum}:${boot_env_part} ${mark_prefix}.next; then
	setenv condev "earlyprintk console=ttyS2,1500000n8 console=tty0"
else
	setenv condev "earlyprintk console=ttyFIQ0,1500000n8 console=tty0"
fi

setenv boot_start booti ${kernel_addr_r} ${ramdisk_addr_r} ${fdt_addr_r}

setenv bootargs "${bootargs} ${condev} rw root=${rootdev} rootfstype=ext4 init=/sbin/init rootwait board_type=${board_type} board_type_name=${board_type_name} fan=${fan_mode}"

for distro_bootpart in ${devplist}; do
	echo "Scanning ${devtype} ${devnum}:${distro_bootpart}..."

	if load ${devtype} ${devnum}:${distro_bootpart} ${ramdisk_addr_r} uInitrd; then
		if load ${devtype} ${devnum}:${distro_bootpart} ${kernel_addr_r} zImage; then
			if load ${devtype} ${devnum}:${distro_bootpart} ${fdt_addr_r} ${dtb_prefix}${boot_dtb}; then
				run boot_start;
			fi;
		fi;
	fi;

done

# Rebuilt
# mkimage -A arm64 -O linux -T script -C none -a 0 -e 0 -n "rk3399 autoscript" -d /boot/rk3399_autoscript.cmd /boot/boot.scr

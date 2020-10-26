echo "Run Khadas boot script"

setenv dtbo_loadaddr "0x5000000"

# Constant
setenv BOARD_TYPE_NONE		0
setenv BOARD_TYPE_EDGE		1
setenv BOARD_TYPE_EDGE_V	2
setenv BOARD_TYPE_CAPTAIN	3

# Detect board type
kbi boarddetect

if test ${board_type} = ${BOARD_TYPE_NONE}; then
	echo "Unsupported board detected! Stop here. Reboot...";
	sleep 5;
	reset;
fi

setenv emmc_root_part		7
setenv emmc_boot_part		7
setenv emmc_mbr_root_part	2
setenv emmc_mbr_boot_part	1
setenv sd_root_part			2
setenv sd_boot_part			1

if test ${devnum} = 0; then
	echo "Uboot loaded from eMMC.";
	if test -e mmc ${devnum}:${emmc_root_part} zImage; then
		setenv imagetype "EMMC";
		setenv boot_env_part ${emmc_boot_part};
		setenv root_part ${emmc_root_part};
		setenv mark_prefix "boot/";
	else
		setenv imagetype "EMMC_MBR";
		setenv boot_env_part ${emmc_mbr_boot_part};
		setenv root_part ${emmc_mbr_root_part};
		setenv mark_prefix "";
	fi;

	if test -e mmc ${devnum}:${boot_env_part} ${mark_prefix}.next; then
		setenv default_rootdev "/dev/mmcblk2p${root_part}"
	else
		setenv default_rootdev "/dev/mmcblk1p${root_part}"
	fi
else if test ${devnum} = 1; then
	echo "Uboot loaded from SD.";
	setenv boot_env_part ${sd_boot_part};
	setenv root_part ${sd_root_part}
	setenv mark_prefix ""
	if test -e mmc ${devnum}:${boot_env_part} ${mark_prefix}.next; then
		setenv default_rootdev "/dev/mmcblk1p${sd_root_part}"
	else
		setenv default_rootdev "/dev/mmcblk0p${sd_root_part}"
	fi
	setenv imagetype "SD-USB";
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
	if test ${board_type} = ${BOARD_TYPE_EDGE}; then
		setenv boot_dtb "rk3399-khadas-edge.dtb";
	else if test ${board_type} = ${BOARD_TYPE_EDGE_V}; then
		setenv boot_dtb "rk3399-khadas-edge-v.dtb";
		setenv overlaydir "edgev";
	else if test ${board_type} = ${BOARD_TYPE_CAPTAIN}; then
		setenv boot_dtb "rk3399-khadas-edge-captain.dtb";
		setenv overlaydir "captain";
	fi;fi;fi
else
	if test ${board_type} = ${BOARD_TYPE_EDGE}; then
		setenv boot_dtb "rk3399-khadas-edge-linux.dtb";
	else if test ${board_type} = ${BOARD_TYPE_EDGE_V}; then
		setenv boot_dtb "rk3399-khadas-edgev${dtb_suffix}-linux.dtb";
		setenv overlaydir "edgev";
	else if test ${board_type} = ${BOARD_TYPE_CAPTAIN}; then
		setenv boot_dtb "rk3399-khadas-captain${dtb_suffix}-linux.dtb";
		setenv overlaydir "captain";
	fi;fi;fi
fi

if test ${devnum} = 0; then
	if test -e mmc ${devnum}:${boot_env_part} ${mark_prefix}.next; then
		if test ${imagetype} = EMMC_MBR; then
			setenv dtb_prefix "/dtb/rockchip/";
		else
			setenv dtb_prefix "/boot/dtb/rockchip/";
		fi
	else
		if test ${imagetype} = EMMC_MBR; then
			setenv dtb_prefix "/dtb/";
		else
			setenv dtb_prefix "/boot/dtb/";
		fi
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

part uuid mmc ${devnum}:1 ubootpartuuid;
if test "X${ubootpartuuid}" = "X"; then
	echo "Can not get u-boot part UUID, set to NULL";
	setenv ubootpartuuid "NULL";
fi;

kbi ethmac
if test -e ${custom_ethmac}; then
	echo "Found custom ethmac: ${custom_ethmac}, overwrite eth_mac!";
	setenv eth_mac ${custom_ethmac}
fi

if test "X${eth_mac}" = "X" || test "X${eth_mac}" = "X00:00:00:00:00:00"; then
	echo "Set default mac address to ethaddr: ${ethaddr}!";
	setenv eth_mac ${ethaddr};
	setenv saveethmac "save_ethmac=yes";
fi;

if test -e ${loglevel}; then
	setenv log "loglevel=${loglevel}"
fi

setenv bootargs "${bootargs} ${condev} ${log} rw root=${rootdev} rootfstype=ext4 init=/sbin/init rootwait ubootpart=${ubootpartuuid} board_type=${board_type} board_type_name=${board_type_name} khadas_board=${board_type_name} fan=${fan_mode} mac=${eth_mac} androidboot.mac=${eth_mac} ${saveethmac} coherent_pool=${dma_size} imagetype=${imagetype} ${user_kernel_args}"

for distro_bootpart in ${devplist}; do
	echo "Scanning ${devtype} ${devnum}:${distro_bootpart}..."

	if load ${devtype} ${devnum}:${distro_bootpart} ${ramdisk_addr_r} uInitrd; then
		if load ${devtype} ${devnum}:${distro_bootpart} ${kernel_addr_r} zImage; then
			if load ${devtype} ${devnum}:${distro_bootpart} ${fdt_addr_r} ${dtb_prefix}${boot_dtb}; then
				fdt addr ${fdt_addr_r};
				fdt resize 65536;
				if test "X${overlays}" != "X"; then
				    for overlay in ${overlays}; do
						echo Apply dtbo ${overlay}
						if load ${devtype} ${devnum}:${distro_bootpart} ${dtbo_loadaddr} ${mark_prefix}dtb/overlays/${overlaydir}/${overlay}.dtbo; then
							fdt apply ${dtbo_loadaddr}
						fi
					done
				fi;
				run boot_start;
			fi;
		fi;
	fi;

done

# Rebuilt
# mkimage -A arm64 -O linux -T script -C none -a 0 -e 0 -n "rk3399 autoscript" -d /boot/rk3399_autoscript.cmd /boot/boot.scr

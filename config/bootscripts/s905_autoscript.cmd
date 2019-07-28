echo "Starting S905 autoscript..."

setenv kernel_loadaddr "0x11000000"
setenv dtb_loadaddr "0x1000000"
setenv initrd_loadaddr "0x13000000"
setenv env_loadaddr "0x20000000"

setenv hdmiargs "logo=${display_layer},loaded,${fb_addr},${outputmode} vout=${outputmode},enable hdmimode=${hdmimode}"

if test "X${lcd_exist}" = "X1"; then
	setenv panelargs "panel_exist=${lcd_exist} panel_type=${panel_type}";
fi;

if test "X${fdtfile}" = "Xamlogic/meson-gxl-s905x-khadas-vim.dtb"; then
	setenv uboottype "mainline";
	setenv khadas_board "VIM1";
else if test "X${fdtfile}" = "Xamlogic/meson-gxm-khadas-vim2.dtb"; then
	setenv uboottype "mainline";
	setenv khadas_board "VIM2";
else if test "X${fdtfile}" = "Xamlogic/meson-g12b-khadas-vim3.dtb"; then
	setenv uboottype "mainline";
	setenv khadas_board "VIM3";
else
	setenv uboottype "vendor";
	if test "X${maxcpus}" = "X4"; then
		setenv khadas_board "VIM1";
	else if test "X${maxcpus}" = "X8"; then
		setenv khadas_board "VIM2";
	else if test "X${maxcpus}" = "X6"; then
		setenv khadas_board "VIM3";
	fi;fi;fi;
fi;fi;fi;

echo "uboot type: $uboottype"

if test "X${autoscript_source}" = "Xmmc"; then
	echo "autoscript loaded from: mmc";
	setenv devs "mmc";
else if test "X${autoscript_source}" = "Xusb"; then
	echo "autoscript loaded from: usb";
	setenv devs "usb";
else
	setenv devs "mmc usb";
fi;fi;
setenv mmc_devplist "1 5"
setenv mmc_devnums "0 1 2"
setenv usb_devplist "1"
setenv usb_devnums "0 1 2 3"

setenv boot_start booti ${kernel_loadaddr} ${initrd_loadaddr} ${dtb_loadaddr}

## First, boot from mmc
## Second, boot from USB storage
for dev in ${devs}; do
	if test "X${dev}" = "Xmmc"; then
		setenv devplist ${mmc_devplist};
		setenv devnums ${mmc_devnums};
	else if test "X${dev}" = "Xusb"; then
		setenv devplist ${usb_devplist};
		setenv devnums ${usb_devnums};
	fi;fi;
	for dev_num in ${devnums}; do
		for distro_bootpart in ${devplist}; do
			echo "Scanning ${dev} ${dev_num}:${distro_bootpart}...";
			if test "X${distro_bootpart}" = "X5"; then
				setenv load_method "ext4load";
				setenv mark_prefix "boot/";
				setenv imagetype "EMMC";
			else
				setenv load_method "fatload";
				setenv mark_prefix "";
				if test "X${uboottype}" = "Xvendor"; then
					if test "X${dev_num}" = "X0"; then
						setenv imagetype "SD-USB";
					else
						setenv imagetype "EMMC_MBR";
					fi;
				else
					if test "X${dev_num}" = "X1"; then
						setenv imagetype "SD-USB";
					else
						setenv imagetype "EMMC_MBR";
					fi;
				fi;
			fi;
			if ${load_method} ${dev} ${dev_num}:${distro_bootpart} ${initrd_loadaddr} uInitrd; then
				if ${load_method} ${dev} ${dev_num}:${distro_bootpart} ${kernel_loadaddr} zImage; then
					if ${load_method} ${dev} ${dev_num}:${distro_bootpart} ${dtb_loadaddr} dtb.img; then
						if ${load_method} ${dev} ${dev_num}:${distro_bootpart} ${env_loadaddr} /boot/env.txt || ${load_method} ${dev} ${dev_num}:${distro_bootpart} ${env_loadaddr} env.txt; then
							echo "Import env.txt"; env import -t ${env_loadaddr} ${filesize};
						fi;
						if test "X${rootdev}" = "X"; then
							echo "rootdev is missing! use default: root=LABEL=ROOTFS!";
							setenv rootdev "LABEL=ROOTFS";
						fi;
						if test "X${dev}" = "Xmmc"; then
							part uuid mmc ${dev_num}:${distro_bootpart} ubootpartuuid;
							if test "X${ubootpartuuid}" = "X"; then
								echo "Can not get u-boot part UUID, set to NULL";
								setenv ubootpartuuid "NULL";
							fi;
						else
							setenv ubootpartuuid "NULL";
						fi;
						if test "X${custom_ethmac}" != "X"; then
							echo "Found custom ethmac: ${custom_ethmac}, overwrite eth_mac!";
							setenv eth_mac ${custom_ethmac};
						fi;
						if test "X${eth_mac}" = "X"; then
							echo "Set default mac address to ethaddr: ${ethaddr}!";
							setenv eth_mac ${ethaddr};
							setenv save_ethmac "yes";
						fi;
						if test -e ${dev} ${dev_num}:${distro_bootpart} ${mark_prefix}.next; then
							echo "Booting mainline kernel...";
							setenv condev "console=ttyAML0,115200n8 console=tty0 no_console_suspend consoleblank=0";
						else
							echo "Booting legacy kernel...";
							setenv condev "console=ttyS0,115200n8 console=tty0 no_console_suspend consoleblank=0";
						fi;

						fdt addr ${dtb_loadaddr};
						fdt resize 65536;
						if test "X${hwver}" = "XVIM2.V14"; then
							fdt set /fan hwver "VIM2.V14";
							fdt set /i2c@c11087c0/khadas-mcu hwver "VIM2.V14";
							fdt set /soc/cbus@c1100000/i2c@87c0/khadas-mcu hwver "VIM2.V14";
						else if test "X${hwver}" = "XVIM3.V11"; then
							fdt set /soc/aobus@ff800000/i2c@5000/khadas-mcu hwver "VIM3.V11";
							kbi init;
							kbi portmode r;
							if test ${port_mode} = 0; then
								fdt set /usb3phy@ffe09080 portnum <1>;
								fdt set /pcieA@fc000000 status disabled;
							else
								fdt set /usb3phy@ffe09080 portnum <0>;
								fdt set /pcieA@fc000000 status okay;
							fi;
						fi;fi;
						if test "X${imagetype}" = "XEMMC_MBR"; then
							echo "Remove eMMC vendor partitions...";
							fdt rm /partitions;
						fi;
						setenv bootargs "root=${rootdev} rootfstype=ext4 rootflags=data=writeback rw ubootpart=${ubootpartuuid} ${condev} ${hdmiargs} ${panelargs} fsck.repair=yes net.ifnames=0 ddr_size=${ddr_size} wol_enable=${wol_enable}  jtag=disable mac=${eth_mac} androidboot.mac=${eth_mac} save_ethmac=${save_ethmac} fan=${fan_mode} khadas_board=${khadas_board} hwver=${hwver} coherent_pool=${dma_size} reboot_mode=${reboot_mode} imagetype=${imagetype} uboottype=${uboottype}";
						run boot_start;
					fi;
				fi;
			fi;
		done;
	done;
done

# Rebuilt
# mkimage -A arm64 -O linux -T script -C none -a 0 -e 0 -n "S905 autoscript" -d /boot/s905_autoscript.cmd /boot/s905_autoscript
# mkimage -A arm64 -O linux -T script -C none -a 0 -e 0 -n "S905 autoscript" -d /boot/s905_autoscript.cmd /boot/boot.scr

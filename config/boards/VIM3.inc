#!/bin/bash
###################################
## VIM3 series common part
###################################

#### Packing image
IMAGE_PACKAGE_CONF=package_g12.conf
IMAGE_PLATFORM_CONF=platform_g12.conf

###################################
## Include VIM series common part
###################################
source config/boards/VIM.inc

###################################
## tweaks for platform
tweaks_platform() {
	echo "#Serial console allow root" >> $ROOTFS_TEMP/etc/securetty
	echo "ttyAML0" >> $ROOTFS_TEMP/etc/securetty

	# Enable services
	eval 'LC_ALL=C LANG=C chroot $ROOTFS_TEMP /bin/bash -c "systemctl --no-reload enable fan.service"'

	if [ "$DISTRIB_TYPE" != "server" ] && [ "$LINUX" != "mainline" ]; then
		eval 'LC_ALL=C LANG=C chroot $ROOTFS_TEMP /bin/bash -c "systemctl --no-reload enable panel.service hdmi_resolution.service"'
	fi

	if [ "$LINUX" != "mainline" ]; then
		eval 'LC_ALL=C LANG=C chroot $ROOTFS_TEMP /bin/bash -c "systemctl --no-reload enable bluetooth-khadas.service"'
		if [ "$KHADAS_BOARD" == "VIM3" ]; then
			eval 'LC_ALL=C LANG=C chroot $ROOTFS_TEMP /bin/bash -c "systemctl --no-reload enable camera_isp_3a_server.service"'
		fi
	fi

	# Create boot links
	if [ "$INSTALL_TYPE" == "EMMC" ]; then
		eval 'LC_ALL=C LANG=C chroot $ROOTFS_TEMP /bin/bash -c "ln -fs /boot/zImage zImage"'
		eval 'LC_ALL=C LANG=C chroot $ROOTFS_TEMP /bin/bash -c "ln -fs /boot/uInitrd uInitrd"'
		eval 'LC_ALL=C LANG=C chroot $ROOTFS_TEMP /bin/bash -c "ln -fs /boot/dtb/$(basename $LINUX_DTB) dtb.img"'
	else
		# Setup default DTB for SD/USB images
		if [ "$LINUX" == "mainline" ]; then
			eval 'LC_ALL=C LANG=C chroot $ROOTFS_TEMP /bin/bash -c "cp /boot/dtb/amlogic/$(basename $LINUX_DTB) /boot/dtb.img"'
		else
			eval 'LC_ALL=C LANG=C chroot $ROOTFS_TEMP /bin/bash -c "cp /boot/dtb/$(basename $LINUX_DTB) /boot/dtb.img"'
		fi
	fi
}

## Build deb packages for platform
build_deb_packages_platform() {

	if [ "$DISTRIB_TYPE" == "minimal" ]; then
		warning_msg "Ignore build platform packages for minimal image."
		return 0
	fi

	if [ "$LINUX" == "4.9" ] && [ "$DISTRIBUTION" == "Ubuntu" ]; then

		info_msg "Building Kodi packages..."
		# FIXME
		# remove build stamp to force build for other arch
		rm -rf $BUILD/.stamps/kodi_aml
		build_package "kodi_aml:target"

		info_msg "Building libplayer_aml packages..."
		# FIXME
		# remove build stamp to force build for other arch
		rm -rf $BUILD/.stamps/libplayer_aml
		build_package "libplayer_aml:target"

		info_msg "Building amremote packages..."
		# FIXME
		# remove build stamp to force build for other arch
		rm -rf $BUILD/.stamps/amremote
		build_package "amremote:target"

		info_msg "Building gstreamer_aml packages..."
		# FIXME
		# remove build stamp to force build for other arch
		rm -rf $BUILD/.stamps/gstreamer_aml
		build_package "gstreamer_aml:target"

		info_msg "Building npu_aml packages..."
		# FIXME
		# remove build stamp to force build for other arch
		rm -rf $BUILD/.stamps/npu_aml
		build_package "npu_aml:target"

		info_msg "Building opencv3 packages..."
		# FIXME
		# remove build stamp to force build for other arch
		rm -rf $BUILD/.stamps/opencv3
		build_package "opencv3:target"

		info_msg "Building edid-decode-deb packages..."
		# FIXME
		# remove build stamp to force build for other arch
		rm -rf $BUILD/.stamps/edid-decode-deb
		build_package "edid-decode-deb:target"

		info_msg "Building mali_examples_aml packages..."
		# FIXME
		# remove build stamp to force build for other arch
		rm -rf $BUILD/.stamps/mali_examples_aml
		build_package "mali_examples_aml:target"

		info_msg "Building libcec..."
		# FIXME
		# remove build stamp to force build for other arch
		rm -rf $BUILD/.stamps/libcec_debs
		build_package "libcec_debs:target"

		info_msg "Building encoder..."
		# FIXME
		# remove build stamp to force build for other arch
		rm -rf $BUILD/.stamps/encoder_libs_deb_aml
		build_package "encoder_libs_deb_aml:target"
	fi

	if [ "$LINUX" == "mainline" ] && [ "$DISTRIB_RELEASE" != "bionic" ] && [ "$DISTRIB_TYPE" != "server" ]; then
		info_msg "Building mesa..."
		# FIXME
		# remove build stamp to force build for other arch
		rm -rf $BUILD/.stamps/mesa_debs
		build_package "mesa_debs:target"
	fi

}

## Install deb packages for platform
install_deb_packages_platform() {

	if [ "$DISTRIB_TYPE" == "minimal" ]; then
		warning_msg "Ignore install platform packages for minimal image."
		return 0
	fi

	if [ "$LINUX" == "4.9" ] && [ "$DISTRIBUTION" == "Ubuntu" ]; then

		cd $ROOT

		# Install Kodi in chroot
		info_msg "Installing Kodi packages..."
		if [ $DISTRIB_RELEASE == "bionic" ]; then
			install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/kodi/*.deb
		elif [ $DISTRIB_RELEASE == "focal" ]; then
			debs=$(ls $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/kodi/deps/*.deb)
			for deb in $debs
			do
				install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/kodi/deps/$(basename $deb)
			done
			install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/kodi/kodi-bin_*.deb
			install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/kodi/kodi_*.deb
		fi

		info_msg "Installing libplayer_aml packages..."
		install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/libplayer_aml/*.deb

		info_msg "Installing amremote packages..."
		install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/amremote/*.deb

		info_msg "Installing gstreamer_aml packages..."
		install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/gstreamer_aml/*.deb

		info_msg "Installing npu_aml packages..."
		install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/npu_aml/*.deb

		info_msg "Installing opencv3 packages..."
		install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/opencv3/*.deb

		# Enable khadas remote
		eval 'LC_ALL=C LANG=C chroot $ROOTFS_TEMP /bin/bash -c "systemctl --no-reload enable amlogic-remotecfg.service"'

		info_msg "Installing edid-decode-deb packages..."
		install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/edid-decode-deb/*.deb

		info_msg "Installing mali_examples_aml packages..."
		install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/mali_examples_aml/*.deb

		# Install libcec in chroot
		info_msg "Installing libcec..."
		install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/libcec/libcec4_*.deb
		install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/libcec/libcec_*.deb
		install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/libcec/libcec4-*.deb
		install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/libcec/python3-libcec_*.deb
		install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/libcec/cec-utils_*.deb

		# Install encoder libriries in chroot
		install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/encoder/*.deb
	fi

	if [ "$LINUX" == "mainline" ] && [ "$DISTRIB_TYPE" != "server" ]; then
		# Install mesa in chroot
		info_msg "Installing mesa..."

		if [ "$DISTRIB_RELEASE" == "focal" ]; then
			install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/mesa/mesa/libd3dadapter9-mesa_*_arm64.deb
			install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/mesa/mesa/libegl1-mesa_*_arm64.deb
			install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/mesa/mesa/libgbm1_*_arm64.deb
			install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/mesa/mesa/libglapi-mesa_*_arm64.deb
			install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/mesa/mesa/libgl1-mesa-dri_*_arm64.deb
			install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/mesa/mesa/libgles2-mesa_*_arm64.deb
			install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/mesa/mesa/libegl-mesa0_*_arm64.deb
			install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/mesa/mesa/libglx-mesa0_*_arm64.deb
			install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/mesa/mesa/libgl1-mesa-glx_*_arm64.deb
			install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/mesa/mesa/libosmesa6_*_arm64.deb
			install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/mesa/mesa/libwayland-egl1-mesa_*_arm64.deb
			install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/mesa/mesa/mesa-opencl-icd_*_arm64.deb
			install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/mesa/mesa/mesa-va-drivers_*_arm64.deb
			install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/mesa/mesa/mesa-vdpau-drivers_*_arm64.deb
			install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/mesa/mesa/mesa-vulkan-drivers_*_arm64.deb
			#install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/mesa/mesa/mesa-common-dev_*_arm64.deb
		fi
	fi
}

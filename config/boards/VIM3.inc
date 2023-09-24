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
	# Setup GST environment
	echo "export GST_DEFAULT_V4L2_BUF_MODE=DMA_BUF_IMPORT" >> $ROOTFS_TEMP/etc/bash.bashrc

	# Enable services
	execute_in_chroot "systemctl --no-reload enable fan.service"

	if [ "$LINUX" != "mainline" ]; then
		execute_in_chroot "systemctl --no-reload enable panel.service"
		if [ "$DISTRIB_TYPE" != "server" ]; then
			execute_in_chroot "systemctl --no-reload enable tone2-control.service"
			execute_in_chroot "systemctl --no-reload enable hdmi_resolution.service"
		fi
	fi

	if [ "$LINUX" != "mainline" ]; then
		execute_in_chroot "systemctl --no-reload enable bluetooth-khadas.service"
		if [ "$KHADAS_BOARD" == "VIM3" ]; then
			execute_in_chroot "systemctl --no-reload enable camera_isp_3a_server.service"
		fi
	fi

	# Create boot links
	if [ "$INSTALL_TYPE" == "EMMC" ]; then
		if [ "$LINUX" != "5.15" ]; then
			execute_in_chroot "ln -fs /boot/zImage zImage"
			execute_in_chroot "ln -fs /boot/uInitrd uInitrd"
			execute_in_chroot "ln -fs /boot/dtb/$(basename $LINUX_DTB) dtb.img"
		else
			execute_in_chroot "ln -fs /boot/Image Image"
			execute_in_chroot "ln -fs /boot/initrd.img initrd.img"
			execute_in_chroot "ln -fs /boot/dtb/amlogic/$(basename $LINUX_DTB) dtb.img"
			execute_in_chroot "ln -fs /boot/dtb dtb"
		fi
	else
		# Setup default DTB for SD/USB images
		if [ "$LINUX" == "mainline" ] || [ "$LINUX" == "5.15" ]; then
			execute_in_chroot "ln -fs dtb/amlogic/$(basename $LINUX_DTB) /boot/dtb.img || cp /boot/dtb/amlogic/$(basename $LINUX_DTB) /boot/dtb.img"
		else
			execute_in_chroot "cp /boot/dtb/$(basename $LINUX_DTB) /boot/dtb.img"
		fi
	fi
}

## Build deb packages for platform
build_deb_packages_platform() {

	if [ "$DISTRIB_TYPE" == "minimal" ]; then
		warning_msg "Ignore build platform packages for minimal image."
		return 0
	fi

	if [ "$DISTRIBUTION" == "Ubuntu" ]; then

		info_msg "Building npu_aml packages..."
		# FIXME
		# remove build stamp to force build for other arch
		rm -rf $BUILD/.stamps/npu_aml
		build_package "npu_aml:target"

		if [ "$LINUX" == "4.9" ]; then

			if [ "$DISTRIB_RELEASE" != "jammy" ]; then
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

				info_msg "Building gstreamer_aml packages..."
				# FIXME
				# remove build stamp to force build for other arch
				rm -rf $BUILD/.stamps/gstreamer_aml
				build_package "gstreamer_aml:target"
			fi

			info_msg "Building amremote packages..."
			# FIXME
			# remove build stamp to force build for other arch
			rm -rf $BUILD/.stamps/amremote
			build_package "amremote:target"

			if [ "$DISTRIB_RELEASE" == "bionic" ]; then
				info_msg "Building opencv3 packages..."
				# FIXME
				# remove build stamp to force build for other arch
				rm -rf $BUILD/.stamps/opencv3
				build_package "opencv3:target"
			fi

			if [ "$DISTRIB_RELEASE" != "jammy" ]; then
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
			fi

			info_msg "Building encoder..."
			# FIXME
			# remove build stamp to force build for other arch
			rm -rf $BUILD/.stamps/encoder_libs_deb_aml
			build_package "encoder_libs_deb_aml:target"
		fi

		if [ "$LINUX" == "5.15" ]; then
			if [ "$DISTRIB_RELEASE" == "jammy" ]; then
				if [ "$DISTRIB_TYPE" != "server" ]; then
					info_msg "Building mali-debs package..."
					# FIXME
					# remove build stamp to force build for other arch
					rm -rf $BUILD/.stamps/mali-debs
					build_package "mali-debs:target"
				fi

				info_msg "Building OPTEE userspace package..."
				# FIXME
				# remove build stamp to force build for other arch
				rm -rf $BUILD/.stamps/optee_userspace_deb_aml
				build_package "optee_userspace_deb_aml:target"

				info_msg "Building OPTEE video firmware package..."
				# FIXME
				# remove build stamp to force build for other arch
				rm -rf $BUILD/.stamps/optee_video_firmware_deb_aml
				build_package "optee_video_firmware_deb_aml:target"

				info_msg "Building libion package..."
				# FIXME
				# remove build stamp to force build for other arch
				rm -rf $BUILD/.stamps/libion_deb_aml
				build_package "libion_deb_aml:target"

				info_msg "Building libge2d package..."
				# FIXME
				# remove build stamp to force build for other arch
				rm -rf $BUILD/.stamps/libge2d_deb_aml
				build_package "libge2d_deb_aml:target"

				info_msg "Building libjpegenc package..."
				# FIXME
				# remove build stamp to force build for other arch
				rm -rf $BUILD/.stamps/libjpegenc_deb_aml
				build_package "libjpegenc_deb_aml:target"

				# FIXME
				# remove build stamp to force build for other arch
				rm -rf $BUILD/.stamps/libamvenc_deb_aml
				build_package "libamvenc_deb_aml:target"

				info_msg "Building multimedia package..."
				# FIXME
				# remove build stamp to force build for other arch
				rm -rf $BUILD/.stamps/multimedia_debs_aml
				build_package "multimedia_debs_aml:target"

				info_msg "Building gstreamer_aml package..."
				# FIXME
				# remove build stamp to force build for other arch
				rm -rf $BUILD/.stamps/gstreamer_aml
				build_package "gstreamer_aml:target"

				info_msg "Building meson-display package..."
				# FIXME
				# remove build stamp to force build for other arch
				rm -rf $BUILD/.stamps/meson-display-deb-aml
				build_package "meson-display-deb-aml:target"
			fi
		fi
	fi

	if [ "$LINUX" == "mainline" ] && [ "$DISTRIB_RELEASE" != "bionic" ] && [ "$DISTRIB_RELEASE" != "jammy" ] && [ "$DISTRIB_TYPE" != "server" ]; then
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

	if [ "$DISTRIBUTION" == "Ubuntu" ]; then

		cd $ROOT

		info_msg "Installing npu_aml packages..."
		install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/npu_aml/*.deb

		if [ "$LINUX" == "4.9" ]; then

			if [ "$DISTRIB_RELEASE" != "jammy" ]; then
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

				info_msg "Installing gstreamer_aml packages..."
				install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/gstreamer_aml/*.deb
			fi

			info_msg "Installing amremote packages..."
			install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/amremote/*.deb

			if [ "$DISTRIB_RELEASE" == "bionic" ]; then
				info_msg "Installing opencv3 packages..."
				install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/opencv3/*.deb
			fi

			# Enable khadas remote
			eval 'LC_ALL=C LANG=C chroot $ROOTFS_TEMP /bin/bash -c "systemctl --no-reload enable amlogic-remotecfg.service"'

			if [ "$DISTRIB_RELEASE" != "jammy" ]; then
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
			fi

			# Install encoder libriries in chroot
			install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/encoder/*.deb
		fi

		if [ "$LINUX" == "5.15" ]; then
			if [ "$DISTRIB_RELEASE" == "jammy" ]; then
				if [ "$DISTRIB_TYPE" != "server" ]; then
					info_msg "Installing mali-debs package ..."
					install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/mali-debs/${GPU_PLATFORM}/*.deb
				fi

				info_msg "Installing OPTEE userspace package..."
				install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/optee_userspace_deb_aml/*.deb

				info_msg "Installing OPTEE video firmware package..."
				install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/optee_video_firmware_deb_aml/*.deb

				info_msg "Installing libion package..."
				install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/libion_deb_aml/*.deb

				info_msg "Installing libge2d package..."
				install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/libge2d_deb_aml/*.deb

				info_msg "Installing libjpegenc package..."
				install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/libjpegenc_deb_aml/*.deb

				info_msg "Installing libamvenc package..."
				install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/libamvenc_deb_aml/*.deb

				# Multimdia
				info_msg "Installing multimdia package..."
				install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/multimedia_debs_aml/gst-aml-drmbufferpool-plugins_*.deb
				install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/multimedia_debs_aml/ispaml_*.deb

				info_msg "Installing gstreamer_aml package..."
				install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/gstreamer_aml/${LINUX}/gstreamer-aml_*.deb
				# gstreamer1.0
				install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/gstreamer_aml/${LINUX}/gstreamer1.0-debs/libgstreamer1.0-0_*.deb
				install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/gstreamer_aml/${LINUX}/gstreamer1.0-debs/gir1.2-gstreamer-1.0_*.deb
				install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/gstreamer_aml/${LINUX}/gstreamer1.0-debs/gstreamer1.0-tools_*.deb
				# gst-plugins-base1.0
				install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/gstreamer_aml/${LINUX}/gst-plugins-base1.0-debs/libgstreamer-plugins-base1.0-0_*.deb
				install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/gstreamer_aml/${LINUX}/gst-plugins-base1.0-debs/libgstreamer-gl1.0-0_*.deb
				install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/gstreamer_aml/${LINUX}/gst-plugins-base1.0-debs/gstreamer1.0-plugins-base_*.deb
				install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/gstreamer_aml/${LINUX}/gst-plugins-base1.0-debs/gstreamer1.0-plugins-base-apps_*.deb
				#install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/gstreamer_aml/${LINUX}/gst-plugins-base1.0-debs/gstreamer1.0-x_*.deb
				install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/gstreamer_aml/${LINUX}/gst-plugins-base1.0-debs/gstreamer1.0-alsa_*.deb
				install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/gstreamer_aml/${LINUX}/gst-plugins-base1.0-debs/gir1.2-gst-plugins-base-1.0_*.deb
				# gst-plugins-good1.0
				install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/gstreamer_aml/${LINUX}/gst-plugins-good1.0-debs/libgstreamer-plugins-good1.0-0_*.deb
				install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/gstreamer_aml/${LINUX}/gst-plugins-good1.0-debs/gstreamer1.0-plugins-good_*.deb
				install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/gstreamer_aml/${LINUX}/gst-plugins-good1.0-debs/gstreamer1.0-pulseaudio_*.deb
				# gst-plugins-bad1.0
				install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/gstreamer_aml/${LINUX}/gst-plugins-bad1.0-debs/libgstreamer-plugins-bad1.0-0_*.deb
				install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/gstreamer_aml/${LINUX}/gst-plugins-bad1.0-debs/gstreamer1.0-plugins-bad_*.deb

				info_msg "Installing meson-display package..."
				install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/meson-display-deb-aml/*.deb
			fi
		fi
	fi

	if [ "$LINUX" == "mainline" ] && [ "$DISTRIB_RELEASE" != "jammy" ] && [ "$DISTRIB_TYPE" != "server" ]; then
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

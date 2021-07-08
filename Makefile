all:
ifeq ($(and $(DISTRIBUTION),$(DISTRIB_RELEASE),$(DISTRIB_TYPE),$(DISTRIB_ARCH),$(KHADAS_BOARD),$(LINUX),$(UBOOT),$(INSTALL_TYPE)),)
	$(call help_message)
else
	@./scripts/create_image.sh
endif

define help_message
	@echo "You should setup environment first."
	@echo "Run 'source env/setenv.sh' to setup environment."
endef

image:
ifeq ($(and $(DISTRIBUTION),$(DISTRIB_RELEASE),$(DISTRIB_TYPE),$(DISTRIB_ARCH),$(KHADAS_BOARD),$(LINUX),$(UBOOT),$(INSTALL_TYPE)),)
	$(call help_message)
else
	@echo "This script requires root privileges, trying to use sudo, please enter your passowrd!"
	@sudo -E ./scripts/make_image.sh
endif

kernel:
ifeq ($(and $(DISTRIBUTION),$(DISTRIB_RELEASE),$(DISTRIB_TYPE),$(DISTRIB_ARCH),$(KHADAS_BOARD),$(LINUX),$(UBOOT),$(INSTALL_TYPE)),)
	$(call help_message)
else
	@./scripts/build.sh linux
endif

kernel-clean:
ifeq ($(and $(DISTRIBUTION),$(DISTRIB_RELEASE),$(DISTRIB_TYPE),$(DISTRIB_ARCH),$(KHADAS_BOARD),$(LINUX),$(UBOOT),$(INSTALL_TYPE)),)
	$(call help_message)
else
	@./scripts/build.sh linux-clean
endif

kernel-config:
ifeq ($(and $(DISTRIBUTION),$(DISTRIB_RELEASE),$(DISTRIB_TYPE),$(DISTRIB_ARCH),$(KHADAS_BOARD),$(LINUX),$(UBOOT),$(INSTALL_TYPE)),)
	$(call help_message)
else
	@./scripts/build.sh linux-config
endif

kernel-saveconfig:
ifeq ($(and $(DISTRIBUTION),$(DISTRIB_RELEASE),$(DISTRIB_TYPE),$(DISTRIB_ARCH),$(KHADAS_BOARD),$(LINUX),$(UBOOT),$(INSTALL_TYPE)),)
	$(call help_message)
else
	@./scripts/build.sh linux-saveconfig
endif

uboot:
ifeq ($(and $(DISTRIBUTION),$(DISTRIB_RELEASE),$(DISTRIB_TYPE),$(DISTRIB_ARCH),$(KHADAS_BOARD),$(LINUX),$(UBOOT),$(INSTALL_TYPE)),)
	$(call help_message)
else
	@./scripts/build.sh u-boot
endif

uboot-clean:
ifeq ($(and $(DISTRIBUTION),$(DISTRIB_RELEASE),$(DISTRIB_TYPE),$(DISTRIB_ARCH),$(KHADAS_BOARD),$(LINUX),$(UBOOT),$(INSTALL_TYPE)),)
	$(call help_message)
else
	@./scripts/build.sh u-boot-clean
endif

debs: uboot kernel
ifeq ($(and $(DISTRIBUTION),$(DISTRIB_RELEASE),$(DISTRIB_TYPE),$(DISTRIB_ARCH),$(KHADAS_BOARD),$(LINUX),$(UBOOT),$(INSTALL_TYPE)),)
	$(call help_message)
else
	@./scripts/build.sh debs
endif

uboot-deb: uboot kernel
ifeq ($(and $(DISTRIBUTION),$(DISTRIB_RELEASE),$(DISTRIB_TYPE),$(DISTRIB_ARCH),$(KHADAS_BOARD),$(LINUX),$(UBOOT),$(INSTALL_TYPE)),)
	$(call help_message)
else
	@./scripts/build.sh uboot-deb
endif

uboot-image: uboot kernel
ifeq ($(and $(DISTRIBUTION),$(DISTRIB_RELEASE),$(DISTRIB_TYPE),$(DISTRIB_ARCH),$(KHADAS_BOARD),$(LINUX),$(UBOOT),$(INSTALL_TYPE)),)
	$(call help_message)
else
	@./scripts/build.sh uboot-image
endif


kernel-deb: kernel
ifeq ($(and $(DISTRIBUTION),$(DISTRIB_RELEASE),$(DISTRIB_TYPE),$(DISTRIB_ARCH),$(KHADAS_BOARD),$(LINUX),$(UBOOT),$(INSTALL_TYPE)),)
	$(call help_message)
else
	@./scripts/build.sh linux-deb
endif

board-deb:
ifeq ($(and $(DISTRIBUTION),$(DISTRIB_RELEASE),$(DISTRIB_TYPE),$(DISTRIB_ARCH),$(KHADAS_BOARD),$(LINUX),$(UBOOT),$(INSTALL_TYPE)),)
	$(call help_message)
else
	@./scripts/build.sh board-deb
endif

gpu-deb:
ifeq ($(and $(DISTRIBUTION),$(DISTRIB_RELEASE),$(DISTRIB_TYPE),$(DISTRIB_ARCH),$(KHADAS_BOARD),$(LINUX),$(UBOOT),$(INSTALL_TYPE)),)
	$(call help_message)
else
	@./scripts/build.sh gpu-deb
endif

desktop-deb:
ifeq ($(and $(DISTRIBUTION),$(DISTRIB_RELEASE),$(DISTRIB_TYPE),$(DISTRIB_ARCH),$(KHADAS_BOARD),$(LINUX),$(UBOOT),$(INSTALL_TYPE)),)
	$(call help_message)
else
	@./scripts/build.sh desktop-deb
endif

common-deb:
ifeq ($(and $(DISTRIBUTION),$(DISTRIB_RELEASE),$(DISTRIB_TYPE),$(DISTRIB_ARCH),$(KHADAS_BOARD),$(LINUX),$(UBOOT),$(INSTALL_TYPE)),)
	$(call help_message)
else
	@./scripts/build.sh common-deb
endif

updater-deb:
ifeq ($(and $(DISTRIBUTION),$(DISTRIB_RELEASE),$(DISTRIB_TYPE),$(DISTRIB_ARCH),$(KHADAS_BOARD),$(LINUX),$(UBOOT),$(INSTALL_TYPE)),)
	$(call help_message)
else
	@./scripts/build.sh updater-deb
endif

get-make-params:
	@./scripts/param.sh make_params

info:
	@echo ""
	@echo "Version: ${VERSION}"
	@echo "Current environment:"
	@echo "==========================================="
	@echo
	@echo "#KHADAS_BOARD=${KHADAS_BOARD}"
	@echo "#VENDOR=${VENDOR}"
	@echo "#CHIP=${CHIP}"
	@echo "#LINUX=${LINUX}"
	@echo "#UBOOT=${UBOOT}"
	@echo "#DISTRIBUTION=${DISTRIBUTION}"
	@echo "#DISTRIB_RELEASE=${DISTRIB_RELEASE}"
	@echo "#DISTRIB_TYPE=${DISTRIB_TYPE}"
	@echo "#DISTRIB_ARCH=${DISTRIB_ARCH}"
	@echo "#INSTALL_TYPE=${INSTALL_TYPE}"
	@echo
	@echo "==========================================="
	@echo ""

help:
	@echo "Fenix scripts help messages:"
	@echo "  all                   - Create image according to environment."
	@echo "  kernel                - Build linux kernel."
	@echo "  kernel-clean          - Clean linux source tree."
	@echo "  kernel-config         - Show linux menuconfig."
	@echo "  kernel-saveconfig     - Save linux defconfig."
	@echo "  uboot                 - Build u-boot."
	@echo "  uboot-clean           - Clean u-boot source tree."
	@echo "  uboot-deb             - Build u-boot debian package."
	@echo "  uboot-image           - Build minimal image only with u-boot."
	@echo "  kernel-deb            - Build linux debian package."
	@echo "  board-deb             - Build board debian package."
	@echo "  common-deb            - Build common debian package."
	@echo "  desktop-deb           - Build desktop debian package."
	@echo "  gpu-deb               - Build gpu debian package."
	@echo "  debs                  - Build all debian packages."
	@echo "  image                 - Pack update image."
	@echo "  clean                 - Cleanup."
	@echo "  clean-all             - Cleanup all."
	@echo "  clean-ccache          - Cleanup ccache only."
	@echo "  clean-old             - Cleanup old build session only."
	@echo "  info                  - Display current environment."
	@echo "  get-make-params       - Get available make parameters."
	@echo "  write                 - Write image to device"
	@echo "  write-boot-online     - Write u-boot to device via Krescue"
	@echo "  write-help            - Get detailed help about write ..."
	@echo "  krescue               - Build/update Krescue ..."
	@echo "  krescue-write         - Write Krescue image to SD/USB..."
	@echo "  krescue-write-vim1    - Write Krescue VIM1 image ......."
	@echo "  krescue-write-vim2    - Write Krescue VIM2 image ......."
	@echo "  krescue-write-vim3    - Write Krescue VIM3 image ......."
	@echo "  krescue-write-vim3l   - Write Krescue VIM3L image ......"
	@echo "  krescue-write-edge    - Write Krescue Edge image ......."
clean:
	./scripts/clean.sh
clean-all:
	CLEAN_ALL=1 ./scripts/clean.sh
clean-ccache:
	CLEAN_CCACHE_ONLY=1 ./scripts/clean.sh
clean-old:
	CLEAN_OLD_ONLY=1 ./scripts/clean.sh

write write-help write-boot-online write-boot-emmc-online write-boot-spi-online write-boot-spi-online-apply :
	./scripts/write_image.sh "$@"
krescue krescue-write krescue-write-vim1 krescue-write-vim2 krescue-write-vim3 krescue-write-vim3l krescue-write-edge :
	./scripts/krescue.sh "$@"


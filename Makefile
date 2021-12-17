all: _env_is_setup
	@./scripts/create_image.sh

_env_is_setup:
	@if test "$(DISTRIBUTION)" -a "$(DISTRIB_RELEASE)" -a "$(DISTRIB_TYPE)" -a "$(DISTRIB_ARCH)" -a "$(KHADAS_BOARD)" -a "$(LINUX)" -a "$(UBOOT)" -a "$(INSTALL_TYPE)"; then \
		exit 0; \
	else \
		echo "You should setup environment first."; \
		echo "Run 'source env/setenv.sh' to setup environment."; \
		exit 1; \
	fi

image: _env_is_setup
	@echo "This script requires root privileges, trying to use sudo, please enter your passowrd!"
	@sudo -E ./scripts/make_image.sh

kernel: _env_is_setup
	@./scripts/build.sh linux

kernel-clean: _env_is_setup
	@./scripts/build.sh linux-clean

kernel-config: _env_is_setup
	@./scripts/build.sh linux-config

kernel-saveconfig: _env_is_setup
	@./scripts/build.sh linux-saveconfig

uboot: _env_is_setup
	@./scripts/build.sh u-boot

uboot-clean: _env_is_setup
	@./scripts/build.sh u-boot-clean

debs: uboot kernel
	@./scripts/build.sh debs

uboot-deb: uboot kernel
	@./scripts/build.sh uboot-deb

uboot-image: uboot kernel
	@./scripts/build.sh uboot-image

kernel-deb: kernel
	@./scripts/build.sh linux-deb

board-deb: _env_is_setup
	@./scripts/build.sh board-deb

gpu-deb: _env_is_setup
	@./scripts/build.sh gpu-deb

desktop-deb: _env_is_setup
	@./scripts/build.sh desktop-deb

common-deb: _env_is_setup
	@./scripts/build.sh common-deb

updater-deb: _env_is_setup
	@./scripts/build.sh updater-deb

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


.PHONY: _env_is_setup

IMAGES_DIR=images

all:
ifeq ($(and $(DISTRIBUTION),$(DISTRIB_RELEASE),$(DISTRIB_TYPE),$(DISTRIB_ARCH),$(KHADAS_BOARD),$(LINUX),$(UBOOT),$(INSTALL_TYPE)),)
	$(call help_message)
else
	./scripts/create_image.sh
endif

define help_message
	@echo "You should setup environment first."
	@echo "Run 'source env/setenv.sh' to setup environment."
endef

release:
	./scripts/image release

image:
ifeq ($(and $(DISTRIBUTION),$(DISTRIB_RELEASE),$(DISTRIB_TYPE),$(DISTRIB_ARCH),$(KHADAS_BOARD),$(LINUX),$(UBOOT),$(INSTALL_TYPE)),)
	$(call help_message)
else
	@echo "This script requires root privileges, trying to use sudo, please enter your passowrd!"
	sudo -E ./scripts/make_image.sh
endif

kernel:
ifeq ($(and $(DISTRIBUTION),$(DISTRIB_RELEASE),$(DISTRIB_TYPE),$(DISTRIB_ARCH),$(KHADAS_BOARD),$(LINUX),$(UBOOT),$(INSTALL_TYPE)),)
	$(call help_message)
else
	./scripts/build.sh linux
endif

uboot:
ifeq ($(and $(DISTRIBUTION),$(DISTRIB_RELEASE),$(DISTRIB_TYPE),$(DISTRIB_ARCH),$(KHADAS_BOARD),$(LINUX),$(UBOOT),$(INSTALL_TYPE)),)
	$(call help_message)
else
	./scripts/build.sh u-boot
endif

debs:
ifeq ($(and $(DISTRIBUTION),$(DISTRIB_RELEASE),$(DISTRIB_TYPE),$(DISTRIB_ARCH),$(KHADAS_BOARD),$(LINUX),$(UBOOT),$(INSTALL_TYPE)),)
	$(call help_message)
else
	./scripts/build.sh debs
endif

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
	@echo "  all           - Create image according to environment."
	@echo "  kernel        - Build linux kernel."
	@echo "  uboot         - Build u-boot."
	@echo "  debs          - Build debs."
	@echo "  image         - Pack update image."
	@echo "  clean         - Cleanup."
	@echo "  info          - Display current environment."
clean:
	./scripts/clean.sh

## Refs
# Buildroot
# Android repo
# LibreELEC

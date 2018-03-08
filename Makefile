IMAGES_DIR=images

all:
ifeq ($(and $(UBUNTU_TYPE),$(KHADAS_BOARD),$(UBUNTU),$(LINUX),$(UBUNTU_ARCH),$(INSTALL_TYPE)),)
	$(call help_message)
else
	./scripts/create_image.sh $(UBUNTU_TYPE) $(KHADAS_BOARD) $(UBUNTU) $(LINUX) $(UBUNTU_ARCH) $(INSTALL_TYPE)
endif


define help_message
	@echo "You should setup environment first."
	@echo "Run 'source env/setenv.sh' to setup environment."
endef

release:
	./scripts/image release

image:
ifeq ($(and $(KHADAS_BOARD),$(INSTALL_TYPE)),)
	$(call help_message)
else
	./scripts/make_image.sh $(KHADAS_BOARD) $(INSTALL_TYPE)
endif

github:
	./scripts/github.sh

remount:
ifeq ($(and $(KHADAS_BOARD),$(LINUX),$(UBUNTU_ARCH),$(INSTALL_TYPE)),)
	$(call help_message)
else
	./scripts/remount_rootfs.sh $(KHADAS_BOARD) $(LINUX) $(UBUNTU_ARCH) $(INSTALL_TYPE)
endif

info:
	@echo ""
	@echo "Version: ${VERSION}"
	@echo "Current environment:"
	@echo "==========================================="
	@echo
	@echo "#KHADAS_BOARD=${KHADAS_BOARD}"
	@echo "#VENDER=${VENDER}"
	@echo "#CHIP=${CHIP}"
	@echo "#LINUX=${LINUX}"
	@echo "#UBOOT=${UBOOT}"
	@echo "#UBUNTU_TYPE=${UBUNTU_TYPE}"
ifeq ($(UBUNTU_TYPE),mate)
	@echo "#UBUNTU_MATE_ROOTFS_TYPE=${UBUNTU_MATE_ROOTFS_TYPE}"
endif
	@echo "#UBUNTU=${UBUNTU}"
	@echo "#UBUNTU_ARCH=${UBUNTU_ARCH}"
	@echo "#INSTALL_TYPE=${INSTALL_TYPE}"
	@echo
	@echo "==========================================="
	@echo ""

help:
	@echo "Fenix scripts help messages:"
	@echo "  all           - Create image according to environment."
	@echo "  remount       - Remount rootfs and recreate initrd."
	@echo "  github        - Update repositories from Khadas GitHub."
	@echo "  image         - Pack update image."
	@echo "  clean         - Cleanup."
	@echo "  info          - Display current environment."
clean:
	./scripts/clean.sh

## Refs
# Buildroot
# Android repo
# LibreELEC

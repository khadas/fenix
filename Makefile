IMAGES_DIR=images

all: help

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

balbes150:
	./scripts/balbes150.sh

server:
ifeq ($(and $(KHADAS_BOARD),$(UBUNTU),$(LINUX),$(UBUNTU_ARCH),$(INSTALL_TYPE)),)
	$(call help_message)
else
	./scripts/server.sh $(KHADAS_BOARD) $(UBUNTU) $(LINUX) $(UBUNTU_ARCH) $(INSTALL_TYPE)
endif

ubuntu-mate:
ifeq ($(and $(KHADAS_BOARD),$(UBUNTU),$(LINUX),$(UBUNTU_ARCH),$(INSTALL_TYPE)),)
	$(call help_message)
else
	./scripts/ubuntu-mate.sh $(KHADAS_BOARD) $(UBUNTU) $(LINUX) $(UBUNTU_ARCH) $(INSTALL_TYPE)
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
	@echo "Current environment:"
	@echo "==========================================="
	@echo
	@echo "#KHADAS_BOARD=${KHADAS_BOARD}"
	@echo "#LINUX=${LINUX}"
	@echo "#UBUNTU=${UBUNTU}"
	@echo "#UBUNTU_ARCH=${UBUNTU_ARCH}"
	@echo "#INSTALL_TYPE=${INSTALL_TYPE}"
	@echo
	@echo "==========================================="
	@echo ""

help:
	@echo "Fenix scripts help messages:"
	@echo "  server        - Create ubuntu server update image."
	@echo "  ubuntu-mate   - Create ubuntu mate update image."
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

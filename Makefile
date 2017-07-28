IMAGES_DIR=images

all: help

define help_message
	@echo "You should setup environment first."
	@echo "Run 'source env/setenv.sh' to setup environment."
endef

release:
	./scripts/image release

image:
ifeq ($(and $(KHADAS_BOARD)),)
	$(call help_message)
else
	./scripts/make_image.sh $(KHADAS_BOARD)
endif

balbes150:
	./scripts/balbes150.sh

server:
ifeq ($(and $(KHADAS_BOARD),$(UBUNTU),$(LINUX)),)
	$(call help_message)
else
	./scripts/server.sh $(KHADAS_BOARD) $(UBUNTU) $(LINUX)
endif

ubuntu-mate:
	./scripts/ubuntu-mate.sh

github:
	./scripts/github.sh

remount:
ifeq ($(and $(KHADAS_BOARD),$(LINUX)),)
	$(call help_message)
else
	./scripts/remount_rootfs.sh $(KHADAS_BOARD) $(LINUX)
endif

help:
	@echo "Fenix scripts help messages:"
	@echo "  server        - Create ubuntu server update image."
	@echo "  remount       - Remount rootfs and recreate initrd."
	@echo "  github        - Update repositories from Khadas GitHub."
	@echo "  image         - Pack update image."
	@echo "  clean         - Cleanup."

clean:
	./scripts/clean.sh

## Refs
# Buildroot
# Android repo
# LibreELEC

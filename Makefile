IMAGES_DIR=images

all: help

release:
	./scripts/image release

image:
ifeq ($(and $(KHADAS_BOARD)),)
	@echo "Usage: make <KHADAS_BOARD=VIM|VIM2> image"
	@echo "   eg: make KHADAS_BOARD=VIM2 image"
else
	./scripts/make_image.sh $(KHADAS_BOARD)
endif

balbes150:
	./scripts/balbes150.sh

server:
ifeq ($(and $(KHADAS_BOARD),$(UBUNTU),$(LINUX)),)
	@echo "Usage: make <KHADAS_BOARD=VIM|VIM2> <UBUNTU=16.04.2|17.04|17.10> <LINUX=3.14|4.9> server"
	@echo "   eg: make KHADAS_BOARD=VIM2 UBUNTU=16.04.2 LINUX=4.9 server"
else
	./scripts/server.sh $(KHADAS_BOARD) $(UBUNTU) $(LINUX)
endif

ubuntu-mate:
	./scripts/ubuntu-mate.sh

github:
	./scripts/github.sh

remount:
ifeq ($(and $(KHADAS_BOARD),$(LINUX)),)
	@echo "Usage: make <KHADAS_BOARD=VIM|VIM2> <LINUX=3.14|4.9> remount"
	@echo "   eg: make KHADAS_BOARD=VIM2 LINUX=4.9 remount"
else
	./scripts/remount_rootfs.sh $(KHADAS_BOARD) $(LINUX)
endif

help:
	@echo -e "Fenix scripts help messages.\n"
	@echo -e "Create ubuntu server update image."
	@echo -e "    make <KHADAS_BOARD=VIM|VIM2> <UBUNTU=16.04.2|17.04|17.10> <LINUX=3.14|4.9> server\n"
	@echo -e "Remount rootfs and recreate initrd."
	@echo -e "    make <KHADAS_BOARD=VIM|VIM2> <LINUX=3.14|4.9> remount\n"
	@echo -e "Update repositories from Khadas GitHub."
	@echo -e "    make github\n"
	@echo -e "Pack update image."
	@echo -e "    make <KHADAS_BOARD=VIM|VIM2> image\n"
	@echo -e "Cleanup."
	@echo -e "    make clean\n"

clean:
	./scripts/clean.sh

## Refs
# Buildroot
# Android repo
# LibreELEC

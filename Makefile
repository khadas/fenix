IMAGES_DIR=images

all: github

release:
	./scripts/image release

image:
	./scripts/image mkimage

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

clean:
	./scripts/clean.sh

## Refs
# Buildroot
# Android repo
# LibreELEC

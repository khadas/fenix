IMAGES_DIR=images

all: github

release:
	./scripts/image release

image:
	./scripts/image mkimage

balbes150:
	./scripts/balbes150.sh

server:
	./scripts/server.sh

ubuntu-mate:
	./scripts/ubuntu-mate.sh

github:
	./scripts/github.sh

clean:
	rm -rf $(IMAGES_DIR)/*.img

## Refs
# Buildroot
# Android repo
# LibreELEC

#!/bin/bash

touch .ignore-update
source env/setenv.sh config config-travis.conf
NO_CCACHE=yes make kernel-deb
mkdir debs
cp build/images/debs/$VERSION/linux-dtb-amlogic-mainline_*.deb debs
cp build/images/debs/$VERSION/linux-headers-amlogic-mainline_*.deb debs
cp build/images/debs/$VERSION/linux-image-amlogic-mainline_*.deb debs


.travis/deploy.sh

echo "Done!"

#!/bin/sh

echo "# MERGED INITRD MODULES CONFIG FOR AMLOGIC ROCKCHIP " | tee modules
grep -vh ^\# modules.aml modules.rk | sort | uniq >> modules



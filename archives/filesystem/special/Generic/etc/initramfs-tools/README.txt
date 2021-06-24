# initrd modules help

+ modules     - modules list
+ modules.aml - amlogic full modules
+ modules.rk  - rockchip full modules

NOTE! need optimize! remove all unusable for initramfs

# generate one universal modules list

    ./merge.sh

# try dont use most

    grep MODULES  initramfs.conf

#MODULES=most
MODULES=list


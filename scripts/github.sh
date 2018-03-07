#!/bin/bash

########################### Parameters ###################################

UBOOT_GIT_BRANCH_VIM="khadas-vim-v2015.01"
UBOOT_GIT_BRANCH_VIM2="khadas-vim-v2015.01"
LINUX_GIT_BRANCH_3_14="khadas-vim-3.14.y"
LINUX_GIT_BRANCH_4_9="khadas-vim-4.9.y"

source config/config

############################## Functions #################################
source config/functions

## Pull latest repository from Kkadas GitHub
update_github_repository() {
	install -d ${UBUNTU_WORKING_DIR}/archives/{ubuntu-base,ubuntu-mate}
	cd ${UBUNTU_WORKING_DIR}

	## Update fenix repository
	echo "Updating 'fenix/master' repository..."
	git pull origin master
	[ $? != 0 ] && error_msg "Failed to update repository 'fenix/master'" && return -1
	echo "Updating 'fenix/master' repository OK."

	## Update u-boot repository
	cd ${UBUNTU_WORKING_DIR}
	if [ ! -d u-boot/.git ]; then
		echo "U-boot repository does not exist, clone u-boot repository('$UBOOT_GIT_BRANCH_VIM') form Khadas GitHub..."
		## Clone u-boot from Khadas GitHub
		git clone https://github.com/khadas/u-boot -b $UBOOT_GIT_BRANCH_VIM
		[ $? != 0 ] && error_msg "Failed to clone 'u-boot'" && return -1
	fi

	cd u-boot/

	# Store current u-boot branch
	current_uboot_git_branch=`git branch | grep "^*" | awk '{print $2}'`

	# Update u-boot branch UBOOT_GIT_BRANCH_VIM
	make distclean
	git checkout $UBOOT_GIT_BRANCH_VIM
	echo "Updating 'u-boot/$UBOOT_GIT_BRANCH_VIM' repository..."
	git pull origin $UBOOT_GIT_BRANCH_VIM
	[ $? != 0 ] && error_msg "Failed to update 'u-boot/$UBOOT_GIT_BRANCH_VIM'" && return -1
	echo "Updating 'u-boot/$UBOOT_GIT_BRANCH_VIM' repository OK."

	# Update u-boot branch UBOOT_GIT_BRANCH_VIM2
	git checkout $UBOOT_GIT_BRANCH_VIM2
	echo "Updating 'u-boot/$UBOOT_GIT_BRANCH_VIM2' repository..."
	git pull origin $UBOOT_GIT_BRANCH_VIM2
	[ $? != 0 ] && error_msg "Failed to update 'u-boot/$UBOOT_GIT_BRANCH_VIM2'" && return -1
	echo "Updating 'u-boot/$UBOOT_GIT_BRANCH_VIM2' repository OK."

	# Restore u-boot branch
	git checkout $current_uboot_git_branch

	cd -

	## Update linux repository
	cd ${UBUNTU_WORKING_DIR}
	if [ ! -d linux/.git ]; then
		echo "Linux repository does not exist, clone linux repository('$LINUX_GIT_BRANCH_3_14') form Khadas GitHub..."
		## Clone linux from Khadas GitHub
		git clone https://github.com/khadas/linux -b $LINUX_GIT_BRANCH_3_14
		[ $? != 0 ] && error_msg "Failed to clone 'linux'" && return -1
	fi

	cd linux/

	# Store current linux branch
	current_linux_git_branch=`git branch | grep "^*" | awk '{print $2}'`

	# Update linux branch LINUX_GIT_BRANCH_3_14
	make ARCH=arm64 distclean
	git checkout $LINUX_GIT_BRANCH_3_14
	echo "Updating 'linux/$LINUX_GIT_BRANCH_3_14' repository..."
	git pull origin $LINUX_GIT_BRANCH_3_14
	[ $? != 0 ] && error_msg "Failed to update 'linux/$LINUX_GIT_BRANCH_3_14'" && return -1
	echo "Updating 'linux/$LINUX_GIT_BRANCH_3_14' repository OK."

	# Update linux branch LINUX_GIT_BRANCH_4_9
	git checkout $LINUX_GIT_BRANCH_4_9
	echo "Updating 'linux/$LINUX_GIT_BRANCH_4_9' repository..."
	git pull origin $LINUX_GIT_BRANCH_4_9
	[ $? != 0 ] && error_msg "Failed to update 'linux/$LINUX_GIT_BRANCH_4_9'" && return -1
	echo "Updating 'linux/$LINUX_GIT_BRANCH_4_9' repository OK."

	# Restore linux branch
	git checkout $current_linux_git_branch

	cd -

	return 0
}


##############################################
update_github_repository		&&
echo -e "\nDone."
echo -e "\n`date`"

#!/bin/bash

########################### Parameters ###################################

UBOOT_GIT_BRANCH_VIM="ubuntu"
UBOOT_GIT_BRANCH_VIM2="ubuntu-vim2"
LINUX_GIT_BRANCH_3_14="ubuntu"
LINUX_GIT_BRANCH_4_9="ubuntu-4.9"

BASE_DIR="$HOME"
PROJECT_DIR="${BASE_DIR}/project"
KHADAS_DIR="${PROJECT_DIR}/khadas"
UBUNTU_WORKING_DIR="$(dirname "$(dirname "$(readlink -fm "$0")")")"

CURRENT_FILE="$0"

ERROR="\033[31mError:\033[0m"
WARNING="\033[35mWarning:\033[0m"

############################## Functions #################################

## Print error message
## $1 - file name
## $2 - line number
## $3 - message
error_msg() {
	echo -e "$1:$2" $ERROR "$3"
}

## Print warning message
## $1 - file name
## $2 - line number
## $3 - message
warning_msg() {
	echo -e "$1:$2" $WARNING "$3"
}

## Pull latest repository from Kkadas GitHub
update_github_repository() {
	install -d ${UBUNTU_WORKING_DIR}/{linux,rootfs,archives/{ubuntu-base,debs,hwpacks},images,scripts}
	cd ${UBUNTU_WORKING_DIR}

	## Update fenix repository
	echo "Updating 'fenix/master' repository..."
	git pull origin master
	[ $? != 0 ] && error_msg $CURRENT_FILE $LINENO "Failed to update repository 'fenix/master'" && return -1
	echo "Updating 'fenix/master' repository OK."

	## Update utils repository
	if [ ! -d "utils/.git" ]; then
		##Clone utils.git from Khadas GitHub
		echo "Utils repository dose not exist, clone utils repository('master') from Khadas GitHub..."
		git clone https://github.com/khadas/utils.git
		[ $? != 0 ] && error_msg $CURRENT_FILE $LINENO "Failed to clone repository 'utils.git/master'" && return -1
	fi

	cd utils/
	echo "Updating 'utils/master' repository..."
	git pull origin master
	[ $? != 0 ] && error_msg $CURRENT_FILE $LINENO "Failed to update repository 'utils/master'" && return -1
	echo "Updating 'utils/master' repository OK."
	cd -

	## Update upgrade repository
	cd images/
	if [ ! -d "upgrade/.git" ]; then
		##Clone upgrade.git from Khadas GitHub
		echo "Upgrade repository dose not exist, clone upgrade repository('master') from Khadas GitHub..."
		git clone https://github.com/khadas/upgrade.git
		[ $? != 0 ] && error_msg $CURRENT_FILE $LINENO "Failed to clone 'upgrade.git/master'" && return -1
	fi

	cd upgrade/
	echo "Updating 'upgrade/master' repository..."
	git pull origin master
	[ $? != 0 ] && error_msg $CURRENT_FILE $LINENO "Failed to update repository 'upgrade/master'" && return -1
	echo "Updating 'upgrade/master' repository OK."
	cd -

	## Update u-boot repository
	cd ${UBUNTU_WORKING_DIR}
	if [ ! -d u-boot/.git ]; then
		echo "U-boot repository does not exist, clone u-boot repository('$UBOOT_GIT_BRANCH_VIM') form Khadas GitHub..."
		## Clone u-boot from Khadas GitHub
		git clone https://github.com/khadas/u-boot -b $UBOOT_GIT_BRANCH_VIM
		[ $? != 0 ] && error_msg $CURRENT_FILE $LINENO "Failed to clone 'u-boot'" && return -1
	fi

	cd u-boot/

	# Store current u-boot branch
	current_uboot_git_branch=`git branch | grep "^*" | awk '{print $2}'`

	# Update u-boot branch UBOOT_GIT_BRANCH_VIM
	make distclean
	git checkout $UBOOT_GIT_BRANCH_VIM
	echo "Updating 'u-boot/$UBOOT_GIT_BRANCH_VIM' repository..."
	git pull origin $UBOOT_GIT_BRANCH_VIM
	[ $? != 0 ] && error_msg $CURRENT_FILE $LINENO "Failed to update 'u-boot/$UBOOT_GIT_BRANCH_VIM'" && return -1
	echo "Updating 'u-boot/$UBOOT_GIT_BRANCH_VIM' repository OK."

	# Update u-boot branch UBOOT_GIT_BRANCH_VIM2
	git checkout $UBOOT_GIT_BRANCH_VIM2
	echo "Updating 'u-boot/$UBOOT_GIT_BRANCH_VIM2' repository..."
	git pull origin $UBOOT_GIT_BRANCH_VIM2
	[ $? != 0 ] && error_msg $CURRENT_FILE $LINENO "Failed to update 'u-boot/$UBOOT_GIT_BRANCH_VIM2'" && return -1
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
		[ $? != 0 ] && error_msg $CURRENT_FILE $LINENO "Failed to clone 'linux'" && return -1
	fi

	cd linux/

	# Store current linux branch
	current_linux_git_branch=`git branch | grep "^*" | awk '{print $2}'`

	# Update linux branch LINUX_GIT_BRANCH_3_14
	make ARCH=arm64 distclean
	git checkout $LINUX_GIT_BRANCH_3_14
	echo "Updating 'linux/$LINUX_GIT_BRANCH_3_14' repository..."
	git pull origin $LINUX_GIT_BRANCH_3_14
	[ $? != 0 ] && error_msg $CURRENT_FILE $LINENO "Failed to update 'linux/$LINUX_GIT_BRANCH_3_14'" && return -1
	echo "Updating 'linux/$LINUX_GIT_BRANCH_3_14' repository OK."

	# Update linux branch LINUX_GIT_BRANCH_4_9
	git checkout $LINUX_GIT_BRANCH_4_9
	echo "Updating 'linux/$LINUX_GIT_BRANCH_4_9' repository..."
	git pull origin $LINUX_GIT_BRANCH_4_9
	[ $? != 0 ] && error_msg $CURRENT_FILE $LINENO "Failed to update 'linux/$LINUX_GIT_BRANCH_4_9'" && return -1
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

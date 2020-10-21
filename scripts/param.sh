#!/bin/bash

set -e -o pipefail

## Parameters
source config/config

## Functions
source config/functions/functions

######################################################################################
TARGET="$1"

case "$TARGET" in
	make_params)
		get_available_make_params
		;;
esac

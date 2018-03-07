#!/bin/bash

########################### Parameters ###################################
source config/config

############################## Functions #################################
source config/functions

##########################################################
prepare_aml_update_tool_config
pack_update_image

echo -e "\nDone."
echo -e "\n`date`"

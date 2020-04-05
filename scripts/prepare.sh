#!/bin/bash

set -xe -o pipefail

## Parameters
source config/config

## Functions
source config/functions/functions

######################################################################################

"prepare_$1"
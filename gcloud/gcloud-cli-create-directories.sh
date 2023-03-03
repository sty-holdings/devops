#!/bin/bash
#
# Name: gcloud-cli-create-directories.sh
#
# Description: This will create directories on a gcloud instance.
#
# Installation:
#   None required
#
# Copyright (c) 2022 STY-Holdings Inc
# All Rights Reserved
#

set -eo pipefail

# Passed by caller
GC_REGION=$1
GC_REMOTE_INSTANCE_LOGIN=$2
TARGET_DIRECTORY=$3

echo "Making directories on GCloud instance"
gcloud compute ssh --zone "${GC_REGION}" "${GC_REMOTE_INSTANCE_LOGIN}" --command "mkdir -p ${TARGET_DIRECTORY}/scripts/"
echo "Finished making directories on GCloud instance"

exit 0

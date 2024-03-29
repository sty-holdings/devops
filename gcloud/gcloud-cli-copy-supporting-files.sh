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
GC_REMOTE_LOGIN=$2
SHARED_DIRECTORY=$3
TARGET_DIRECTORY=$4

if gcloud compute scp --recurse --zone "${GC_REGION}" "${SHARED_DIRECTORY}/." "${GC_REMOTE_LOGIN}:${TARGET_DIRECTORY}/scripts/."; then
  echo -n
fi

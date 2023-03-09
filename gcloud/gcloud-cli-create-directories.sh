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
TARGET_DIRECTORY=$3
GC_SERVER_USER=$4

if gcloud compute ssh --zone "${GC_REGION}" "${GC_REMOTE_LOGIN}" --command "mkdir -p ${TARGET_DIRECTORY}/scripts/"; then
  echo -n
fi
if gcloud compute ssh --zone "${GC_REGION}" "${GC_REMOTE_LOGIN}" --command "ln -s /mnt/disks/nats_home ${TARGET_DIRECTORY}/nats"; then
  echo -n
fi

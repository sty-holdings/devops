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
NATS_SOURCE_DIRECTORY=$3
TARGET_DIRECTORY=$4
# script variables

echo "Copying files to GCloud instance"
gcloud compute scp --recurse --zone "${GC_REGION}" "${NATS_SOURCE_DIRECTORY}"/NATS* "${GC_REMOTE_INSTANCE_LOGIN}:${TARGET_DIRECTORY}"/scripts/.
echo "Finished copying NATS files to GCloud instance"

# Set permissions
echo "Setting file permissions on GCloud instance"
gcloud compute ssh --zone "${GC_REGION}" "${GC_REMOTE_INSTANCE_LOGIN}" --command "chmod -R 711 ${TARGET_DIRECTORY}/scripts/*"
gcloud compute ssh --zone "${GC_REGION}" "${GC_REMOTE_INSTANCE_LOGIN}" --command "chmod -R 711 ${TARGET_DIRECTORY}/scripts/.*"
echo "Finished setting file permissions on GCloud instance"

exit 0

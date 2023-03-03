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
TARGET_ENVIRONMENT=$5
TARGET_DIRECTORY=$6
# script variables
KEYS_DIRECTORY=${ROOT_DIRECTORY}/keys/${TARGET_ENVIRONMENT}/.keys
BIN_DIRECTORY=${SAVUP_ROOT_DIRECTORY}/bin

echo "Copying files to GCloud instance"
gcloud compute scp --recurse --zone "${GC_REGION}" "${SAVUP_ROOT_DIRECTORY}/devops/scripts/0-config-instance.sh" "${GC_REMOTE_INSTANCE_LOGIN}:${TARGET_DIRECTORY}/scripts/."
gcloud compute scp --recurse --zone "${GC_REGION}" "${KEYS_DIRECTORY}/TEST_FIREBASE_CREDENTIALS.json"" ${GC_REMOTE_INSTANCE_LOGIN}:${TARGET_DIRECTORY}/.keys/."
gcloud compute scp --recurse --zone "${GC_REGION}" "${KEYS_DIRECTORY}/savup-nats.creds" "${GC_REMOTE_INSTANCE_LOGIN}:${TARGET_DIRECTORY}/.keys/."
gcloud compute scp --recurse --zone "${GC_REGION}" "${KEYS_DIRECTORY}/plaid-TEST.json" "${GC_REMOTE_INSTANCE_LOGIN}:${TARGET_DIRECTORY}/.keys/."
gcloud compute scp --recurse --zone "${GC_REGION}" "${KEYS_DIRECTORY}/Stripe-TEST-Key.json" "${GC_REMOTE_INSTANCE_LOGIN}:${TARGET_DIRECTORY}/.keys/."
gcloud compute scp --recurse --zone "${GC_REGION}" "${BIN_DIRECTORY}/savup-server" "${GC_REMOTE_INSTANCE_LOGIN}:${TARGET_DIRECTORY}/bin/."
gcloud compute scp --recurse --zone "${GC_REGION}" "${SAVUP_ROOT_DIRECTORY}/config/${TARGET_ENVIRONMENT}/savup-config.json" "${GC_REMOTE_INSTANCE_LOGIN}:${TARGET_DIRECTORY}/.config/."
gcloud compute scp --recurse --zone "${GC_REGION}" "${SAVUP_ROOT_DIRECTORY}/config/SAVUP.servicefile" "${GC_REMOTE_INSTANCE_LOGIN}:${TARGET_DIRECTORY}/.config/."
echo "Finished copying files to GCloud instance"

# Set permissions
echo "Setting file permissions on GCloud instance"
gcloud compute ssh --zone "${GC_REGION}" "${GC_REMOTE_INSTANCE_LOGIN}" --command "chmod -R 711 ${TARGET_DIRECTORY}/*"
gcloud compute ssh --zone "${GC_REGION}" "${GC_REMOTE_INSTANCE_LOGIN}" --command "chmod -R 711 ${TARGET_DIRECTORY}/.*"
echo "Finished setting file permissions on GCloud instance"

exit 0

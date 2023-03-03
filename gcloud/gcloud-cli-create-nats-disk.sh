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
if gcloud compute disks create asdf --project=savup-f3343 --type=pd-ssd \
  --size=10GB --resource-policies=projects/savup-f3343/regions/us-central1/resourcePolicies/daily \
  --region=us-central1 --replica-zones=projects/savup-f3343/zones/us-central1-c,projects/savup-f3343/zones/us-central1-a \
  --source-disk=projects/savup-f3343/zones/us-central1-c/disks/nats-dev-1-1; then
  exit 0
fi

echo "Finished making directories on GCloud instance"

exit 0


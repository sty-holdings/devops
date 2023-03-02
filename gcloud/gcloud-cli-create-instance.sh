#!/bin/bash
#
# Name: gcloud-cli-create-instance.sh
#
# Description: This will create a gcloud instance.
#
# Installation:
#   None required
#
# Copyright (c) 2022 STY-Holdings Inc
# All Rights Reserved
#

set -eo pipefail

# Passed by caller
NAME=$1
REGION=$2
ADDRESS=$3
SERVICE_ACCOUNT=$4
FIREWALL_TAGS=$5

# NOTE: The config has to be set before this command runs or it will execute against the last set GCloud project set.
# The if/then prevents a gcloud and error from terminating the script.
if gcloud compute instances create "${NAME}" \
  --zone="${REGION}" \
  --machine-type=g1-small \
  --network-interface=network-tier=PREMIUM,subnet=default,address="${ADDRESS}" \
  --metadata=environment=development,enable-oslogin=true \
  --maintenance-policy=MIGRATE \
  --provisioning-model=STANDARD \
  --service-account="${SERVICE_ACCOUNT}"-compute@developer.gserviceaccount.com \
  --scopes=https://www.googleapis.com/auth/cloud-platform \
  --tags="${FIREWALL_TAGS}" \
  --create-disk=auto-delete=yes,boot=yes,device-name=nats-dev-1,image=projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20230114,mode=rw,size=10,type=projects/savup-f3343/zones/us-central1-c/diskTypes/pd-balanced \
  --no-shielded-secure-boot \
  --shielded-vtpm \
  --shielded-integrity-monitoring \
  --reservation-affinity=any \
  --key-revocation-action-type=stop; then
  exit 0
fi

exit 0

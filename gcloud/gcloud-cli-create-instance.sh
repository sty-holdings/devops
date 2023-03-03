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
GC_INSTANCE_NAME=$1
REGION=$2
ADDRESS=$3
SERVICE_ACCOUNT=$4
FIREWALL_TAGS=$5
# Script variables
IMAGE_NAME=projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20230302

# NOTE: The project config has to be set before this command runs or it will execute against the last GCloud project set.
if [ "${ADDRESS}" = "0.0.0.0" ]; then
  echo "${ON_YELLOW}  ${COLOR_OFF}"
  echo "${ON_YELLOW}Since there is no assigned IP Address, this will be connected to the STANDARD Google network.${COLOR_OFF}"
  echo "${ON_YELLOW}  ${COLOR_OFF}"
  # The if/then prevents gcloud or an error from terminating the script.
  if gcloud compute instances create "${GC_INSTANCE_NAME}" \
    --zone="${REGION}" \
    --machine-type=g1-small \
    --network-interface=network-tier=STANDARD,subnet=default \
    --metadata=environment=development,enable-oslogin=true \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --service-account="${SERVICE_ACCOUNT}"-compute@developer.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/cloud-platform \
    --tags="${FIREWALL_TAGS}" \
    --create-disk=auto-delete=yes,boot=yes,device-name="${GC_INSTANCE_NAME}",image="${IMAGE_NAME}",mode=rw,size=10,type=projects/savup-f3343/zones/us-central1-c/diskTypes/pd-balanced \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --reservation-affinity=any \
    --key-revocation-action-type=stop; then
    exit 0
  fi
else
  echo "${ON_YELLOW}  ${COLOR_OFF}"
  echo "${ON_YELLOW}Since there is an assigned IP Address, this will be connected to the PREMIUM Google network.${COLOR_OFF}"
  echo "${ON_YELLOW}  ${COLOR_OFF}"
  # The if/then prevents gcloud or an error from terminating the script.
  if gcloud compute instances create "${GC_INSTANCE_NAME}" \
    --zone="${REGION}" \
    --machine-type=g1-small \
    --network-interface=network-tier=PREMIUM,subnet=default,address="${ADDRESS}" \
    --metadata=environment=development,enable-oslogin=true \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --service-account="${SERVICE_ACCOUNT}"-compute@developer.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/cloud-platform \
    --tags="${FIREWALL_TAGS}" \
    --create-disk=auto-delete=yes,boot=yes,device-name="${GC_INSTANCE_NAME}",image="${IMAGE_NAME}",mode=rw,size=10,type=projects/savup-f3343/zones/us-central1-c/diskTypes/pd-balanced \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --reservation-affinity=any \
    --key-revocation-action-type=stop; then
    exit 0
  fi
fi

exit 0

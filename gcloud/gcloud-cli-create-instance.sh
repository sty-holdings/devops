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
GC_PROJECT_ID=$1
GC_INSTANCE_NAME=$2
GC_REGION=$3
GC_ADDRESS=$4
GC_SERVICE_ACCOUNT=$5
FIREWALL_TAGS=$6
# Script variables
IMAGE_NAME=projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20230302
EPOCHSECONDS=$(date +%s)
GC_INSTANCE_DISK_NAME="${GC_INSTANCE_NAME}-$EPOCHSECONDS"

# NOTE: The project config has to be set before this command runs or it will execute against the last GCloud project set.
if [ "${GC_ADDRESS}" = "0.0.0.0" ]; then
  echo -e "${BLACK}${ON_YELLOW}Since there is no assigned IP Address, this will be connected to the STANDARD Google network.${COLOR_OFF}"
  # The if/then prevents gcloud or an error from terminating the script.
  if gcloud compute instances create "${GC_INSTANCE_NAME}" \
    --project="${GC_PROJECT_ID}" \
    --zone="${GC_REGION}" \
    --machine-type=g1-small \
    --network-interface=network-tier=STANDARD,subnet=default \
    --metadata=environment=development,enable-oslogin=true \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --service-account="${GC_SERVICE_ACCOUNT}"-compute@developer.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/cloud-platform \
    --tags="${FIREWALL_TAGS}" \
    --create-disk=auto-delete=yes,boot=yes,device-name="${GC_INSTANCE_NAME}",image="${IMAGE_NAME}",mode=rw,size=10,type=projects/"${GC_PROJECT_ID}"/zones/"${GC_REGION}"/diskTypes/pd-balanced \
    --create-disk=device-name="${GC_INSTANCE_DISK_NAME}",mode=rw,name="${GC_INSTANCE_DISK_NAME}",size=10,type=projects/"${GC_PROJECT_ID}"/zones/"${GC_REGION}"/diskTypes/pd-balanced \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --reservation-affinity=any \
    --key-revocation-action-type=stop; then
    exit 0
  fi
else
  echo -e "${BLACK}${ON_YELLOW}Since there is an assigned IP Address, this will be connected to the PREMIUM Google network.${COLOR_OFF}"
  # The if/then prevents gcloud or an error from terminating the script.
  if gcloud compute instances create "${GC_INSTANCE_NAME}" \
    --project="${GC_PROJECT_ID}" \
    --zone="${GC_REGION}" \
    --machine-type=g1-small \
    --address="${GC_ADDRESS}" \
    --metadata=environment=development,enable-oslogin=true \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --service-account="${GC_SERVICE_ACCOUNT}"-compute@developer.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/cloud-platform \
    --tags="${FIREWALL_TAGS}" \
    --create-disk=auto-delete=yes,boot=yes,device-name="${GC_INSTANCE_NAME}",image="${IMAGE_NAME}",mode=rw,size=10,type=projects/"${GC_PROJECT_ID}"/zones/"${GC_REGION}"/diskTypes/pd-balanced \
    --create-disk=device-name="${GC_INSTANCE_DISK_NAME}",mode=rw,name="${GC_INSTANCE_DISK_NAME}",size=10,type=projects/"${GC_PROJECT_ID}"/zones/"${GC_REGION}"/diskTypes/pd-balanced \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --reservation-affinity=any \
    --key-revocation-action-type=stop; then
    exit 0
  fi
fi

exit 0

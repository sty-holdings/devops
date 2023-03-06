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
GC_SERVER_USER=$3

echo "Making mounting disk on GCloud instance"
gcloud compute ssh --zone "${GC_REGION}" "${GC_REMOTE_LOGIN}" --command "if [ ! -f \"/etc/original.fstab\" ]; then lsblk --noheadings --raw -o NAME,MOUNTPOINT | awk 'length(\$1) == 3 && \$1 != \"sda\"' > /tmp/drive-letter.tmp; fi"
gcloud compute ssh --zone "${GC_REGION}" "${GC_REMOTE_LOGIN}" --command "if [ ! -f \"/etc/original.fstab\" ]; then drive=\$(cat /tmp/drive-letter.tmp); sudo mkfs.ext4 /dev/\$drive; fi"
echo "Built filesystem for NATS"
gcloud compute ssh --zone "${GC_REGION}" "${GC_REMOTE_LOGIN}" --command "if [ ! -f \"/etc/original.fstab\" ]; then drive=\$(cat /tmp/drive-letter.tmp); lsblk -f /dev/\$drive | awk '\$4!=\"LABEL\" { print \$4 }' > /tmp/drive-uuid.tmp; fi"
gcloud compute ssh --zone "${GC_REGION}" "${GC_REMOTE_LOGIN}" --command "if [ ! -f \"/etc/original.fstab\" ]; then cp /etc/fstab /tmp/fstab; uuid=\$(cat /tmp/drive-uuid.tmp); echo \"UUID=\$uuid /mnt/disks/nats_home ext4 rw 0 \" >> /tmp/fstab; fi"
echo "Built tmp fstab file"
gcloud compute ssh --zone "${GC_REGION}" "${GC_REMOTE_LOGIN}" --command "if [ ! -f \"/etc/original.fstab\" ]; then sudo cp /etc/fstab /etc/original.fstab; sudo cp /tmp/fstab /etc/fstab; fi"
echo "Replaced original fstab with tmp fstab file"
gcloud compute ssh --zone "${GC_REGION}" "${GC_REMOTE_LOGIN}" --command "sudo mkdir -p /mnt/disks/nats_home; sudo chown -R ${GC_SERVER_USER} /mnt/disks/nats_home/.; sudo chown -R ${GC_SERVER_USER} /mnt/disks/nats_home/.*"
gcloud compute ssh --zone "${GC_REGION}" "${GC_REMOTE_LOGIN}" --command "if [ ! -f \"/etc/original.fstab\" ]; then drive=\$(cat /tmp/drive-letter.tmp); sudo mount /dev/\$drive /mnt/disks/nats_home; fi"
echo "Created mount point and mounted drive"
echo "Finished mounting disk on GCloud instance"

exit 0

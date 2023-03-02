#!/bin/bash
#
# Name: gcloud-cli-create-firewall-rules.sh
#
# Description: This will create a gcloud instance.
#
# Installation:
#   None required
#
# Copyright (c) 2022 STY-Holdings Inc
# All Rights Reserved
#

# NOTE: The config has to be set before this command runs or it will execute against the last set GCloud project set.
# The if then prevents the gcloud returning and error and the script terminating.
gcloud compute firewall-rules create nats --direction=INGRESS --priority=1000 --network=default --allow=TCP:4222,TCP:9222

gcloud compute firewall-rules create plaid --direction=INGRESS --priority=1000 --network=default --allow=TCP:3000,TCP:8000

exit 0

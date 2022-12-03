#!/bin/bash
#
# This will create a user for SavUp App
#

USER_NAME=scott_yacko

# SavUp App
echo "==> Create $APP_NAME account"
nsc add user $USER_NAME

echo
echo "==> Make sure to start the Nats Server and push"
echo "run: nsc push"

echo
echo Done

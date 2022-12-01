#!/bin/bash
#
# This will create a user for SavUp App
#

cd $HOME/nats

APP_NAME=SAVUP_APP

# SavUp App
echo "==> Create $APP_NAME account"
nsc add user $APP_NAME $USER_NAME

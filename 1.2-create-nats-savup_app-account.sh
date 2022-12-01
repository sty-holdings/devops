#!/bin/bash
#
# This will create an account for SavUp App
#


cd $HOME/nats

APP_NAME=SAVUP_APP

# SavUp App
echo "==> Create $APP_NAME account"
nsc add account $APP_NAME

echo "==> Generate $APP_NAME account signature key"
nsc edit account $APP_NAME --sk generate

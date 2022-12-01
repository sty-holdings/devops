#!/bin/bash
#
# This will create the nats-server resolver config
#

cd $HOME/nats

echo "==> Create nats-server resolver config file"
nsc generate config --nats-resolver --sys-account SYS > resolver.conf


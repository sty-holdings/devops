#!/bin/bash
#
# This will start the NATS server using the nats.conf file

# Start server
nats-server -c $NATS_HOME/nats.conf & </dev/null &>/dev/null

#!/bin/bash 
#
# This will start the NATS server using the nats.conf file

# Start server
echo "Starting NATS Server" >>NATS_log_file 2>>NATS_log_file
nats-server -c $MY_NATS_HOME/nats.conf & </dev/null &>/dev/null
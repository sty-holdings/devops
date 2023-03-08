#!/bin/bash 
#
# This will start the NATS server using the nats.conf file
HOME=$1
NATS_HOME=$2
NATS_CONF_NAME=$3

echo " - Installing nats.service file"
echo "ExecStart=/usr/bin/nats-server -c /mnt/disks/nats_home/$NATS_CONF_NAME" >> NATS.servicefile
sudo mv "$HOME"/scripts/NATS.servicefile /etc/systemd/system/nats.service
sudo chmod 755 /etc/systemd/system/nats.service
sudo systemctl daemon-reload

# Start server
echo " - Starting NATS Server" >> "$NATS_HOME"/NATS_log_file 2>> "$NATS_HOME"/NATS_log_file
sudo systemctl start nats.service
echo

#!/bin/bash
#
# This will create the nats context for SYS and the SavUp Account

echo "==> Creating the NATS Service"
sudo cp $MY_NATS_HOME/NATS.servicefile /etc/systemd/system/nats.service
sudo chmod 755 /etc/systemd/system/nats.service
sudo systemctl daemon-reload
sudo systemctl start nats.service
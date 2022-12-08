#!/bin/bash 
#
# This will start the NATS server using the nats.conf file

echo "==> Configuring the NATS Service"
sudo cp $MY_NATS_HOME/NATS.servicefile /etc/systemd/system/nats.service
sudo chmod 755 /etc/systemd/system/nats.service
sudo systemctl daemon-reload

# Start server
echo "Starting NATS Server" >>$MY_NATS_HOME/NATS_log_file 2>>$MY_NATS_HOME/NATS_log_file
sudo systemctl start nats.service

#!/bin/bash -vx
#
# This will install NATS, NATSCLI, and NSC
#
NATS_HOME=$1
NATS_BIN=$2
NATSCLI_BIN=$3
NSC_BIN=$4

echo " - Setting up NATS user, group, home directory, and permissions"
if [ -f "$NATS_HOME"/includes ]; then
  echo "   - $NATS_HOME/includes already exists. No action taken."
else
  mkdir -p "$NATS_HOME"/includes
fi

if [ -f "$NATS_HOME"/includes ]; then
  echo "   - $NATS_HOME/jwt already exists. No action taken."
else
  mkdir -p "$NATS_HOME"/jwt
fi

if grep -q "nats" "/etc/passwd"; then
  echo "   - NATS user already exist. No action taken."
else
  sudo useradd --home /mnt/disks/nats_home/ -M -s /bin/false -g nats -G google-sudoers nats
  sudo groupadd nats
  sudo chgrp -R nats "$NATS_HOME"
  sudo chmod g+s "$NATS_HOME"
fi

echo " - Installing NATS server at $NATS_BIN"
if [ -f "$NATS_BIN" ]; then
	echo "   - Server has already been installed"
else
	curl -L https://github.com/nats-io/nats-server/releases/download/v2.9.8/nats-server-v2.9.15-linux-386.zip -o nats-server-v2.9.15.zip
	unzip nats-server-v2.9.8.zip -d nats-server
	sudo cp "$NATS_HOME/nats-server/nats-server-v2.9.8-linux-386/nats-server" $NATS_BIN
fi

echo " - Installing NATSCLI server at $NATSCLI_BIN"
if [ -f "$NATSCLI_BIN" ]; then
	echo "   - NATSCLI has already been installed"
else
	curl -L https://github.com/nats-io/natscli/releases/download/v0.0.35/nats-0.0.35-linux-386.zip -o nats-cli-v0.0.35.zip
	unzip nats-cli-v0.0.35.zip -d nats-cli
	sudo cp "$NATS_HOME/nats-cli/nats-0.0.35-linux-386/nats" "$NATSCLI_BIN"
fi

echo " - Installing NSC server at $NSC_BIN"
if [ -f "$NSC_BIN" ]; then
	echo "   - NSC has already been installed"
else
	curl -L https://github.com/nats-io/nsc/releases/download/2.7.8/nsc-linux-386.zip -o nsc.7.8.zip
	unzip nsc.7.4.zip -d nsc
	sudo cp "$NATS_HOME/nsc/nsc" $NSC_BIN
fi

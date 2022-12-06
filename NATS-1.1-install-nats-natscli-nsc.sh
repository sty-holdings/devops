#!/bin/bash
#
# This will install NATS, NATS CLI, and NSC
#

if grep -q $NATS_HOME "/etc/fstab"; then
	echo "==> NATS home is already mounted"
else
	echo "==> Mounting NATS home"
	sudo mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb
	sudo mkdir -p $NATS_HOME
	sudo mount -o discard,defaults /dev/sdb $NATS_HOME
	sudo chmod a+w $NATS_HOME
	SHOW_MOUNT_NOTES=1
fi

cd $NATS_HOME
echo "--------------"
echo "==> Setting up NATS home directory"
mkdir -p $NATS_HOME/includes
mkdir -p $NATS_HOME/jwt
 
cd $HOME
echo
echo
if [ -d "$HOME/nats" ]; then
	echo "==> SKIPPING - Creating link to $NATS_HOME - ALREADY EXISTS"
	echo
	echo
else
	echo "==> Creating link to $NATS_HOME called nats in $HOME"
	sudo ln -s $NATS_HOME $HOME/nats 
	echo
	echo
fi


# NATS Server
cd $NATS_HOME
echo "--------------"
echo "==> Installing NATS Server"
if [ -f "$NATS_BIN" ]; then
	echo "Server has already been installed"
else
	curl -L https://github.com/nats-io/nats-server/releases/download/v2.9.8/nats-server-v2.9.8-linux-386.zip -o nats-server-v2.9.8.zip
	unzip nats-server-v2.9.8.zip -d nats-server
	sudo cp "$NATS_HOME/nats-server/nats-server-v2.9.8-linux-386/nats-server" $NATS_BIN
fi

# NATS CLI
if [ -f "$NATS_CLI_BIN" ]; then
	echo "CLI has already been installed"
else
	echo "--------------"
	echo "==> Installing NATS CLI"
	curl -L https://github.com/nats-io/natscli/releases/download/v0.0.35/nats-0.0.35-linux-386.zip -o nats-cli-v0.0.35.zip
	unzip nats-cli-v0.0.35.zip -d nats-cli
	sudo cp "$NATS_HOME/nats-cli/nats-0.0.35-linux-386/nats" $NATS_CLI_BIN
fi

# NATS NCS
if [ -f "$NSC_BIN" ]; then
	echo "NSC has already been installed"
else
	echo "--------------"
	echo "==> Installing NSC"
	curl -L https://github.com/nats-io/nsc/releases/download/2.7.4/nsc-linux-386.zip -o nsc.7.4.zip
	unzip nsc.7.4.zip -d nsc
	sudo cp "$NATS_HOME/nsc/nsc" $NSC_BIN
fi
#!/bin/bash
#
# This will install NATS, NATS CLI, and NSC. Additionally, it will create the operator and account
#
NATS_HOME=/mnt/disks/nats_home
#
NATS_BIN=/usr/bin/nats-server
NATS_CLI_BIN=/usr/bin/nats
NSC_BIN=/usr/bin/nsc
#
NATS_OPERATOR=styh
NATS_ACCOUNT=SAVUP
NATS_USER=savup
#
SHOW_MOUNT_NOTES=0


echo
echo "--------------"
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

echo "--------------"
echo "==> Creating NSC operator"
CMD="nsc add operator --generate-signing-key --sys --name $NATS_OPERATOR"
${CMD}
echo "==> NSC operator will require keys and push them to $NATS_URL"
CMD="nsc edit operator --require-signing-keys --account-jwt-server-url $NATS_URL"
${CMD}
echo "==> Create $NATS_ACCOUNT account"
CMD="nsc add account $NATS_ACCOUNT"
${CMD}
echo "==> Generate $NATS_ACCOUNT account signature key"
CMD="nsc edit account $NATS_ACCOUNT --sk generate"
${CMD}
echo "==> Create $NATS_USER user"
CMD="nsc add user $NATS_USER"
${CMD}

echo "--------------"
echo
if [ "$SHOW_MOUNT_NOTES" == "1" ]; then
	sudo cp /etc/fstab /etc/original.fstab
	echo "==> You need to update fstab"
	echo
	echo "run: sudo blkid /dev/sdb"
	echo 
	echo "copy the UUID name/value pair" 
	echo
	echo "run: sudo vim /etc/fstab"
	echo "add the following to the bottom of the file:"
	echo "{UUID name/value pair} $NATS_HOME ext4 discard,defaults 0 2"
	echo
	echo "run: cat /etc/fstab"
	echo "verify that {UUID name/value pair} $NATS_HOME ext4 discard,defaults 0 2 is at the bottom of the file."
	echo
	echo "==> You must run: sudo shutdown -r now"
	echo " This will load the changes made."
	echo
fi
echo
echo Done


#!/bin/bash
#
# Setting needed variables for NATS install and config scripts
#

echo
echo "================================"
echo "  N    N    AA    TTTTTT   SSSS"
echo "  NN   N   A  A     TT    S    "
echo "  N N  N   AAAA     TT     SSS "
echo "  N  N N   A  A     TT        S"
echo "  N   NN  A    A    TT    SSSS "
echo "==============================="
echo

echo "--------------------------"
echo " Setting script variables "
#
# If you make changes here, you may need to make the same change in init.d/nats
#
export NATS_BIN=/usr/bin/nats-server
export NATS_CLI_BIN=/usr/bin/nats
export NSC_BIN=/usr/bin/nsc
export NATS_HOME=/mnt/disks/nats_home
export NATS_RESOLVER=resolver.conf
#
export NATS_OPERATOR=styh
export NATS_ACCOUNT=SAVUP
export NATS_USER=savup
#
export NATS_URL=nats://0.0.0.0:4222
#

echo "--------------------------"
echo " WARNING"
echo " WARNING: You are about to remove the existing Nats server and all files!! "
echo " WARNING"
echo
echo " Do you want to skip this step? (Y/n)"
read continue
if [ "$continue" == "n" ]; then
	sudo rm -rf $NATS_HOME/*
	sudo rm $NATS_BIN
	sudo rm $NATS_CLI_BIN
	sudo rm $NSC_BIN
	rm -rf $HOME/.config/nats
	rm -rf $HOME/.local/nats
	rm -rf $HOME/nats
	rm -rf $HOME/jwt
	echo " Do you want restart to clear NATS from the system? (y/N)"
		read restart
	if [ "$restart" == "y" ]; then
		sudo shutdown -r now
		exit
	fi
fi

echo
echo "==========="
echo "==> Creating the $HOME/.bash_exports"
echo
if grep -q $$NATS_URL "$HOME/.bash_exports"; then
	echo "==> NATS exports already exist"
else
	cat >> "$HOME/.bash_exports" <<- EOF
		export NATS_URL=$NATS_URL
		export NATS_HOME=$NATS_HOME
	EOF
fi


echo
echo "==========="
echo "NEXT: Install NATS server, NATS CLI, and NSC"
echo
echo " Do you want to skip this step? (Y/n)"
read continue
if [ "$continue" == "n" ]; then
	sh $HOME/NATS-1.1-install-nats-natscli-nsc.sh
fi

echo
echo "==========="
echo "NEXT: Creating NATS operator and SYS account"
echo
echo " Do you want to skip this step? (Y/n)"
read continue
if [ "$continue" == "n" ]; then
	sh $HOME/NATS-1.2-create-operator.sh
fi

echo
echo "==========="
echo "NEXT: Creating NATS SAVUP account and savup user"
echo
echo " Do you want to skip this step? (Y/n)"
read continue
if [ "$continue" == "n" ]; then
	sh $HOME/NATS-1.2.1-create-savup-account-user.sh
fi

echo
echo "==========="
echo "NEXT: Creating NATS config file"
echo
echo " Do you want to skip this step? (Y/n)"
read continue
if [ "$continue" == "n" ]; then
	sh $HOME/NATS-1.3-create-config-file.sh
fi

echo
echo "==========="
echo "NEXT: Creating NATS resolver file"
echo
echo " Do you want to skip this step? (Y/n)"
read continue
if [ "$continue" == "n" ]; then
	sh $HOME/NATS-1.4-create-resolver-file.sh
fi

echo "==========="
echo
echo "==> XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
echo "==> XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
echo "==> XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
echo "==> XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
echo
echo "==> You are about to start the NATS server in background mode"
echo "==>"
echo "==>"
echo " Do you want to skip this step? (Y/n)"
read continue
if [ "$continue" == "n" ]; then
	nohup sh $HOME/NATS-1.5-start-server.sh & </dev/null &>/dev/null
fi

echo
echo "==========="
echo "NEXT: Pushing NSC account to Nats server"
echo
echo " Do you want to skip this step? (Y/n)"
read continue
if [ "$continue" == "n" ]; then
	sh $HOME/NATS-1.6-push-accounts-users.sh
fi

echo
echo "==========="
echo "NEXT: Creating NATS contexts"
echo
echo " Do you want to skip this step? (Y/n)"
read continue
if [ "$continue" == "n" ]; then
	sh $HOME/NATS-1.7-create-contexts.sh
fi

echo
echo "==========="
echo "NEXT: Clean up and next steps "
echo
echo " Do you want to skip this step? (Y/n)"
read continue
if [ "$continue" == "n" ]; then
	sh $HOME/NATS-1.9-cleanup.sh
	echo
	echo "==> Clean up is done"
fi

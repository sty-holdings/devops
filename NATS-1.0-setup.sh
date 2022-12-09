#!/bin/bash

#
# Setting needed variables for NATS install and config scripts
#

# TODO: Pass variable to sub scripts to make them reusable
# TODO: Add option to execute all steps except the reboot


displayNATS() {
	echo
	echo "================================"
	echo "  N    N    AA    TTTTTT   SSSS"
	echo "  NN   N   A  A     TT    S    "
	echo "  N N  N   AAAA     TT     SSS "
	echo "  N  N N   A  A     TT        S"
	echo "  N   NN  A    A    TT    SSSS "
	echo "==============================="
	echo
}

dislpayAlert() {
	echo
	echo "**********************************"
	echo 
	echo "  AA   L      EEEEEE RRRR   TTTTT"
	echo " A  A  L      E      R   R    T  "
	echo " AAAA  L      EEEE   RRRR     T  "
	echo "A    A L      E      R   R    T  "
	echo "A    A LLLLLL EEEEEE R    R   T  "
	echo 
	echo "**********************************"
	echo
}

displayStepSpacer() {
	echo
	echo
	echo
	echo
	echo "--------------------------"
}


displayNATS()

sudo ps aux | grep nats-server | awk '/nats.conf/' > /tmp/natsAUX.tmp
NATS_PID=$(sudo cat /tmp/natsAUX.tmp | awk '//{print $2}')
if ! [[ -z "$NATS_PID" ]]; then
	displayAlert()
	echo " A NATS Server is already running on this system."
	echo
	echo " Please investigate the configuration of this system."
	echo 
	echo "NATS PID: $NATS_PID"
	echo
	echo "You must stop NATS before this script will run."
	echo
	echo "run: kill -USR2 $NATS_PID"
	echo
	exit
fi 

displayStepSpacer()
echo " Setting script variables "
#
# If you make changes here, you may need to make the same change in init.d/nats
#
export MY_NATS_BIN=/usr/bin/nats-server
export MY_NATS_CLI_BIN=/usr/bin/nats
export MY_NSC_BIN=/usr/bin/nsc
export MY_NATS_HOME=/mnt/disks/nats_home
export MY_NATS_RESOLVER=resolver.conf
export MY_NATS_CONF=nats.conf
export MY_NATS_PID=nats.pid
export MY_NATS_PID_RUNNING=nats.pid.running
#
export MY_NATS_OPERATOR=styh
export MY_NATS_ACCOUNT=SAVUP
export MY_NATS_USER=savup
#
export MY_NATS_URL="nats://0.0.0.0:4222"
export MY_NATS_SERVER_NAME="nats-dev-1"
#

displayStepSpacer()
echo " WARNING"
echo " WARNING: You are about to remove the existing NATS server and all files!! "
echo " WARNING"
echo
echo " Do you want to SKIP this step? (Y/n)"
echo "                ----"
read continue
if [ "$continue" == "n" ]; then
	sudo rm -rf $MY_NATS_HOME/*
	sudo rm $MY_NATS_BIN
	sudo rm $MY_NATS_CLI_BIN
	sudo rm $MY_NSC_BIN
	rm -rf $HOME/.config/NATS
	rm -rf $HOME/.local/NATS
	rm -rf $HOME/.local/share
	rm -rf $HOME/NATS
	rm -rf $HOME/jwt
	rm $MY_NATS_HOME/NATS_log_file
	echo
	echo " Do you want RESTART the system? (y/N)"
	echo "             -------"
		read restart
	if [ "$restart" == "y" ]; then
		sudo shutdown -r now
		exit
	fi
fi

echo
echo "==========="
echo "==> Appending NATS to the $HOME/.bash_exports"
echo
if grep -q $MY_NATS_URL "$HOME/.bash_exports"; then
	echo "==> NATS exports already exist"
else
	cat >> "$HOME/.bash_exports" <<- EOF
		export NATS_URL=$MY_NATS_URL
		export NATS_HOME=$MY_NATS_HOME
	EOF
fi



displayStepSpacer()
echo "NEXT: Install NATS server, NATS CLI, and NSC"
echo
echo " Do you want to SKIP this step? (Y/n)"
echo "                ----"
read continue
if [ "$continue" == "n" ]; then
	sh $HOME/NATS-1.1-install-nats-natscli-nsc.sh
fi

displayStepSpacer()
echo "NEXT: Creating NATS operator and SYS"
echo
echo " Do you want to SKIP this step? (Y/n)"
echo "                ----"
read continue
if [ "$continue" == "n" ]; then
	sh $HOME/NATS-1.2-create-operator-sys.sh
fi

displayStepSpacer()
echo "NEXT: Creating NATS SAVUP account"
echo
echo " Do you want to SKIP this step? (Y/n)"
echo "                ----"
read continue
if [ "$continue" == "n" ]; then
	sh $HOME/NATS-1.2.1-create-savup-account.sh
fi

displayStepSpacer()
echo "NEXT: Creating NATS resolver file"
echo
echo " Do you want to SKIP this step? (Y/n)"
echo "                ----"
read continue
if [ "$continue" == "n" ]; then
	sh $HOME/NATS-1.3-create-resolver-file.sh
	sh $HOME/NATS-1.3.1-edit-jwt-dir.sh
fi

displayStepSpacer()
echo "NEXT: Creating NATS config file"
echo
echo " Do you want to SKIP this step? (Y/n)"
echo "                ----"
read continue
if [ "$continue" == "n" ]; then
	sh $HOME/NATS-1.4-create-config-file.sh
fi

displayStepSpacer()
echo "==> XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
echo "==> XX WARNING - VERY IMPORTANT     XX"
echo "==> XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
echo
echo "==> You are about to start the NATS server in background mode"
echo "==>"
echo "==>"
echo " Do you want to SKIP this step? (Y/n)"
echo "                ----"
read continue
if [ "$continue" == "n" ]; then
	sh $HOME/NATS-1.5-start-server.sh &
	sleep 2
	sudo ps aux | grep nats-server | awk '/nats.conf/' > /tmp/natsAUX.tmp
	NATS_PID=$(sudo cat /tmp/natsAUX.tmp | awk '//{print $2}')
	if [[ -z "$NATS_PID" ]]; then
		echo "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
		echo "ZZ      SERVER DID NOT START        ZZ"
		echo "ZZ           EXISTING               ZZ"
		echo "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
		exit
	fi
fi

displayStepSpacer()
echo "NEXT: Pushing NSC account to NATS server"
echo
echo " Do you want to SKIP this step? (Y/n)"
echo "                ----"
read continue
if [ "$continue" == "n" ]; then
	sh $HOME/NATS-1.6-push-accounts.sh
fi

displayStepSpacer()
echo "NEXT: Creating NATS savup user"
echo
echo " Do you want to SKIP this step? (Y/n)"
echo "                ----"
read continue
if [ "$continue" == "n" ]; then
	sh $HOME/NATS-1.7-create-savup-user.sh
fi

displayStepSpacer()
echo "NEXT: Creating NATS contexts"
echo
echo " Do you want to SKIP this step? (Y/n)"
echo "                ----"
read continue
if [ "$continue" == "n" ]; then
	sh $HOME/NATS-1.7.1-create-contexts.sh
fi

displayStepSpacer()
echo "NEXT: Clean up and next steps "
echo
echo " Do you want to SKIP this step? (Y/n)"
echo "                ----"
read continue
if [ "$continue" == "n" ]; then
	sh $HOME/NATS-1.9-cleanup.sh
	echo
	echo "==> Clean up is done"
fi

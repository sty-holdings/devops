#!/bin/bash
#
# Name: NATS-1.0-setup.sh
#
# Description: Installs a stand alone instance of the NATS server
#
# Installation:
#   None required
#
# Copyright (c) 2022 STY-Holdings Inc
# All Rights Reserved
#

set -eo pipefail

# script variables
# shellcheck disable=SC2006
FILENAME=$(basename "$0")
# Directory and files
ROOT_DIRECTORY=/home/scott_yacko_sty_holdings_com # Remote instance
SCRIPT_DIRECTORY=${ROOT_DIRECTORY}/scripts  # Remote instance
NATS_OPERATOR=""
NATS_ACCOUNT=""
NATS_USER=""
NATS_URL=""
NATS_SERVER_NAME=""
NATS_WEBSOCKET_PORT=""
# Internal Variables
MY_NATS_BIN=/usr/bin/nats-server
MY_NATS_CLI_BIN=/usr/bin/nats
MY_NSC_BIN=/usr/bin/nsc
MY_NATS_HOME=/mnt/disks/nats_home
MY_NATS_RESOLVER=resolver.conf
MY_NATS_CONF=nats.conf
MY_NATS_PID=nats.pid
MY_NATS_PID_RUNNING=nats.pid.running
WARNING_MESSAGE=""

function init_script() {
  . "${SCRIPT_DIRECTORY}"/echo-colors.sh
}

function display_savup() {
  echo "  ======================================"
  echo "     SSSS    AA    V    V  U   U  PPPP  "
  echo "    S       A  A   V    V  U   U  P   P "
  echo "     SSS    AAAA    V  V   U   U  PPPP  "
  echo "        S  A    A   V  V   U   U  P     "
  echo "    SSSS   A    A    VV     UUU   P     "
  echo "  ======================================"
  echo
  echo " NATS SERVER installation and configuration"
}

function displayAlert() {
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

function displayWarning() {
  echo -e "${ON_YELLOW} WARNING: ${WARNING_MESSAGE}${COLOR_OFF}"
  echo
}

function displayStepSpacer() {
	echo "--------------------------"
}

function displaySkipMessage() {
  if [ "$1" == "y" ]; then
    echo -e " Do you want to ${ON_GREEN}SKIP${COLOR_OFF} this step? (${ON_GREEN}Y${COLOR_OFF}/n)"
  else
    echo -e " Do you want to ${ON_GREEN}SKIP${COLOR_OFF} this step? y/(${ON_GREEN}N${COLOR_OFF})"
  fi
}

function isNATSAlreadyRunning() {
  sudo ps aux | grep nats-server | awk '/nats.conf/' > /tmp/natsAUX.tmp
  NATS_PID=$(sudo cat /tmp/natsAUX.tmp | awk '//{print $2}')

  if [[ -n "$NATS_PID" ]]; then
   	displayAlert
    	echo -e "${ON_RED} A NATS Server is already running on this system.${COLOR_OFF}"
    	echo
    	echo -e "${ON_RED} Please investigate the configuration of this system.${COLOR_OFF}"
    	echo
    	echo -e "${ON_RED} NATS PID:${COLOR_OFF} $NATS_PID"
    	echo
    	echo -e "${ON_RED} You must stop NATS before this script will run.${COLOR_OFF}"
    	echo
    	echo -e "${ON_RED} run: kill -USR2 $NATS_PID${COLOR_OFF}"
    	echo
    	exit 1
  fi
}

function print_error() {
  echo -e "${ON_RED}$1${COLOR_OFF}"
}

function set_variable() {
  cmd="${1}=$2"
  eval "$cmd"
  cmd="${1}_CHECKED=\"true\""
  eval "$cmd"
}

function validate_parameters() {
  if [ -z "$NATS_OPERATOR_CHECKED" ]; then
    local Failed="true"
    print_error "ERROR: The operator parameter is missing"
  fi
  if [ -z "$NATS_ACCOUNT_CHECKED" ]; then
    local Failed="true"
    print_error "ERROR: The account parameter is missing"
  fi
  if [ -z "$NATS_USER_CHECKED" ]; then
    local Failed="true"
    print_error "ERROR: The user parameter is missing"
  fi
  if [ -z "$NATS_URL_CHECKED" ]; then
    local Failed="true"
    print_error "ERROR: The URL parameter is missing"
  fi
  if [ -z "$NATS_SERVER_NAME_CHECKED" ]; then
    local Failed="true"
    print_error "ERROR: The server name parameter is missing"
  fi

  if [ "$Failed" == "true" ]; then
    print_usage
    exit 1
  fi
}

function print_parameters() {
  echo "Here are the values you have supplied:"
  echo -e "NATS_OPERATOR:\t     ${NATS_OPERATOR}"
  echo -e "NATS_ACCOUNT:\t     ${NATS_ACCOUNT}"
  echo -e "NATS_USER:\t     ${NATS_USER}"
  echo -e "NATS_URL:\t     ${NATS_URL}"
  echo -e "NATS_SERVER_NAME:    ${NATS_SERVER_NAME}"
  if [ -z "${NATS_WEBSOCKET_PORT}" ]; then
  echo -e "NATS_WEBSOCKET_PORT: ${NATS_WEBSOCKET_PORT}"
  else
  echo -e "NATS_WEBSOCKET_PORT: ${NATS_WEBSOCKET_PORT}"
  fi-
  echo
  echo "Here are the pre-set or defined variables:"
  echo -e "ROOT_DIRECTORY:   ${ROOT_DIRECTORY}"
  echo -e "SCRIPT_DIRECTORY: ${SCRIPT_DIRECTORY}"
  echo
}

function removeNATS() {
  WARNING_MESSAGE="You are about to remove any existing NATS software from the instance!!"
  displayWarning
  displaySkipMessage
  read -r continue
  if [ "$continue" == "n" ]; then
    sudo rm -rf $MY_NATS_HOME/*
    sudo rm $MY_NATS_BIN
   	sudo rm $MY_NATS_CLI_BIN
   	sudo rm $MY_NSC_BIN
   	rm -rf "$HOME"/.config/NATS
   	rm -rf "$HOME"/.local/NATS
   	rm -rf "$HOME"/.local/share
   	rm -rf "$HOME"/NATS
   	rm -rf "$HOME"/jwt
   	rm "$MY_NATS_HOME"/NATS_log_file
  else
    echo "You elected to skip this step"
  fi
}

function restartSystem() {
  echo " Do you want ${ON_GREEN}RESTART${COLOR_OFF} the system? (y/${ON_GREEN}N${COLOR_OFF})"
  	read -r restart
  if [ "$restart" == "y" ]; then
  	sudo shutdown -r now
  	exit
  fi
}

function addNATSExport() {
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
}

function installNATSTools() {
  echo
  echo "Install NATS server, NATS CLI, and NSC"
  displaySkipMessage
  read continue
  if [ "$continue" == "n" ]; then
  	sh $HOME/scripts/NATS-install-nats-natscli-nsc.sh
  fi
}

function createOperatorAndSystem() {
  echo
  echo "Creating NATS operator and SYS"
  displaySkipMessage
  echo "                ----"
  read continue
  if [ "$continue" == "n" ]; then
  	sh $HOME/NATS-1.2-create-operator-sys.sh
  fi
}

function createAccount() {
  #echo "NEXT: Creating NATS SAVUP account"
  #echo
  #echo " Do you want to SKIP this step? (Y/n)"
  #echo "                ----"
  #read continue
  #if [ "$continue" == "n" ]; then
  #	sh $HOME/NATS-1.2.1-create-savup-account.sh
  #fi

}

function createResolver() {
  #echo "NEXT: Creating NATS resolver file"
  #echo
  #echo " Do you want to SKIP this step? (Y/n)"
  #echo "                ----"
  #read continue
  #if [ "$continue" == "n" ]; then
  #	sh $HOME/NATS-1.3-create-resolver-file.sh
  #	sh $HOME/NATS-1.3.1-edit-jwt-dir.sh
  #fi
}

function createNATSServerConfig() {
    #echo "NEXT: Creating NATS config file"
    #echo
    #echo " Do you want to SKIP this step? (Y/n)"
    #echo "                ----"
    #read continue
    #if [ "$continue" == "n" ]; then
    #	sh $HOME/NATS-1.4-create-config-file.sh
    #fi
}

function startNATSServer() {
  #echo "==> XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  #echo "==> XX WARNING - VERY IMPORTANT     XX"
  #echo "==> XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  #echo
  #echo "==> You are about to start the NATS server in background mode"
  #echo "==>"
  #echo "==>"
  #echo " Do you want to SKIP this step? (Y/n)"
  #echo "                ----"
  #read continue
  #if [ "$continue" == "n" ]; then
  #	sh $HOME/NATS-1.5-start-server.sh &
  #	sleep 2
  #	sudo ps aux | grep nats-server | awk '/nats.conf/' > /tmp/natsAUX.tmp
  #	NATS_PID=$(sudo cat /tmp/natsAUX.tmp | awk '//{print $2}')
  #	if [[ -z "$NATS_PID" ]]; then
  #		echo "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
  #		echo "ZZ      SERVER DID NOT START        ZZ"
  #		echo "ZZ           EXISTING               ZZ"
  #		echo "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
  #		exit
  #	fi
  #fi
}

function pushAllAccountsUser() {
  #echo "NEXT: Pushing NSC account to NATS server"
  #echo
  #echo " Do you want to SKIP this step? (Y/n)"
  #echo "                ----"
  #read continue
  #if [ "$continue" == "n" ]; then
  #	sh $HOME/NATS-1.6-push-accounts.sh
  #fi
}

function createUser() {
  #echo "NEXT: Creating NATS savup user"
  #echo
  #echo " Do you want to SKIP this step? (Y/n)"
  #echo "                ----"
  #read continue
  #if [ "$continue" == "n" ]; then
  #	sh $HOME/NATS-1.7-create-savup-user.sh
  #fi
}

function createContext() {
  #echo "NEXT: Creating NATS contexts"
  #echo
  #echo " Do you want to SKIP this step? (Y/n)"
  #echo "                ----"
  #read continue
  #if [ "$continue" == "n" ]; then
  #	sh $HOME/NATS-1.7.1-create-contexts.sh
  #fi
}

function cleanUp() {
  #echo "NEXT: Clean up and next steps "
  #echo
  #echo " Do you want to SKIP this step? (Y/n)"
  #echo "                ----"
  #read continue
  #if [ "$continue" == "n" ]; then
  #	sh $HOME/NATS-1.9-cleanup.sh
  #	echo
  #	echo "==> Clean up is done"
  #fi
}

function print_usage() {
  echo
  echo "This will create an instance on GCloud."
  echo
  echo "Usage: ${FILENAME} -h | -o {operator name} -a {account name} -u {user name} -n {url} -s {server name} -w {port number}"
  echo
  echo "flags:"
  echo -e "  -h\t\t\t display help"
  echo -e "  -o {operator name}\t The name of the operator."
  echo -e "  -a {account name}\t The name of the starter account."
  echo -e "  -u {user name}\t The name of the starter user."
  echo -e "  -n {url}\t\t The URL for the server. This has to be set up in DNS or the host file."
  echo -e "  -s {server name}\t The instance name of the server."
  echo -e "  -w {port number}\t Optional - Websocket port number. Recommended to use 9222"
  echo
}

# Main function of this script
function run_script {
  if [ "$#" == "0" ]; then
    print_error "ERROR: No parameters where provided."
    print_usage
    exit 1
  fi

  display_savup
  isNATSAlreadyRunning

  while getopts 'o:a:u:n:s:w:h' OPT; do # see print_usage
    case "$OPT" in
    o)
      set_variable NATS_OPERATOR "$OPTARG"
      ;;
    a)
      set_variable NATS_ACCOUNT "$OPTARG"
      ;;
    u)
      set_variable NATS_USER "$OPTARG"
      ;;
    n)
      set_variable NATS_URL "$OPTARG"
      ;;
    s)
      set_variable NATS_SERVER_NAME "$OPTARG"
      ;;
    w)
      set_variable NATS_WEBSOCKET_PORT "$OPTARG"
      ;;
    h)
      print_usage
      exit 0
      ;;
    *)
      print_error "${ON_RED}ERROR: Please review the usage printed below:${COLOR_OFF}" >&2
      print_usage
      exit 1
      ;;
    esac
  done

  validate_parameters
  print_parameters
  removeNATS
  restartSystem
  addNATSExport
  installNATSTools
  createOperatorAndSystem
  createAccount
  createResolver
  createNATSServerConfig
  startNATSServer
  pushAllAccountsUser
  createUser
  createContext
  cleanUp
}

init_script
run_script "$@"

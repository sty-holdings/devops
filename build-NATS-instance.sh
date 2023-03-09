#!/bin/bash
#
# Name: build-NATS-instance.sh
# To execute: ./build-NATS-instance.sh ...
#
# Description: Creates a GCloud instance for running a NATS server.
#
# Installation:
#   You need to have a Google account with a project.
#
# NOTES:
#   It is recommended that you have a service account for the project. If you don't, you will need to
#   remove --service-account from the GCloud-cli-create-instance.sh file.
#
# Required IAM Roles:
#  - Compute Admin
#  - Compute Network Admin
#  - Compute Organization Resource Admin
#  - Compute OS Admin Login
#  - Owner
#  - Tech Support Editor
#
# Copyright (c) 2022 STY-Holdings Inc
# All Rights Reserved
#
# shellcheck disable=SC2028
set -eo pipefail

# script variables
# shellcheck disable=SC2006
FILENAME=$(basename "$0")
# Directory and files
ROOT_DIRECTORY=/Users/syacko/workspace/styh-dev/devops
GCLOUD_ROOT_DIRECTORY=${ROOT_DIRECTORY}/gcloud
NATS_ROOT_DIRECTORY=${ROOT_DIRECTORY}/nats_server_setup
SHARED_DIRECTORY=${ROOT_DIRECTORY}/shared
TARGET_DIRECTORY=/home/scott_yacko_sty_holdings_com
# GCloud variables
GC_SERVER_USER="scott_yacko_sty_holdings_com"
GC_REGION="us-central1-c"
GC_INSTANCE_NAME=""
GC_REMOTE_LOGIN=""
GC_PROJECT_ID=""
GC_SERVICE_ACCOUNT=""
GC_INSTANCE_NUMBER=""
GC_INSTANCE_ADDRESS=""
GC_FIREWALL_TAGS=""

function buildInstanceDiskNames() {
  # shellcheck disable=SC2155
  local paddedNumber="$(printf %04d "${GC_INSTANCE_NUMBER}")"
  GC_INSTANCE_NAME="nats-${SHORT_TARGET_ENVIRONMENT}-${paddedNumber}"
}

function buildRemoteInstanceLogin() {
  GC_REMOTE_LOGIN=${GC_SERVER_USER}@${GC_INSTANCE_NAME}
}

function copyingFileGCloudInstance() {
  displayInfo "Copying support files to GCloud instance"
  . ${GCLOUD_ROOT_DIRECTORY}/gcloud-cli-copy-supporting-files.sh "$1" "$2" "$3" "$5"
  echo
  displayInfo "Copying NATS files to GCloud instance"
  . ${NATS_ROOT_DIRECTORY}/gcloud_cli_copy_nats_files.sh "$1" "$2" "$4" "$5"
  echo
}

function creatingGCloudDirectories() {
  displayInfo "Making directories on GCloud instance"
  . ${GCLOUD_ROOT_DIRECTORY}/gcloud-cli-create-directories.sh "$1" "$2" "$3" "$4"
  echo
}

function creatingGCloudFirewallRules() {
  displayInfo "Making firewall rules"
  printFailureNote "firewall rule"
  . ${GCLOUD_ROOT_DIRECTORY}/gcloud-cli-create-nats-firewall-rules.sh
  echo
}

function creatingGCloudInstance() {
  displayInfo "Building GCloud Instance"
  printFailureNote "instance"
  . ${GCLOUD_ROOT_DIRECTORY}/gcloud-cli-create-instance.sh "$1" "$2" "$3" "$4" "$5" "$6" "$7"
  displayInfo "The script is going to pause for 30 seconds to allow time for the instance to spin up."
#  echo "${BLACK}${ON_YELLOW}The script is going to pause for 30 seconds to allow time for the instance to spin up.${COLOR_OFF}"
  sleep 30
  echo
}

function displaySavup() {
  echo "======================================"
  echo "   SSSS    AA    V    V  U   U  PPPP  "
  echo "  S       A  A   V    V  U   U  P   P "
  echo "   SSS    AAAA    V  V   U   U  PPPP  "
  echo "      S  A    A   V  V   U   U  P     "
  echo "  SSSS   A    A    VV     UUU   P     "
  echo "======================================"
}

function executingGCloudBaseConfiguration() {
  displayInfo "Starting base configuration of the instance."
  if gcloud compute ssh --zone "${GC_REGION}" "${GC_REMOTE_LOGIN}" --command "sh ${TARGET_DIRECTORY}/scripts/0-config-instance.sh"; then
    echo
  fi
}

function  getServiceAccountNumber() {
  displayInfo "Getting the service account id for the GCloud project"
  if gcloud iam service-accounts list --project="${GC_PROJECT_ID}" > /tmp/service-account.tmp; then
    awk ' $1=="Compute" { print $6 } ' < /tmp/service-account.tmp > /tmp/service-account-email.tmp
    GC_SERVICE_ACCOUNT=$(awk -F - ' { print $1 } ' < /tmp/service-account-email.tmp)
    rm /tmp/service-account.tmp /tmp/service-account-email.tmp
  fi
  echo
}

function initScript() {
  . "${SHARED_DIRECTORY}"/echo-colors.sh
  . "${SHARED_DIRECTORY}"/display-info.sh
  . "${SHARED_DIRECTORY}"/display-warning.sh
  . "${SHARED_DIRECTORY}"/display-error.sh
}

function mountNatsDrive() {
  displayInfo "Building and mounting NATS disk on GCloud instance"
  . "${GCLOUD_ROOT_DIRECTORY}"/gcloud-cli-mount-drive.sh "$1" "$2" "$3"
  echo
}

function printFailureNote() {
  displayInfo "If running any of the $1 commands fail, this script will continue to execute. You will have investigate if the error is critical."
}

function printParameters() {
  displayInfo "Here are the values you have supplied:"
  echo -e "Target Environment:\t${TARGET_ENVIRONMENT}"
  echo -e "GC_PROJECT_ID=\t\t${GC_PROJECT_ID}"
  echo -e "\t\t\tmust match the target environment. Env of dev should have the dev project id."
  echo -e "GC_SERVICE_ACCOUNT=\t${GC_SERVICE_ACCOUNT}"
  echo -e "\t\t\tmust match the target environment. Env of dev should have the dev service account."
  echo -e "GC_INSTANCE_NUMBER=\t${GC_INSTANCE_NUMBER}"
  echo -e "GC_INSTANCE_ADDRESS=\t${GC_INSTANCE_ADDRESS}"
  echo -e "GC_FIREWALL_TAGS=\t${GC_FIREWALL_TAGS}"
  echo
  echo "Here are the pre-set or defined variables:"
  echo -e "ROOT_DIRECTORY= \t${ROOT_DIRECTORY}"
  echo -e "GCLOUD_ROOT_DIRECTORY=\t${ROOT_DIRECTORY}/gcloud"
  echo -e "NATS_ROOT_DIRECTORY=\t${ROOT_DIRECTORY}/nats_server_setup"
  echo -e "SHARED_DIRECTORY=\t${ROOT_DIRECTORY}/shared"
  echo -e "TARGET_DIRECTORY=\t${TARGET_DIRECTORY}"
  echo -e "GC_SERVER_USER= \t${GC_SERVER_USER}"
  echo -e "GC_REGION=      \t${GC_REGION}"
  echo -e "GC_INSTANCE_NAME=\t${GC_INSTANCE_NAME}"
  echo -e "GC_REMOTE_LOGIN=\t${GC_REMOTE_LOGIN}"
  echo
}

function printUsage() {
  echo "This will create an NATS server instance on GCloud."
  echo
  echo "Usage: ./${FILENAME} -h, -d | -p, -a {argument}, -f {argument}, -n {argument}, -g {Google project id}"
  echo
  echo "flags:"
  echo -e "-h\t\t\t display help"
  echo -e "-d\t\t\t Install a GCloud development instance. (-d | -p Must be first flag provided."
  echo -e "-p\t\t\t Install a GCloud production instance. (-d | -p Must be first flag provided."
  echo -e "-a {IPV4 address}\t The IPV4 address for the instance. To have an IP address assigned, use 0.0.0.0"
  echo -e "-n {number}\t\t The unique number that identifies the instance."
  echo -e "-f {tag,...}\t\t Which firewall tags that should be applied to this instance."
  echo -e "-g {project id}\t\t The project id that matches the environment. Project Id for dev vs the project id for production."
  echo -e "\t\t\t clicking on Computer Engine default service account. You want the number at the beginning of the email."
  echo
}

function restartingGCloudInstance() {
  displayInfo "Restarting GCloud instance"
  if gcloud compute ssh --zone "${GC_REGION}" "${GC_REMOTE_LOGIN}" --command "sudo shutdown -r now"; then
    displayInfo "The script is going to pause for 1 minute to allow time for the instance to spin up after the reboot."
    sleep 60
  fi
  echo
}

function setVariable() {
  if [ "$1" == "TARGET_ENVIRONMENT" ]; then
    if [ -n "$TARGET_ENVIRONMENT" ]; then
      displayError "You can only use -d or -p, not both."
      printUsage
      exit 1
    fi
  fi
  cmd="${1}=$2"
  eval "$cmd"
  cmd="${1}_CHECKED=\"true\""
  eval "$cmd"
}

function validateParameters() {
  if [ -z "$GC_INSTANCE_ADDRESS_CHECKED" ]; then
    local Failed="true"
    dislpayError "The address parameter is missing"
  fi
  if [ -z "$GC_INSTANCE_NUMBER_CHECKED" ]; then
    local Failed="true"
    dislpayError "The number parameter is missing"
  fi
  if [ -z "$GC_FIREWALL_TAGS_CHECKED" ]; then
    local Failed="true"
    dislpayError "The firewall tags parameter is missing"
  fi
  if [ -z "$GC_PROJECT_ID_CHECKED" ]; then
    local Failed="true"
    dislpayError "The Google project id parameter is missing"
  fi

  if [ "$Failed" == "true" ]; then
    printUsage
    exit 1
  fi
}

# Main function of this script
function runScript {
  if [ "$#" == "0" ]; then
    dislpayError "No parameters where provided."
    printUsage
    exit 1
  fi
  if [ ! "$1" == "-p" ] && [ ! "$1" == "-d" ] && [ ! "$1" == "-h" ]; then
    dislpayError "The first parameter must be -d, -h, or -p."
    printUsage
    exit 1
  fi

  displaySavup

  while getopts 'd|pa:f:n:g:s:h' OPT; do
    case "$OPT" in
    a)
      setVariable GC_INSTANCE_ADDRESS "$OPTARG"
      ;;
    d)
      setVariable TARGET_ENVIRONMENT "development"
      SHORT_TARGET_ENVIRONMENT="dev"
      ;;
    f)
      setVariable GC_FIREWALL_TAGS "$OPTARG"
      ;;
    g)
      setVariable GC_PROJECT_ID "$OPTARG"
      ;;
    h)
      printUsage
      exit 0
      ;;
    n)
      setVariable GC_INSTANCE_NUMBER "$OPTARG"
      ;;
    p)
      setVariable TARGET_ENVIRONMENT "production"
      SHORT_TARGET_ENVIRONMENT="prod"
      ;;
    *)
      dislpayError "Please review the usage below:" >&2
      printUsage
      exit 1
      ;;
    esac
  done

  validateParameters
  buildInstanceDiskNames
  buildRemoteInstanceLogin
  printParameters

  if [ ! -d "$ROOT_DIRECTORY" ]; then
    dislpayError "Directory $ROOT_DIRECTORY DOES NOT exists. Edit the 'Directory and files' section at the top of the script to match your system."
    exit 9
  fi

  # The GCloud config set $GC_PROJECT_ID is required to make sure the resources are built in the correct project.
  if gcloud config set project "$GC_PROJECT_ID"; then
    getServiceAccountNumber "$GC_PROJECT_ID"
    creatingGCloudFirewallRules
    creatingGCloudInstance "$GC_PROJECT_ID" "$GC_INSTANCE_NAME" "$GC_REGION" "$GC_INSTANCE_ADDRESS" "$GC_SERVICE_ACCOUNT" "$GC_FIREWALL_TAGS" "$SHARED_DIRECTORY"
    mountNatsDrive "$GC_REGION" "$GC_REMOTE_LOGIN" "$GC_SERVER_USER"
    creatingGCloudDirectories "$GC_REGION" "$GC_REMOTE_LOGIN" "$TARGET_DIRECTORY" $GC_SERVER_USER
    copyingFileGCloudInstance "$GC_REGION" "$GC_REMOTE_LOGIN" "$SHARED_DIRECTORY" "$NATS_ROOT_DIRECTORY" "$TARGET_DIRECTORY"
    executingGCloudBaseConfiguration
    restartingGCloudInstance

    echo -e "${BLACK}${ON_GREEN}Post installation steps:${COLOR_OFF}"
    echo "Check the following items to see if the installation complete:"
    echo -e "\tYou can connect to the ${GC_INSTANCE_NAME}"
    echo -e "\tThe following directories exist:"
    echo -e "\t\t${TARGET_DIRECTORY}"
    echo -e "\t\t${TARGET_DIRECTORY}/scripts"
    echo -e "\tThere are files in the scripts directory"
    echo -e "\t/etc/original.fstab exists"
    echo -e "\tYou can enter lsl on the command line and get a list of files."
    echo "To install the NATS server, go to ${TARGET_DIRECTORY}/scripts and run nats-setup.sh"
    echo "Done"
    echo
  fi
}

initScript
runScript "$@"

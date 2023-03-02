#!/bin/bash
#
# Name: build-NATS-server-instance.sh
#
# Description: Creates a gcloud instance for running a NATS server.
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
ROOT_DIRECTORY=/Users/syacko/workspace/styh-dev/src/albert
SAVUP_DIRECTORY=/SavUpServer
SAVUP_ROOT_DIRECTORY=${ROOT_DIRECTORY}${SAVUP_DIRECTORY}
TARGET_DIRECTORY=/home/scott_yacko_sty_holdings_com/styh/server
# GCloud variables
GC_SERVER_USER="scott_yacko_sty_holdings_com"
GC_REGION="us-central1-c"
GC_INSTANCE_NAME=""
GC_REMOTE_INSTANCE_LOGIN=""
GC_PROJECT_NAME=""
GC_SERVICE_ACCOUNT=""
GC_INSTANCE_NUMBER=""
GC_INSTANCE_ADDRESS=""
GC_FIREWALL_TAGS=""

function build_instance_name() {
  # shellcheck disable=SC2155
  local paddedNumber="$(printf %04d "${GC_INSTANCE_NUMBER}")"
  GC_INSTANCE_NAME="savup-${SHORT_TARGET_ENVIRONMENT}-${paddedNumber}"
}

function build_remote_instance_login() {
  GC_REMOTE_INSTANCE_LOGIN=${GC_SERVER_USER}@${GC_INSTANCE_NAME}
}

function copying_file_gcloud_instance() {
  print_failure_note "copy or setting permission"
  sh ${SAVUP_ROOT_DIRECTORY}/devops/scripts/gcloud_copy_savup_files.sh "$1" "$2" "$3" "$4" "$5" "$6"
  echo
}

function creating_gcloud_directories() {
  print_failure_note "directory"
  sh ${SAVUP_ROOT_DIRECTORY}/devops/scripts/gcloud-cli-create-directories.sh "$1" "$2" "$3"
  echo
}

function creating_gcloud_firewall_rules() {
  print_failure_note "firewall rule"
  sh ${SAVUP_ROOT_DIRECTORY}/devops/scripts/gcloud-cli-create-firewall-rules.sh
  echo
}

function creating_gcloud_instance() {
  print_failure_note "instance"
  sh ${SAVUP_ROOT_DIRECTORY}/devops/scripts/gcloud-cli-create-instance.sh "$1" "$2" "$3" "$4" "$5"
  echo -e "${ON_YELLOW}The script is going to pause for 1 minute to allow time for the instance to spin up.${COLOR_OFF}"
  sleep 60
}

function display_alert() {
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

function display_savup() {
  echo "======================================"
  echo "   SSSS    AA    V    V  U   U  PPPP  "
  echo "  S       A  A   V    V  U   U  P   P "
  echo "   SSS    AAAA    V  V   U   U  PPPP  "
  echo "      S  A    A   V  V   U   U  P     "
  echo "  SSSS   A    A    VV     UUU   P     "
  echo "======================================"
  echo
}

function display_step_spacer() {
  echo -e "${ON_GREEN}--------------------------${COLOR_OFF}"
  echo
}

function executing_gcloud_base_configuration() {
  echo "Starting base configuration of the instance."
  gcloud compute ssh --zone "${GC_REGION}" "${GC_REMOTE_INSTANCE_LOGIN}" --command "sh ${TARGET_DIRECTORY}/scripts/0-config-instance.sh"
  echo "Base configuration has been applied to the GCloud instance"
  # Test if messages are getting to the SavUp Server
  display_step_spacer
  if [ "${TARGET_ENVIRONMENT}" == "development" ]; then
    nats request "SAVUPDEV.command.shutdown" ""
  else
    nats request "SAVUP.command.shutdown" ""
  fi
  display_step_spacer
}

function init_script() {
  . /Users/syacko/workspace/styh-dev/src/albert/shared/devops/scripts/echo-colors.sh
}

function print_error() {
  echo -e "${ON_RED}$1${COLOR_OFF}"
}

function print_failure_note() {
  echo "NOTE: If running any of the $1 commands fail, this script will continue to execute. You will have investigate if the error is critical."
}

function print_parameters() {
  echo "Here are the values you have supplied:"
  echo -e "Target Environment:\t${TARGET_ENVIRONMENT}"
  echo -e "GC_PROJECT_NAME=\t${GC_PROJECT_NAME}"
  echo -e "\t\t\tis set based on the -d or -p argument"
  echo -e "GC_SERVICE_ACCOUNT=\t${GC_SERVICE_ACCOUNT}"
  echo -e "\t\t\tis set based on the -d or -p argument"
  echo -e "GC_INSTANCE_NUMBER=\t${GC_INSTANCE_NUMBER}"
  echo -e "GC_INSTANCE_ADDRESS=\t${GC_INSTANCE_ADDRESS}"
  echo -e "GC_FIREWALL_TAGS=\t${GC_FIREWALL_TAGS}"
  echo
  echo "Here are the pre-set or defined variables:"
  echo -e "ROOT_DIRECTORY= \t${ROOT_DIRECTORY}"
  echo -e "SAVUP_DIRECTORY=\t${SAVUP_DIRECTORY}"
  echo -e "TARGET_DIRECTORY=\t${TARGET_DIRECTORY}"
  echo -e "GC_SERVER_USER= \t${GC_SERVER_USER}"
  echo -e "GC_REGION=      \t${GC_REGION}"
  echo -e "GC_INSTANCE_NAME=\t${GC_INSTANCE_NAME}"
  echo -e "GC_REMOTE_INSTANCE_LOGIN=\t${GC_REMOTE_INSTANCE_LOGIN}"
  echo
}

function print_usage() {
  echo
  echo "This will create an instance  on GCloud."
  echo
  echo "Usage: ${FILENAME} -h | -d | -p -a {IP address} -n {instance name} -f {firewall tag,...}"
  echo
  echo "flags:"
  echo -e "  -h\t\t\t display help"
  echo -e "  -d\t\t\t Install a gcloud development instance. (-d | -p Must be first flag provided."
  echo -e "  -p\t\t\t Install a gcloud production instance. (-d | -p Must be first flag provided."
  echo -e "  -a {IPV4 address}\t The IPV4 address for the instance."
  echo -e "  -n {number}\t\t The unique number that identifies the instance."
  echo -e "  -f {tag,...}\t\t Which firewall tags that should be applied to this instance."
  echo
}

function restarting_gcloud_instance() {
  # Restarting the GCloud Instance
  gcloud compute ssh --zone "${GC_REGION}" "${GC_REMOTE_INSTANCE_LOGIN}" --command "sudo shutdown -r now"
  echo -e "${ON_YELLOW}The script is going to pause for 1 minute to allow time for the instance to spin up after the reboot.${COLOR_OFF}"
  sleep 60
}

function set_variable() {
  if [ "$1" == "TARGET_ENVIRONMENT" ]; then
    if [ -n "$TARGET_ENVIRONMENT" ]; then
      print_error "ERROR: You can only use -d or -p, not both."
      print_usage
      exit 1
    fi
  fi
  cmd="${1}=$2"
  eval "$cmd"
  cmd="${1}_CHECKED=\"true\""
  eval "$cmd"
}

function validate_parameters() {
  if [ -z "$GC_INSTANCE_ADDRESS_CHECKED" ]; then
    local Failed="true"
    print_error "ERROR: The address parameter is missing"
  fi
  if [ -z "$GC_INSTANCE_NUMBER_CHECKED" ]; then
    local Failed="true"
    print_error "ERROR: The number parameter is missing"
  fi
  if [ -z "$GC_FIREWALL_TAGS_CHECKED" ]; then
    local Failed="true"
    print_error "ERROR: The firewall tags parameter is missing"
  fi

  if [ "$Failed" == "true" ]; then
    print_usage
    exit 1
  fi
}

# Main function of this script
function run_script {
  if [ "$#" == "0" ]; then
    print_error "ERROR: No parameters where provided."
    print_usage
    exit 1
  fi
  if [ ! "$1" == "-p" ] && [ ! "$1" == "-d" ] && [ ! "$1" == "-h" ]; then
    print_error "ERROR: The first parameter must be -d, -h, or -p."
    print_usage
    exit 1
  fi

  display_savup

  while getopts 'd|pa:f:n:h' OPT; do # -h -d | -p, -a {argument}, -f {argument}, -n {argument}
    case "$OPT" in
    a)
      set_variable GC_INSTANCE_ADDRESS "$OPTARG"
      ;;
    d)
      set_variable TARGET_ENVIRONMENT "development"
      SHORT_TARGET_ENVIRONMENT="dev"
      GC_PROJECT_NAME=savup-development
      GC_SERVICE_ACCOUNT=914442230861
      ;;
    f)
      set_variable GC_FIREWALL_TAGS "$OPTARG"
      ;;
    h)
      print_usage
      exit 0
      ;;
    n)
      set_variable GC_INSTANCE_NUMBER "$OPTARG"
      ;;
    p)
      set_variable TARGET_ENVIRONMENT "production"
      SHORT_TARGET_ENVIRONMENT="prod"
      GC_PROJECT_NAME=savup-f3343
      GC_SERVICE_ACCOUNT=212575879830
      ;;
    *)
      print_error "ERROR: The parameters are -h, -d | -p, -a {argument}, -f {argument}, -n {argument}" >&2
      print_usage
      exit 1
      ;;
    esac
  done

  validate_parameters
  build_instance_name
  build_remote_instance_login
  print_parameters

  if [ ! -d "$ROOT_DIRECTORY" ]; then
    print_error "ERROR: Directory $ROOT_DIRECTORY DOES NOT exists. Edit the 'Directory and files' section at the top of the script to match your system."
    exit 9
  fi

  # The gcloud config set $GC_PROJECT_NAME is required to make sure the resources are built in the correct project.
  gcloud config set project $GC_PROJECT_NAME
  creating_gcloud_firewall_rules
  creating_gcloud_instance "$GC_INSTANCE_NAME" "$GC_REGION" "$GC_INSTANCE_ADDRESS" "$GC_SERVICE_ACCOUNT" "$GC_FIREWALL_TAGS"
  creating_gcloud_directories "$GC_REGION" "$GC_REMOTE_INSTANCE_LOGIN" "$TARGET_DIRECTORY"
  copying_file_gcloud_instance "$GC_REGION" "$GC_REMOTE_INSTANCE_LOGIN" "$ROOT_DIRECTORY" "$SAVUP_ROOT_DIRECTORY" "$TARGET_ENVIRONMENT" "$TARGET_DIRECTORY"
  executing_gcloud_base_configuration
  restarting_gcloud_instance

  echo
  echo "Done"
  echo
}

init_script
run_script "$@"

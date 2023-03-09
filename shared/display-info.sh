#!/bin/bash
#
# This is reusable code for displaying a warning message
#

# shellcheck disable=SC2129
function displayInfo() {
  echo -e "${BLACK}${ON_GREEN}INFO: $1${COLOR_OFF}"
}


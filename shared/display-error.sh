#!/bin/bash
#
# This is reusable code for displaying a warning message
#

# shellcheck disable=SC2129
function displayError() {
  echo -e "${ON_RED}ERROR: $1${COLOR_OFF}"
}


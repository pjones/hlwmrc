#!/usr/bin/env bash

################################################################################
# Display a Rofi menu with all sorts of stuff in it.
set -eu
set -o pipefail

################################################################################
desktop=$(realpath "$(dirname "$0")/hlwm-desktop-menu.sh")

################################################################################
herbstclient \
  sprintf TAG "%s>" tags.focus.name \
  spawn rofi \
  -display-combi TAG \
  -drun-match-fields name \
  -drun-show-actions \
  -show combi \
  -modi combi,Desktop:"$desktop",window,windowcd,drun \
  -combi-modi Desktop:"$desktop",window,drun

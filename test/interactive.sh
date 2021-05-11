#!/usr/bin/env bash

################################################################################
set -eux
set -o pipefail

################################################################################
export xephyr_display=:5

################################################################################
Xephyr \
  -screen 1280x768 \
  +xinerama +extension RANDR \
  -ac \
  +iglx \
  -verbosity 10 \
  -softCursor \
  "$xephyr_display" &

sleep 2 # let Xephyr catch up

################################################################################
export DISPLAY="$xephyr_display"

picom --config /dev/null -f --inactive-dim=0.4 &

exec herbstluftwm \
  --verbose \
  --locked \
  --autostart "$(dirname "$0")/autostart"

#!/usr/bin/env bash

################################################################################
# Display/hind one of my scratch pads.
#
# Based on:
# https://github.com/herbstluftwm/herbstluftwm/blob/master/scripts/scratchpad.sh
set -eu
set -o pipefail

################################################################################
top=$(realpath "$(dirname "$0")")

################################################################################
function hc() {
  herbstclient "$@"
}

################################################################################
function create_monitor() {
  local monitor=$1
  local tag=$2

  local style
  style=$(get_style_for_tag "$tag")

  local current_rect
  IFS=" " read -r -a current_rect < <(hc monitor_rect)

  local x=${current_rect[0]}
  local y=${current_rect[1]}
  local width=${current_rect[2]}
  local height=${current_rect[3]}

  local rect

  if [ "$style" = right ]; then
    rect=(
      $((width * 40 / 100))
      $((height - 100))
      $((x + width - (width * 40 / 100)))
      $((y + 50))
    )
  else
    rect=(
      $((width * 80 / 100))
      $((height * 80 / 100))
      $((x + (width / 8)))
      $((y + (height / 8)))
    )
  fi

  hc add "$tag"

  hc silent \
    add_monitor \
    "$(printf "%dx%d%+d%+d" "${rect[@]}")" \
    "$tag" \
    "$monitor"
}

################################################################################
# A style dictates how the maybe_create_monitor function displays the monitor.
function get_style_for_tag() {
  local tag=$1

  case $tag in
  notes)
    echo "right"
    ;;
  *)
    echo "center"
    ;;
  esac
}

################################################################################
function show() {
  local monitor=$1
  local tag=$2

  create_monitor "$monitor" "$tag"

  hc \
    substitute MIDX monitors.focus.index \
    substitute WID clients.focus.winid \
    chain \
    , new_attr uint monitors.by-name."$monitor".my_prev_monitor MIDX \
    , new_attr string monitors.by-name."$monitor".my_prev_window WID \
    , lock \
    , raise_monitor "$monitor" \
    , focus_monitor "$monitor" \
    , unlock \
    , lock_tag "$monitor"

  if [ "$(hc attr tags.focus.client_count)" -eq 0 ]; then
    "$top/hlwm-launch.sh"
  fi
}

################################################################################
function hide() {
  local monitor=$1

  hc \
    substitute MIDX monitors.by-name."$monitor".my_prev_monitor \
    substitute WID monitors.by-name."$monitor".my_prev_window \
    and \
    , compare monitors.focus.name = "$monitor" \
    , chain \
    - lock \
    - focus_monitor MIDX \
    - jumpto WID \
    - remove_monitor "$monitor" \
    - unlock
}

################################################################################
function main() {
  local monitor=scratchpad
  local tag=${1:-$monitor}

  if hc silent attr "monitors.by-name.$monitor"; then
    if [ "$(hc attr "monitors.by-name.$monitor.tag")" = "$tag" ]; then
      if [ "$(hc attr monitors.focus.name)" = "$monitor" ]; then
        # Monitor is focused and has the correct tag:
        hide "$monitor"
      else
        # Monitor is not focused but has the correct tag:
        hc chain \
          , raise_monitor "$monitor" \
          , focus_monitor "$monitor"
      fi
    else
      # Monitor has the wrong tag:
      hide "$monitor"
      show "$monitor" "$tag"
    fi
  else
    # Monitor doesn't exist:
    show "$monitor" "$tag"
  fi
}

################################################################################
main "$@"

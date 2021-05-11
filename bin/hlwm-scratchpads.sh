#!/usr/bin/env bash

################################################################################
# Display/hind one of my scratch pads.
#
# Based on:
# https://github.com/herbstluftwm/herbstluftwm/blob/master/scripts/scratchpad.sh
set -eu
set -o pipefail

################################################################################
function hc() {
  herbstclient "$@"
}

################################################################################
function maybe_create_monitor() {
  local monitor=$1
  local tag=$2
  local style=$3

  local current_rect
  IFS=" " read -r -a current_rect < <(hc monitor_rect)

  local x=${current_rect[0]}
  local y=${current_rect[1]}
  local width=${current_rect[2]}
  local height=${current_rect[3]}

  local rect

  if [ "$style" = right ]; then
    rect=(
      $((width / 3))
      $((height - 100))
      $((x + width - (width / 3)))
      $((y + 50))
    )
  else
    rect=(
      $((width / 2))
      $((height / 2))
      $((x + (width / 4)))
      $((y + (height / 4)))
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
function on_show_empty_tag() {
  local tag=$1

  case $tag in
  notes)
    e -cs notes
    ;;
  browser-sidebar)
    browser-sidebar
    ;;
  esac
}

################################################################################
function show() {
  local monitor=$1
  local tag=$2

  hc chain \
    , new_attr string monitors.by-name."$monitor".my_prev_focus \
    , substitute M monitors.focus.index \
    set_attr monitors.by-name."$monitor".my_prev_focus M

  hc lock
  hc raise_monitor "$monitor"
  hc focus_monitor "$monitor"
  hc unlock
  hc lock_tag "$monitor"

  if [ "$(hc attr tags.focus.client_count)" -eq 0 ]; then
    on_show_empty_tag "$tag"
  fi
}

################################################################################
function hide() {
  local monitor=$1

  hc substitute M monitors.by-name."$monitor".my_prev_focus \
    and + compare monitors.focus.name = "$monitor" \
    + focus_monitor M

  hc remove_monitor "$monitor"
}

################################################################################
function main() {
  local monitor=scratchpad
  local tag=${1:-$monitor}

  local style
  style=$(get_style_for_tag "$tag")

  if maybe_create_monitor "$monitor" "$tag" "$style"; then
    show "$monitor" "$tag"
  else
    hide "$monitor"
  fi
}

################################################################################
main "$@"

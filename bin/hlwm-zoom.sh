#!/usr/bin/env bash

################################################################################
# Zoom in/out on the focused window.
set -eu
set -o pipefail

################################################################################
function hc() {
  herbstclient "$@"
}

################################################################################
function zoom() {
  local layout
  layout=$(hc dump)

  local current_rect
  IFS=" " read -r -a current_rect < <(hc monitor_rect)

  local x=${current_rect[0]}
  local y=${current_rect[1]}
  local width=${current_rect[2]}
  local height=${current_rect[3]}

  local rect=(
    $((width * 80 / 100))
    $((height * 80 / 100))
    $((x + (width / 8)))
    $((y + (height / 8)))
  )

  hc \
    substitute RECT clients.focus.floating_geometry \
    chain \
    , silent new_attr string clients.focus.my_before_zoom_floating_geometry RECT \
    , silent new_attr string clients.focus.my_before_zoom_layout "$layout" \
    , attr clients.focus.floating_geometry "$(printf "%dx%d%+d%+d" "${rect[@]}")" \
    , attr clients.focus.floating on
}

################################################################################
function restore() {
  hc \
    substitute RECT clients.focus.my_before_zoom_floating_geometry \
    substitute LAYOUT clients.focus.my_before_zoom_layout \
    substitute WIN clients.focus.winid \
    chain \
    , lock \
    , load LAYOUT \
    , attr clients.focus.floating off \
    , attr clients.focus.floating_geometry RECT \
    , jumpto WIN \
    , remove_attr clients.focus.my_before_zoom_floating_geometry \
    , remove_attr clients.focus.my_before_zoom_layout \
    , unlock
}

################################################################################
function main() {
  if [ "$(hc attr monitors.focus.name)" = "scratchpad" ]; then
    # Don't perform any sort of zooming in the scratchpad monitor.
    # Instead, destroy the monitor and switch to the correct tag.
    tag=$(hc attr monitors.focus.tag)
    "$(dirname "$0")/hlwm-scratchpads.sh" "$tag"
    hc use "$tag"
    exit
  fi

  if hc and \
    , compare clients.focus.floating = on \
    , attr clients.focus.my_before_zoom_floating_geometry; then
    restore
  else
    zoom
  fi
}

################################################################################
main "$@"

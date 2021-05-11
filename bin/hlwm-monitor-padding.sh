#!/usr/bin/env bash

################################################################################
# Toggle useless monitor padding.
set -eu
set -o pipefail

################################################################################
function hc() {
  herbstclient "$@"
}

################################################################################
function main() {
  local current_rect
  IFS=" " read -r -a current_rect < <(hc monitor_rect)

  local width=${current_rect[2]}
  local pad=$((width / 5))

  hc chain \
    , cycle_value monitors.focus.pad_left 10 "$pad" \
    , cycle_value monitors.focus.pad_right 10 "$pad"
}

################################################################################
main "$@"

#!/usr/bin/env bash

################################################################################
# Create frames in a column layout
set -eu
set -o pipefail

################################################################################
top=$(realpath "$(dirname "$0")")

################################################################################
function main() {
  local count=${1:-3}

  herbstclient lock
  "$top/hlwm-layout-reset.sh"

  case $count in
  1)
    : # Already have 1 frame ;)
    ;;

  2)
    herbstclient split right 0.5
    ;;

  3)
    herbstclient \
      chain \
      , split left 0.3 \
      , split right 0.5
    ;;
  esac

  herbstclient unlock
}

################################################################################
main "$@"

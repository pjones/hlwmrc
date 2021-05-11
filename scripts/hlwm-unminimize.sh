#!/usr/bin/env bash

################################################################################
# Minimize or restore windows.
#
# Based on https://github.com/herbstluftwm/herbstluftwm/blob/master/scripts/unminimize.sh
set -eu
set -o pipefail

################################################################################
function hc() {
  herbstclient "$@"
}

################################################################################
function minimize() {
  hc and \
    , substitute C my_minimized_counter new_attr uint clients.focus.my_minimized_age C \
    , set_attr my_minimized_counter $(($(hc get_attr my_minimized_counter) + 1)) \
    , set_attr clients.focus.minimized true
}

################################################################################
function restore() {
  hc \
    mktemp string LASTCLIENTATT \
    mktemp uint LASTAGEATT chain \
    . set_attr LASTAGEATT 0 \
    . foreach CLIENT clients. and \
    , sprintf MINATT "%c.minimized" CLIENT \
    compare MINATT "=" "true" \
    , sprintf TAGATT "%c.tag" CLIENT substitute FOCUS "tags.focus.name" \
    compare TAGATT "=" FOCUS \
    , sprintf AGEATT "%c.my_minimized_age" CLIENT or \
    case: and \
    : ! get_attr AGEATT \
    : compare LASTAGEATT "=" 0 \
    case: and \
    : substitute LASTAGE LASTAGEATT \
    compare AGEATT 'gt' LASTAGE \
    : substitute AGE AGEATT \
    set_attr LASTAGEATT AGE \
    , set_attr LASTCLIENTATT CLIENT \
    . and \
    , compare LASTCLIENTATT "!=" "" \
    , substitute CLIENT LASTCLIENTATT chain \
    : sprintf MINATT "%c.minimized" CLIENT \
    set_attr MINATT false \
    : sprintf AGEATT "%c.my_minimized_age" CLIENT \
    try remove_attr AGEATT
}

################################################################################
function main() {
  hc or \
    , silent attr_type my_minimized_counter \
    , new_attr uint my_minimized_counter 1

  if [ "$1" = minimize ]; then
    minimize
  else
    restore
  fi
}

################################################################################
main "$@"

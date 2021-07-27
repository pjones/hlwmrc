#!/usr/bin/env bash

################################################################################
# A script which called by rofi to:
#
#   1. Produce a list of desktops, or
#   2. Switch to the chosen desktop
set -eu
set -o pipefail

################################################################################
function list_desktops() {
  current_window_title=$(herbstclient attr clients.focus.title)
  echo -en "\0message\x1fMove \"$current_window_title\" with M-RET, delete selected tag with M-Backspace\n"

  herbstclient \
    substitute IDX tags.focus.index \
    foreach TAG tags.by-name. \
    sprintf JDX "%c.index" TAG \
    sprintf NAMEATTR "%c.name" TAG \
    or \
    , compare JDX = IDX \
    , sprintf NAME "%s:%s" JDX NAMEATTR echo NAME |
    awk -F: '{print $1 + 1 ":" $2 "\0icon\x1fpreferences-desktop-workspaces"}' |
    sort -n
}

################################################################################
function goto_desktop() {
  local desktop=$1
  local index_and_name

  mapfile -t index_and_name < <(
    sed -E 's/^([0-9]+):/\1\n/' <<<"$desktop"
  )

  if [ "${#index_and_name[@]}" -gt 1 ]; then
    index=${index_and_name[0]}
    name=${index_and_name[1]}

    if [ "${ROFI_RETV:-1}" -eq 10 ]; then
      herbstclient \
        chain \
        , move_index $((index - 1)) \
        , use_index $((index - 1))
    elif [ "${ROFI_RETV:-1}" -eq 11 ]; then
      herbstclient merge_tag "$name"
    else
      herbstclient use_index $((index - 1))
    fi
  elif ! herbstclient use "$desktop"; then
    herbstclient \
      chain \
      , add "$desktop" \
      , use "$desktop"
  fi
}

################################################################################
function main() {
  if [ $# -eq 0 ]; then
    list_desktops
  else
    goto_desktop "$1"
  fi
}

################################################################################
main "$@"

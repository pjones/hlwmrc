#!/usr/bin/env bash

################################################################################
#
# Automatically disable focus_follows_mouse when a floating window is
# focused and restore it when a non-floating window has the focus.
#
# This especially handy when raise_on_focus_temporarily is enabled.
# I'm quite clumsy with the mouse and often lose floating dialog
# windows when the mouse moves into a tiled window.
#
set -eu
set -o pipefail

################################################################################
# Save a few keystrokes.
function hc() {
  herbstclient "$@"
}

################################################################################
# Turn focus_follows_mouse on.
function enable_ffm() {
  hc set focus_follows_mouse on
}

################################################################################
# Turn focus_follows_mouse off.
function disable_ffm() {
  hc set focus_follows_mouse off
}

################################################################################
# Given a window ID, decide if focus_follows_mouse needs to be turned
# on or off based on its floating state.
function update_state_from_window() {
  local win=$1

  # The winodw ID can be 0x0 if we focus a frame and not a window:
  if [ "$win" = "0x0" ]; then
    return
  fi

  if [ "$(hc attr "clients.$win.floating")" = "true" ]; then
    disable_ffm
  else
    enable_ffm
  fi
}

################################################################################
# Return the ID of the currently focused window.
function current_window_id() {
  hc attr clients.focus.winid 2>/dev/null ||
    echo "0x0"
}

################################################################################
function main() {
  local line
  local args

  # Update the state based on the currently focused window:
  update_state_from_window "$(current_window_id)"

  # Request hooks when the focused window changes floating state:
  hc watch clients.focus.floating

  # Respond to hooks:
  hc --idle '(attribute_changed|focus_changed|reload)' |
    while read -r line; do
      IFS=$'\t' read -ra args <<<"$line"

      case ${args[0]} in
      focus_changed)
        update_state_from_window "${args[1]}"
        ;;

      attribute_changed)
        if [ "${args[1]}" = "clients.focus.floating" ]; then
          update_state_from_window "$(current_window_id)"
        fi
        ;;

      reload)
        exit
        ;;
      esac
    done
}

################################################################################
trap enable_ffm EXIT
main "$@"

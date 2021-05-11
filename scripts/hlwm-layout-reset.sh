#!/usr/bin/env bash

################################################################################
# Remove all frames sans the root frame
set -eu
set -o pipefail

################################################################################
herbstclient lock

while [ "$(herbstclient attr tags.focus.frame_count)" -gt 1 ]; do
  herbstclient remove
done

herbstclient unlock

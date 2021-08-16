#!/usr/bin/env bash

################################################################################
# Launch a set of applications that go with the current tag.
set -eu
set -o pipefail

################################################################################
case $(herbstclient attr tags.focus.name) in
notes)
  e -cs notes
  ;;

browser-sidebar)
  browser-sidebar
  ;;

browsers)
  browser &
  sleep 0.5
  browser --new-window "https://calendar.google.com/calendar/"
  ;;

chat)
  signal-desktop &
  telegram-desktop &
  mattermost-desktop &
  browser-app "https://messages.google.com/web/conversations"
  ;;

mail)
  e -cs mail
  browser-app "https://outlook.office365.com/mail/inbox"
  ;;

music)
  cantata &
  spotify &
  ;;

monitoring)
  browser-app "https://stats.devalot.com/d/fkNz2pRMz/system-health?orgId=1&from=now-1h&to=now&refresh=30s&kiosk&var-node=kilgrave&var-node=medusa"
  browser-app "https://stats.devalot.com/d/fkNz2pRMz/system-health?orgId=1&from=now-1h&to=now&refresh=30s&kiosk&var-node=moriarty&var-node=ursula"
  browser-app "https://stats.devalot.com/d/UJ0W9oRGk/headquarters?openVizPicker&orgId=1&from=now-3h&to=now&refresh=30s&kiosk"
  ;;

*)
  konsole &
  ;;
esac

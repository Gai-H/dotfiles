#!/usr/bin/env bash

set -euo pipefail

AEROSPACE_BIN="/opt/homebrew/bin/aerospace"
ALTTAB_BIN="/Applications/AltTab.app/Contents/MacOS/AltTab"

notify_error() {
  local message="$1"
  osascript -e "display notification \"${message}\" with title \"Aerospace Tweak\" sound name \"Funk\""
}

need_cmd() {
  if [[ ! -x "$1" ]]; then
    notify_error "Command not found or not executable: $1"
    exit 127
  fi
}

need_cmd "$AEROSPACE_BIN"
need_cmd "$ALTTAB_BIN"
command -v jq >/dev/null 2>&1 || {
  notify_error "Command 'jq' not found."
  exit 127
}

focused_window_id="$(
  "$AEROSPACE_BIN" list-windows --focused --json \
    | jq -r '.[0]."window-id"' 2>/dev/null || true
)"

if [[ -z "${focused_window_id}" || "${focused_window_id}" == "null" ]]; then
  notify_error "Failed to get the focused window ID."
  exit 1
fi

target_window_id="$(
  "$ALTTAB_BIN" --detailed-list 2>/dev/null \
    | jq -r '.windows[] | select(.lastFocusOrder==1) | .id' \
    | head -n 1
)"

if [[ -z "${target_window_id}" || "${target_window_id}" == "null" ]]; then
  notify_error "Failed to find a window with lastFocusOrder == 1."
  exit 1
fi

if ! "$AEROSPACE_BIN" macos-native-minimize; then
  notify_error "Failed to minimize the current window."
  exit 1
fi

if ! "$AEROSPACE_BIN" focus --window-id "${target_window_id}"; then
  notify_error "Failed to focus window ID ${target_window_id}."
  exit 1
fi


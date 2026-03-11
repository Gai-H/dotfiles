#!/usr/bin/env bash
# Description:
# 1) Get the currently focused window ID via Aerospace
# 2) Get the window ID with lastFocusOrder == 1 from AltTab
# 3) Minimize the currently focused window
# 4) Focus the target window
# 5) Show macOS notifications only for errors (title: "Aerospace Tweak")

set -euo pipefail

# ---- Configuration ----
AEROSPACE_BIN="/opt/homebrew/bin/aerospace"
ALTTAB_BIN="/Applications/AltTab.app/Contents/MacOS/AltTab"

# ---- Helper: show macOS notification for errors ----
notify_error() {
  local message="$1"
  osascript -e "display notification \"${message}\" with title \"Aerospace Tweak\" sound name \"Funk\""
}

# ---- Dependency check ----
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

# ---- 1. Get focused window ID ----
focused_window_id="$(
  "$AEROSPACE_BIN" list-windows --focused --json \
    | jq -r '.[0]."window-id"' 2>/dev/null || true
)"

if [[ -z "${focused_window_id}" || "${focused_window_id}" == "null" ]]; then
  notify_error "Failed to get the focused window ID."
  exit 1
fi

# ---- 2. Get AltTab window list and extract the one with lastFocusOrder == 1 ----
target_window_id="$(
  "$ALTTAB_BIN" --detailed-list 2>/dev/null \
    | jq -r '.windows[] | select(.lastFocusOrder==1) | .id' \
    | head -n 1
)"

if [[ -z "${target_window_id}" || "${target_window_id}" == "null" ]]; then
  notify_error "Failed to find a window with lastFocusOrder == 1."
  exit 1
fi

# ---- 3. Minimize current focused window ----
if ! "$AEROSPACE_BIN" macos-native-minimize; then
  notify_error "Failed to minimize the current window."
  exit 1
fi

# ---- 4. Focus the target window ----
if ! "$AEROSPACE_BIN" focus --window-id "${target_window_id}"; then
  notify_error "Failed to focus window ID ${target_window_id}."
  exit 1
fi

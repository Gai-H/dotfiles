#!/usr/bin/env bash
set -euo pipefail

notify() {
  # Show a macOS notification with the given message
  local message="$1"
  /usr/bin/osascript -e "display notification \"${message}\" with title \"Kitty Tweak\""
}

# ---- Validate argument ----
case "${1:-}" in
  new_tab|close_tab|next_tab|previous_tab) action="$1" ;;
  *)
    notify "Usage: karabiner-kitty-bridge.sh {new_tab|close_tab|next_tab|previous_tab}"
    exit 2
    ;;
esac

# ---- Get frontmost (focused) app info ----
if ! front_token="$(/usr/bin/lsappinfo front 2>/dev/null)"; then
  notify "Failed to get frontmost app token (lsappinfo front)."
  exit 1
fi

if ! info=$(/usr/bin/lsappinfo info "$front_token" 2>/dev/null); then
  notify "Failed to get frontmost app info (lsappinfo info)."
  exit 1
fi

# ---- Extract bundle ID (supports both output formats) ----
bundle_id="$(
  printf '%s\n' "$info" \
  | /usr/bin/sed -nE \
      -e 's/.*CFBundleIdentifier"[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/p' \
      -e 's/.*bundleID="([^"]+)".*/\1/p' \
  | /usr/bin/head -n1
)"

# ---- Extract PID (supports both output formats) ----
pid="$(
  printf '%s\n' "$info" \
  | /usr/bin/sed -nE \
      -e 's/.*"pid"[[:space:]]*=[[:space:]]*([0-9]+).*/\1/p' \
      -e 's/.*(^|[^A-Za-z])pid[[:space:]]*=[[:space:]]*([0-9]+).*/\2/p' \
  | /usr/bin/head -n1
)"

if [[ -z "${bundle_id:-}" || -z "${pid:-}" ]]; then
  notify "Failed to parse frontmost app info (bundle_id or PID missing)."
  exit 1
fi

# ---- Verify it's Kitty ----
if [[ "$bundle_id" != "net.kovidgoyal.kitty" ]]; then
  notify "Frontmost app is not Kitty (found: $bundle_id)."
  exit 1
fi

# ---- Check kitten binary ----
if [[ ! -x /opt/homebrew/bin/kitten ]]; then
  notify "kitten binary not found at /opt/homebrew/bin/kitten."
  exit 1
fi

# ---- Execute kitten remote control ----
sock="unix:/tmp/kitty-$pid"
if ! /opt/homebrew/bin/kitten @ --to "$sock" action "$action" 2>/dev/null; then
  notify "Failed to execute kitten action '$action' (PID=$pid, socket=$sock)."
  exit 1
fi

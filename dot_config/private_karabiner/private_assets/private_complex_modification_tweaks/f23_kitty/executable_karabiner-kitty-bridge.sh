#!/bin/zsh
set -euo pipefail

notify() {
  local message="$1"
  /usr/bin/osascript -e "display notification \"${message}\" with title \"karabiner-kitty-bridge.sh\""
}

IFS=$'\t' read -r frontmost_app_bundle_id frontmost_app_pid <<< "$(
  osascript -e '
tell application "System Events"
  set frontApp to first application process whose frontmost is true
  return (bundle identifier of frontApp) & tab & (unix id of frontApp)
end tell
'
)"

if [[ -z "${frontmost_app_bundle_id:-}" || -z "${frontmost_app_pid:-}" ]]; then
  notify "Failed to get frontmost app info (bundle_id or pid missing)."
  exit 1
fi

if [[ "$frontmost_app_bundle_id" != "net.kovidgoyal.kitty" ]]; then
  notify "Frontmost app is not Kitty (found: $frontmost_app_bundle_id)."
  exit 1
fi

socket="unix:/tmp/kitty-$frontmost_app_pid"
args="$*"

if ! /opt/homebrew/bin/kitten --to "$socket" "$args" 2>/dev/null; then
  notify "Failed to execute kitten (socket=$socket, args=$args)."
  exit 1
fi


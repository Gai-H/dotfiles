#!/bin/zsh
set -euo pipefail

notify() {
  local message="$1"
  /usr/bin/osascript -e "display notification \"${message}\" with title \"karabiner-kitty-bridge.sh\""
}

get_frontmost_app_info() {
  local front_token front_info

  front_token="$(/usr/bin/lsappinfo front 2>/dev/null)" || return 1
  front_info="$(/usr/bin/lsappinfo info "$front_token" 2>/dev/null)" || return 1

  if [[ "$front_info" =~ 'bundleID="([^"]+)"' ]]; then
    frontmost_app_bundle_id="${match[1]}"
  elif [[ "$front_info" =~ 'CFBundleIdentifier"[[:space:]]*=[[:space:]]*"([^"]+)"' ]]; then
    frontmost_app_bundle_id="${match[1]}"
  else
    return 1
  fi

  if [[ "$front_info" =~ '(^|[^[:alnum:]_])pid[[:space:]]*=[[:space:]]*([0-9]+)' ]]; then
    frontmost_app_pid="${match[2]}"
  elif [[ "$front_info" =~ '"pid"[[:space:]]*=[[:space:]]*([0-9]+)' ]]; then
    frontmost_app_pid="${match[1]}"
  else
    return 1
  fi
}

frontmost_app_bundle_id=""
frontmost_app_pid=""

if ! get_frontmost_app_info; then
  notify "Failed to get frontmost app info (lsappinfo)."
  exit 1
fi

if [[ -z "${frontmost_app_bundle_id:-}" || -z "${frontmost_app_pid:-}" ]]; then
  notify "Failed to get frontmost app info (bundle_id or pid missing)."
  exit 1
fi

if [[ "$frontmost_app_bundle_id" != "net.kovidgoyal.kitty" ]]; then
  notify "Frontmost app is not Kitty (found: $frontmost_app_bundle_id)."
  exit 1
fi

socket="unix:/tmp/kitty-$frontmost_app_pid"

if ! /opt/homebrew/bin/kitten @ --to "$socket" "$@" 2>/dev/null; then
  notify "Failed to execute kitten (socket=$socket, args=$*)."
  exit 1
fi

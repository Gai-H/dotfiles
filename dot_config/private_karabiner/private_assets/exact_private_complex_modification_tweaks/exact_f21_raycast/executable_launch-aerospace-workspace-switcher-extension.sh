#!/bin/bash

SELECTED_INDEX=$1
HISTORY_FILE="/tmp/aerospace_workspace_history"

notify_error() {
    local message="$1"
    echo "Error: $message" >&2
    osascript -e "display notification \"$message\" with title \"AeroSpace Switcher\""
    exit 1
}

if [ -z "$SELECTED_INDEX" ]; then
    notify_error "引数 'selected-index' が指定されていません。"
fi

if [ ! -f "$HISTORY_FILE" ]; then
    notify_error "履歴ファイルが見つかりません: $HISTORY_FILE"
fi

ENCODED_CONTEXT=$(/usr/bin/jq -R -s -r --argjson idx "$SELECTED_INDEX" '
  split("\n") | map(select(length > 0)) as $ws_list |
  ($ws_list | length) as $len |
  {
    "workspaces": $ws_list,
    "selected-workspace": (if $len > 0 then $ws_list[$idx % $len] else "" end)
  } | tostring | @uri
' "$HISTORY_FILE")

if [ $? -ne 0 ]; then
    notify_error "JSONデータの生成に失敗しました (jq error)。"
fi

BASE_URL="raycast://extensions/gaishi/aerospace-workspace-switcher/switch-workspace-recent"
FULL_URL="${BASE_URL}?launchContext=${ENCODED_CONTEXT}"

if ! open "$FULL_URL"; then
    notify_error "Raycastの起動に失敗しました。"
fi


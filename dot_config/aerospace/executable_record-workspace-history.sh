#!/bin/bash

AEROSPACE_BIN="/opt/homebrew/bin/aerospace"
HISTORY_FILE="/tmp/aerospace_workspace_history"

send_error_notification() {
    local message="$1"
    osascript -e "display notification \"$message\" with title \"record-workspace-history.sh\""
}

CURRENT_WS="$AEROSPACE_FOCUSED_WORKSPACE"

if [ -z "$CURRENT_WS" ]; then
    CURRENT_WS=$("$AEROSPACE_BIN" list-workspaces --focused)
fi

VALID_WORKSPACES=$("$AEROSPACE_BIN" list-workspaces --all)

if [ -z "$CURRENT_WS" ]; then
    send_error_notification "Could not detect the current workspace."
    exit 1
fi

if [ -z "$VALID_WORKSPACES" ]; then
    send_error_notification "Could not retrieve the list of workspaces."
    exit 1
fi

NEW_HISTORY=$(mktemp)
SEEN_WORKSPACES=$(mktemp)

echo "$CURRENT_WS" >> "$NEW_HISTORY"
echo "$CURRENT_WS" >> "$SEEN_WORKSPACES"

if [ -f "$HISTORY_FILE" ]; then
    while IFS= read -r ws; do
        [ -z "$ws" ] && continue
        
        if grep -qFx "$ws" "$SEEN_WORKSPACES"; then
            continue
        fi

        if echo "$VALID_WORKSPACES" | grep -qFx "$ws"; then
            echo "$ws" >> "$NEW_HISTORY"
            echo "$ws" >> "$SEEN_WORKSPACES"
        fi
    done < "$HISTORY_FILE"
fi

echo "$VALID_WORKSPACES" | while IFS= read -r ws; do
    [ -z "$ws" ] && continue
    
    if ! grep -qFx "$ws" "$SEEN_WORKSPACES"; then
        echo "$ws" >> "$NEW_HISTORY"
    fi
done

if mv "$NEW_HISTORY" "$HISTORY_FILE"; then
    rm "$SEEN_WORKSPACES"
else
    send_error_notification "Failed to update the history file."
    rm "$NEW_HISTORY" "$SEEN_WORKSPACES"
    exit 1
fi


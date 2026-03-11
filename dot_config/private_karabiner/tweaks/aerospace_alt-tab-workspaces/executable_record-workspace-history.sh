#!/bin/bash

# Absolute path to AeroSpace binary
AEROSPACE_BIN="/opt/homebrew/bin/aerospace"
HISTORY_FILE="/tmp/aerospace_workspace_history"

# Function to send error notifications only
send_error_notification() {
    local message="$1"
    # Title updated to the script name
    osascript -e "display notification \"$message\" with title \"record-workspace-history.sh\""
}

# Get current workspace from environment variable
CURRENT_WS="$AEROSPACE_FOCUSED_WORKSPACE"

# Fallback if environment variable is empty
if [ -z "$CURRENT_WS" ]; then
    CURRENT_WS=$("$AEROSPACE_BIN" list-workspaces --focused)
fi

# 1. Get all currently valid workspaces to prevent ghost entries
VALID_WORKSPACES=$("$AEROSPACE_BIN" list-workspaces --all)

# Check for errors: if current workspace or valid list is empty, stop and notify
if [ -z "$CURRENT_WS" ]; then
    send_error_notification "Could not detect the current workspace."
    exit 1
fi

if [ -z "$VALID_WORKSPACES" ]; then
    send_error_notification "Could not retrieve the list of workspaces."
    exit 1
fi

# Create temporary files
NEW_HISTORY=$(mktemp)
SEEN_WORKSPACES=$(mktemp) # To track added workspaces and avoid duplicates

# --- Step 1: Add current workspace to the TOP ---
echo "$CURRENT_WS" >> "$NEW_HISTORY"
echo "$CURRENT_WS" >> "$SEEN_WORKSPACES"

# --- Step 2: Append existing valid workspaces from history ---
if [ -f "$HISTORY_FILE" ]; then
    while IFS= read -r ws; do
        # Skip empty lines
        [ -z "$ws" ] && continue
        
        # Skip if already added (i.e., it is the current workspace)
        if grep -qFx "$ws" "$SEEN_WORKSPACES"; then
            continue
        fi

        # Check if the workspace from history is still valid
        if echo "$VALID_WORKSPACES" | grep -qFx "$ws"; then
            echo "$ws" >> "$NEW_HISTORY"
            echo "$ws" >> "$SEEN_WORKSPACES"
        fi
    done < "$HISTORY_FILE"
fi

# --- Step 3: Append any other valid workspaces not present in history ---
echo "$VALID_WORKSPACES" | while IFS= read -r ws; do
    [ -z "$ws" ] && continue
    
    # Add only if not already processed
    if ! grep -qFx "$ws" "$SEEN_WORKSPACES"; then
        echo "$ws" >> "$NEW_HISTORY"
    fi
done

# 4. Update the history file
if mv "$NEW_HISTORY" "$HISTORY_FILE"; then
    rm "$SEEN_WORKSPACES"
else
    send_error_notification "Failed to update the history file."
    rm "$NEW_HISTORY" "$SEEN_WORKSPACES"
    exit 1
fi

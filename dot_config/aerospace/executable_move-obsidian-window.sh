#!/bin/bash

# Obsidian sets its window title (which contains the vault name) only after the
# window appears, so on-window-detected cannot match on the title directly.
# This script waits for the title of the detected window and then moves it.

AEROSPACE_BIN="/opt/homebrew/bin/aerospace"
WINDOW_ID="${AEROSPACE_WINDOW_ID:?AEROSPACE_WINDOW_ID is not set}"

# Check every 0.1 seconds for up to 2 seconds.
for _ in $(seq 20); do
    title=$("$AEROSPACE_BIN" list-windows --monitor all --app-bundle-id md.obsidian \
        --format '%{window-id}|%{window-title}' | sed -n "s/^${WINDOW_ID}|//p")

    case "$title" in
        *"university - Obsidian"*)
            exec "$AEROSPACE_BIN" move-node-to-workspace --focus-follows-window --window-id "$WINDOW_ID" Obsidian-University
            ;;
        *"life - Obsidian"*)
            exec "$AEROSPACE_BIN" move-node-to-workspace --focus-follows-window --window-id "$WINDOW_ID" Obsidian-Life
            ;;
    esac

    sleep 0.1
done

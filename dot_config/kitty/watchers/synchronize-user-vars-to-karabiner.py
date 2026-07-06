#!/usr/bin/python3

import json
import subprocess
import sys
import threading
from typing import Any, Optional

from kitty.boss import Boss
from kitty.window import Window


KARABINER_VARIABLE_NAME = "kitty_user-variables"
KARABINER_CLI_PATH = "/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"
KARABINER_CLI_TIMEOUT_SECONDS = 1.0
NOTIFICATION_TITLE = "Kitty Karabiner watcher"


def notify_error(message: str) -> None:
    escape_for_applescript = lambda s: s.replace("\\", "\\\\").replace('"', '\\"')
    script = (
        "display notification "
        f"{escape_for_applescript(message)} "
        "with title "
        f"{escape_for_applescript(NOTIFICATION_TITLE)}"
    )
    try:
        subprocess.run(
            ["/usr/bin/osascript", "-e", script],
            check=False,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            timeout=1.0,
        )
    except Exception as e:
        print(e, file=sys.stderr)


def get_window_user_variables_string(window: Window) -> str:
    user_variables = getattr(window, "user_vars", {})
    window_user_variables_string = json.dumps(user_variables, ensure_ascii=False, separators=(",", ":"), sort_keys=True)
    return window_user_variables_string


def get_karabiner_cli_payload_string(value: str) -> str:
    karabiner_cli_payload = {KARABINER_VARIABLE_NAME: value}
    karabiner_cli_payload_string = json.dumps(karabiner_cli_payload, ensure_ascii=False, separators=(",", ":"))
    return karabiner_cli_payload_string


def synchronize_window_user_variables(window: Optional[Window]) -> None:
    karabiner_variable_value = get_window_user_variables_string(window) if window is not None else ""
    karabiner_cli_payload_string = get_karabiner_cli_payload_string(karabiner_variable_value)
    try:
        subprocess.run(
            [KARABINER_CLI_PATH, "--set-variables", karabiner_cli_payload_string],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            timeout=KARABINER_CLI_TIMEOUT_SECONDS,
        )
    except Exception as e:
        message = f"failed to set Karabiner variable: {e}"
        print(message, file=sys.stderr)
        notify_error(message)

def on_focus_change(boss: Boss, window: Window, data: dict[str, Any]) -> None:
    """
    called from both the "From" window and the "To" window
    data.focused (Bool): true if the window is the "To" window
    """
    if data.get("focused"):
        synchronize_window_user_variables(window)


def on_set_user_var(boss: Boss, window: Window, data: dict[str, Any]) -> None:
    """
    called when a "user variable" is set or deleted on a window. Here
    data will contain key and value
    """
    if getattr(window, "is_focused", False):
        synchronize_window_user_variables(window)


def on_quit(boss: Boss, window: Window, data: dict[str, Any]) -> None:
    """
    called when kitty is about to quit. This is called in *global watchers*
    only. It is called twice: once before the quit confirmation dialog is
    shown (data['confirmed'] will be False) and once after the user has
    confirmed quitting (data['confirmed'] will be True). Setting
    data['aborted'] to True will abort the quit in both cases.
    """
    if data.get("confirmed"):
        synchronize_window_user_variables(None)

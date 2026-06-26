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


def focused_window(boss: Boss) -> Optional[Window]:
    return getattr(boss, "active_window", None)


def user_vars_as_json(window: Optional[Window]) -> str:
    user_vars = getattr(window, "user_vars", {}) if window is not None else {}
    return json.dumps(user_vars, ensure_ascii=False, separators=(",", ":"), sort_keys=True)


def applescript_string(value: str) -> str:
    return '"' + value.replace("\\", "\\\\").replace('"', '\\"') + '"'


def notify(message: str) -> None:
    script = (
        "display notification "
        f"{applescript_string(message)} "
        "with title "
        f"{applescript_string(NOTIFICATION_TITLE)}"
    )
    try:
        subprocess.run(
            ["/usr/bin/osascript", "-e", script],
            check=False,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            timeout=1.0,
        )
    except Exception:
        pass


def set_karabiner_variable(value: str) -> None:
    payload = json.dumps({KARABINER_VARIABLE_NAME: value}, ensure_ascii=False, separators=(",", ":"))
    try:
        subprocess.run(
            [KARABINER_CLI_PATH, "--set-variables", payload],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            timeout=KARABINER_CLI_TIMEOUT_SECONDS,
        )
    except Exception as exc:
        message = f"failed to set Karabiner variable: {exc}"
        print(message, file=sys.stderr)
        notify(message)


def set_karabiner_variable_in_worker(value: str) -> None:
    thread = threading.Thread(
        target=set_karabiner_variable,
        args=(value,),
        daemon=True,
    )
    thread.start()


def synchronize_window(window: Optional[Window]) -> None:
    set_karabiner_variable_in_worker(user_vars_as_json(window))


def synchronize_focused_window(boss: Boss) -> None:
    synchronize_window(focused_window(boss))


def on_load(boss: Boss, data: dict[str, Any]) -> None:
    synchronize_focused_window(boss)


def on_focus_change(boss: Boss, window: Window, data: dict[str, Any]) -> None:
    if data.get("focused"):
        synchronize_window(window)


def on_set_user_var(boss: Boss, window: Window, data: dict[str, Any]) -> None:
    if getattr(window, "is_focused", False):
        synchronize_window(window)


def on_close(boss: Boss, window: Window, data: dict[str, Any]) -> None:
    synchronize_focused_window(boss)

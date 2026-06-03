#!/usr/bin/python3

import json
import subprocess
import sys
from typing import Any, Optional

from kitty.boss import Boss
from kitty.window import Window


KARABINER_VARIABLE_NAME = "kitty_user-variables"
KARABINER_CLI_PATH = "/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"


def focused_window(boss: Boss) -> Optional[Window]:
    return getattr(boss, "active_window", None)


def user_vars_as_json(window: Optional[Window]) -> str:
    user_vars = getattr(window, "user_vars", {}) if window is not None else {}
    return json.dumps(user_vars, ensure_ascii=False, separators=(",", ":"), sort_keys=True)


def set_karabiner_variable(value: str) -> None:
    payload = json.dumps({KARABINER_VARIABLE_NAME: value}, ensure_ascii=False, separators=(",", ":"))
    try:
        subprocess.run(
            [KARABINER_CLI_PATH, "--set-variables", payload],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    except Exception as exc:
        print(f"failed to set Karabiner variable: {exc}", file=sys.stderr)


def synchronize_window(window: Optional[Window]) -> None:
    set_karabiner_variable(user_vars_as_json(window))


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

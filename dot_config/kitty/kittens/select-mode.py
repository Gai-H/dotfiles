#!/usr/bin/python3

from typing import List, Optional

from kitty.boss import Boss


VARIABLE_KEY = "mode"
VALIABLE_VALUE_NONE = "none"
VARIABLE_VALUES = (VALIABLE_VALUE_NONE, "tmux")
CANCEL = "__cancel__"


def normalize_answer(answer: str) -> Optional[str]:
    answer = answer.strip()
    if not answer:
        return None
    if answer.isdecimal():
        index = int(answer) - 1
        if 0 <= index < len(VARIABLE_VALUES):
            return VARIABLE_VALUES[index]
        return None
    if answer in VARIABLE_VALUES:
        return answer
    return None


def prompt() -> str:
    print("Select mode")
    print()
    for index, mode in enumerate(VARIABLE_VALUES, start=1):
        print(f"{index}. {mode}")
    print()
    return input("mode> ")


def main(args: List[str]) -> str:
    while True:
        try:
            mode = normalize_answer(prompt())
        except (EOFError, KeyboardInterrupt):
            return CANCEL

        if mode is not None:
            return mode

        print()
        print("Choose one of: " + ", ".join(VARIABLE_VALUES))
        print()


def handle_result(args: List[str], answer: str, target_window_id: int, boss: Boss) -> None:
    if answer == CANCEL:
        return

    window = boss.window_id_map.get(target_window_id)
    if window is None:
        return

    if answer == VALIABLE_VALUE_NONE:
        window.set_user_var(VARIABLE_KEY, None)
        return

    window.set_user_var(VARIABLE_KEY, answer)

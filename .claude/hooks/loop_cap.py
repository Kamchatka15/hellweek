#!/usr/bin/env python3
"""PreToolUse on Bash: cap the debug loop.

Counts identical commands within one session. Same command 3x = warn.
5x = block and escalate to Justin. Stops the 90-minute grind on a stuck thing.
"""
import hashlib
import json
import os
import re
import sys

STATE = os.path.join(os.path.dirname(os.path.abspath(__file__)), ".state")
WARN_AT, BLOCK_AT = 3, 5

# Only commands that look like build/test/run thrash. Editing files is not thrash.
WATCH = re.compile(r"\b(rojo|lune|selene|stylua|wally|npm|node|pnpm|pytest|"
                   r"make|cargo|luau|run_tests?|build_map)\b")


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        return 0
    if data.get("tool_name") != "Bash":
        return 0
    cmd = (data.get("tool_input") or {}).get("command", "")
    if not cmd or not WATCH.search(cmd):
        return 0

    norm = " ".join(cmd.split())
    key = hashlib.sha1(norm.encode()).hexdigest()[:12]
    sid = re.sub(r"[^A-Za-z0-9_-]", "", str(data.get("session_id", "nosession")))[:40]
    os.makedirs(STATE, exist_ok=True)
    fp = os.path.join(STATE, f"loop-{sid}.json")
    try:
        with open(fp) as f:
            counts = json.load(f)
    except Exception:
        counts = {}
    n = counts.get(key, 0) + 1
    counts[key] = n
    try:
        with open(fp, "w") as f:
            json.dump(counts, f)
    except OSError:
        pass

    short = norm if len(norm) <= 90 else norm[:87] + "..."
    if n >= BLOCK_AT:
        sys.stderr.write(
            f"\nDEBUG LOOP CAP — run #{n} of the same command this session:\n"
            f"  {short}\n\n"
            "Five identical attempts means the current theory is wrong, not that the\n"
            "next run will differ. STOP. Write up for Justin: what you were trying to\n"
            "do, the four things you tried, the actual error, and two options with a\n"
            "recommendation. Then wait. (PIPELINE.md: between gates you proceed on\n"
            "defaults — this is not between gates, this is stuck.)\n")
        return 2
    if n == WARN_AT:
        sys.stderr.write(
            f"\nrbx_guard: 3rd identical run of `{short}`. Two attempts left before the\n"
            "loop cap fires. Change the theory, not the retry.\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())

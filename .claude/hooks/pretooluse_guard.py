#!/usr/bin/env python3
"""PreToolUse: scan what Claude is about to write, before it lands on disk.

Reconstructs the resulting file (disk content + the pending edit) so whole-file
rules like R3 still work on a one-line Edit. Exit 2 = block, stderr goes to Claude.
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import rbx_guard  # noqa: E402


def resulting_text(tool, ti):
    path = ti.get("file_path") or ti.get("path") or ""
    if not path:
        return None, None
    if tool == "Write":
        return path, ti.get("content", "")
    try:
        with open(path, "r", errors="replace") as f:
            text = f.read()
    except OSError:
        text = ""
    if tool == "Edit":
        old, new = ti.get("old_string", ""), ti.get("new_string", "")
        if ti.get("replace_all"):
            return path, text.replace(old, new)
        return path, (text.replace(old, new, 1) if old else text + new)
    if tool in ("MultiEdit", "NotebookEdit"):
        for e in ti.get("edits", []):
            old, new = e.get("old_string", ""), e.get("new_string", "")
            if old:
                text = text.replace(old, new, 1)
        return path, text
    return None, None


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        return 0
    tool = data.get("tool_name", "")
    if tool not in ("Write", "Edit", "MultiEdit", "NotebookEdit"):
        return 0
    path, text = resulting_text(tool, data.get("tool_input", {}) or {})
    if path is None or text is None:
        return 0
    blocking, report = rbx_guard.scan(path, text)
    if report:
        sys.stderr.write("rbx_guard — non-negotiables (CLAUDE.md / ROBLOX_SUCCESS_LOGIC.md)\n")
        sys.stderr.write("\n".join(report) + "\n")
        if blocking:
            sys.stderr.write(
                "\nWrite BLOCKED. Fix the code, or add a deliberate exception line:\n"
                "    -- @rbx-allow: <RULE_ID> <reason>\n"
                "(logged to docs/runs/hook-allow.log). Do not silently work around this.\n")
            return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())

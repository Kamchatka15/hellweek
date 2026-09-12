#!/usr/bin/env python3
"""SessionStart: put the standing orders and the current gate state in front of
Claude before it does anything, so a fresh session does not start from zero.

stdout from a SessionStart hook is added to the session context.
"""
import os
import re
import sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
PIPE = os.path.join(REPO, "roblox-pipeline")
STATE = os.path.join(PIPE, "docs", "runs", "STATE.md")


def read(path, limit=None):
    try:
        with open(path, errors="replace") as f:
            t = f.read()
        return t[:limit] if limit else t
    except OSError:
        return ""


def idea_counts():
    t = read(os.path.join(PIPE, "docs", "IDEA_LOG.md"))
    body = t.split("## Entry template", 1)[-1]
    n = len(re.findall(r"^\s*[-*]?\s*\*{0,2}Status\*{0,2}\s*:", body, re.M))
    return n


def main():
    out = []
    out.append("=== STANDING ORDERS (rbx SessionStart hook) ===")
    out.append("1. Read docs/ROBLOX_SUCCESS_LOGIC.md before build/marketing work. "
               "If a task fights that file, that file wins.")
    out.append("2. One active title at a time. A title is killed only at a gate, "
               "on evidence, with a learnings doc.")
    out.append("3. Ideas are NEVER held back: pitch on the spot, log in docs/IDEA_LOG.md, "
               "then continue the task you were on. Pitching is not switching.")
    out.append("4. Deliverables are written into the Roblox Business folder. "
               "A file that exists only in a chat window does not exist.")
    out.append("5. G5 (publish / any paid product) is a human click. Silence is NOT approval.")
    out.append("")
    out.append("=== HOW A SESSION RUNS ===")
    out.append("Runbook: docs/OPERATING_MANUAL.md — six waves, file contracts, Pass 1/Pass 2, "
               "the look bar, the MCP four-beat, and what Justin can say. Read it before build work.")
    out.append("TWO CLOCKS: attended ~4h/day (gates, cut line, playtests, G5 clicks) vs unattended "
               "(everything else). If Justin is not here, work docs/runs/QUEUE.md top-first — reversible "
               "work only, never Studio/publish/spend — and rewrite the next attended move in STATE.md.")
    out.append("")
    out.append("=== HOOKS ARE LIVE — these will refuse a write, not just warn ===")
    out.append("R1 client-authoritative economy | R2 raw remote (use RemoteGuard) | "
               "R3 ProcessReceipt without a PurchaseId ledger | R4 DataStore outside "
               "DataService | R5 gambling-shaped monetization (warn) | R6 third-party IP (warn)")
    out.append("Deliberate exception: `-- @rbx-allow: R4 reason` (logged, visible). "
               "Identical shell command 5x in a session is blocked — escalate to Justin instead.")
    out.append("")

    state = read(STATE)
    if state.strip():
        out.append("=== CURRENT STATE (docs/runs/STATE.md) ===")
        out.append(state.strip()[:1800])
    else:
        out.append("=== CURRENT STATE ===")
        out.append("docs/runs/STATE.md is missing or empty. Before doing anything else, "
                   "reconstruct it from docs/runs/, specs/ and games/, and ask Justin to confirm.")
    out.append("")

    n = idea_counts()
    if n:
        out.append(f"Idea log: {n} entr{'y' if n == 1 else 'ies'}. "
                   "Re-read the top 3 at any Gate B or kill decision.")

    q = read(os.path.join(PIPE, "docs", "runs", "QUEUE.md"))
    if q.strip():
        nxt = ""
        for i, line in enumerate(q.splitlines()):
            if line.startswith("## Next attended move"):
                nxt = " ".join(l.strip() for l in q.splitlines()[i + 1:i + 3] if l.strip())
                break
        open_items = sum(1 for l in q.splitlines() if l.strip().startswith("- [ ]"))
        if nxt:
            out.append(f"NEXT ATTENDED MOVE: {nxt[:300]}")
        out.append(f"Unattended queue: {open_items} open item(s) in docs/runs/QUEUE.md")
        out.append("")

    digest_log = os.path.join(PIPE, "research", "DIGEST_LOG.md")
    dl = [l for l in read(digest_log).splitlines()
          if l.strip() and not l.startswith("#") and not l.startswith(">")]
    if dl:
        out.append(f"Latest market digest: {dl[-1].strip()}  (research/ — read it before any research or design step)")

    allow_log = os.path.join(PIPE, "docs", "runs", "hook-allow.log")
    lines = [l for l in read(allow_log).splitlines() if l.strip()]
    if lines:
        out.append(f"Open hook exceptions: {len(lines)} (docs/runs/hook-allow.log). "
                   "Each one is a non-negotiable someone turned off on purpose — "
                   "confirm it is still justified before a gate.")

    sys.stdout.write("\n".join(out) + "\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())

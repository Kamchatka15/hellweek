#!/usr/bin/env python3
"""
match.py — ask the evidence ledger what it knows about a new situation.

  python3 evidence/match.py --domain retention --loop_verb collect --session_shape snack
  python3 evidence/match.py --brief roblox-pipeline/games/<slug>/brief.md
  python3 evidence/match.py --matrix > evidence/MATRIX.md

Deliberately simple and explainable: it reports WHY each record matched, so a
match can be overruled. A ranking you cannot interrogate is one you cannot argue
with, and this ledger must never become conservatism with a database.
"""
import argparse
import datetime
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LEDGER = os.path.join(ROOT, "evidence", "ledger")

DIMS = ["domain", "loop_verb", "session_shape", "audience", "monetization", "wave", "scale"]
WEIGHT = {"domain": 3, "loop_verb": 2, "session_shape": 2,
          "audience": 1, "monetization": 1, "wave": 1, "scale": 1}
STALE_DAYS = 365


def load():
    out = []
    if not os.path.isdir(LEDGER):
        return out
    for fn in sorted(os.listdir(LEDGER)):
        if not fn.endswith(".md"):
            continue
        text = open(os.path.join(LEDGER, fn), errors="replace").read()
        m = re.match(r"\s*---\s*\n(.*?)\n---\s*\n?(.*)", text, re.S)
        if not m:
            continue
        rec = {"_notes": m.group(2).strip(), "_file": fn}
        for line in m.group(1).splitlines():
            if ":" in line:
                k, v = line.split(":", 1)
                rec[k.strip()] = v.strip()
        out.append(rec)
    return out


def score(rec, query):
    """Return (points, reasons[]). 'any' on a record means unscoped, not a match."""
    pts, reasons = 0, []
    for d in DIMS:
        want = (query.get(d) or "").strip().lower()
        have = (rec.get(d) or "").strip().lower()
        if not want:
            continue
        if have in ("", "any"):
            continue
        if want == have or want in [x.strip() for x in have.split(",")]:
            pts += WEIGHT[d]
            reasons.append(f"{d}={have}")
    return pts, reasons


def confidence_note(rec):
    n = (rec.get("confidence") or "").replace("n=", "").strip()
    try:
        n = int(n)
    except ValueError:
        return "confidence unstated — treat as n=1"
    if n == 0:
        return "n=0 UNTESTED — cannot be cited as a reason for anything"
    if n == 1:
        return "n=1 one observation — NOT a law, must not become a default"
    return f"n={n} reproduced — eligible to become a default"


def stale(rec):
    try:
        d = datetime.date.fromisoformat((rec.get("observed") or "").strip())
    except ValueError:
        return False
    return (datetime.date.today() - d).days > STALE_DAYS


def from_brief(path):
    """Pull context out of a GAME_BRIEF table without requiring a strict format."""
    try:
        t = open(path, errors="replace").read().lower()
    except OSError:
        sys.exit(f"cannot read brief: {path}")
    q = {}
    for verb in ["collect", "mine", "steal", "build", "race", "survive", "fight", "tycoon"]:
        if re.search(rf"loop verb[^\n|]*\|[^\n]*{verb}", t) or f"**{verb}**" in t:
            q["loop_verb"] = verb
            break
    if "snack" in t:
        q["session_shape"] = "snack"
    elif "sit-down" in t or "sit down" in t:
        q["session_shape"] = "sit-down"
    if "full fair-play catalog" in t or "full-catalog" in t:
        q["monetization"] = "full-catalog"
    elif "cosmetics" in t:
        q["monetization"] = "cosmetics"
    # Age band only where it is actually described as an age — otherwise a date
    # like 2026-09-11 gets read as an audience of 26-09.
    m = re.search(r"(?:age|audience|band)[^\n|]{0,40}?\b(\d{1,2})\s*[-\u2013]\s*(\d{1,2})\b", t)
    if m:
        q["audience"] = f"{m.group(1)}-{m.group(2)}"
    return q


def conflicts(recs):
    """Find records that disagree: explicit contradicts: links, plus same-domain
    records with overlapping context and opposing outcomes."""
    by_id = {r.get("id"): r for r in recs}
    pairs, seen = [], set()

    for r in recs:
        for other in re.split(r"[,\s]+", (r.get("contradicts") or "").strip()):
            if other and other in by_id:
                key = tuple(sorted([r.get("id"), other]))
                if key not in seen:
                    seen.add(key)
                    pairs.append((by_id[key[0]], by_id[key[1]], "declared"))

    opposed = {("confirmed", "refuted"), ("refuted", "confirmed")}
    for i, a in enumerate(recs):
        for b in recs[i + 1:]:
            key = tuple(sorted([a.get("id", ""), b.get("id", "")]))
            if key in seen or a.get("domain") != b.get("domain"):
                continue
            if (a.get("outcome"), b.get("outcome")) not in opposed:
                continue
            shared = [d for d in DIMS[1:]
                      if (a.get(d) or "any") != "any"
                      and (a.get(d) or "") == (b.get(d) or "")]
            if len(shared) >= 2:
                seen.add(key)
                pairs.append((a, b, "inferred"))
    return pairs


def report_conflicts(recs):
    pairs = conflicts(recs)
    print("# Open questions — unresolved contradictions\n")
    print("_Generated. Both records in every pair still stand; neither was edited._")
    print("_A contradiction is not resolved when it is found. It is resolved when a "
          "decision depends on it._\n")
    if not pairs:
        print("No contradictions in the ledger.\n")
        print("That is expected this early: contradictions need at least two titles "
              "to have reported on the same thing. An empty queue here is a sign the "
              "ledger is young, not a sign the system is working.")
        return
    for a, b, how in pairs:
        differs = [d for d in DIMS[1:]
                   if (a.get(d) or "any") != "any" and (b.get(d) or "any") != "any"
                   and a.get(d) != b.get(d)]
        print(f"## {a.get('id')} vs {b.get('id')}  ({how})\n")
        print(f"- **{a.get('id')}** {a.get('outcome','').upper()} — {a.get('claim')}")
        print(f"- **{b.get('id')}** {b.get('outcome','').upper()} — {b.get('claim')}")
        if differs:
            print(f"- **Likely missing variable:** {', '.join(differs)}")
        else:
            print("- **Likely missing variable:** none of the tracked dimensions differ. "
                  "That means a dimension we do not yet track is doing the work — "
                  "the most valuable kind of conflict, and a reason to consider a new dimension.")
        print(f"- Sources: {a.get('source','-')} · {b.get('source','-')}")
        print("- **Escalate to Justin only when a pending decision depends on this.** "
              "Otherwise it waits here.\n")


def matrix(recs):
    print("# Evidence matrix — generated, do not edit by hand\n")
    print(f"_{len(recs)} records · regenerate with `python3 evidence/match.py --matrix > evidence/MATRIX.md`_\n")
    print("| ID | Claim | Domain | Outcome | Conf | Scope | Status |")
    print("|---|---|---|---|---|---|---|")
    for r in recs:
        scope = ", ".join(f"{d}:{r.get(d)}" for d in DIMS[1:] if (r.get(d) or "any") != "any") or "unscoped"
        print("| {} | {} | {} | {} | {} | {} | {} |".format(
            r.get("id", "?"), (r.get("claim", "") or "")[:90], r.get("domain", ""),
            r.get("outcome", ""), r.get("confidence", ""), scope, r.get("status", "")))
    open_h = [r for r in recs if (r.get("status") or "") == "open-hypothesis"]
    if open_h:
        print("\n## Open hypotheses — filed to be proven wrong\n")
        for r in open_h:
            print(f"- **{r.get('id')}** — {r.get('claim')}")


def main():
    ap = argparse.ArgumentParser()
    for d in DIMS:
        ap.add_argument(f"--{d}")
    ap.add_argument("--brief")
    ap.add_argument("--matrix", action="store_true")
    ap.add_argument("--conflicts", action="store_true",
                    help="list unresolved contradictions (the open-questions queue)")
    ap.add_argument("--all", action="store_true", help="include zero-scoring records")
    a = ap.parse_args()

    recs = load()
    if not recs:
        sys.exit("ledger is empty — nothing learned yet")
    if a.matrix:
        matrix(recs)
        return
    if a.conflicts:
        report_conflicts(recs)
        return

    q = from_brief(a.brief) if a.brief else {}
    for d in DIMS:
        if getattr(a, d):
            q[d] = getattr(a, d)
    if not q:
        sys.exit("give at least one dimension, or --brief <path>, or --matrix")

    print(f"QUERY  {', '.join(f'{k}={v}' for k, v in q.items())}\n")
    scored = []
    for r in recs:
        pts, why = score(r, q)
        if pts or a.all:
            scored.append((pts, why, r))
    scored.sort(key=lambda x: -x[0])

    if not scored:
        print("No record matches this context.")
        print("That is a real answer: this is new ground, and whatever you try here is")
        print("worth filing as a record afterwards precisely because nothing covers it.")
        return

    for pts, why, r in scored:
        flags = []
        if stale(r):
            flags.append("STALE >12mo — re-verify before relying on it")
        if (r.get("status") or "") != "active":
            flags.append(r.get("status", "").upper())
        if r.get("contradicts"):
            flags.append(f"CONTRADICTS {r['contradicts']} — read both")
        print(f"[{pts:>2}] {r.get('id')}  {r.get('outcome','').upper()}")
        print(f"     {r.get('claim')}")
        print(f"     matched on: {', '.join(why) or 'nothing (listed via --all)'}")
        print(f"     {confidence_note(r)}")
        if r.get("metric"):
            print(f"     settled by: {r['metric']}")
        for f in flags:
            print(f"     ! {f}")
        print(f"     source: {r.get('source','-')}\n")

    ids = {r.get("id") for _, _, r in scored}
    live = [(x, y) for x, y, _ in conflicts(recs) if x.get("id") in ids or y.get("id") in ids]
    if live:
        print("!! UNRESOLVED CONTRADICTIONS touching these records:")
        for x, y in live:
            print(f"   {x.get('id')} vs {y.get('id')} — see evidence/OPEN_QUESTIONS.md")
        print("   Do not pick a side silently. If this decision depends on it, escalate.\n")

    n2 = [r for _, _, r in scored if (r.get("confidence") or "") not in ("n=0", "n=1", "")]
    print(f"{len(scored)} matched · {len(n2)} reproduced (n>=2) · "
          f"{len(scored) - len(n2)} single observations that must not be treated as rules")


if __name__ == "__main__":
    main()

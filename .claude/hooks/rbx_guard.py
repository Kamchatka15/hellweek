#!/usr/bin/env python3
"""
rbx_guard — mechanical enforcement of the non-negotiables in CLAUDE.md.

Governed by docs/ROBLOX_SUCCESS_LOGIC.md. These are the rules that are both
CATASTROPHIC and DETECTABLE IN A DIFF. Nothing here has an opinion about whether
a game is fun; that is what the gates are for.

Usage:
  rbx_guard.py <path> [<path> ...]        scan files on disk
  rbx_guard.py --content <path>           scan stdin as if it were <path>
Exit: 0 clean (warnings allowed), 1 blocked.

Escape hatch: put a line in the file
    -- @rbx-allow: R4 reason goes here
It suppresses that rule for that file and is logged to docs/runs/hook-allow.log.
"""
import os
import re
import sys
import datetime

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
PIPE = os.path.join(REPO, "roblox-pipeline")

BLOCK, WARN = "BLOCK", "WARN"

# ---------------------------------------------------------------- rule helpers

def _is_client(path, text):
    p = path.replace("\\", "/")
    return ("/src/client/" in p or p.endswith(".client.luau")
            or "LocalScript" in text)

def _rel(path):
    try:
        return os.path.relpath(os.path.abspath(path), REPO)
    except ValueError:
        return path

# Lines that are pure comments never trip a rule.
def _code_lines(text):
    for i, line in enumerate(text.splitlines(), 1):
        s = line.strip()
        if s.startswith("--"):
            continue
        yield i, line

_STR = re.compile(r'"[^"\n]*"|\'[^\'\n]*\'|\[\[.*?\]\]', re.S)


def _nostrings(line):
    """Blank out string literals. Used by rules whose target is a MECHANISM;
    rules whose target is player-facing TEXT (R6) deliberately keep strings."""
    return _STR.sub('""', line)


CURRENCY = r"(Coins?|Cash|Gems?|Bucks|Money|Credits?|Balance|Currency|Tokens?)"

RULES = []

def rule(rid, name, severity, fix):
    def deco(fn):
        RULES.append({"id": rid, "name": name, "severity": severity,
                      "fix": fix, "check": fn})
        return fn
    return deco


@rule("R1", "Client-authoritative economy", BLOCK,
      "Currency is decided on the server. Client code may DISPLAY a balance "
      "(StateSync) and may REQUEST a spend through RemoteGuard. It may never set one.")
def r1(path, text):
    if not _is_client(path, text):
        return []
    pats = [
        re.compile(rf"{CURRENCY}[^\n]*\.Value\s*=", re.I),
        re.compile(rf"\b(function\s+\w*|[.:])(Grant|Award|Add|Give|Set|Credit)\w*{CURRENCY}", re.I),
        re.compile(rf"\b(leaderstats)\b[^\n]*=\s*(?!nil)", re.I),
    ]
    hits = []
    for n, line in _code_lines(text):
        bare = _nostrings(line)
        for p in pats:
            if p.search(bare):
                hits.append((n, line.strip()))
                break
    return hits


@rule("R2", "Raw remote handler (bypasses RemoteGuard)", BLOCK,
      "Bind it through RemoteGuard so it gets arg validation + a rate limit. "
      "A raw OnServerEvent is an unvalidated, unthrottled entry point.")
def r2(path, text):
    rel = _rel(path).replace("\\", "/")
    if rel.endswith(("src/core/RemoteGuard.luau", "src/shared/Net.luau")):
        return []
    p = re.compile(r"OnServerEvent\s*:\s*Connect|OnServerInvoke\s*=")
    return [(n, l.strip()) for n, l in _code_lines(text) if p.search(_nostrings(l))]


@rule("R3", "ProcessReceipt without idempotency", BLOCK,
      "Roblox RETRIES receipts. Without a durable PurchaseId ledger you either "
      "double-grant (you eat it) or drop it (a kid paid and got nothing).")
def r3(path, text):
    # Only a real handler binding counts. A design doc that happens to be .luau
    # may name ProcessReceipt without implementing it.
    binding = re.compile(r"ProcessReceipt\s*=|function\s+[\w.:]*ProcessReceipt")
    bound = [(n, l) for n, l in _code_lines(text) if binding.search(_nostrings(l))]
    if not bound:
        return []
    code = "\n".join(_nostrings(l) for _, l in _code_lines(text))
    has_id = "PurchaseId" in code
    has_ledger = re.search(r"ledger|Ledger|alreadyGranted|wasProcessed|receiptStore", code)
    if has_id and has_ledger:
        return []
    missing = []
    if not has_id:
        missing.append("no PurchaseId check")
    if not has_ledger:
        missing.append("no durable receipt ledger")
    n, l = bound[0]
    return [(n, f"{l.strip()}   <-- {', '.join(missing)}")]


@rule("R4", "DataStore access outside DataService", BLOCK,
      "All persistence goes through DataService, which owns the session lock, "
      "schema version and retry/backoff. A second writer is how saves get wiped.")
def r4(path, text):
    rel = _rel(path).replace("\\", "/")
    in_data_service = rel.endswith("src/core/DataService.luau")
    p_any = re.compile(r":(SetAsync|UpdateAsync|GetAsync|IncrementAsync|RemoveAsync)\s*\(")
    p_set = re.compile(r":SetAsync\s*\(")
    hits = []
    for n, line in _code_lines(text):
        bare = _nostrings(line)
        if in_data_service:
            # DataService itself may persist, but SetAsync skips the retry path.
            if p_set.search(bare):
                hits.append((n, line.strip() + "   <-- use UpdateAsync, not SetAsync"))
        elif p_any.search(bare):
            hits.append((n, line.strip()))
    return hits


@rule("R5", "Possible gambling-shaped monetization", WARN,
      "Simulated gambling is banned at EVERY rating and is a takedown risk. "
      "Paid randomness needs exact pre-purchase odds + PolicyService fallbacks. "
      "Prefer direct-buy + earnable. Needs a human decision, not a hook's.")
def r5(path, text):
    chance = re.compile(r"\b(crate|lootbox|loot_box|gacha|spin|wheel|jackpot|"
                        r"mystery|lucky|gamble|roll)\w*\b", re.I)
    paid = re.compile(r"PromptProductPurchase|PromptPurchase|DeveloperProduct|"
                      r"MarketplaceService|GamePass|Robux", re.I)
    if not paid.search(_nostrings(text)):
        return []
    return [(n, l.strip()) for n, l in _code_lines(text)
            if chance.search(_nostrings(l))]


@rule("R6", "Possible third-party IP", WARN,
      "No real brands, meme-coin logos, or other games' mascots/names. "
      "Rename it or confirm it is generic.")
def r6(path, text):
    brands = re.compile(r"\b(Dogecoin|Shiba|Pepe|Minecraft|Fortnite|Pokemon|Pokémon|"
                        r"Mario|Sonic|Nike|Adidas|Gucci|McDonald|Disney|Marvel|"
                        r"Brainrot|Bitcoin|Elon|Tesla)\w*\b", re.I)
    return [(n, l.strip()) for n, l in _code_lines(text) if brands.search(l)]


def _game_slugs():
    d = os.path.join(PIPE, "games")
    try:
        return [x for x in os.listdir(d) if os.path.isdir(os.path.join(d, x))
                and not x.startswith(".")]
    except OSError:
        return []


@rule("R7", "Engine module knows about a specific game", BLOCK,
      "src/core/ is the factory; games/ is the title. The moment an engine module "
      "names one game, the engine stops being reusable and nothing is portable to a "
      "second project. Read it from the content pack instead.")
def r7(path, text):
    rel = _rel(path).replace("\\", "/")
    if "src/core/" not in rel:
        return []
    slugs = _game_slugs()
    pats = [re.compile(r"\bgames/")]
    for slug in slugs:
        pats.append(re.compile(re.escape(slug), re.I))
        pats.append(re.compile(re.escape(slug.replace("-", "")), re.I))
    hits = []
    for n, line in _code_lines(text):
        for pp in pats:
            if pp.search(line):
                hits.append((n, line.strip()))
                break
    return hits


# ---------------------------------------------------------------- scan / report

ALLOW = re.compile(r"--\s*@rbx-allow:\s*(R\d+)\s*(.*)")

def _allowed(text):
    out = {}
    for m in ALLOW.finditer(text):
        out[m.group(1)] = (m.group(2) or "").strip() or "(no reason given)"
    return out

def _log_allow(path, allows):
    if not allows:
        return
    d = os.path.join(PIPE, "docs", "runs")
    try:
        os.makedirs(d, exist_ok=True)
        with open(os.path.join(d, "hook-allow.log"), "a") as f:
            ts = datetime.datetime.now().isoformat(timespec="seconds")
            for rid, why in allows.items():
                f.write(f"{ts}\t{_rel(path)}\t{rid}\t{why}\n")
    except OSError:
        pass

def scan(path, text):
    """Return (blocking, lines[])."""
    if not path.endswith((".luau", ".lua")):
        return False, []
    allows = _allowed(text)
    _log_allow(path, allows)
    report, blocking = [], False
    for r in RULES:
        if r["id"] in allows:
            continue
        hits = r["check"](path, text)
        if not hits:
            continue
        if r["severity"] == BLOCK:
            blocking = True
        report.append(f"\n{r['severity']}  {r['id']} — {r['name']}")
        report.append(f"  file: {_rel(path)}")
        for n, line in hits[:6]:
            report.append(f"  L{n}: {line[:150]}")
        if len(hits) > 6:
            report.append(f"  ... and {len(hits) - 6} more")
        report.append(f"  why: {r['fix']}")
    return blocking, report


def main(argv):
    if len(argv) >= 3 and argv[1] == "--content":
        path = argv[2]
        text = sys.stdin.read()
        blocking, report = scan(path, text)
    else:
        blocking, report = False, []
        for path in argv[1:]:
            try:
                with open(path, "r", errors="replace") as f:
                    text = f.read()
            except OSError:
                continue
            b, r = scan(path, text)
            blocking = blocking or b
            report += r
    if report:
        sys.stderr.write("rbx_guard — non-negotiables (CLAUDE.md)\n")
        sys.stderr.write("\n".join(report) + "\n")
        if blocking:
            sys.stderr.write(
                "\nBLOCKED. Fix it, or if this is a deliberate exception add a line:\n"
                "    -- @rbx-allow: <RULE_ID> <reason>\n"
                "(logged to docs/runs/hook-allow.log so it stays visible)\n")
            return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))

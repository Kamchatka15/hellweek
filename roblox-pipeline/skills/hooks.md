# Skill — the enforcement layer (hooks)

> **Governed by `docs/ROBLOX_SUCCESS_LOGIC.md` (standing orders).** If this file fights that file, that file wins.

**What this is in one line:** the non-negotiables in `CLAUDE.md` stopped being sentences a long session can drift past, and became code that refuses the write.

## Why it exists

A rule written in prose is only as strong as whether the session still has it in working memory three hours in. These six are the rules that are both **catastrophic** and **detectable in a diff** — they fail silently, in production, after a human already approved the build. Nothing here has an opinion about whether a game is fun; that is what the gates are for.

## The six rules

| ID | Rule | Severity | The failure it prevents |
|---|---|---|---|
| R1 | Client-authoritative economy | BLOCK | One player edits their own balance; the economy dies overnight |
| R2 | Raw remote handler | BLOCK | An unvalidated, unrate-limited entry point. Everything binds through `RemoteGuard` |
| R3 | `ProcessReceipt` without a `PurchaseId` ledger | BLOCK | Roblox retries receipts. Double-grant (we eat it) or drop (a kid paid and got nothing) |
| R4 | DataStore access outside `DataService` | BLOCK | A second writer without the session lock. This is how saves get wiped |
| R5 | Gambling-shaped monetization | WARN | Banned at every rating. Takedown risk, not a bug |
| R6 | Third-party IP | WARN | Moderation removes it, and the takedown lands *after* the title is worth something |

R5 and R6 warn rather than block because they need a human decision, not a regex's.

## Where it runs

| Trigger | Covers | File |
|---|---|---|
| Before every Write/Edit in Claude Code | Anything Claude writes | `.claude/hooks/pretooluse_guard.py` |
| Every `git commit` | Anything anyone writes, including other agents and hand edits | `.githooks/pre-commit` |
| Start of every session | Loads standing orders + `docs/runs/STATE.md` | `.claude/hooks/session_start.py` |
| Same shell command 5× in a session | Debug-loop cap — escalate, don't grind | `.claude/hooks/loop_cap.py` |

The scanner itself is `.claude/hooks/rbx_guard.py`. One copy; everything else calls it.

## The escape hatch

Sometimes a rule is genuinely wrong for one file. Add a line to that file:

```lua
-- @rbx-allow: R4 one-off migration, run manually, never in the live loop
```

That suppresses the rule for that file **and writes it to `docs/runs/hook-allow.log`**, which the SessionStart hook counts and reports. An exception is allowed; a silent one is not. Review the log before any gate.

## Adding a rule

Per `docs/SYSTEM_ARCHITECTURE.md` §3: when something goes wrong that no rule caught, it becomes a rule. If it is visible in a diff, it goes here as a hook. If it needs judgment, it goes to a gate instead — do not force a judgment call into a regex.

New rules go in `rbx_guard.py` using the `@rule(...)` decorator, and **must** be tested two ways before landing: fires on a deliberately bad file, and produces zero findings across all existing `src/` and `games/` code.

## Testing

```sh
python3 .claude/hooks/rbx_guard.py $(find roblox-pipeline/src roblox-pipeline/games -name '*.luau')
```

Exit 0 with no output is the expected state of a healthy repo.

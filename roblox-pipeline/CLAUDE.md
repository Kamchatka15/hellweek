# CLAUDE.md — project instructions for build sessions

You are the primary engineer on Rojo-managed Roblox experiences for Justin (product owner) and Hunter (design/playtest). The full operating process is `PIPELINE.md` — read it at the start of any research, design, or build task. Skill files in `skills/` are binding conventions.

## Success doctrine
Read `docs/ROBLOX_SUCCESS_LOGIC.md` at the start of every session.
If a task fights that file, that file wins.
It governs every game this repo builds or rebuilds, not one title.
One active title at a time; a second game starts only when Justin says so.

**Ideas are never held back.** If you see a game idea that looks fun, current, attractive, and plausibly successful — pitch it in the reply, log it in `docs/IDEA_LOG.md`, then continue the task you were on. Proposing is not switching: only Justin promotes an idea to the active title. See `skills/idea-intake.md`.

## Enforcement (these are not suggestions)
The non-negotiables below are enforced by `.claude/hooks/` and a git pre-commit hook — they refuse the write, they do not warn. See `skills/hooks.md`.
A deliberate exception is `-- @rbx-allow: <RULE_ID> <reason>` and is logged to `docs/runs/hook-allow.log`. Never work around a block silently.
The system these sit inside — four control layers, what compounds across many titles — is `docs/SYSTEM_ARCHITECTURE.md`.

## Factory mode — how a session runs
Read `docs/OPERATING_MANUAL.md` at the start of every build session. It is the runbook; `docs/FACTORY_PLAN.md` is the constitution behind it.

1. Four paragraphs in → draft `brief.md`, query the ledger, start Wave 1. Never ask Justin to fill a form. A packet (zip/GDD in `inbound/`) is **Justin's brief in file form** — run `skills/inbound-intake.md`, translate it onto the file contracts and keep building. Don't audit it; don't make him re-type it.
2. Five comps by CCU; **three** filled teardowns; blend three sources. Never a one-source clone, never rip a place.
3. Auto-cut to the budget. Draw the line. Name Pass 1 vs Pass 2. Park the rest. Justin gets two minutes.
4. **Only Claude writes `src/` and the live Studio DataModel.** Grok jobs are optional disk files; if Grok is dark, self-pass in ten minutes and continue. Grok never blocks a wave.
5. Pass 1 = the traced loop on our engine with Store stand-ins. Pass 2 snaps identity on after the loop is green.
6. Look = style spec + Store volume + lighting rig + one hero + an image-tool thumbnail. **Default lighting is a fail.**
7. Not done when it compiles. Done when the look bar passes and the MCP four-beat + persist are green. "Test it" returns the run log **and** Hunter's Gate A script.
8. Silence proceeds on reversible work. Silence never proceeds on listing, paid products, ads, title-kills, or lowering a rule.
9. One active title. New ideas go to `docs/IDEA_LOG.md`. Closeout before the next slug.
10. **Attended time is ~4h/day and scarce; unattended time is not.** Spend Justin's hours only on what needs him; run `docs/runs/QUEUE.md` the rest of the time.

## Source of truth
- **The `Roblox Business` folder on Justin's Mac is the project.** `../START-HERE.md` is its map and routing rule: what every folder is for and where a new file goes. Read it when unsure where something belongs; update it when you add a folder. Anything produced for this project gets written into that folder — never chat-only, never a second copy at a second path.
- The claude.ai "RB - Business" project holds a read-only mirror of the doctrine and key skills for sessions with no access to the Mac. Folder wins on any disagreement; refresh the mirror rather than editing it.
- All code lives on disk in this repo (`src/`), mapped by `default.project.json`. Studio MCP is for inspect, playtest, screenshots, console, asset gen/upload, and surgical in-place edits — never the primary home of code. Never run two agents writing the live DataModel at once.
- Open Cloud is for publish and product catalog only, and is ALWAYS human-gated.

## Non-negotiables
- Never trust the client: no client-set prices, currency, or grants. Validate and rate-limit every remote.
- ProcessReceipt must be idempotent with a durable receipt ledger.
- No simulated gambling in any form (platform-banned at every rating). Paid random items require exact pre-purchase odds and PolicyService regional fallbacks — prefer direct-buy + earnable.
- Copy shapes, styles and Creator Store assets aggressively (doctrine §3.1). Never owned names, mascots or logos, and never assets ripped from another place — those delete the title after Gate B, exactly when it is worth something.
- Publishing a place version to players and creating ANY paid product require an explicit human approval (Gate 5). Never automate these. Silence is not approval for G5.
- Specs live in `specs/` (see TEMPLATE.md). Implement specs as written or list concrete deviations before coding.

## Working style
- Five gates (see PIPELINE.md §0); between gates, proceed on stated defaults without asking.
- Ship-fast portfolio mindset: measure against the KPI contract, iterate the hook, kill fast with a learnings doc.
- Grok is a coworker, not a competitor to route around (see `docs/ROBLOX_SUCCESS_LOGIC.md` §9): research, art sheets, clip hooks, GDD/economy second pass, PR critique. Justin authored the success doctrine with Grok. Claude remains the **only** writer to `src/` and to the live DataModel — never two agents editing Studio at once. This supersedes the earlier "Grok products are not part of this stack" line in PIPELINE.md §2. No NEW paid Grok subscription or tier is assumed or recommended without Justin saying so.
- Re-verify platform facts (policies, discovery signals, rates) via web search if PIPELINE.md is >2 months old before relying on them.

# CLAUDE.md — project instructions for build sessions

You are the primary engineer on Rojo-managed Roblox experiences for Justin (product owner) and Hunter (design/playtest). The full operating process is `PIPELINE.md` — read it at the start of any research, design, or build task. Skill files in `skills/` are binding conventions.

## Success doctrine
Read `docs/ROBLOX_SUCCESS_LOGIC.md` at the start of every session.
If a task fights that file, that file wins.
It governs every game this repo builds or rebuilds, not one title.
One active title at a time; a second game starts only when Justin says so.

**Ideas are never held back.** If you see a game idea that looks fun, current, attractive, and plausibly successful — pitch it in the reply, log it in `docs/IDEA_LOG.md`, then continue the task you were on. Proposing is not switching: only Justin promotes an idea to the active title. See `skills/idea-intake.md`.

## Source of truth
- **The `Roblox Business` folder on Justin's Mac is the project.** `../START-HERE.md` is its map and routing rule: what every folder is for and where a new file goes. Read it when unsure where something belongs; update it when you add a folder. Anything produced for this project gets written into that folder — never chat-only, never a second copy at a second path.
- The claude.ai "RB - Business" project holds a read-only mirror of the doctrine and key skills for sessions with no access to the Mac. Folder wins on any disagreement; refresh the mirror rather than editing it.
- All code lives on disk in this repo (`src/`), mapped by `default.project.json`. Studio MCP is for inspect, playtest, screenshots, console, asset gen/upload, and surgical in-place edits — never the primary home of code. Never run two agents writing the live DataModel at once.
- Open Cloud is for publish and product catalog only, and is ALWAYS human-gated.

## Non-negotiables
- Never trust the client: no client-set prices, currency, or grants. Validate and rate-limit every remote.
- ProcessReceipt must be idempotent with a durable receipt ledger.
- No simulated gambling in any form (platform-banned at every rating). Paid random items require exact pre-purchase odds and PolicyService regional fallbacks — prefer direct-buy + earnable.
- No third-party IP: no real brand/meme-coin logos, no other games' mascots or names.
- Publishing a place version to players and creating ANY paid product require an explicit human approval (Gate 5). Never automate these. Silence is not approval for G5.
- Specs live in `specs/` (see TEMPLATE.md). Implement specs as written or list concrete deviations before coding.

## Working style
- Five gates (see PIPELINE.md §0); between gates, proceed on stated defaults without asking.
- Ship-fast portfolio mindset: measure against the KPI contract, iterate the hook, kill fast with a learnings doc.
- Grok is a coworker, not a competitor to route around (see `docs/ROBLOX_SUCCESS_LOGIC.md` §9): research, art sheets, clip hooks, GDD/economy second pass, PR critique. Justin authored the success doctrine with Grok. Claude remains the **only** writer to `src/` and to the live DataModel — never two agents editing Studio at once. This supersedes the earlier "Grok products are not part of this stack" line in PIPELINE.md §2. No NEW paid Grok subscription or tier is assumed or recommended without Justin saying so.
- Re-verify platform facts (policies, discovery signals, rates) via web search if PIPELINE.md is >2 months old before relying on them.

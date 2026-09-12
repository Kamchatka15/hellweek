# STATE — the control panel

> Loaded into every Claude Code session by `.claude/hooks/session_start.py`. **One file. Keep it current.** Stale is worse than missing.

## How a session runs

**Runbook: `docs/OPERATING_MANUAL.md`.** Six waves, file contracts, Pass 1 / Pass 2, the look bar, the MCP four-beat, the command vocabulary.

**Two clocks.** Attended ≈ **4 hours a day** (gates, the cut line, playtests, the G5 clicks) — scarce, spend it only on what needs Justin. Unattended = everything else: work `docs/runs/QUEUE.md` top-first, reversible only, and rewrite the next attended move here before stopping.

## Standing rule until further notice (2026-09-12, re-pointed)

**No further system work — no new hooks, agents, or restructuring — until Hell Week has been through Gate A with three fresh testers.** Only work that directly unblocks that test is allowed. The test of the factory is a game. (Justin re-pointed the rule from Fat Man Gets Rich to Hell Week by promoting the title in chat.)

## Where we are

| Field | Value | Updated |
|---|---|---|
| Active title | **Hell Week** (`games/hell-week/`) — arrived as a packet, intake fast path, Pass 1 built same day | 2026-09-12 |
| Parked | Fat Man Gets Rich (before Gate A, no evidence against it, re-mounts via `default.project.json`) · Layer Mine | 2026-09-12 |
| Gate position | **Before Gate A.** Pass 1 slice playable end to end on the scratch place; four-beat: 3 green, persist blocked on the publish click (`docs/runs/2026-09-12-hell-week-mcp.md`) | 2026-09-12 |
| Economy | Fuel budget simulated (`games/hell-week/economy.md`): Day 1–2 safe for everyone, Day 3 bites only a slacker, one Gift helps a slacker and costs a casual the week. Wick cap 15 is the Days 4–7 soft spot — a G2 decision after Gate A | 2026-09-12 |
| Persistence | **Unverified.** Same blocker as before: unlisted publish + API access (Justin's click, `docs/runs/PERSISTENCE_TEST.md`). Fields: `bestDay`, `tutorialComplete` | 2026-09-12 |
| Engine | Two night-rule fixes synced (last-tick death; zero at nightfall) — rerun the night beats next session. Two loop families now: `LoopService` (sweep-and-bank) and `SurviveLoop` (clock + beacon + stalker). 15 core modules. R1–R7 clean. One engine bug found by the second loop and fixed (`ZoneService` cylinder discs) | 2026-09-12 |
| Paid products | **None.** No `MarketplaceService` call in the repo. `games/hell-week/server/sku.luau` is a draft soft shop | 2026-09-12 |
| Art + sound | **Opening act at every join** (owner amendment; reopens §4 + §1.1 — Gate A weighs it). **Crafting bench in the pack as data** (`server/bench.luau`, 82 parts, from Justin's Blender drop; set dressing, synced and verified 11.7 studs from the Wick). Grey-box with the lighting rig applied from data (default lighting gone). Shelf ready: 15 model IDs + 7 audio IDs (`games/hell-week/shelf.md`). Inserts and recolor are Wave 4, behind the publish (InsertService) | 2026-09-12 |
| Studio | Scratch place `Place1` carries the tree via `tools/studio_sync.py`. `Lighting.Technology = Future` is a one-time Studio click (plugin-only property) | 2026-09-12 |
| Enforcement | R1–R7 + loop cap + SessionStart + git backstop. Intake scanner regex fixed (`bet*` matched "better") | 2026-09-12 |
| Evidence | 10 records (8 process, 1 economy, 1 tech). 0 player evidence — Gate A has not happened. 0 open contradictions | 2026-09-12 |

## Waiting on Justin (only the irreversible ones)

1. **Publish an unlisted place + Studio API access on** — unblocks the persist beat, InsertService dressing, and an honest Gate A. `docs/runs/PERSISTENCE_TEST.md` has the clicks.
2. **`Lighting.Technology = Future`** in the Lighting properties panel (cannot be set from a script). One click, once.
3. **Gate A:** Hunter recruits three kids; script at `games/hell-week/gate-a-script.md`.
4. **G2, after Gate A:** the Days 4–7 tuning and the Wick cap (`games/hell-week/economy.md` §"What it says", point 4).

## Next real move

**Justin's two clicks (publish unlisted + API on; Technology = Future), then the persist beat, then Wave 4 dressing from the shelf, then Gate A.** In that order. Nothing in Wave 4 needs a design decision; it needs InsertService.

## Open gaps named on purpose

- No sound wired (IDs on the shelf; a night-drop sting was not found — search in Wave 4).
- Days 4–7 are placeholders; the clock reaches them, the numbers are not the ones we mean.
- Co-op is untested: the loop is server-wide and multi-player by construction, but only one player has been in a run.
- `screen_capture` is edit-time only; the four-beat screenshots are staged, not live (run-01 finding, still true).
- TestEZ not installed; the fuel budget exists only as `tools/survive_sim.py`.

# STATE — the control panel

> Loaded into every Claude Code session by `.claude/hooks/session_start.py`. **One file. Keep it current.** Stale is worse than missing.

## How a session runs

**Runbook: `docs/OPERATING_MANUAL.md`.** Six waves, file contracts, Pass 1 / Pass 2, the look bar, the MCP four-beat, the command vocabulary.

**Two clocks.** Attended ≈ **4 hours a day** (gates, the cut line, playtests, the G5 clicks) — scarce, spend it only on what needs Justin. Unattended = everything else: work `docs/runs/QUEUE.md` top-first, reversible only, and rewrite the next attended move here before stopping.

## Standing rule until further notice (2026-09-12, re-pointed)

**No further system work — no new hooks, agents, or restructuring — until the ACTIVE TITLE has been through Gate A with three fresh testers.** Only work that directly unblocks that test is allowed. The test of the factory is a game. (2026-09-20: Justin promoted SPACEHEX in chat; the rule re-points to SPACEHEX. It has now survived two title swaps without either title reaching Gate A — that is itself the finding, and it is the one thing on this page worth worrying about.)

## Where we are

| Field | Value | Updated |
|---|---|---|
| Worlds | **All four generated and swappable 360°** — Ashen Waste 1,462 parts · Still Wood 2,158 · Drowned Quarter 1,175 · Kiln 1,024. Fixtures (obelisk, stone, points, table, light) never change; scenery/ground/rigs/fog swap whole on mastery | 2026-09-12 |
| Offering | Table stands OUTSIDE the pentagram at 40 studs on the fifth point's bearing. That point is its status light: grey empty · blue holding · green a sacrifice is ready (the real resolver decides) | 2026-09-12 |
| Controls | **PICK UP / ACTION / INFO**, always on screen and dimmed when idle; E / F / Tab. Auto-pickup off. INFO carries how-to-play, the trials and the recipe book. One remote (`C2S_Act`), verb only, server proves range | 2026-09-12 |
| Held things | Bone Knife (cactus x2), Brand (9-stud ward + carried light), **Sigil — the artifact of faith, 19-stud ward**. None kill: the Tempter stays unkillable | 2026-09-12 |
| World 1 | **The Ashen Waste** — a 700-stud desert, 1,156 generated scenery parts, three resources (Ashwood / Cactus / Stone) and four recipes run at the obelisk. Replaces The Quiet Shore | 2026-09-12 |
| Shape of the game | **Offerings:** a bowl beside the stone takes a sack and returns it a tier up at dawn (Ashwood→Emberwood→Heartwood). Craft bench CUT — the obelisk absorbed it. **Four worlds on four pentagram points** (Ashen Waste · Still Wood · Drowned Quarter · Kiln), seven trials each, point dark/red/green; the fifth point is the offering table. Framework built and wired; only world 1 exists (`games/hell-week/server/biomes.luau`) | 2026-09-12 |
| Active title | **SPACEHEX** (`games/spacehex/`) — promoted 2026-09-20. Buy parts in a warehouse → assemble a rocket → roll out → launch → earn on performance → upgrade. First goal the space station, then the Moon. Brief `games/spacehex/brief.md`, spec `specs/2026-09-20-spacehex-slice.md`, catalogue `games/spacehex/PARTS.md`, validated curve `games/spacehex/economy.md` | 2026-09-20 |
| SPACEHEX state | **Built end to end, unverified in Studio (2026-09-21 overnight run).** Third loop family `src/core/BuildLoop.luau` + `src/client/BuildHud.luau`: buy → stack → roll out → pad card → launch (trace playback on ClockService, stage separation, hold-down) → payout from `config.payout` → milestones → missions. Schema v2. Generated silhouette (`tools/gen_rocket.py`), lighting rig from data. All gates green (`rojo build`, `selene`, `stylua`, `rbx_guard`), Python cross-check of physics + payout green (`tools/spacehex_flight_check.py`). **Never booted:** Studio may not be driven unattended. Run log `docs/runs/2026-09-21-spacehex-run.md` | 2026-09-21 |
| SPACEHEX blocker | **The four-beat has not been run.** First attended task: open the built place, press Play, run the four beats in the run log §1, fix what the console says. Second: the `luau` CLI is not installed, so the career sim could not be re-run; the game seeds a player ~$0.9M richer than the sim (`economy.md` 2026-09-21), docking is probably a launch or two earlier than 19 | 2026-09-21 |
| Parked | **Hell Week** (before Gate A, no evidence against it, four worlds built, re-mounts via `default.project.json`) · Fat Man Gets Rich · Layer Mine | 2026-09-20 |
| Gate position | **Before Gate A.** SPACEHEX: four-beat NOT RUN (no Studio unattended). Hell Week's 3-of-4 four-beat (`docs/runs/2026-09-12-hell-week-mcp.md`) is parked with it | 2026-09-21 |
| Economy | Fuel budget simulated (`games/hell-week/economy.md`): Day 1–2 safe for everyone, Day 3 bites only a slacker, one Gift helps a slacker and costs a casual the week. Wick cap 15 is the Days 4–7 soft spot — a G2 decision after Gate A | 2026-09-12 |
| Persistence | **Unverified.** Same blocker: unlisted publish + API access (Justin's click, `docs/runs/PERSISTENCE_TEST.md`). SPACEHEX fields to check: `cash`, `parts`, `assembly`, `padTier`, `bestApogee`, `bestDV`, `launches`, `milestones`, `worlds` | 2026-09-21 |
| Engine | `ToolService` (held things, ward/harvest/light, no combat). `SackService` (typed carry) + `RecipeService` (bag → products, cascading). `OfferingService` (deposit value, return richer goods on a trigger — generic). `ChallengeService` (generic worlds + per-player trials, persisted). Two night-rule fixes synced (last-tick death; zero at nightfall) — rerun the night beats next session. **Three loop families now:** `LoopService` (sweep-and-bank), `SurviveLoop` (clock + beacon + stalker), `BuildLoop` (buy + stack + launch + pay). `EconomyService.setBalanceField`, `ContentLoader` builds a `Sky` from data, `StateSync` push is pcall'd. 16 core modules. R1–R7 clean, no `@rbx-allow` on the books. One engine bug found by the second loop and fixed (`ZoneService` cylinder discs) | 2026-09-12 |
| Paid products | **None.** No `MarketplaceService` call in the repo. SPACEHEX has no `sku.luau` at all | 2026-09-21 |
| Lighting | **Day and night are two complete rigs**, tweened (`ContentLoader.tweenLighting`). The desert day is bright, bleached and hazier than the camp; night is its own cold rig where the obelisk is the only warm light. Per-world data, so later biomes can be dark ones | 2026-09-12 |
| Art + sound | **The obelisk is the beacon** (HW-001 at the origin, 18 studs, on a gold-pentagram stone floor; cap fire = the light; no post, no candles anywhere; HW-002 fire jet from data on obelisk + bench). **Opening act at every join** (owner amendment; reopens §4 + §1.1 — Gate A weighs it). **Crafting bench in the pack as data** (`server/bench.luau`, 82 parts, from Justin's Blender drop; set dressing, synced and verified 11.7 studs from the Wick). Grey-box with the lighting rig applied from data (default lighting gone). Shelf ready: 15 model IDs + 7 audio IDs (`games/hell-week/shelf.md`). Inserts and recolor are Wave 4, behind the publish (InsertService) | 2026-09-12 |
| Studio | Scratch place `Place1` carries the tree via `tools/studio_sync.py`. `Lighting.Technology = Future` is a one-time Studio click (plugin-only property) | 2026-09-12 |
| Enforcement | R1–R7 + loop cap + SessionStart + git backstop. `games/layer-mine/` (parked, untracked drop) excluded from selene/stylua by config so the pre-commit can judge the tree it owns | 2026-09-21 |
| Evidence | 10 records (8 process, 1 economy, 1 tech). 0 player evidence — Gate A has not happened. 0 open contradictions | 2026-09-12 |

## Waiting on Justin (only the irreversible ones)

1. **Press Play on SPACEHEX** (attended, with Claude on the MCP): the four beats in `docs/runs/2026-09-21-spacehex-run.md` §1. This is the only thing standing between the overnight build and "playable".
2. **Publish an unlisted place + Studio API access on** — unblocks the persist beat and an honest Gate A. `docs/runs/PERSISTENCE_TEST.md` has the clicks. (Hell Week's published place exists; SPACEHEX needs its own or a re-point.)
3. **`Lighting.Technology = Future`** in the Lighting properties panel (plugin-only). And one look at the sky: it should be black with a hard sun and stars.
4. **`rokit add luau-lang/luau`** so `tools/spacehex_career.luau` can run again (a download; not done unattended).
5. **Gate A:** Hunter recruits three kids; the script for this title is not written yet (`brief.md` has the question).

## Next real move

**Boot it.** Open Studio on the built place, press Play, run the four beats, fix what the console says, then the two clicks, then Gate A on the launch loop. Nothing in the next attended hour needs a design decision; it needs eyes on a console.

## Open gaps named on purpose

- **SPACEHEX has never been booted.** Every check that can run without Studio is green; the one that matters most cannot.
- The career sim and the game disagree on the seed (free starters + $1M vs. $88k after buying them); the game's reading is the brief's, the sim needs re-running with it once `luau` exists.
- The sky is a bet: empty skybox faces are expected to render black; if not, black texture ids.
- No sound anywhere in SPACEHEX (ignition, staging, the payout). Creator Store audio waits on the publish.
- Mobile: the HUD scales down uniformly below 960×640 but was designed at desktop size; nobody has held it on a phone.
- One shared pad: a second player waits for the first flight to end. Multiplayer pads are out of scope for Pass 1 and it is written down as such.
- TestEZ still not installed; the physics has a Python second opinion, not a test.
- Hell Week: the Days 4–7 placeholders, the unsynced night fixes and the co-op test are all parked with it.

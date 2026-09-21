# Run log — 2026-09-21 — SPACEHEX overnight build — Waves 1–6

**Prompt as given:** the overnight brief (`../SPACEHEX-OVERNIGHT-BUILD-PROMPT.txt` at the folder root): *"Make SPACEHEX playable end to end, alone, in Studio, without a human in the room."* Six waves, top down, each with a stop condition; no Studio, no publish, no sim retune, no dead buttons.

**Outcome:** all six waves are written, linted and committed (pushed on `vision-rework`). Overnight the full circuit — join with $1,000,000 → buy → stack → roll out → read the card → launch → watch the altitude → get paid → buy something better — was verified statically and numerically only, because Studio may not be driven unattended. **On the morning of 2026-09-21, attended, it booted with a clean console and closed the circuit on the first try: beats 1–3 green, beat 4 blocked on the publish click, staging and the hold-down verified** (§1).

**Questions asked of Justin: zero.** Two design forks were decided for the first session and written to `QUEUE.md`.

---

## 1. The four-beat — run attended on 2026-09-21, 10:42–11:20

Per `templates/MCP_RUN_LOG.md`. Justin woke, said "where is my new game, please connect", and the built place (`rojo build -o build.rbxlx`, opened with `open`) was driven over the Studio MCP with every verb fired from the **client** DataModel through the real remote, exactly as the buttons send them. Screen access to Studio was declined, so every reading below is from the DataModel and the console, not a screenshot; Justin was at the screen.

| Beat | Pass? | Evidence |
|---|---|---|
| 1 · Join | **GREEN** | Console: `[ContentLoader] pack 'SPACEHEX' loaded — loop 'build', 3 zones` · `[boot] SPACEHEX ready` · `[funnel] HunterV_15 step=join`. World built (floor, walls, six clamps, gantry, hangar shell, four masts, three zones, spawn), character spawned, `PlayerGui.BuildHud` present. No errors. The DataStore fallback warning fired as expected for an unpublished place. |
| 2 · First earn | **GREEN** | `warehouse:buy:fins_basic` → cash $1M → $892K, `[funnel] step=first_buy`, `[event] buy_fins_basic=108000`. Stepping onto the pad zone opened PAD CARD: THRUST 9 kN · WEIGHT 3 kN · LIFT-OFF 3.36 : 1 · EST. APOGEE 1.6 km · REFURBISH −$38.4K · ROLL OUT green · no red lines (fins auto-fitted). `pad:rollout` → rocket at (0, 1, −30), 32 parts. `pad:launch` → T-3 → ASCENT 19 m at +1.2 s → DESCENT 1.5 km → RECOVERY; camera Scriptable at y=5,575 studs then released to Custom. `[funnel] step=first_launch`, `step=first_record`, `[event] launch_apogee_m=1587`, `launch_pay=834411`, `mission_first_launch=1`. Payout card: **PAID +$834.4K · NEW RECORD**. Cash $1.6M. Board: Upper Atmosphere 1/3. Rocket cleared from the pad. |
| 3 · First spend | **GREEN** | `warehouse:buy:dec_light` with earned money → cash $1.6M → $1.5M, `[event] buy_dec_light=96000`. `assembly:set` with a two-stage stack → `[funnel] step=first_assembly`; the reopened card read LIFT-OFF 1.77 : 1 · GOOD LIFT-OFF · MASS 0.5 t · EST. APOGEE 2.8 km · REFURBISH −$74.8K. Server-side balance change; the client sent verbs only (R1). |
| 4 · Upgrade + persist | **BLOCKED** | In-memory fallback: *"You must publish this place to the web to access DataStore."* Same click as every run before it. |

**Also verified on the same Play:** stage separation (ribbon STAGE 1/2 → STAGE 2/2 at 1.1 km; the stack lost `Stage1` and landed back on the pad; the loose stage was gone after its Debris timer) · the **hold-down** (Medium Tank under one Hopper: ribbon HOLD-DOWN 0 m for the four seconds, payout card **HOLD-DOWN · $0 · IT WILL NOT LIFT — thrust is less than weight.**, cash charged only the −$76.8K refurbish) · every number matched `tools/spacehex_flight_check.py` to the dollar ($834,411; $1,688,011 → "$1.6M").

**Persist 7-row:** __ / 7 — blocked on the publish.

**Bugs found by the attended pass, fixed on disk the same hour:** the payout card printed a minus Δv on a starter stack; the ribbon sat at 61 m after touchdown; a held flight appended "APOGEE 0 m". Nothing else. Zero console errors across four flights.

**One sentence a kid would still not understand:** *"OVERPOWERED — you are burning fuel fighting the air"* on a 3.36 : 1 starter rocket reads as a scolding for a rocket that just flew fine; Gate A should watch whether it lands as information or as a telling-off.

**Gotchas for the next MCP session:** the Studio MCP runs `execute_luau` calls one after another, never in parallel — a "server sampler" issued beside a 25 s client call starts after it ends. `screen_capture` is black in Play and screen access was declined, so read the DataModel instead.

## 2. What I read before starting

Everything in the brief's section 0, in order, plus every engine module BuildLoop reuses (`LoopService`, `SurviveLoop`, `DataService`, `EconomyService`, `StateSync`, `ChallengeService`, `ClockService`, `ZoneService`, `ContentLoader`, `RemoteGuard`, `AnalyticsService`), both HUDs, `Hotbar`, `UIKit`, `OpeningAct`, the whole pack, the career sim, `gen_obelisk.py`, the pre-commit, and run-02 as the model for this log. `PIPELINE.md` was skimmed, not read; the manual supersedes it for a build session.

## 3. What was built, wave by wave

**Wave 1 — the third loop family** (`src/core/BuildLoop.luau`, 1,400 lines, R1–R7 clean). `config.loop = "build"` → `ContentLoader.loopModuleName` → `BuildLoop`. It owns cash (through `EconomyService`, which learned to name its balance field so this family's money is `cash` with no second balance), owned parts as a set, the current assembly, the pad tier, one shared pad, the launch, the payout, the milestones, the ladder and the funnel. One remote, `C2S_Act`, six verbs, 12 per 4 s; every stack the client sends is rebuilt field by field against ownership, class, the stage and engine limits. `DataService` moved to schema 2 with an explicit `1 → 2` migration that adds the eight fields and drops nothing. Stop condition met as far as the tools reach: `rojo build`, `selene`, `stylua`, `rbx_guard` green; the built place contains every module.

**Wave 2 — the three screens** (`src/client/BuildHud.luau`, 1,760 lines). WAREHOUSE by class with a real 3D icon per part: the shared silhouette module is photographed in a `ViewportFrame` through `Hotbar.iconOf` (now exported), so thirty parts have icons and no art exists. Greyed, never hidden. ASSEMBLY edits a draft of the stack with `<`/`>` cycles over owned parts, previews the whole rocket the same way, and lists the problems in red. PAD CARD is two bars and a ratio plus Δv against 7,700, mass against the pad, the verdict, the refurbish, ROLL OUT and LAUNCH. Every string is a theme key (138 of them, cross-checked by script).

**Wave 3 — the launch.** The server re-runs `assembly.check`, resolves, simulates, then plays the trace back on `ClockService` phases: prelaunch 3 s → ascent (real time up to a cap) → coast → descent → recovery. The stack's CFrame follows the trace at 1 stud = 0.28 m up to the 2,000 m ceiling, then drifts slowly while the owner's camera pulls back to a long shot and the ribbon reads km. At each burnout the spent stage's model is unanchored, kicked, and left to fall (Debris, 14 s). Held rockets shake on the clamps with the bell lit for 4 s. Telemetry goes to every client at 8 Hz on `S2C_Fx`, not in the state packet.

**Wave 4 — the money.** Exactly the sim's formula, as data in `config.payout`: altitude pay, performance pay, the 62% repeat, the 4% / 1% refurbish (never below zero cash), five altitude and five Δv milestones plus ORBIT and DOCKED, each paid once and remembered on the profile. Missions: `tiers.luau` rewritten so every rung is decidable from one launch result; mastering a tier opens the next in the same evaluation pass. Funnel: join, first_buy, first_assembly, first_launch, first_record, karman, orbit, docked.

**Wave 5 — the look.** `tools/gen_rocket.py` → `games/spacehex/shared/rocket.luau`: 10-ring parabolic bells, a 16-ring tangent ogive, an 8-ring cone, a 12-ring fairing, 6-ring interstages between tanks of different width, swept fins in four stepped plates. The same module draws the pad, the preview and the icons. A lighting rig in `world.luau`: no skybox faces, one hard sun, 3,000 stars, black scattering, no haze, cold tint, bloom only on the exhaust; the loader learned to build a `Sky` from data.

**Wave 6 — this file**, `STATE.md`, `QUEUE.md`, the economy note, and `tools/spacehex_flight_check.py`.

## 4. How it was verified, and what that does and does not prove

| Check | Result | Proves |
|---|---|---|
| `rojo build` | green, every module in the tree | the project maps |
| `selene src games` | 0 errors, 0 warnings (it fails the pre-commit on warnings) | parses; no unused/ shadowing/ style traps |
| `stylua --check src games` | green | parses; repo format |
| `rbx_guard.py` on every touched `.luau` | exit 0, no `@rbx-allow` used | R1–R7 |
| `tools/spacehex_flight_check.py` | six launches, cash ≥ 0 throughout, formula reproduces the economy table | the payout, the hold-down, the timeline math |
| theme-key cross-check | 0 keys used by HUD or loop missing from `theme.copy` | no nil string at runtime |
| a read-back of BuildLoop and BuildHud against every engine API they call | four fixes (below) | contracts match |

**Not proven:** that it boots. Runtime errors that no linter can see (a wrong Instance property name, a nil in a path I did not trace, replication order) will only show on Play. The read-back was thorough; it is not a substitute.

## 5. Every fix made during review

1. `StateSync`'s push loop had no `pcall`; a builder that threw would have silently stopped every player's packets for the session. Hardened (engine-generic).
2. The physics runs inside the packet builder; wrapped in `pcall` so a stack the physics cannot read darkens the card with a sentence instead of killing the packet.
3. `challengeMet`/`milestoneMet` compared against a possibly-nil `at`; guarded.
4. `DataService.save` was called from inside the clock's signal; moved off-thread.
5. A `next()` local shadowed the global in the assembly screen; renamed.
6. The pad card printed a negative Δv for a small stack; display clamps at 0.
7. First-launch playback was 44 s wall; caps tightened to 14/8/6 → ~35 s.

## 6. What I refused, and why

- **Installing the `luau` CLI.** The brief: note it as blocked and carry on. The Python port is a second opinion, labelled as one, and reads the catalogue live so only the physics lines can drift.
- **Opening Studio.** Unattended sessions never drive it (`OPERATING_MANUAL.md` §8); the brief said the same.
- **Touching `games/layer-mine/`.** The pre-commit lints the whole tree and that untracked drop fails both linters, so it was excluded by config (`selene.toml` `exclude`, `.styluaignore`) — one line each, reversible, documented — rather than edited or bypassed with `--no-verify`.
- **Retuning `parts.luau` / `flight.luau`.** Formatting, rule 9, and two drawing constants only. `ORBIT_DV` untouched.
- **A `sku.luau`.** Optional in the brief; nothing monetised, no `MarketplaceService` call anywhere.
- **Fins in the starter kit.** Two readings of the brief (see `QUEUE.md`); the one where the first red line is the first purchase teaches the loop and was kept.

## 7. What changed my mind

- The sim's ladder in `tiers.luau` had rungs the game cannot decide ("recover 20 pieces of scrap", "hold horizontal velocity", "burn inside the window"). A rung nobody can complete is a dead button, so every rung became a test on a launch result and tiers 5–6 became real stacks (four stages, two vacuum engines, 100 t off the pad) rather than a Moon that does not exist yet.
- The rocket module moved from `server/` (the brief's suggestion) to `shared/` because the client draws the same silhouette for the preview and the icons; it holds no prices.
- One extra profile field beyond the brief's list: `milestones` (a set), so a bonus is paid exactly once even if thresholds are retuned later.

## 8. Engine changes, and whether they are generic

| Module | Change | Generic? |
|---|---|---|
| `BuildLoop` (new) | the family | shape yes; a second build title is the proof |
| `EconomyService.setBalanceField` | the loop names its balance field | yes |
| `DataService` schema 2 + migration | eight fields | yes |
| `ContentLoader` | `build` branch; `Sky` from data | yes |
| `StateSync` | pcall around push | yes, bug fix |
| `Hotbar.iconOf` | exported | yes |
| `BuildHud` (client) | third HUD in `src/client/` | same note as runs 01–02: `src/client/` wants a `core/client` mount before a fourth |

## 9. Ideas logged this session: none

Every idea-shaped thought was a feature of this title (a ghost line of the previous flight's altitude on the ribbon; a station module you can see from the pad once orbit is reached). Backlog, not idea log.

## 10. What the next session should do first

1. **Attended:** open Studio on the built place (`rojo build -o` or the plugin), press Play, run the four beats in §1. Fix what the console says. Set `Lighting.Technology = Future` (one click) and look at the sky: if the empty skybox faces do not render black, the fallback is a `Sky` with black texture ids.
2. Justin's two clicks (unlisted publish + API access) → the persist beat.
3. `rokit add luau-lang/luau` (attended) → re-run `tools/spacehex_career.luau` with the game's seed and record the docking launch in `economy.md`.
4. Gate A with Hunter's script — which does not exist yet for this title; write it from `brief.md`'s Gate A question before recruiting.

# MCP run log — hell-week — 2026-09-12

> Wave 4 form. A compiling pack is not a game; this log is. Run on the **unpublished scratch place `Place1`** via `tools/studio_sync.py` + Studio MCP, so InsertService and DataStores are dark and **the persist beat cannot be honest yet** (`docs/runs/PERSISTENCE_TEST.md`).

## How the tree got into Studio
`python3 tools/studio_sync.py 34873` on disk → one `execute_luau` in Edit mode fetched `/tree` (32 nodes) and rebuilt `ServerScriptService.{Core,Pack,Server}`, `ReplicatedStorage.{Shared,Pack}`, `StarterPlayerScripts.Client`. Template `Baseplate` + `SpawnLocation` removed from the scratch place (they put the spawn at the origin). `Lighting.Technology` could not be set from a script ("lacking capability RobloxScript") — Justin's click.

## The four beats

| Beat | Pass? | Evidence |
|---|---|---|
| 1 · Join — no error spam, player moves, first action obvious | **PASS** | Console: `[ContentLoader] pack 'Hell Week' loaded — loop 'survive', 1 zones` · `[boot] Hell Week ready` · `[funnel] step=join`. Only warning: the expected DataStore memory fallback. Spawn at `(0, 4, 30)`, LookVector `(0,0,-1)` = facing the Wick 30 studs away; 14 Ashwood on the floor, 3 of them on the spawn line, the first labelled PICK UP; light range 25; Tempter hidden (`y=-500`). |
| 2 · First earn — a number goes up within 60 s | **PASS** | Character moved onto the nearest Ashwood (8.6 studs): floor 14 → 13 in 0.42 s. Three more attempts: floor 11 (sack cap 3 refused the fourth; SACK FULL toast path). HUD read from the **client** DataModel: `DAY 1` · `WICK 9` · `SACK 0 / 3` — exactly three numbers, 5 TextLabels total (two hidden run-end labels). |
| 3 · First spend / sink — server-side change, client cannot edit (R1) | **PASS on rerun** (first run RED) | Stepping onto the Wick disc: light range 25 → **49** (3 fed × 8), flame scaled 0.91 → 1.07, Tempter appeared on the light-line at `(0, 0, -51)` beyond the Wick along the spawn bearing. Feed latency 0.8 s. Nine fed: range **90** (cap), fog ring **175 → 280**, Ring C spawned (floor 5 → 11). **First run red:** standing on the disc fed nothing — `ZoneService` box test vs. a rotated cylinder (E-0009). Fixed generically, re-synced, green. There is **no client→server remote** in this loop family; nothing to forge. |
| 4 · Upgrade + persist — survives stop/start, not a memory store | **BLOCKED** | `DataService` is on the in-memory fallback ("You must publish this place to the web to access DataStore"). `bestDay` and `tutorialComplete` are written to the profile and the run-end path calls `DataService.save`, but a stop/start on a memory store proves nothing. Same click as run 01. |

**Persist 7-row:** 0 / 7 — not run, blocked on the publish.

## Beyond the four beats — the night, observed from a server logger (5 s samples)

| t | What happened | Verdict |
|---|---|---|
| Night 1 | Brightness tweened 1.80 → 0.55 in ~8 s; range drained 90 → 74 over the 40 s night (burn 3 ≈ 2 units/40 s + rounding, as configured); Tempter stood still on the shrinking line (`z -92 → -77`), never entered | PASS — night-1 mercy |
| Day 2 | Brightness back to 1.80; floor respawned 11 → 30 (A + B + C); Tempter held the line in watch mode | PASS |
| Night 2 | Range 88 → 58 over 45 s (burn 4); Tempter in hunt mode but the player sat inside the light (`r=16`) so it held the line like glass | PASS — pane of glass |
| Day 3 | `gift=true` — the Gift spawned on the light-line with the pink PointLight; floor 48 | PASS |
| Night 3 | Logger stepped the player out to `r=120` (during Day 3: no chase, correct). At Night 3 the Tempter walked from the line (`z -59`) toward the player (`-86`, `-95`, `-100`) at ~9 studs/s and **touched**: player teleported back to `r=6` at the Wick, `downed` fx + toast fired, fuel penalty applied, Weight +1 | PASS — hunt + downed + wake at Wick |
| Boundary | Not exercised (push-back at 360 studs) | untested |
| Run end / score | Not reached (fuel never hit 0 at night; week not completed) | untested in Studio; math in `scoreNow` |
| Co-op | One player only | untested |

Note: the step-out landed on Day 3 instead of Night 2 because the logger's clock started ~90 s after the run's. Same test, one day later.

## Look bar (grey-box, before Wave 4 inserts)
200px hero: **not yet** (primitive Ashwood log; hero mesh is Wave 4) · spawn shot: **yes** — the Wick post + gold Neon flame + WICK label is the brightest thing from spawn · one meter: **yes** — Day bar drains; Wick and Sack are the other two numbers · palette: **yes** — grey sand / black water + gold; the Gift pink is the only third colour · set dressing: **primitives only**, no Store packs yet · light: **rig applied from data** — ClockTime 20.4, Atmosphere 0.42, ColorCorrection, Bloom; default lighting gone; `Technology=Future` pending Justin's click · IP: **clean** (R6 zero hits; all names original)

## Screenshots
**None captured.** `screen_capture` returned black frames: a human started a Play session on the scratch place during the staging window (Studio reported Play mode), and captures are edit-time only (run-01 finding). The staged photo scene (`workspace.World`, edit-time) is discarded automatically the next time the loop boots. Re-take in Wave 4 on the published place, where the dressed scene is the one worth photographing.

## Hunter played it — three runs on the scratch place, unprompted (console, 2026-09-12)

Not Gate A (Hunter co-designed the brief and the script says he cannot be the subject), but the first human input this title has had, and it found two bugs the four-beat did not:

| Run | What the funnel shows | What it means |
|---|---|---|
| 1 | join → first_pickup **+18.0 s** → first_feed **+19.6 s** → Day 2 at 130 s → Day 3 at 265 s → downed by the Tempter on Day 3 → reached Day 4. 440 s session | The one-minute teach works on a human who knows the design: pick up in 18 s, feed 1.6 s later |
| 2, 3 | fed **exactly 3** on Day 1 → `run_end_light_out` at **130.0 s** — the last tick of Night 1. Again on the next run with fuel 1. Later: `run_fuel_in=6`, burn 3+4=7 → light out at the last tick of Night 2 | **Bug 1: feeding exactly the burn is death.** Fixed: `emptied` inside the last 2 s of a night is a wick that guttered and held (`config.night.graceSeconds`) |
| idle | after that, runs with `run_fuel_in=0 · run_fuel_out=0 · run_days_cleared=7 · run_score=7000`, repeatedly | **Bug 2: a wick at zero when night falls is never checked** — `emptied` only fires on a transition to zero, so an idle player at 0 fuel survives every night. Fixed: night start with fuel ≤ 0 ends the run |
| anomaly | more completed weeks in the console than 38 minutes allows | Sampled the live clock from the client: `remaining` drops 1.0/s, `length` 80 on Day 4 — **the clock runs at 1×**. The extra weeks are not explained; most likely console carry-over across Hunter's stop/starts. Left open in the run log |

Both fixes are synced to the scratch place (the Play session turned out to be idle for 20+ minutes and was stopped). The night beats have not been re-run since; that is the first thing the next session does.

## One sentence a kid would still not understand
> **"Why did the tall thing stop right there?"** — the pane-of-glass rule is invisible until you see it fail to cross the line once. Gate A will tell us whether the first night's watching is enough to teach it, or whether the light-line needs to be drawn on the sand.

## Verdict
**Beats 1–3 green, beat 4 blocked on the publish click.** Not "built" by the manual's definition until persist is green and the look bar has a hero; **built enough to hand to Hunter for a first look** on the scratch place. Wave 5 (list-ready) is not opened.

# Hell Week — Claude Code execution brief

Read this whole file before writing Luau.
You are the only writer to `src/` and Studio.
Grok jobs (confusion pass, extra thumb prompts) are optional and must not block.
If this fights `ROBLOX_SUCCESS_LOGIC.md` on safety, children, money, or publishing, the doctrine wins.
If this fights older factory addenda on speed or dressing, **this brief + FACTORY v2.0** win.

**Owner intent:** give Hell Week a shot. One active slug while this is in progress: `hell-week`. Park other titles in IDEA_LOG. Do not open Pocket Factory. Do not rip 99 Nights in the Forest.

---

## 0. What you are building (one paragraph)

**Hell Week** is a 4-player co-op survival week in a fictional underworld that is *quiet and wrong*, not a sermon. You wake on a grey shore. A wick is the only clock and the only safe light. Days are long. When the light thins, a silhouette (the Tempter) walks the edge. You do not kill it. You feed the wick, gather fuel, pass one simple night rule, and last 7 days. Optional Robux tools start to *matter* on Day 3–4 (oil, carry, one revive). They never lock a day. Visual bar = 99 Nights in the Forest (low-poly, dark ground, warm light, fog ring). Not better. Not worse on purpose.

Zone 1 only. Name on signs and HUD: **The Quiet Shore**.
Design register (do not print on the tile or as a lore lecture): Sheol-like — realm of the dead / the grave; hush; both kinds of wanderers; **not** a torture chamber, not Gehenna, not Lake of Fire, not Satan, not Bible quotes.

---

## 1. Settled answers (do not reopen)

1. Not religious content. No scripture, no crosses-as-puzzles, no “salvation,” no “damnation” splash, no pentagram logo, no zone named Gehenna / Tartarus / Lake of Fire / Outer Darkness on launch.
2. Title **Hell Week** is the brand. Zone 1 player-facing name is **The Quiet Shore**.
3. Copy 99 Nights’ *machine*, never its meshes, audio, scripts, deer, kids, class names, or UI chrome.
4. Mild fear only (9+): silhouette, sound, shrinking light. No realistic gore, no torture, no jump-scare spam.
5. Soft shop, not a door. F2P can finish Day 7 if they play well. Oil is slack, not a key.
6. Pass 1 is Days 1–2 teach + Day 3 oil-pressure **prototype**, one trial type, one Tempter, one camp. Stop.

---

## 2. 99 Nights teardown (what to trace)

### The machine (COPY SHAPE)

| Piece | How 99 Nights does it | Hell Week equivalent |
|---|---|---|
| Core verb | Chop / loot by day | Pick **Ashwood** (fuel) and carry it |
| Sink | Feed campfire; fire = safe radius + map peel | Feed the **Wick**; light = safe radius + fog peel |
| Night threat | Deer is unkilleable; stay in light or flashlight | **Tempter** is unkilleable; stay in light. Night 1 it does not enter. |
| Clock | ~3 min day / 1.5 min night | **Long Hour** ~90s day / **Trial** ~45s night (tune). 7 days = a week. |
| First night mercy | Deer skips night 1 | Tempter visible at the fog line, does not chase Night 1 |
| Map gate | Fire level reveals fog | Wick level 0→2 reveals two rings of the Shore |
| Return hook | Next night is worse if you slacked fuel | Same. Burn rate ticks up each day |
| Social | 4 players, shared fire | 4 players, shared wick |
| Score / goal | Reach day 99 (beds + kids multiply) | Last **7 days**. Score = days×1000 + wickLeft×10 − gifts×200 |
| Shop timing | Classes after you understand nights | Oil / Deep Pockets / Second Wind offered after first Day-2 survive |
| Look | Low-poly forest, dark ground, warm fire, fog, readable props | Same budget. Grey sand, black water, driftwood, one wick, pale trees |

### Do not copy

Meshes, animations, deer rig, kid models, crafting-bench UI, class shop, cultist raids, biomes 2+, guns, taming flute, pelt trader, “99,” their audio, their thumb style if it uses their characters.

### Wedge (ours)

99 Nights = gather and hide.
Hell Week = gather, hide, and **the easy pile is a trap**.
Once per day a **Gift** sits at the edge of the light (extra fuel that is cursed). Taking it fills **Weight** and raises tomorrow’s burn. Refusing it is slower and safer. That is the clip.

---

## 3. Complexity budget (Pass 1)

IN:

- 1 core verb: pick up Ashwood → walk → feed Wick
- 1 return hook: Day N+1 burns faster if you slacked or took a Gift
- 1 social/clip hook: the Gift at the light-line (temptation)
- Systems (≤4): Wick + fuel, Day/Night clock, Tempter (Night 2+ chase outside light), Sack (carry cap 3)
- On-screen numbers (≤3): Day (1–7), Wick fuel, carry (n/3)
- Onboarding artifact: the Wick itself + **one** world prompt at spawn

PARKED (do not build): classes, diamonds, other zones, bosses roster, sleepers-to-rescue, beds/day-multiplier, squad oil, collections, weekly board UI, crafting wiki, guns, hunger meter as a fourth HUD number, religious names on signs.

---

## 4. First 60 seconds (non-negotiable teach)

Player must be able to say, without a speech:

> “Feed the light. Don’t go into the dark. Don’t take the pile that looks too good.”

### Beat script (Claude implements this order)

0:00 — Black. One breath-length fade. No logo dump.

0:03 — First-person or over-shoulder on grey sand. Water is black glass. Fog close. A **Wick** (tall candle / lantern on a driftwood post) burns 30 studs ahead, warm, obvious. One line only, world text above it or a single toast:

`THE WICK IS THE ONLY CLOCK`

0:08 — Between player and Wick: **3 Ashwood** pieces, big, pale, outlined. Prompt on look: `Pick up` then `Carry to the Wick`.

0:20 — Feed 1 Ashwood. Wick flare. Light radius pops from 20 → 40 studs. Fog steps back. Soft sound. Toast dies. No second paragraph.

0:30 — Day meter visible: `DAY 1` + a thin bar emptying toward night. Player can grab the other two woods.

0:45 — After the first feed, the **Wick light-line** (not the far fog wall) is the ring that matters. A tall thin silhouette stands on *that* line, facing the Wick, close enough to read. The map fog can sit at 175 studs; the Tempter must not spawn on a wall the player cannot see. Night 0/1 it does not move. Optional second toast, one line:

`IT WAITS FOR THE LIGHT TO THIN`

1:00 — First Long Hour continues. If they have not fed the Wick by 0:25, the Wick pulse-pings and the nearest Ashwood sparkles. No tutorial NPC. No cutscene.

**Fail the minute if:** more than 2 toasts, a paragraph, four HUD numbers, a shop prompt, or a jumping scare.

---

## 5. Zone 1 — The Quiet Shore (build this first)

### Feel

Sheol-register: grave, hush, grey, not fire-and-brimstone. Both “wanderers” (harmless seated figures in the fog, non-interact, no faces copied from anyone) can exist as set dressing. It should feel like low tide in a place that used to be a beach.

### Playable dimensions (bigger than 99 Nights’ first fog pocket)

- Starting playable disk **350×350 studs** (175 stud radius from the Wick to the Day-1 fog wall). Owner request: start **larger** than 99 Nights’ cramped first circle. This is still camp + first shore, not a second biome.
- Wick at origin. The one-minute teach stays in **Ring A** so the extra sand does not hide the goal.
- Ring A (always; the teach): **0–50 studs**. Spawn, Wick, 6–8 Ashwood *in the path* to the Wick, 2 driftwood piles. Wick + wood must read without a full turn.
- Ring B (open at start — the extra size): **50–175 studs**. Scatter Ashwood, one ruined rowboat, pale tree clusters, grey flats. Day-1 fog wall at ~175.
- Ring C (Wick Level 1 peel, after ~8 fuel): **175–280 studs**. Extra fuel. Gift prefers this line on Day 3.
- Ring D (Wick Level 2, Pass 1 optional): **280–350 studs**. Shore edge. Push-back past **360** with toast `NOT THAT WAY`. No drown-loop.
- Walk at 16 studs/s: ~3s to finish the teach, ~11s to the starting fog wall, ~18s into Ring C after the first peel.

### Lighting (lock these numbers in `lighting.md`, then apply)

- ClockTime ~20.4 (false dusk that never becomes noon)
- Brightness 1.5–2
- OutdoorAmbient dark blue-grey
- Atmosphere: Density ~0.4, Haze enough that Ring C dies softly
- ColorCorrection: slight desat, contrast +0.12, tint cool except near Wick
- Bloom only on Wick flame + Gift (Gift gets a *wrong* warmer bloom)
- One PointLight on Wick, warm, range scales with fuel level
- Tempter has no point light. It is a hole.

### Style spec (five lines)

1. Silhouette: low-poly, single-colour props, readable at 200px
2. Ground + accent: grey sand / black water + **warm wick gold**
3. Light source: the Wick. Gift bloom is the only competing warm
4. Eye track: Wick + one fuel pile + Day number
5. Mood: hush, mild fear, zero gore, zero sermon

### Shelf (legal only)

Search Toolbox by silhouette, insert by ID, recolor to grey/gold:

- Low-poly driftwood, grey rocks, dead trees, lantern post, rowboat, fog-friendly grass or none
- Wick can be Cube short prompt: `low poly tall candle lantern on driftwood post, single colour, no text` + triangle cap, then paint gold flame
- Tempter: primitive tall capsule + dark Material + slight sway. Do **not** generate a demon face. No horns required. Wrong proportions beat a stock devil.

Audio: Store licensed — one hush loop, pickup, wick-feed flare, night-drop sting, distant wood-creak. No named-after-another-game files.

### Tempter rules (Pass 1)

- Night 1: stands on fog line. No chase.
- Night 2+: if player is outside Wick radius, Tempter moves toward them slowly. Touch = downed (fade, wake at Wick, lose 20% current fuel, Weight +1). Not a gore death.
- Inside radius: Tempter stops at the line like a pane of glass.
- No combat. No weapons. Flashlight is PARKED (99 Nights extra; we have the radius only).

### Gift rules (Pass 1, appears Day 3)

- One pile that looks like 5 Ashwood but with the wrong bloom.
- Take it: +5 fuel now, Weight +1, next day’s burn ×1.25 (stacking).
- Leave it: nothing.
- HUD does not add a fourth number. Weight only changes burn; it is not drawn until Day 3 and even then it is a small mark on the Day badge, not a new meter.

---

## 6. Days and numbers (Candidate — run through sim, then freeze)

| Day | Day length | Night length | Burn per night (fuel units) | Ashwood in Ring A+B | Tempter |
|---|---|---|---|---|---|
| 1 | 90s | 40s | 3 | plenty (8+) | watch only |
| 2 | 90s | 45s | 4 | plenty | chase outside light |
| 3 | 85s | 50s | 6 | tight if sloppy | chase + Gift appears |
| 4–7 | PARKED tuning | — | escalate | — | same AI, faster |

Carry cap 3. Feeding 1 Ashwood = 1 fuel. Wick radius: 25 + 8×currentFuel, cap 90.

Shop (code the products, do not force prompt before Day 3 survive):

- Wick Oil: +4 fuel this run. Cheap Robux **or** a grind currency if you already have ProductService patterns. Optional.
- Deep Pockets: carry cap 5, this run or persist (persist is better).
- Second Wind: one extra wake per run without fuel penalty.

Do not implement a lobby class shop in Pass 1.

Score (compute, show at run end, no full board UI required in Pass 1):
`daysCleared * 1000 + wickLeft * 10 - giftsTaken * 200`

---

## 7. Factory waves — execute in this order

### Wave 0 (you, now)

- Slug: `hell-week`
- Create `games/hell-week/` with this brief copied as `brief.md`
- STATE.md: Active = hell-week, Wave = 1
- Hypotheses:
  - H1: Kids can say the three-sentence gist after one minute without a narrator.
  - H2: Day 3 Gift is understood as a trap by at least 2 of 3 Gate A kids.

### Wave 1 (disk)

Write, do not wander:

- `research/hell-week/ccu-board.md` — 99 Nights + 2 other survive-the-night comps (Doors or similar), CCU if reachable, else “live / genre”
- `research/patterns/hell-week-99nights.md` — this teardown, COPY / DO NOT COPY filled
- `games/hell-week/theme.md` — the five lines
- `games/hell-week/shelf.md` — ≥12 Store IDs + 4 audio IDs
- `games/hell-week/lighting.md` — numbers from §5
- `games/hell-week/economy.md` — table in §6 + shop three SKUs
- `games/hell-week/wedge.md` — Gift as clip hook
- `games/hell-week/cut-list.md` — IN vs PARKED from §3

Silence 2 minutes on the cut after you draw it, then build.

### Wave 3 — Pass 1 pack (only writer)

Engine patterns from the factory if they exist (DataService, RemoteGuard, ProcessReceipt). If Hell Week is a **new place** not the FMGR pack, still use those wrappers. No raw remotes. No client-authoritative fuel.

Minimum scripts:

- `DayNightService` — clock, day index 1–7, events `DayStarted` / `NightStarted`
- `WickService` — fuel, radius, persist mid-run if you already have session save; persist **bestDay** + cosmetics across sessions
- `GatherService` — Ashwood spawn in rings, sack cap, give to wick (server)
- `TempterController` — server-side position vs radius
- `GiftService` — Day 3+ spawn, take = Weight
- `Onboarding` — the two one-line toasts, then never again that session
- HUD: Day, Wick, Carry only

R1–R7: fuel and purchases server-side. Receipt ledger if any Robux product goes live. Kids-safe copy. No gambling. No third-party IP.

### Wave 4 — dress + prove

- Insert shelf IDs, recolor, apply lighting rig
- Look-bar: spawn shot shows Wick; collectable (Ashwood) readable; one meter filling; two colours; default lighting gone
- MCP four-beat:
  1. Join — no error spam, Wick visible, first Ashwood obvious
  2. First earn — pick Ashwood, carry count up, <60s
  3. First spend/sink — feed Wick, radius grows, server fuel changes
  4. Persist — survive to Day 2 start *or* stop/start studio play and bestDay / tutorial-complete flag survives
- Write `docs/runs/YYYY-MM-DD-hell-week-mcp.md`
- Red beat = patch in-session. Do not declare built.

### Wave 5

List-ready checklist only. Owner clicks G5. No ads. Gate A script for three kids printed verbatim from §4 gist + “what is the pile with the weird glow.”

---

## 8. Intro / walkthrough (what exists in the place)

Not a separate movie. The place *is* the walkthrough.

1. Fade in Quiet Shore.
2. One line: `THE WICK IS THE ONLY CLOCK`
3. Ashwood in the path.
4. Feed → light grows → fog steps back.
5. Silhouette on the ring.
6. Optional line once: `IT WAITS FOR THE LIGHT TO THIN`
7. Day bar ticks. Night 1: darkens, Tempter still. Night 2: chase if they leave the circle.
8. Day 3: Gift with wrong bloom. No toast if you can help it. If Gate A shows confusion, one line max: `SOME PILES COST TOMORROW`

If they stand still 20s, sparkle the nearest Ashwood. That is the whole tutorial budget.

---

## 9. Claude Code standing orders for this title

1. Four paragraphs already in this file. Do not ask for a form.
2. Blend 99 Nights + generic survive-the-night. Never one-source visual clone.
3. Auto-cut is already drawn in §3. Build Pass 1.
4. You own `src/` and Studio. Do not wait on Grok.
5. Look = spec + Store + lighting + primitive Tempter + Cube wick if needed. Screenshot is not the thumb.
6. Done = look-bar + four-beat green, not “scripts compile.”
7. Soft shop only. No locked days.
8. One slug: `hell-week`.
9. No Bible text in Workspace, toasts, product names, or audio names.
10. Safety / children / money / publishing: doctrine wins.

---

## 10. First files to write on disk (in order)

1. `games/hell-week/brief.md` (copy §§0–6)
2. `games/hell-week/cut-list.md`
3. `games/hell-week/theme.md` + `lighting.md` + `shelf.md`
4. Place folder / pack: Quiet Shore greybox disk + Wick part + 3 Ashwood
5. Services in §7 Wave 3
6. HUD three numbers
7. Tempter Night 2
8. Gift Day 3
9. Lighting rig
10. MCP log

Stop after a stranger can feed the wick and understand the dark in one minute.

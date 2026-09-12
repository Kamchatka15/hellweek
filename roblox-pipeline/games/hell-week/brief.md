# GAME BRIEF — Hell Week

> Input to the pipeline. Arrived as a packet (`inbound/HellWeek-ClaudePack.zip`, 2026-09-12) — Justin's brief in file form, adopted on the intake fast path. Sections 0–6 below are his design, verbatim from the packet's execution brief; the six-question table, hypotheses and ledger query were added at intake.
> Status: **ACTIVE TITLE** as of 2026-09-12 (Justin, in chat: "I'm creating a new game called Hell Week"). Fat Man Gets Rich is parked, not killed — before Gate A, no evidence recorded against it.

| Field | Answer |
|---|---|
| Working title | Hell Week |
| Slug | `hell-week` |
| Loop verb | **Survive** — pick up Ashwood → carry (cap 3) → feed the Wick |
| Hook (2 seconds) | The light thins and a tall silhouette is standing on the edge of it |
| Reason to open it tomorrow | **Tomorrow burns faster if you slacked or took the Gift** — plus a persisted best day |
| Session shape | **Sit-down**: a 7-day week is ~14 minutes at the candidate clock; a 3-day Pass 1 run is ~6–7 |
| Monetization | **Soft shop, not a door.** Three stubs (Wick Oil, Deep Pockets, Second Wind) drafted in `server/sku.luau`, wired to nothing, offered only after a Day-2 survive. G5 is Justin's click |
| Art seed | 99 Nights in the Forest as the visual bar: low-poly, dark ground, warm light, fog ring. Grey sand / black water / wick gold (`theme.md`) |
| Comps | 99 Nights in the Forest (the machine), DOORS + three others on `ccu-board.md` |

## What the first session must do

A stranger, with nobody in voice chat, can say after one minute and no speech: **"Feed the light. Don't go into the dark. Don't take the pile that looks too good."**

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
- Ring B (open at start — the extra size): **50–175 studs**. Scatter Ashwood, one ruined rowboat, pale tree clusters, grey flats. Day-1 fog wall at ~175. Place **HW-001 Obelisk** here (~90–120 studs from Wick, offset so it does not sit on the teach line). Black stone, gold glyphs, **one skull per face**, fire out the cap. Concept lock: `GrokBDownloads/HW-001_Obelisk_01/2d/HW-001-obelisk-v3-oneskull-34.jpg`. Cap flame: `2d/HW-002-fire-v1.jpg`. Not a second wick. Landmark only.
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


---

## Hypotheses this title is testing (from the packet, Wave 0)

1. **H1 — Kids can say the three-sentence gist after one minute without a narrator.** Settled by Gate A's comprehension test (`skills/playtest-comprehension.md`): 2 of 3 fresh testers describe feed-the-light / stay-in-the-light in their own words. *Refuted if* two of three describe a different game or cannot say what the Wick is for.
2. **H2 — The Day-3 Gift is understood as a trap by at least 2 of 3 Gate A kids.** Settled by the extra Gate A question, "what is the pile with the weird glow?" *Refuted if* two of three call it free fuel, or nobody notices it is different.

## Ledger query at intake (2026-09-12)

`evidence/ledger/` holds six records, all `loop_verb: collect` or `process`, none `survive`. Nothing matches this context directly. Two process records carry over regardless of verb: E-0003-class findings on getting code into Studio unattended (`tools/studio_sync.py`), and the run-01 rule that MCP `require` measures a second empty universe. No contradictions opened.

## Platform checks at intake

- **Gambling shape:** none. The Gift is free and its cost is stated; the shop is direct-buy only. The intake scanner's one gambling flag was the word "better" matching `bet*` (regex fixed in `tools/intake_zip.py`).
- **Owned names:** none in the design. Title, zone and every proper noun are original; "99 Nights" appears only as a comp. The PDF flag ("doge7") was a byte string inside a binary PDF, not text.
- **Coercion:** none. No timers that punish absence, no "invite N friends", no locked days.
- **Religious register:** settled answer §1.1 holds — nothing in `theme.luau` copy references scripture, salvation, or any parked place name.


## Owner amendments after intake

### 2026-09-12 — Opening act (Justin, in chat)
An opening act plays over the black at **every join**, skippable with a tap after 1.5 s (`shared/theme.luau` → `opening`, rendered by `src/client/OpeningAct.luau`): three narration lines (largest, pale), the four-line voice (bold horror face, blood-red with running drips), then "Somehow you know it means:" and the meaning in a quiet serif. The HUD holds any toast until the act ends, the character's controls are off while it plays, and the world fades in after.

This **reopens two of the brief's own rules on purpose**, by the owner: §4's "no paragraph, no cutscene in the first minute", and settled answer §1.1's register (the meaning names angels, heaven and bonds of fire — it is Old English verse, not scripture, but it is the register the settled answer kept off the tile). Recorded here so Gate A can weigh it: the act costs ~23 s of Day 1's 90 s clock when watched to the end, and the comprehension script should note whether kids skip it.

### 2026-09-12 — HW-001 Obelisk + no candles (Justin, packet `RB BUSINESS/HELLWEEK`, archived to `GrokBDownloads/HW-001_Obelisk_01/`)
Obelisk landmark in Ring B (~103 studs from the Wick at bearing right-of-centre from spawn), one skull facing the Wick, glyphs Neon gold, cap fire from HW-002, never fed. **No candles anywhere in Quiet Shore**: the bench's back-edge candle and the Wick's own wax head are both replaced with the same HW-002 fire jet on a stone lip. The Wick keeps its name and its light-radius mechanic; only its head changed. Built as pack data from the art bot's Blender script (`tools/obelisk_from_blender.py`), no mesh upload.

### 2026-09-12 — The obelisk IS the Wick (Justin, in chat: "there is no wick, the obelisk replaces the wick")
Supersedes the "landmark only, Ring B" lines of the HW-001 packet above. The obelisk stands at the origin and is the beacon: players feed it by walking into the gold ring around its 15.6-stud base, the cap fire (HW-002) is the light that holds the night, and the safe-radius light sits low on an invisible anchor so it reaches the sand. The post is gone; nothing in the copy says Wick any more (`names.beacon = "Obelisk"`, toasts "THE FIRE IS THE ONLY CLOCK" / "CARRY IT TO THE OBELISK"). Ring A's inner edge moved from 9 to 14 studs and the teach path aims at the feed ring, not the centre; the bench moved to 16 studs out to clear the base corner. Engine side: a beacon can now be handed over as parts with a named flame core (`config.beacon.parts` / `flameName` / `feedRadius` / `lightOffset`), which is generic. The sim's slacker row dipped (P(see Day 4) 58% → 44%) because every trip is a few studs longer — a G2 number, not a Pass 1 one.

### 2026-09-12 — Shorter obelisk, pentagram floor, bench to the fog edge (Justin, in chat)
Obelisk scale ×2 (≈18 studs) so the cap flame sits in frame from spawn with more perspective. A charcoal stone slab (radius 14) under the base carries a **gold pentagram inlay** (five Neon lines + a ring); the slab is the feed zone. This reopens settled answer §1.1's "no pentagram logo" — owner's call. The bench moved to just inside the Day-1 fog wall (~157 studs from the obelisk, right-of-centre from spawn), read from "just inside zone 1"; if "zone 1" meant Ring A, it is one number in `world.luau` (`benchAt`).

### 2026-09-12 — Bigger pentagram, and the obelisk has to glow (Justin, in chat)
The star now has a 24-stud outer radius on a 30-stud stone, so the obelisk stands **inside** the pentagram rather than covering its centre. Spawn moved back to 48 studs and Ring A's inner edge to 32 so the stone is a walk, not a step, and no Ashwood lands on it.

**Lighting, as a rule rather than a number:** dim is the register, black is a bug. The sun is weak (1.1, ClockTime 21.2) and ambient is low so distance falls off honestly; the obelisk is what a player reads by. A light *inside* a solid prop lights nothing, so four pale-warm anchors ring the shaft and wash its faces and five sit at the star tips and pour onto the sand. The beacon's own light keeps a high brightness floor (0.7 of full at zero fuel) because fuel is supposed to change how **far** the light reaches, not whether there is any. The stone stays charcoal (38,38,45) and the wash is pale, not orange — warm light on grey stone reads as sand and kills the gold.

### 2026-09-12 — Five worlds, one per pentagram point (Justin, in chat)
The pentagram has five points, so the game has five worlds. Picked for three things: each has to read differently at 200px, each has to be a different **kind** of fear rather than the same night repainted, and each has to run on the engine that already exists. The order is the curve — cover is taken away, then the ground, then the horizon, then the fire itself turns on you.

| # | World | What it takes away |
|---|---|---|
| 1 | **The Quiet Shore** | nothing — it is the teach. Grey sand, black water, a fog ring. |
| 2 | **The Still Wood** | **sightlines.** Dead standing trees break the light-line, so the thing on it is only ever half visible. |
| 3 | **The Drowned Quarter** | **the ground.** Flooded ruins; fuel floats and drifts, and light does not cross water the way it crosses sand. |
| 4 | **The Long Salt** | **distance.** White flats under a black sky, the palette inverted and the only bright world. You watch it come for a full minute across open ground. |
| 5 | **The Kiln** | **the fire.** The one warm world: fuel is everywhere and burns four times as fast, and ember light on every surface makes the safe circle almost unreadable. |

Point 1 faces spawn; the rest run clockwise. A point's triangle is **dark** while its world is locked, **red** once opened, **green** once mastered. Mastering means clearing that world's **seven trials**, listed in a pull-down at the upper right with the finished ones struck through. Clearing all seven opens the next world.

**Pass 1 reality:** only The Quiet Shore exists, and only its seven trials are wired to real signals (first feed, hold night one, push the fog back, reach day three, reach day three having taken no Gift, reach day three untouched, last the week). The other four worlds are data so the stone has something true to draw. Building any of them is its own wave. Progress is per player and persisted, so in co-op everyone reads their own stone.

### 2026-09-12 — The offering, and the bench is cut (Justin, in chat)
"You place offerings in at the obelisk, and it returns finished or modified products to you." Built as a stone bowl on the sand beside the pentagram — in plain sight from spawn, **off** the straight walk to the fire. Walk in carrying a sack and the obelisk takes it: nothing burns, the light does not grow, and at dawn it lays out more than it took, packaged into the best tiers the total affords. **Ashwood (1) → Emberwood (3) → Heartwood (8)**, at ×1.6, so three Ashwood offered come back as an Emberwood and an Ashwood.

**Why a delay and not an instant swap:** it turns the core verb into the game's own question. Fuel handed over is fuel not burned tonight, so an offering is a bet that there will be a tomorrow — which is the same bet the Gift asks in reverse. One line in `config.offering` if instant is wanted instead.

**It is not a second verb.** You still walk into a thing carrying a sack. What changed is that there are now two things to walk into, and the decision is where you stop. The first build put the bowl directly on the walk-in line and it became a toll booth that took the sack of anyone heading for the fire; a few steps to the side turned the same object into a choice.

**The craft bench is cut** — the obelisk absorbed it. A bench and an offering bowl are two answers to one question, and the bowl is the one attached to the thing the whole game is about. The art stays on disk.

### 2026-09-12 — World 1 is a desert, and the obelisk is the workbench (Justin, in chat)
"Build out the first biome and it should be the desert biome first… as large as a biome in 99 Nights… with rocks and trees and cactus to make the needed supplies. Also cactus convert to water… remember the obelisk works as the workbench."

**The Ashen Waste** replaces The Quiet Shore as world 1: a **700-stud disk** (4× the old area, a 22-second walk from the obelisk to the edge) of bleached dead sand. 1,156 generated scenery parts — dunes, rock mesas, dead trees, scrub, half-buried ruins, bone scatter, and one dry wash cutting across to give the eye a line — from `tools/gen_desert.py` on a fixed seed, so it is reproducible and diffable and needs no mesh upload.

**Three resources instead of one.** Deadfall gives Ashwood (burns), cactus gives Cactus, boulders give Stone. Cactus and stone do **not** burn: the obelisk is the only thing that turns them into anything, which is what makes it the workbench rather than a fire with a bowl next to it.

**Water is an ingredient, not a meter.** A desert invites a thirst bar and the brief already parked that idea, for the right reason. Instead: `2 Cactus → 1 Water`, and water is what every worthwhile recipe needs — `Water + 2 Ashwood → Emberwood`, `Water + Emberwood → Heartwood`, `Water + 2 Stone → Wardstone`. Recipes cascade in one dawn, so a sack of cactus and wood comes back as tempered fuel without the player knowing the chain.

**The Wardstone ties the workbench to the wedge.** Fed to the fire it lifts one Weight, so the Gift becomes a three-way choice: leave it, take it and pay tomorrow, or take it and spend a day's cactus undoing it.

The sack now holds **typed items, six slots**, and the HUD shows what is in it rather than a fullness bar — "4/6" cannot tell you whether you have the two cactus a recipe wants.

### 2026-09-12 — Four worlds, the fifth point is the offering table (Justin, in chat)
"Each point points to a biome/zone, now just fill in that point/triangle inside the pentagon… lets have 4 biomes to start and use one of the points of the pentagram to hold the offering table."

**Four worlds on four points, the fifth is the table.** Point 1 faces spawn and is the world you are standing in; points 2–4 run clockwise; point 5, right of centre, is the offering table. Dropping to four cost **The Long Salt**, the weakest of the five once a desert took slot one — both are open arid ground, and "no cover at all" reads as less of a world than a wood, a flood or a furnace. Kept here in case it comes back.

**The triangles were pointing the wrong way.** They filled the star's points apex-INWARD at the obelisk, which is the opposite of what a point means. Rebuilt as a fan of tapering strips rather than a pair of wedges: a WedgePart's right-angle corner is a convention that is easy to get backwards, and a fan cannot be got backwards.

**The offering table replaces the standalone bowl.** It is the point-5 triangle itself — a raised stone surface with a gold lip — so the pentagram now carries the whole game: four futures and the place you trade for them. The feed zone shrank from the whole 30-stud stone to a 10-stud circle at the obelisk's foot, because standing on a point must not also be feeding the fire.

**The whole world is lit.** Not a pool with a void around it: from anywhere on the 700-stud disk you can see the sand, the dunes and the mesas on the horizon. Contrast is kept by the obelisk being the only warm light and the only thing that gets brighter, rather than by taking light away from everything else.

**The obelisk was visibly low-resolution and is rebuilt** (`tools/gen_obelisk.py`, superseding the Blender translation): 52 thin shaft slices so the taper is smooth instead of a staircase, a real 22-slice pyramid cap, five fine base steps, and four faces of gold glyph marks recessed into dark channels that follow the taper. **Skulls removed** — at this scale under a shaft wash they read as smudges, and if they return they need to be lit from their own side.

### 2026-09-12 — The desert is the bright world (Justin, in chat)
"Make the 1st biome the desert biome brighter than the initial area."

Day and night are now **two complete rigs**, not one rig with the lamp turned down (`world.lighting` and `config.night.rig`, tweened by `ContentLoader.tweenLighting`). That is what lets a world look like a different place after dark rather than the same place dimmed.

**Day: The Ashen Waste is bright and exposed** — brighter than the camp at its centre. Heavy sand haze (Haze 5 on a bone-coloured Atmosphere) bleaches the sky to white-hot instead of the postcard blue Roblox gives by default, saturation is down a third, and the sun sits low at 7.1 for long hard shadows. The camp reads *darker* than the waste because the pentagram slab is dark slate, the obelisk is charcoal, and its warm lights are turned down to 12% by daylight. So by day the obelisk is a cold monument on a hot plain.

**Night is its own world.** The sky goes out, the haze thickens and cools to blue-grey, the bloom threshold drops so gold and fire are allowed to burn, and the camp's warm lights come back to full. The same monument that read cold and exposed at noon is the only warm thing on the waste — which is the whole point of the game, and it is now something the player watches happen rather than something the design asserts.

Brightness is per-world data, so the later biomes are free to be dark ones.

### 2026-09-12 — The opening act, flipped (Justin, in chat)
"Change the intro text to 'You must of fell asleep in class…' you hear a voice. Only use the english text, make the text the bloody red and larger. Put the egyptian text beneath and smaller… make it not needed to read, put more to project aura."

The English **is** the voice now. It is the biggest thing on the screen, blood red, in the horror face, with the drips — the line the player actually reads. The old tongue moved beneath it at a third the size and a dim red-grey: it is there to be **felt**, not read, and a player who skips straight past it has missed nothing. The "Somehow you know it means:" bridge is gone, because there is nothing left to bridge.

Measured on screen: narration 25px pale, voice 41px at `rgb(176,6,6)`, echo 13px at `rgb(104,74,74)`.

**One correction, flagged rather than made silently.** The line was written "You must of fell asleep in class" and ships as **"You must've fallen asleep in class..."** — in narration a stranger reads in their first three seconds, the original reads as a typo rather than as a voice. One line in `shared/theme.luau` to revert if the rougher voice was the intent.

watch started 18:48:09Z

## T+0 — spawn, Day 1

- **Day counter top-centre**, small italic serif, low contrast. Not a shouted number.
- **Dead campfire dead centre of spawn**, logs stacked teepee, ring of stones.
- **Two loose logs lying within ~10 studs of the fire.** The tutorial is the level design.
  Nothing tells you to pick them up; they are just there, next to the obvious thing.
- HUD bottom-left: one amber bar, one blue bar. Small. No numbers.
- **No fire-fuel number in the HUD.** Confirms the teardown: fuel is read at the fire, not on screen.
- Fog wall ~60-80 studs out. Trees dissolve into it. The fog IS the map boundary.
- Flat overcast daylight, no harsh sun, no strong shadows.

## T+1 — "Equipped class Assassin"

**Subject is a veteran, not a stranger.** Assassin is the 500-diamond class. Everything seen
here is a returning-player read, not a first-run read. Label every finding accordingly.

- **The class is announced on screen at run start**: big gold emblem, yellow text, centre screen.
  This is the single most important thing seen so far. It is the between-runs meta loop *being
  shown to the player in the first seconds of the run*. The persistence is not quiet. It is a
  cutscene beat.
- **Hotbar bottom-centre, 4 slots**, icons only, selected slot outlined gold. Food, axe, two tools.
- Currency readout top-left next to the chat, yellow.
- Trees near the base are far larger than the starter trees at spawn.
- A built base structure is visible to the right. Base-building is live in this server.

## T+2 — build mode on Day 1

- Carrying a wooden plank/sign held out in front of the avatar. **"Undrag" button bottom-right.**
  Base building is a first-class verb with its own dedicated UI, not a menu.
- Placement is drag-in-worldspace, not a grid menu. You hold the thing and walk it into position.
- **A veteran's first move on Day 1 is building, not feeding the fire.** The survival loop is the
  floor; the base is what he actually came for. This is the second clip type, confirmed live.
- Class emblem still on screen several seconds in. It lingers.

## T+3 — placement camera

- Camera pulls to near top-down while placing. Chat auto-hides. The game gets out of the way
  for building without a mode screen or a menu.
- Still Day 1 well over two minutes in, consistent with the 3:00 day.

## T+4 — Roblox escape menu opened

- Player list shows **one player. This is a solo run.** Difficulty is whatever solo scales to.
- A **"Sprint" button sits bottom-right** in the game HUD. Sprint is a first-class movement verb
  with a permanent on-screen control, not a hidden shift key. Hell Week has no sprint at all.
- Nothing else here is game content; the rest of this frame is Roblox core UI.

## T+5 — fire lit, and the safe radius is DRAWN

Three findings in one frame, and the first is the most important thing seen all session.

1. **The safe radius is a dashed line painted on the ground.** A dotted arc curves across the grass
   at the edge of the fire's zone. You do not infer the boundary from light falloff. You can see
   exactly where it is, in daylight, from any angle, and you can watch it move when the fire levels up.
   **Hell Week draws nothing.** Our safe radius exists only as light falloff, which means at noon it
   is invisible and at night it is a guess. This is a direct, cheap, high-value copy.
2. **The fire is lit and small.** Level 1 flame is modest; the spectacle is the radius, not the blaze.
3. **The bottom-left bar drains and changes colour**, amber when healthy, red when low. Colour is the
   alarm, not a number. No digits anywhere on it.

Also: loose logs scattered on the ground as world pickups, not in nodes to be chopped. Two ways to
get wood, one slow and one free.

## T+6 — full-resolution read of the whole HUD

The most informative frame of the session. Six separate findings.

### 1. The fuel warning is a lowercase sentence, not a number
Centre screen, large, red, in a friendly handwritten italic: **"the campfire is almost out"**.
No percentage. No gauge. No jargon. A nine-year-old reads it at a glance while running.
The alarm is *language*, and the language is deliberately casual and lowercase.

### 2. The carry counter is enormous and lives on the avatar
**"5/5"** rendered in giant red-and-white outlined numerals immediately left of the character,
roughly a sixth of the screen height. Not a corner readout. When your hands are full, the number
is the biggest thing on screen. Hell Week puts the sack count in the HUD corner, which is quieter
than this by an order of magnitude.

### 3. Every contextual verb shows its keybind in a key cap
Bottom-right: **"Sprint  SHIFT"** and **"Unstore  F"**, each with the key drawn as a yellow cap.
Verb on the left, key on the right. Hell Week's PICK UP / ACTION / INFO already does this, so this
is a confirmation that our button design is the platform-correct one. Keep it.

### 4. "Unstore" means there is an in-run storage system
Containers at base hold items between trips. That is a within-run inventory loop sitting on top of
the carry cap, and it is what makes a base worth building. Hell Week has a carry cap and nowhere
to put anything down.

### 5. Hunger is an icon and a colour, never a digit
Bottom-left bar, orange, fork-and-knife glyph in the cap. No label, no number, no percentage.

### 6. Hotbar slots are numbered with their own keys
Four slots, each showing its digit. Selected slot outlined white.

### Scene notes
Built wooden deck, a large storage container, a crafting bench with logs on it, loose weapons on
the ground, sheep wandering as live resources. The base is a real place with furniture.

## T+7 — the carry counter is always on

Counter now reads **0/5**, down from 5/5, beside a green storage container. So:

- The giant carry number is **permanently displayed next to the avatar**, not only when full.
  It is diegetic HUD: it follows the character, it is always legible, and it is the single
  loudest element on screen at all times.
- Storing at a container empties the sack. Store, walk out, fill, walk back. The base is the
  reason the carry cap of 5 is not merely annoying.

### Open timing question
**Day 1 has now lasted well over six minutes of wall clock.** The public sources say a day is
3:00. Either the sources are wrong, the first day is extended, or the counter only advances on
some condition such as the fire surviving the night. Watch for the rollover to Day 2.

## T+8 — two tiers of prompt, and this is the one we got wrong

At a shack door: a small dark pill floating **in world space at the door itself**, containing a key
glyph and the words **"Open Door"**. Standard Roblox proximity-prompt placement.

So 99 Nights runs **two distinct prompt tiers**:

| Tier | Where it lives | Examples |
|---|---|---|
| Object verbs | Anchored on the object, in the world | Open Door, and by extension chop / loot / feed |
| Global verbs | Fixed in the screen corner with a key cap | Sprint, Unstore |

**Hell Week put everything in tier two.** Our PICK UP / ACTION / INFO buttons sit in the corner and
describe whatever happens to be nearest. That works, and the Gate A worry has always been whether a
stranger finds them. This frame shows the answer the genre already settled on: the corner is for
verbs that are always available, and anything attached to a specific object should be labelled **on
that object**. A prompt floating on the obelisk saying FEED is self-teaching in a way a corner
button never is.

Still Day 1.

## T+9 — inside a lootable shack

### Loot is named where it lies
An item on the floor is outlined in white and carries a floating handwritten label: **"Old Radio"**.
Not "press E to pick up". The **name of the thing**. You learn the game's whole item vocabulary by
walking past objects, before you ever open a menu. Hell Week's pickups are silent until you are in
range of the corner button, so a player never learns what anything is called.

### The corner verb stack is contextual and stacks
Bottom-right now shows three at once: **Sprint SHIFT**, **Drag**, **Store F**. Earlier it showed
Sprint and Unstore. The stack grows and shrinks with context, keeping every currently-legal verb on
screen with its key. It never shows a verb you cannot use.

### Currency is visible mid-run
A small gold coin glyph reading **5** sits bottom-left under the hunger bar. Quiet, but present, so
the meta currency is always in the corner of your eye while you play.

### Shack interiors are hand-furnished
Stone floor, shelves with bottles. Interiors are places, not loot boxes. Hell Week's teepees
currently hold a chest and nothing else.

Still Day 1.

## T+10 — the safe ring, seen whole

Clear view of the campfire from outside the zone. The safe area is a **complete dotted ring painted
on the grass**, fully visible in flat daylight from well outside it, with the lit fire, a crafting
bench and a supply crate inside it. A signboard stands just outside.

This upgrades the T+5 finding from "a dashed arc" to the headline of the whole session:

> **The safe zone is a drawn circle, not an inferred one.** It is legible at noon, from outside,
> at distance, with no light cue involved. It tells you where safety ends before you ever need to
> know, and when the fire levels up you watch the circle grow.

Hell Week has no equivalent mark at all. Ours is light falloff only, which means in the desert at
midday the safe boundary is literally invisible, and at night it is a judgement call made while
something is chasing you. This is a small build and the largest single readability win available.

### Correction to the teardown
**Day 1 has now run past twelve minutes of wall clock.** Every public source says a day is 3:00 and
a night is 1:30. That is not what is happening here. Either the sources are wrong, or the first day
is much longer by design, or the counter advances on a condition rather than a timer. Flag the
3:00/1:30 row in the teardown as **disputed by observation** and do not tune Hell Week's day length
against it until it is resolved.

## T+11 — "FIRE REACHED 100%. The Map has grown bigger"

A parchment plaque slides in centre-screen with exactly that sentence, and the fog visibly
retreats: trees that were grey smears two minutes ago are now solid and lit.

Four things at once, and this is the genre's core teaching moment caught on camera.

1. **Fuel is a percentage, and reaching 100% is an event.** Not a level number, not a bar filling
   quietly. A threshold with a name.
2. **The reward is announced as a change to the world, not a change to a stat.** "The Map has grown
   bigger" is a sentence about the place you are standing in. Nobody is told their radius increased
   by N studs. Hell Week's beacon level-up is currently a light change and a toast about the beacon.
   Reframe it as what happened to the *world*.
3. **There are two distinct toast styles**, and the split is by meaning:

| Style | Meaning | Seen |
|---|---|---|
| Red handwritten italic, no background | Danger | "the campfire is almost out" |
| Parchment plaque, dark serif | Progress and reward | "FIRE REACHED 100%. The Map has grown bigger" |

   Hell Week has one toast style for everything. Splitting danger from progress is nearly free and
   it means a player learns which messages to panic about.

4. **The fog peel is the reward.** Not a number, not a badge, not currency. The world literally gets
   larger and you can see it happen from where you stand. This is the thing Hell Week's biome swap
   already does at world scale, but we do nothing at all at the *within-run* scale.

## T+12 — out in the peeled map, light dropping

- He immediately walks **into the ground the fog just gave him**. The reward is consumed within
  seconds of being granted. Map peel is not a cosmetic; it is the next thirty seconds of play.
- New terrain carries different resources: dark green shrubs and grey rock nodes, not just trees.
  **The peel reveals new resource TYPES, not more of the same.** That is why it is worth wanting.
- **A deer stands in the open**, tan, low-poly, motionless, at middle distance. Not fleeing, not
  approaching.
- The whole frame is materially darker than any earlier one. Dusk is starting.
- He has switched to hotbar slot 3, a blade. Corner verbs now read Sprint and **Drop**.

## T+13 — NIGHT, and it is not black

Night lighting caught clean. Two findings, one of which settles an argument we already had.

### 1. Night is navy, and the ground keeps its colour
The sky and air go deep blue. The grass still reads green. Props still read as their own colours,
just desaturated and dimmed. Silhouettes are fully legible at fifty studs with no light source.
**It is dark enough to feel like night and bright enough to keep playing in.**

This is exactly the note already given on Hell Week: dimness is good, darkness is worthless. Here is
the genre leader agreeing. Our night rig should be judged against this frame: can you still identify
a rock, a tree and a cactus by silhouette and residual colour, with no beacon in view? If not, our
night is too dark.

### 2. Landmarks are how a peeled map stays interesting
A **crashed aeroplane**, rusted, half-buried, several times the height of the player, with loot
scattered around its base. A silhouette you can navigate toward from a long way off.

The peel gives you ground; the landmarks give you a *reason* and a *destination*. Hell Week's desert
has teepees, which are small and repeat. It has no single large strange object you would walk toward
just to find out what it is. One per biome would carry the whole exploration loop.

### 3. Night-1 mercy, confirmed by eye
He is **outside the ring, at night, looting, and nothing is attacking him**. The teardown's night-1
mercy row holds up. Hell Week's stalker `watch` mode on day 1 is the right call.

## T+14 — chest at the landmark

An **"Open Chest"** object-anchored prompt on a chest at the foot of the crashed plane, at night,
carry at 4/5. Water visible in the middle distance.

Confirms the pattern: **chests live at landmarks, and the landmark is the advertisement for the
chest.** You do not hunt for containers; you walk toward the big strange silhouette and the reward
is waiting under it.

Hell Week puts chests inside teepees. Teepees are small, they repeat, and they read as scenery from
a distance. Same mechanic, far weaker pull. Pairing each biome's chests with one large landmark
would cost nothing mechanically and change how the map feels to cross.

## T+15 — the crash site tells a story with props

Chest opened. The loot cluster around the wreck is a **fuel canister, a clay jug, a wooden chest and
scattered crates** — not a generic container spawn. The props are specific and they imply what
happened here. The canister is also a high-tier fuel item, so the landmark's *story* and its
*mechanical payoff* are the same object.

Landmark design rule to steal: **the best loot at a landmark should be the thing that landmark would
plausibly contain.** A crashed plane has fuel. Hell Week's desert should have landmarks whose loot
explains them.

Still **Day 1**, through a full night. So the counter increments at dawn and a "day" spans one
daylight plus the night after it. That still leaves the observed cycle far longer than the 3:00/1:30
the public sources claim. Dispute stands.

## T+16 — the carry counter turns red, and the fire is a compass

Two small, excellent details to close on.

### The counter changes colour at full
**5/5 is rendered in red.** Earlier, 0/5, 2/5 and 4/5 were all white. The same element carries two
messages: how much you have, and *go home now*. No second icon, no toast, no sound needed. A player
who never reads a word of UI still learns "red means walk back".

Hell Week's sack readout is a static colour at every value. Making the number change colour at the
cap is a one-line change and it is the cheapest legibility win on this whole list.

### The base fire is visible from across the map at night
A single small orange point glows in the far distance across otherwise dark terrain. That is the
campfire, and it is the only warm light in the frame. **The fire is the compass.** You never need a
minimap because the thing you are trying to protect is also the thing you navigate by.

Hell Week's obelisk flame already does this in principle. Worth verifying at desert scale that the
cap fire is actually visible from the far edge of the biome at night, because the desert is four
times the area the lighting numbers were originally set for.

## T+17 — the ring is visible at night too

Returning to base at 5/5 red, the **dotted safe ring is clearly visible on the dark grass**, reading
as a pale dashed curve. So the ring is a permanent painted decal, not a daylight-only effect and not
a light artefact. It is there at noon, it is there at midnight, and at night it is the line you are
running to get behind.

That makes it the highest-value item on the whole list. It is one decal and it solves "where is safe"
forever, in every lighting condition, for every player, with no words.

## Session close

Ended while still on Day 1, at night, subject alive and returning to base with a full sack.
No death, no lobby, no shop and no dawn observed.

## T+18 (post-close addendum) — the fuel readout is proximity-triggered

Caught on a final frame, standing at the campfire:

> **level 3 progress: 77/100**, with a wide green progress bar beneath it.

This corrects the earlier "fuel is not in the HUD" reading, and the corrected version is better than
either extreme:

- The fuel readout is **not** permanently on screen, and it is **not** absent. It **appears when you
  approach the fire** and is gone the rest of the time. Contextual, exactly like the verb stack.
- It carries a **named level**, an **explicit fraction**, and a **bar**. All three. When the
  information is relevant, they do not skimp on it.
- The copy register is the same lowercase plain English as the danger toast: *level 3 progress*, not
  "FUEL LV.3 77%".
- **The flame itself has visibly scaled** with level. The level 1 fire was a small flicker; this
  level 3 fire is large, bright and throws real light. The prop is the gauge you read from distance;
  the numbers are the gauge you read up close.

That is a two-tier readout matching the two-tier prompt system: coarse and diegetic at range, precise
and numeric in contact.

# Session 2 — same sitting, later. Day 5.

He kept playing. Day 5 produced four findings the first stretch never reached, including the one
that resolves the timing dispute.

## T+19 — the day-length dispute is RESOLVED

**Day 5.** Days 2 through 5 passed in a fraction of the wall clock that Day 1 consumed on its own.

So the answer is: **Day 1 is a long tutorial day, and the normal cadence starts afterwards.** The
public 3:00 / 1:30 figure is plausibly right for days 2 and beyond; it is simply not what Day 1 does.
That is a deliberate and very good design choice, and one Hell Week does not make: our Day 1 runs on
the same 100-second clock as every other day.

**A first day that is several times longer than the rest is the single most forgiving onboarding
device in the genre.** A stranger gets to be bad at the game for as long as they need to, with no
night pressure, and the real clock only starts once they have fed the fire at least once.

## T+20 — night events are NAMED and TELEGRAPHED, with a skip

A parchment scroll, centre screen:

> **"A mysterious group makes its way towards your Campfire"**

with a large green **SKIP** button beneath it, and small lights visible approaching in the dark.

Three things to steal:

1. **The threat is announced before it arrives.** Not a jump scare. You are told what is coming and
   given time to prepare. Dread is manufactured by the warning, not by the surprise.
2. **The threat has a name and a story**, and the copy is deliberately vague: *a mysterious group*.
   It is scarier for not being specified.
3. **There is a SKIP button on their own cutscene.** They know a player on run twenty does not want
   the announcement, and they do not make them sit through it. Hell Week's opening act has a skip
   after 1.5 seconds, which is the same instinct. Apply it to every repeated beat, not just the intro.

Hell Week's stalker simply shows up. Naming our night event and announcing it one beat early is
almost free and it converts a scare into suspense.

## T+21 — the HUD grows with the run

- **Hotbar has expanded from 4 slots to 8.** Capacity is itself a reward, and the HUD visibly grows
  to show it. Hell Week's sack cap is a number that changes; theirs is a row that gets longer.
- **Top-right now carries a map or compass widget and a second progress bar.** The early-run HUD
  genuinely was sparser; UI is introduced as the player earns the need for it.

**Progressive HUD disclosure.** A new player sees almost nothing. A day-5 player sees a map, eight
slots and two bars. Hell Week shows its whole HUD on the first frame of the first run.

## T+22 — a new biome by Day 5
Dark red rock walls, a canyon. The run has moved somewhere visually unrecognisable from the starting
forest. Confirms the biome progression is a within-run journey, not only a between-run unlock.

## T+23 — the carry cap tripled

Counter reads **8/15**. On Day 1 it was **5**. The sack cap has gone from 5 to 15 inside a single run.

This is the clearest reward-structure finding of the whole session. **Carry capacity is the main
progression axis**, and it is expressed in the loudest element on screen. Every trip you make, the
number reminds you both where you are and how far you have come. Hell Week's sack cap is fixed for
the entire run.

Combined with T+21, the pattern is: **the HUD itself is the progress bar.** Slots grow from 4 to 8.
Cap grows from 5 to 15. A map appears. None of it is announced in a menu; you simply notice you have
more room than you used to.

## Session 2 close
Ended on Day 5, inside a lit interior, opening a chest, alive, cap 15, eight hotbar slots.
No death observed in either stretch. The meta loop, shop, lobby and death screen remain unobserved.

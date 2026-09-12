# What watching 99 Nights changed — ranked add-list for Hell Week

> Source: one ~20-minute live observation, 2026-09-12, logged frame by frame in
> `research/patterns/watch/99nights-live-log.md`. Timings, shapes and reactions only. No assets.

## Read this caveat before using anything below

| Condition | What was actually observed |
|---|---|
| Subject | A **veteran**, Assassin class equipped, a 500-diamond unlock. Not a stranger |
| Party | **Solo**, one player in the server |
| Span | One session, roughly 20 minutes, all of it **Day 1** including a full night |
| Not seen | Death, the death screen, the lobby, the team-size picker, the shop, a badge, dawn |

So this session is a strong read on **moment-to-moment legibility** and a blank on **the meta loop**.
Four of the six gaps in `loop-gaps.md` are untouched by it. Those still need a second session that
ends in a death.

## Tier 1 — cheap, and they fix legibility

These are the session's real haul. Every one is small, and every one attacks the same weakness:
Hell Week makes the player infer things that 99 Nights simply draws.

### 1. Draw the safe radius as a ring on the ground
The single most copyable thing in the game. A dotted circle is painted on the terrain around the
fire. It is legible in flat noon daylight from far outside it, and it is legible at midnight on dark
grass. When the fire levels up you watch the circle grow.

Hell Week draws **nothing**. Our safe radius exists only as light falloff, so in the desert at midday
the boundary is invisible, and at night it is a guess made while being chased. One decal, and "where
is safe" is solved permanently in every lighting condition without a single word of UI.

### 2. Make the carry counter loud, put it on the avatar, and turn it red at cap
Their count floats beside the character at roughly a sixth of the screen height, always on. It reads
white at 0/5, 2/5 and 4/5, and **red at 5/5**. One element, two messages: how much you have, and go
home now. A player who reads no UI at all still learns that red means walk back.

Ours sits quietly in a HUD corner at a constant colour.

### 3. Split toasts into two styles by meaning
| Their style | Meaning | Observed copy |
|---|---|---|
| Red handwritten italic, no panel | Danger | *the campfire is almost out* |
| Parchment plaque, dark serif | Progress and reward | *FIRE REACHED 100%. The Map has grown bigger* |

Hell Week uses one style for everything, so a player cannot tell at a glance which messages to panic
about. Note also the register: lowercase, plain, no jargon, no percentage in the danger line.

### 4. Announce progress as a change to the world, not to a stat
"The Map has grown bigger" is a sentence about the place you are standing in. Nobody is told a radius
increased by N studs. Hell Week's beacon level-up is a light change plus a toast about the beacon.
Rewrite it as what happened to the world.

### 5. Move object verbs onto the objects
They run two prompt tiers. Object verbs float on the object in world space, as a pill with a key
glyph: **Open Door**, **Open Chest**. Global verbs sit in the screen corner with a key cap: **Sprint
SHIFT**, **Store F**, **Drag**, **Unstore F**. The corner stack grows and shrinks with context and
never shows an illegal verb.

Hell Week put **everything** in the corner. Our PICK UP / ACTION / INFO design is confirmed correct
*for global verbs*, so keep it. But a prompt floating on the obelisk reading FEED teaches itself in a
way a corner button never will, and that is exactly the Gate A worry we have been carrying.

### 6. Name loot where it lies
Items on the ground are outlined and carry a floating handwritten label with **the item's name** —
"Old Radio" — not "press E". You learn the entire item vocabulary by walking past things, before you
open a single menu. Hell Week's pickups are anonymous until you are in range of the corner button.

### 6b. Two-tier fuel readout: the prop at range, the numbers in contact
Caught at the very end of the session, standing at the fire: **"level 3 progress: 77/100"** with a
green bar, appearing only on approach. Named level, explicit fraction and bar, all three, but only
when you are close enough for it to matter. At distance you read the **flame itself**, which has
visibly scaled from a small level-1 flicker to a large bright level-3 blaze.

This supersedes the cruder "fuel is not in the HUD" note. The rule is: **coarse and diegetic at
range, precise and numeric in contact.** It mirrors their two-tier prompt system exactly.

Hell Week shows the obelisk's fuel in the permanent HUD, which is the one option they rejected.

## Tier 2 — structural, worth doing, not free

### 7. One large landmark per biome, with loot that explains it
A rusted crashed aeroplane, several times player height, visible from a long way off, with a chest, a
**fuel canister**, crates and pottery at its base. The landmark's story and its mechanical payoff are
the same object: a crashed plane has fuel.

Hell Week's desert has teepees. They are small, they repeat, and they read as scenery at distance.
Same mechanic, far weaker pull. One strange large silhouette per biome would carry the exploration
loop on its own.

### 8. Give the base somewhere to put things down
"Store" and "Unstore" at base containers. That is what makes a carry cap of 5 generate *trips*
instead of *annoyance*, and it is most of why building a base is worth doing. Hell Week has a carry
cap and nowhere to unload.

### 9. Sprint, with its key shown
A permanent corner control. We have no sprint at all, and our desert is four times the area the
movement was originally tuned for.

### 10. Show the meta currency during the run
A small gold coin glyph reading 5, bottom-left, under the hunger bar. Quiet but always in the corner
of the eye.

## Tier 3 — the meta gap, now confirmed from the other side

### 11. Announce carried-over power at run start
Within seconds of spawning: a large gold emblem and yellow text, **"Equipped class Assassin"**,
centre screen, lingering. The between-runs meta loop is not a quiet stat. It is a **cutscene beat at
the top of every single run**.

This sharpens gap 1 in `loop-gaps.md`. The problem was never only that Hell Week carries nothing
between runs. It is that even once it does, we would have to *show* it this loudly for it to do any
work. Persistence the player is not told about buys nothing.

## Corrections to the teardown

| Row | Was | Now |
|---|---|---|
| Day 3:00 / night 1:30 | Stated as fact from public guides | **Disputed by observation.** Day 1 ran past fifteen minutes of wall clock including a full night. Do not tune Hell Week's day length against the old numbers until resolved |
| HUD density "medium, four numbers" | Listed as a thing to avoid | **Wrong emphasis.** The playing HUD is one hunger bar with an icon and no digits, a small day counter, the carry number, and a contextual verb stack. Fuel appears only on approach to the fire, and then in full detail. The lesson is not "fewer numbers", it is **make the numbers contextual** |
| Night look | Not verified | **Navy, not black.** Grass keeps its green, props keep their colour desaturated, silhouettes read at distance with no light source. Dark enough to feel like night, bright enough to keep playing. This settles our own dimness-versus-darkness argument with evidence |
| Night-1 mercy | From guides | **Confirmed by eye.** Outside the ring, at night, looting, nothing attacked. Our stalker `watch` mode on day 1 is right |


## Added after a second stretch, same sitting, reaching Day 5

Four more, and the first is arguably the most important single item on this page.

### 12. Make Day 1 several times longer than every other day
Day 1 consumed more wall clock than Days 2 through 5 combined. **Day 1 is a long tutorial day and
the real cadence starts afterwards.** This also resolves the 3:00/1:30 dispute: that figure is
plausible for later days and is simply not what Day 1 does.

A stranger gets to be bad at the game for as long as they need, with no night pressure, and the
clock only really starts once they have fed the fire. It is the most forgiving onboarding device in
the genre and it costs one number. **Hell Week runs Day 1 on the same 100-second clock as Day 7.**

### 13. Name and telegraph the night event, and put a SKIP on it
> *"A mysterious group makes its way towards your Campfire"* — parchment scroll, centre screen,
> with a green SKIP button, while lights approach in the dark.

The threat is announced before it arrives, it has a name, the name is deliberately vague, and a
veteran can skip the announcement. Dread comes from the warning, not the surprise. Hell Week's
stalker just appears.

### 14. Let the HUD grow with the run
Hotbar went from 4 slots to 8. A map widget and a second bar appeared top-right. New players see
almost nothing; a Day 5 player sees all of it. **Progressive disclosure.** Hell Week shows its
entire HUD on the first frame of the first run.

### 15. Make carry capacity the progression axis
The cap went from **5 to 15 within one run**. The single loudest element on screen doubles as the
progress meter, so every trip tells you how far you have come without a menu or a stat screen.
Hell Week's sack cap is fixed for the whole run.

Taken together, 14 and 15 say the same thing: **the HUD is the progress bar.** Nothing is announced;
you simply notice you have more room than you used to.

## What to do next

1. Build tier 1. It is six small changes and it is the best value in the backlog.
2. Run a second watch that **ends in a death**, to settle gaps 1, 2, 4 and 6.
3. Then Gate A on Hell Week with three strangers.

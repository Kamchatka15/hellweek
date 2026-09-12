# Hell Week — loop gaps against 99 Nights

> Source: `research/patterns/hell-week-99nights.md` (verified teardown, 2026-09-12) read against the
> shipped code. Each row says what 99 Nights runs, what Hell Week runs, and whether we should copy it.

## The loops Hell Week already has

| Loop | 99 Nights | Hell Week | Status |
|---|---|---|---|
| Second-to-second | chop / loot → carry → feed | pick → carry → feed the obelisk | built |
| Minute-to-minute | day gather, night hide | 100s day, 45s night, stalker at the light line | built |
| Run-to-end | 99 days, no save | 7 days, `days` table in `config.luau` | built |
| Content unlock | biomes gated by progress | 4 worlds, 7 challenges each, persisted on the profile | built |
| Threat | Deer, unkillable, night-1 mercy | stalker, unkillable, day-1 `watch` then `hunt` | built |
| Craft | campfire levels + classes | obelisk offering → RecipeService | built |

## The loops Hell Week does not have

### 1. Power that carries between runs — the real gap

99 Nights persists **diamonds → 35 classes**, so run two is *the same first minute with a better
loadout*. Hell Week persists `bestDay`, `tutorialComplete` and per-world challenge records. That
unlocks **which world** you play; it never changes **how the first minute plays**.

Consequence: a player who dies on night 3 restarts with exactly the ability they had the first time.
The only thing that improved is them. That is enough for one sitting and it is not enough for a
second session.

This is the one worth solving before Gate A, because Gate A's third pass condition is *wants another
go*, and there is currently nothing waiting for them on that go.

Cheapest shape that fits the wedge: the challenge records already exist and already persist. Let
mastering a world grant a permanent starting item or a permanent sack slot, so the 28 challenges
double as the class ladder instead of being unlock-only.

### 2. Badge ladder as public telemetry

99 Nights runs a badge every 10 days, and the storefront rarity numbers are the retention funnel read
for free: roughly two of three day-10 survivors reach day 20, roughly seven of ten of those reach
day 30. Hell Week has no badges. At a 7-day run the equivalent is a badge per world mastered.

This is cheap and it is measurement, not content.

### 3. Team-size picker at the door

Explicitly on the teardown's copy-this list as 1 to 4 for us. Hell Week has no lobby, no picker, and
difficulty does not scale to headcount. Solo is currently the same difficulty as four players, which
means solo is easy and four players is trivial.

Note the complaint the teardown also records: 99 Nights locks difficulty to the *starting* headcount
and players hate it. Ours should follow the live count.

### 4. A scheduled appointment

The biweekly Update Party pays 20 to 40 diamonds for standing in the lobby on a Saturday. That is a
calendar entry in a player's head. Hell Week has none. This is liveops, not Pass 1, and it needs a
currency to pay out, so it is blocked behind gap 1.

### 5. A second clip type

99 Nights has two: surviving, and base-building. The base videos are the larger of the two. Hell
Week's only clip is surviving the week. The brief's own wedge names a candidate already, one moral
choice per day, and it is not built.

### 6. Lobby-side shop after death

Parked to Pass 2 by the cut list, recorded in `games/hell-week/sku.luau`. Correctly parked. Any paid
product is Gate 5 and needs an explicit human approval regardless.

## Recommended order

1. Persistent power from the challenge ladder, gap 1
2. Badges per world, gap 2
3. Team-size picker with live-count scaling, gap 3

Gaps 4 to 6 wait for Gate A to say the core holds.

---

## Update, 2026-09-12 — watched live

A ~20-minute observed session of 99 Nights sharpened gap 1 and added a tier of readability work that
this document did not anticipate. See `games/hell-week/99nights-watch-findings.md` for the ranked
add-list and `research/patterns/watch/99nights-live-log.md` for the frame-by-frame log.

The headline: gap 1 is not only that nothing carries between runs. 99 Nights announces the thing that
carried with a full-screen beat in the first seconds of every run. Persistence the player is not told
about buys nothing.

Gaps 1, 2, 4 and 6 remain unsettled because the watched session never ended in a death.

# Mining genre winners — what they do and the physics behind it

**Question:** What do the current winners in Roblox mining/digging actually do to retain players and sell Robux — and which of those laws transfer to Layer Mine?

## The numbers

| Game | Visits | Rating | Source, date |
|---|---|---|---|
| The Forge (RPG-mining hybrid) | 1.029B | 94.4% | Robipedia mining ranking, Jul 2026 |
| Break a Lucky Block! | 586.8M | 94.1% | Robipedia, Jul 2026 |
| Bitcoin Miner | 213M | 91.5% | Robipedia, Jul 2026 |
| Mining Simulator 2 | 210.7M | 93.2% | Robipedia, Jul 2026 |
| Mega Miners | 118.5M | 82.4% | Robipedia, Jul 2026 |

- Genre retention benchmarks (BLOXG, 2026, 850+ promoted games): **Simulator D1 32% / D7 14% / D30 6.2%** — second only to RPG (D1 35%). The #1 mining game being an RPG hybrid tracks with that.
- Roblox tags 1,022 games with mining mechanics (Robipedia) — crowded genre; differentiation is mandatory.
- DIG: mechanics well documented below, but live player stats weren't retrievable at access time — scale claims omitted rather than guessed. Prospecting!: same; CCU figures not sourced this pass, so none are stated.

## What they do

**Prospecting!** — dig dirt → pan it in the river → appraise → sell. Luck is the master stat and scales linearly (500 Luck ≈ 10x the rare finds of 50), implemented as extra rerolls. Enchant system on pans (Blessed = luck + capacity), per-area collection/museum filling for Meteor Shards, and Meteor Shower events with 2x luck. *Why they pay:* passes remove friction from a loop players already love — "Sell Anywhere," more ring slots, capacity (Pro Game Guides).

**DIG** — click-to-dig timing minigame with sweet-spot strikes; an endurance bar where busting means **losing the treasure you were digging**; 7 rarity tiers plus value mutations (Big, Golden); colored light-beam dig spots that guarantee a rarity; boss-drop shovels that skip whole progression tiers; random weather events (meteor strike sites with exclusive gear); charm loadouts. *Why they pay:* passes sell pace and extras (vehicles), but earned shovels outrank them — payers buy speed, not power (Of Zen and Computing).

**The Forge** — mine → smelt → forge → sell production chain wrapped in quests; milestone pickaxe jumps (Cobalt 10K → Mythril 67.5K) where skipping mid-tiers is optimal; community calculator culture that turns "random grinding into purposeful crafting sessions"; heavy update cadence behind 1B visits at a 94.4% rating (GamesHub). *Why they pay:* not captured this pass — flagging rather than guessing.

**Genre-wide** (Mr. Mine guide): rebirth resets for permanent multipliers, pets that boost output, VIP servers, timed 2x-resource events, limited cosmetics, trading + leaderboards + wiki communities. Layered goals so "sessions feel productive regardless of playtime."

## The physics

1. **Wrap the slot machine in a skill shell.** Winners put a timing/aiming minigame between click and reward (DIG's sweet spots, Prospecting's panning). Randomness feels earned, so grinding feels like practicing, not pulling a lever.
2. **Make the grind stat the jackpot stat.** Luck as an upgradable master stat means every upgrade is an anticipation purchase — progression and thrill compound instead of competing.
3. **Loss risk prices excitement.** DIG's bust-and-lose-the-haul endurance bar turns each dig into a push-your-luck decision. Stakes, not punishment.
4. **Always show the next scarce thing.** Beam-marked guaranteed spots, meteor events, boss drops — visible, time-and-place-limited opportunities move players around the world and create shared moments.
5. **Collections are the second game.** Museum/collection logs add a completion axis orthogonal to money — a session that earns nothing still fills a slot.
6. **Depth must be a ratchet of promise, not just scale.** Each layer needs a new table/rules, "each layer holding the promise of rare gems" (Mr. Mine) — bigger numbers alone make deeper a treadmill.
7. **The loop starts in under 60 seconds.** Straight into dig→reward before any tutorial or shop (SM Games) — and since Roblox's June 2026 discovery rework pays for retention and session quality, first-minute design is now acquisition strategy too (PIPELINE.md).
8. **They pay to smooth a loop they already love.** Genre monetization that works = friction removal, pace, identity — not power over others, and legible enough for a kid to explain the purchase (matches our understood-purpose rule).

## Policy flags (required per skills/research-legal.md)

- **Gambling shape:** luck mechanics are the genre's engine and sit near the line. Simulated gambling is prohibited at every rating; paid random items require exact displayed odds, and UK/AU/BE/NL/BR gate them via PolicyService. Keep randomness earned in-game; keep purchases deterministic.
- **Engagement-mechanic risk:** the Aug 2026 Steal an Egg takedown (#1 game, ~800K CCU) shows Roblox will kill coercive retention mechanics. Events and streaks yes; panic timers and doomscroll-shaped loops no.
- **Shapes, not stuff:** the loops and patterns above are fair game; ore names, mascots, thumbnail styles, and asset looks from these games are not.

## For our game (Layer Mine)

**Steal (works as-is)**
- Rarity color ladder + ore mutations (Big/Golden variants of existing ores) — a cheap content multiplier on ores Hunter already built.
- Collection log per depth band paying a small reward currency — the second game, orthogonal to ore-selling.
- Scheduled 2x events at a time kids can predict — appointment by anticipation, not coercion.

**Adapt (works with changes)**
- Luck as an upgradable stat feeding roll tables — but tie the best luck payoffs to depth, so the heat system prices them: the richest rolls live where survival windows are 30–60s. Fuses law #2 with the risk system Layer Mine already has.
- DIG-style beam-marked "hot veins" visible at depth — guaranteed-tier finds that force a heat-budget decision (do I have enough shield to reach it?).
- "Sell at depth" convenience pass ≙ Prospecting's Sell Anywhere — friction-removal monetization that passes the understood-purpose test.
- The Forge's production chain (smelt/craft above raw selling) as a later second axis — only after core-loop retention proves out; sequencing before scaling.

**Avoid (would hurt us)**
- Rebirth that wipes depth/shield progress. The genre uses rebirth, but Layer Mine's differentiator is a mastery arc (heat windows, shield tiers) — a reset that erases it kills the reason to care. If ever added: multiply, don't erase.
- Paid luck boosts or paid random rolls — policy-flagged above, and fails the kid-can-explain-it test.
- Deeper-is-just-bigger-numbers depth scaling — every new band must change the rules (new hazard interplay, new table), per law #6.

**Validation worth noting:** Layer Mine's death mechanic (drop ore where you died, recover it next run) is law #3 already implemented — the genre's best risk mechanic, and ours adds a comeback loop DIG doesn't have.

## Sources (accessed 2026-09-11)

- Robipedia — Best Mining Roblox Games (Jul 2026): https://robipedia.com/tag/mining
- BLOXG — Roblox Retention Benchmarks by Genre (2026): https://bloxg.com/statistics/roblox-retention-benchmarks
- SM Games — What Makes a Roblox Game Succeed: https://smgames.net/blog/what-makes-a-roblox-game-succeed.html
- Mr. Mine — Mining Games Roblox guide: https://blog.mrmine.com/mining-games-roblox-complete-guide-to-popular-mining-titles/
- Pro Game Guides — Prospecting beginner's guide: https://progameguides.com/roblox/prospecting-roblox-beginners-guide/
- Of Zen and Computing — DIG gameplay guide (Mar 2026): https://www.ofzenandcomputing.com/roblox-dig-gameplay-shovels-strategies/
- Roblox — DIG game page: https://www.roblox.com/games/126244816328678/DIG
- GamesHub — The Forge tips guide: https://www.gameshub.com/news/guides/the-forge-tips-tricks-guide-roblox-2847306/
- Internal: roblox-pipeline/PIPELINE.md (discovery rework, enforcement cases), roblox-pipeline/skills/research-legal.md

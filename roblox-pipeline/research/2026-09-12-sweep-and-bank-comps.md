# Comps drop — the top three for Fat Man Gets Rich, and what to copy from each — 2026-09-12

> Doctrine §3.1 (copy aggressively). Fills the idea-log field that has said "closest comps: to fill" since 2026-09-11. Teardowns in `patterns/`. Numbers from Rolimon's, RoMonitor and a LevelUpPlay snapshot, all read 2026-09-12.

## The three, and why these three

| Game | Shape it proves | Numbers | Wave |
|---|---|---|---|
| **Mine a Mountain** (10K Steps) | bag-and-bank in 2026: mine → bag full → sell → 12-tier ladder + base-slot collection + hourly reset + consumable sink | 131,867 peak (2 weeks ago) → ~6–19K now · 136.6M visits · 96.8% likes · born May 18 2026 | **Fading** — 4 months old, the graveyard month. Shape proven, window closed |
| **Bee Swarm Simulator** (Onett) | the bag-and-bank *feel* — the trip home is the rhythm; a collection you can see; no early wall | ~20K CCU · 4.6B visits · 96% | **Evergreen** since 2018 |
| **Grow a Garden** | offline progress that is capped not punished; restock timers and Saturday events as appointments; the strongest social loop on the platform | 22.3M peak — the record | **Post-peak evergreen** |

One fading wave, two evergreens. Fat Man Gets Rich is Mine a Mountain's loop with Grow a Garden's return hook and — the missing piece — a social/clip surface that neither Mine a Mountain nor our slice has yet.

## The blend — what Fat Man takes from each (the expansion list, budget applied)

This is the build loop of `docs/SYSTEM_ARCHITECTURE.md` §3 run by hand, once: every applicable shape proposed, the complexity budget applied, a line drawn. **Justin moves the line.** Below it goes to the parking list, not the bin.

| # | Proposed shape | From | Cost to add | Verdict vs budget |
|---|---|---|---|---|
| 1 | **Bag-full teaches the bank** — already built (the first flood overfills a 40-bag) | Mine a Mountain, Bee Swarm | 0 | **In.** Hypothesis 1 in the brief tests it |
| 2 | **Offline earnings, capped not punished** — already built; number wrong (economy sim) | Grow a Garden | Retune only | **In** at Candidate C's rate |
| 3 | **Named upgrade tiers** — "Bigger Bag" → *Duffel, Wheelbarrow, Dump Truck…* so kids say the name | Mine a Mountain's 12 pickaxes | Theme file only | **In.** Zero systems added, big readability win |
| 4 | **A timed golden flood** — every N minutes the pad erupts ×5, server-wide countdown on the HUD | Grow a Garden restock timer, Mine a Mountain hourly reset | Small (LoopService timer + toast) | **In — this is the clip.** Counts as the 1 social/clip hook |
| 5 | **Coin pile you can see** — banked coins render as a growing pile at your spot; others walk past it | Mine a Mountain base slots, Bee Swarm's hive | Medium | **In as system #3** (of 4). The status surface with no cosmetic catalogue needed |
| 6 | **Rare coin variants** (silver / gold / diamond, more value, different sound) | Grow a Garden mutations | Small | **Line drawn here.** Below: adds a 4th on-screen concept; parking list until Gate A says the loop reads |
| 7 | **Consumable sink** (a "magnet bomb" that pulls every coin on the floor) | Mine a Mountain bombs | Medium | Parking — the economy sim's late-wall fix, needed at G2/live-ops, not in the slice |
| 8 | **Gift a flood to a friend** (social SKU / co-play bonus) | Grow a Garden gifting | Medium | Parking — needs 2 players in a session to mean anything; Gate B material |
| 9 | Second area / zones by "warmth" | Mine a Mountain | Large | Parking — doctrine §3: no second area before area one retains |
| 10 | Trading | Grow a Garden | Large + scam-guards | Parking — not before Gate B and not without confirm screens |

**Systems count with the line where drawn:** flood/collect (1), bank + upgrades (2), coin pile (3), golden-flood timer (4) = **4 of 4**. On-screen numbers: coins carried, coins banked, next-flood countdown = **3 of 3**. Onboarding artifact: the overfilling bag + one toast — required, present.

## What the comps say about the economy sim

All three keep the **trip to the bank meaningful** for weeks. Ours stopped mattering by day 2 at 4 offline bursts/hour. The comps agree with Candidate C and add one thing the sim could not see: Bee Swarm protects the *feel* of the trip, not just its value. The bank walk should be a path with sound and a payoff animation, not a teleport.

## Sources
- Rolimon's — Mine a Mountain game page (players, peak, visits, likes, creation date)
- RoMonitor Stats — top-trending chart, 2026-09-12
- Sportskeeda — "Mine a Mountain: A beginner's guide", Jul 8 2026 (loop, shops, upgrades, hourly reset)
- LevelUpPlay simulator ranking snapshot (Pet Sim 99 65.8K / Bee Swarm 19.6K / TDS 8.6K)
- PIPELINE.md §1 and the doctrine for Grow a Garden's record and design

# Economy simulation — fat-man-gets-rich — 30 days × 240s sessions × 300 runs

## Ladder (engine formulas, real config)

| upgrade | max | cost L1→2 | cost to max | effect L1 → max |
|---|---|---|---|---|
| bag | 10 | 50 | 14872 | 40 → 355 |
| payout | 8 | 75 | 7365 | 60 → 214 |
| magnet | 6 | 60 | 1342 | 0 → 12.5 |
| shine | 6 | 120 | 4346 | 1 → 6 |

**Total cost to max everything: 27,925 coins.**

## What the runs say (medians)

| measure | result | bar | verdict |
|---|---|---|---|
| Time to first upgrade | 28s | < 60s (doctrine §4.2, brief) | PASS |
| Everything maxed by | day 3 (100% of runs by D7) | after D7, ideally D14+ | FAIL — meta loop exhausted before the retention window |
| Offline share of all coins | 82% | 20–50% (bedtime-proof, but playing still matters) | FAIL — playing is pointless |
| Longest stretch with nothing to buy | 27 sessions | ≤ 2 | FAIL — a wall |
| Income/min, day 1 → day 30 | 171 → 2130 coins/min (12.4×) | 5–20× over a month | OK |
| Unspent balance at day 30 | 1,384,501 coins | small vs total ladder (27,925) | FAIL — inflation, nothing to spend on |

## Assumptions not in config

- Bank trip costs 6s; collection fraction 0.5 + 0.04 × added magnet radius (±12% per session); session length ±30%; one session a day, every day (no churn — this measures content depth, not retention).
- Greedy buyer: always buys the affordable upgrade with the best income gain per coin. Real kids buy the shiny one. That makes the sim slightly optimistic about progression speed.

## Candidate tunings, side by side (same 300 runs each)

| tuning | 1st upgrade | all maxed | offline | stall | unspent @30d |
|---|---|---|---|---|---|
| AS CONFIGURED                                              |    28s |    day 3 |   82% |  27 |   1,384,501 |
| burstsPerHour=1                                            |    28s |    day 4 |   53% |  26 |     511,428 |
| burstsPerHour=1 bag.maxLevel=16 payout.maxLevel=14 shine.maxLevel=10 magnet.maxLevel=8 |    28s |   > 30 d |   65% |   4 |     192,740 |
| burstsPerHour=0.5 bag.maxLevel=16 payout.maxLevel=14 shine.maxLevel=10 magnet.maxLevel=8 bag.costGrowth=2.0 payout.costGrowth=2.05 shine.costGrowth=2.3 |    28s |   > 30 d |   47% |   4 |      53,516 |

## What this means, in plain terms

**The first minute is right and the second week is empty.** The first upgrade lands at ~28 seconds in every run — the brief's promise holds. But the whole ladder costs 27,925 coins, and by day 3 a kid who plays four minutes a day has bought all of it. From then on the game hands out more coins than it has anything to sell — 1.38 million unspent by day 30 — and 82% of those coins arrive while the kid is asleep. There is no reason to play instead of wait, and no reason to open it on day 4 at all.

This is the `config.luau` header's own warning made specific: "the whole point of the slice is to find out which of them are wrong." Two of them are.

## Recommendation for G2 (Justin approves the numbers — this proposes them)

**Candidate C** — offline at 0.5 bursts/hour (was 4), deeper ladders (bag 16, payout 14, shine 10, magnet 8), slightly steeper late costs:

- first upgrade still ~28s — the first minute is untouched
- nothing is maxed inside 30 days — the meta loop outlives the retention window
- offline share ~47% at snack pace, ~21% for sit-down players — bedtime-proof without making play pointless
- unspent balance falls from 1.38M to ~54k

**What it does not fix, and should not pretend to:** a 4–6 session stretch with nothing affordable appears around week three in every deep-ladder tuning. That is what exponential cost curves do. The honest fix is not a fifth upgrade but a **second sink** — the fair-play catalogue's cosmetics, a collection index, or a rebirth layer — which the doctrine says to add *after* world one retains, i.e. a G2/live-ops decision with Gate B numbers in hand, not a slice change. Flagged, not solved.

## Rerun any time

```sh
python3 tools/econ_sim.py                       # as configured
python3 tools/econ_sim.py --quiet --set burstsPerHour=0.5 --set bag.maxLevel=16   # try a tuning
```

The tool reads the real `config.luau` and the engine's own formulas, so it cannot drift from the game. Its two stated assumptions (bank trip 6s, magnet collection fraction) are the things to argue with.

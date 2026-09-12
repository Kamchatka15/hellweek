# Hell Week — economy (Wave 1)

> The currency is **fuel**, not coins: Ashwood in, burn out. Days×1000 + wickLeft×10 − gifts×200 is the score. Candidate numbers are the brief's §6 table; the sim is `tools/survive_sim.py` (written 2026-09-12 because `econ_sim.py` only knows sweep-and-bank).

## Candidate days (in `server/config.luau`)

| Day | Day length | Night | Burn (units) | Ashwood on the floor | Tempter |
|---|---|---|---|---|---|
| 1 | 90 s | 40 s | 3 | 14 (Ring A 8 incl. 3 on the spawn line, Ring B 6) | watch only |
| 2 | 90 s | 45 s | 4 | +14 respawn (+6 Ring C once 8 fed) | hunts outside the light |
| 3 | 85 s | 50 s | 6 | same, + the Gift on the light-line | hunts + Gift |
| 4–7 | 80→65 s | 55→70 s | 7→10 | **PARKED tuning** — placeholders so the week has a shape | same AI |

Sack 3 · Wick holds 15 · radius 25 + 8×fuel, cap 90 · Ring C opens at 8 fed, Ring D at 20 · Gift +5 now, Weight +1, next burn ×1.25 per Weight · Tempter touch = −20% fuel, Weight +1.

## Sim result (300 runs per row, one player, no co-op, no downed penalties)

Re-run 2026-09-12 after the obelisk layout (feed edge at 30 studs, Ring A 32–50). Trips are now measured from the **feed edge**, not the centre — a 30-stud stone shortens every round trip by 60 studs, which the first version of the sim missed and which made a visual change look like a balance collapse.

| player | gifts | median days survived | P(see Day 2) | P(see Day 4) | P(week) | Day-3 fuel before night (median) |
|---|---|---|---|---|---|---|
| slacker (25% of day gathering) | 0 | 5 | 100% | 100% | 0% | 11.0 |
| slacker | 1 | 5 | 100% | 100% | 0% | 15.0 |
| slacker | 3 | 4 | 100% | 100% | 0% | 15.0 |
| casual (50%) | 0 | 7 | 100% | 100% | 100% | 15.0 |
| casual | 1 | 7 | 100% | 100% | 72% | 15.0 |
| casual | 3 | 4 | 100% | 100% | 0% | 15.0 |
| engaged (75%) | any ≤1 | 7 | 100% | 100% | 100% | 15.0 |
| sweat (100%) | any ≤1 | 7 | 100% | 100% | 100% | 15.0 |
| any | 3 | 4 | 100% | 100% | 0% | 15.0 |

## What it says

1. **Nobody fails Days 1–3 any more.** The wide stone made the loop easier: even a quarter-effort player reaches Day 5. The brief wanted Day 3 "tight if sloppy" and it is no longer tight for anyone. **A G2 lever, not a Pass 1 one** — the honest fixes are a lower beacon cap, a Day-3 burn above 6, or fewer Ring A pieces, and all three want Gate A watched first.
2. **The Gift is still the only thing that kills you.** Three Gifts cap every profile at Day 4, and one costs a casual player the week 100% → 72%. The wedge survived the layout change intact, which is the part that mattered.
3. **The cap (15) is still the ceiling everyone sits at** from Day 3 on, so the parked Days 4–7 escalation still threatens nobody. Same G2 decision as before.

## Shop stubs (drafted, unwired — `server/sku.luau`)

Wick Oil 49 R$ (+4 fuel, this run) · Deep Pockets 99 R$ pass (sack 5, persists) · Second Wind 79 R$ (one wake with no fuel penalty). Offered only after a Day-2 survive. None locks a day. Nothing random. **G5 is Justin's click; no MarketplaceService call exists in the repo.**

## Assumptions not in config

Walk 16 studs/s, 0.4 s per pickup, 6 s of looking per trip, sack always filled to cap, inner rings first, ±15% effort noise, one player. Co-op makes it easier (four sacks, one wick); the Tempter's fuel penalty makes it harder. Neither is modelled yet.

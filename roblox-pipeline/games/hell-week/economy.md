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

| player | gifts | median days survived | P(see Day 2) | P(see Day 4) | P(week) | Day-3 fuel before night (median) |
|---|---|---|---|---|---|---|
| slacker (25% of day gathering) | 0 | 3 | 100% | 58% | 0% | 8.0 |
| slacker | 1 | 3 | 100% | 88% | 0% | 13.0 |
| slacker | 3 | 4 | 100% | 88% | 0% | 13.0 |
| casual (50%) | 0 | 7 | 100% | 100% | 99% | 15.0 |
| casual | 1 | 6 | 100% | 100% | 0% | 15.0 |
| casual | 3 | 4 | 100% | 100% | 0% | 15.0 |
| engaged (75%) | 0 | 7 | 100% | 100% | 100% | 15.0 |
| engaged | 1 | 7 | 100% | 100% | 100% | 15.0 |
| engaged | 3 | 4 | 100% | 100% | 0% | 15.0 |
| sweat (100%) | any ≤1 | 7 | 100% | 100% | 100% | 15.0 |

## What it says

1. **Day 1–2 teach is safe for everyone.** Even a player who gathers a quarter of the day sees Day 2. The brief's "slacker still sees Day 2" holds.
2. **Day 3 bites only the slacker** (58% see Day 4). The brief wanted "tight if sloppy" — this is it. For everyone else Day 3 is comfortable, which is fine for Pass 1: the Day 3 question at Gate A is comprehension of the Gift, not difficulty.
3. **The Gift is a real trap only when taken repeatedly.** One Gift is *helpful* to a slacker (58% → 88% see Day 4) and costs a casual player the week (99% → 0%). Three Gifts cap everyone at Day 4. That is a clip-able moral choice: the first one looks free, the third kills you. Hypothesis H2 is testable.
4. **The Wick cap (15) is the soft spot for Days 4–7.** Every non-slacker sits at 15 fuel before every night from Day 3 on, so the parked escalation (burn 7→10) never threatens them. When Days 4–7 are tuned (Pass 2), the lever is either a lower cap (12), a small daytime idle burn, or Ring C/D fuel counts — **a G2 decision with Gate A in hand, not now.**

## Shop stubs (drafted, unwired — `server/sku.luau`)

Wick Oil 49 R$ (+4 fuel, this run) · Deep Pockets 99 R$ pass (sack 5, persists) · Second Wind 79 R$ (one wake with no fuel penalty). Offered only after a Day-2 survive. None locks a day. Nothing random. **G5 is Justin's click; no MarketplaceService call exists in the repo.**

## Assumptions not in config

Walk 16 studs/s, 0.4 s per pickup, 6 s of looking per trip, sack always filled to cap, inner rings first, ±15% effort noise, one player. Co-op makes it easier (four sacks, one wick); the Tempter's fuel penalty makes it harder. Neither is modelled yet.

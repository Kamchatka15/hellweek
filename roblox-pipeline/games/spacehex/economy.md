# SPACEHEX — the career curve, simulated

> Re-run it: `luau tools/spacehex_career.luau` (needs the `luau` CLI; the sim requires
> `games/spacehex/server/parts.luau` and `flight.luau` — the SAME modules the game runs,
> not a copy. If the game's numbers change, this output changes with them).
> Run 2026-09-20 against the committed catalogue.

## The target Justin set

> *"it should take at least 20 attempts to intelligently upgrade to reach the space station."*

## The result

**Docked on launch 19.** A perfect optimiser, buying the single best part it can afford
each attempt and never wasting money. A real player will not be perfect, so 19 is the
**floor**, not the expectation — which is exactly where the floor should sit.

| # | Bought | Apogee | TWR | Δv | eff. Δv | Earned | Cash after |
|---:|---|---|---:|---:|---:|---|---|
| 1 | *(RM-1 Hopper + Micro Tank at start)* | 1.7 km | 3.72 | 966 | — | $0.85M | $0.90M |
| 2 | Light Decoupler | 4.0 km | 3.44 | 1,774 | — | $1.18M | $1.79M |
| 3 | Small Tank | 13.6 km | 2.17 | 3,319 | 328 | $2.07M | $3.14M |
| 4 | Tail Fins | 13.2 km | 2.14 | 3,313 | 469 | $1.86M | $4.67M |
| 5 | Cone | 16.9 km | 2.12 | 3,182 | 565 | $2.05M | $6.33M |
| 6 | Medium Tank | **0.0 km** | **1.04** | 4,950 | 1,023 | $0.31M | $5.19M |
| 7 | RM-2 Pioneer | 545.9 km | 2.43 | 6,453 | 2,724 | $16.00M | $16.05M |
| 8 | Basic Guidance | 466.3 km | 2.41 | 6,142 | 3,145 | $7.23M | $22.05M |
| 9 | Grid Fins | 445.6 km | 2.39 | 6,136 | 3,517 | $8.01M | $28.49M |
| 10 | Large Tank | 71.7 km | 1.26 | 7,853 | 4,453 | $4.76M | $29.61M |
| 11 | Inertial Unit | 63.8 km | 1.26 | 7,674 | 4,919 | $5.72M | $32.41M |
| 12 | V-1 Vulcan | 14.1 km | 2.37 | 7,996 | 5,661 | $9.81M | $23.93M |
| 13 | Ogive Nose | 15.5 km | 2.37 | 7,915 | 5,756 | $7.64M | $29.88M |
| 14 | K-5 Kestrel [VAC] | 14.5 km | 2.34 | 8,683 | 6,435 | $9.40M | $32.89M |
| 15 | Heavy Tank | 15.7 km | 1.24 | 10,624 | 7,618 | $17.84M | $41.39M |
| 16 | Full GNC | **ORBIT** | 1.24 | 10,486 | 8,123 | $49.46M | $83.91M |
| 17 | RCS Pack | ORBIT | 1.24 | 10,486 | 8,123 | $8.96M | $89.24M |
| 18 | Docking Port | 14.2 km | 1.23 | 9,627 | 7,296 | $7.35M | $91.57M |
| 19 | T-9 Titan | ORBIT | 2.45 | 9,782 | 8,019 | $68.75M | $92.94M → **DOCKED** |

## What the curve is doing, and why each part of it is deliberate

**Launches 1–5 — the hop.** Cheap parts, small numbers, every purchase visibly moves the
altitude. The player is learning that a part changes a number.

**Launch 6 is the best teaching moment in the whole game.** The optimiser buys a Medium
Tank — a strictly bigger, better tank — and **TWR falls to 1.04 and the rocket goes
nowhere.** More fuel is more mass. Nobody has to explain it; the pad card said
*"IT WILL BARELY LIFT"* before the launch and the player pressed the button anyway.
This failure has to survive playtesting. It is the thing that makes the science real.

**Launch 7 is the spike.** A better engine under the big tank and it suddenly clears
545 km on a ballistic shot, tripping four milestones at once. This is a real physical
fact — going *up* is easy — and it is deliberately rewarded, because it is the moment the
player feels enormous. It also sets the trap for the next ten launches.

**Launches 10–15 — the wall, and the lesson.** Apogee *falls* from 71 km to 15 km while
Δv climbs from 7,853 to 10,624. The player is now flying for orbit rather than for
height: guidance turns vertical speed into horizontal speed. **Going up is easy. Going
sideways fast enough to stay up is the hard part.** This is the single most important
thing the game teaches, and the money follows Δv here rather than altitude so the player
is paid for learning it.

**Launch 16 — orbit**, and it is bought with **Full GNC**, not with an engine. Guidance
multiplies the entire stack, so $5.16M of avionics is worth more than $18M of Raptor.
The player who noticed this earlier gets there sooner.

**Launches 17–19 — the station.** RCS, then the port, then enough thrust to lift them.

## Tuning knobs, and where they live

| Knob | File | Current |
|---|---|---|
| Orbital velocity gate | `flight.luau` `ORBIT_DV` | 7,700 m/s (losses already subtracted) |
| Altitude pay | `tools/spacehex_career.luau` `RATE, EXP` | 700,000 × km^0.38 |
| Performance pay | same | 300,000 × (Δv/1000)^1.85 |
| Repeat-flight pay | same | 0.62× unless it beats your record |
| Refurbish | same | 4% of the stack (1% on a recovered stage) |
| Gravity / drag losses | `flight.luau` | 1,450 × (1.40/TWR)^0.95 · 340 × (Cd/0.31) |

To move the docking launch later: cut the altitude pay exponent, raise Core Tank and
Raptor prices, or raise the pad-upgrade costs. To move it earlier: the reverse. **Do not
move `ORBIT_DV`** — 7,700 m/s is orbital velocity at 400 km and it is the one number in
this game that is not ours to tune.

## Known gaps in the model

- No reentry, no aerobraking, no orbital rendezvous phasing — docking is gated on Δv + RCS + port, not flown.
- Recovery refunds are a flat percentage; a real reuse model would degrade parts.
- The optimiser buys perfectly. It has no idea what a nine-year-old will actually do.
  **Gate A replaces this sim, it does not confirm it.**

# SPACEHEX — brief

> Governed by `docs/ROBLOX_SUCCESS_LOGIC.md`. Promoted to **Active** by Justin 2026-09-20.
> Spec: `specs/2026-09-20-spacehex-slice.md` · Comps: `research/2026-09-20-space-rocket-comps.md`

## Hook

**A million dollars, a warehouse full of parts, and nineteen launches between you and the space station.**

## The loop, in the order a player meets it

1. You start with **$1,000,000** and an empty pad.
2. In the **warehouse** you buy parts — an engine, a tank, a nose cone. Every part has real numbers on it.
3. You **assemble** them into a rocket. The game checks it before you roll out and tells you exactly what is wrong: *"Stage 1 has no fins. It will tumble off the pad."*
4. You roll it to the pad. The **pad card** shows thrust, weight, TWR and Δv, and says in plain words whether it will fly.
5. **Launch.** It climbs. The altitude number climbs with it.
6. You are paid on how it performed — altitude early, Δv once you are chasing orbit — plus a one-time bonus every time you break a new barrier.
7. You spend that on better parts. **Launch again.** The number is bigger.

Repeat about nineteen times and you dock with the station. Then it is the Moon, and then your own station.

## Why it takes about twenty launches

Because the numbers say so, and we simulated it: `games/spacehex/economy.md` runs the real catalogue through the real physics with a perfect optimiser and docks on **launch 19**. A perfect optimiser is the floor; a nine-year-old is not perfect, so a real player takes more.

## Why it is called SPACEHEX

Hexagons are the identity and the visual shorthand at every scale: the pad is a hex ringed by six clamps, tier badges are hexes, and the Moon base (Wave 5) is built out of hex modules that tile. It reads at 200px and it is trivially generatable from primitives, so the look costs no art budget.

## The ladder

Six tiers, each a `ChallengeService` world that unlocks the next:
Upper Atmosphere (10 km) → **Kármán Line** (100 km) → Low Earth Orbit (7,700 m/s) → **Station Rendezvous (the first real goal)** → Trans-Lunar Injection → **Moon Landing, then your first Moon base**.

## The wedge

Real science as the upgrade vocabulary — thrust-to-weight, Δv, payload fraction — shown as two bars and a ratio on the pad card. The catalogue is in `games/spacehex/PARTS.md` and **there is not one decorative stat in it**: every number a part carries is read by the flight sim.

The best moment the simulation found is launch 6, and it is a failure. The player buys a Medium Tank — strictly bigger, strictly better — and the rocket does not leave the pad, because more fuel is also more mass. The pad card warned them. That single launch teaches thrust-to-weight better than any tutorial could, and it has to survive playtesting. It must read as *consequence* ("it was too heavy to lift"), never as homework. **Gate A is the test of exactly this.** If three fresh kids read the pad card as a math worksheet, the wedge is a liability and it gets simplified, not defended.

## What it is not

Not a free-flight space sandbox (Space Sailors and Innovation Inc own that, and it is dead air for a 10-year-old). Not a build-screen-first game — the first launch happens before any building. Not "Build a Rocket": that exact phrase maps to four dead titles in search.

## The one number that justifies this title

Six "build a rocket and launch it" games on Roblox share **141M visits and 63 concurrent players.** The one space title that holds players (The Space Simulator, 554 CCU) does it with a **6.1% favorite rate — 30× the genre** — by being a collect-and-upgrade game wearing a space skin. SPACEHEX takes that shape and puts a launch on the front of it.

## Return hook (exactly one, for Pass 1)

Debris keeps falling while you are logged off. The pad is littered when you come back. Capped, never punished.

## Gate A question

*"Tell me what this game is in three sentences, then tell me what you would buy next."*
If they cannot name the next thing they want, the shop is wrong, not the player.

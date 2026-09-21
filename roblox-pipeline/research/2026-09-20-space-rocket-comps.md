# Sweep — the space / rocket family on Roblox — 2026-09-20

> Governed by `docs/ROBLOX_SUCCESS_LOGIC.md`. Intake research for Justin's rocket-to-orbit-to-Moon concept. **Research only — no title promoted, no code written.**
> All numbers pulled live from the Roblox games API on 2026-09-20.

## 1. The board

| Title | CCU now | Visits | Favorites | Fav rate | Created | Last update | Read |
|---|---:|---:|---:|---:|---|---|---|
| **The Space Simulator** | **554** | 90.6M | **5,531,945** | **6.1%** | 2023-10-10 | **today** | The one winner. Not a launch game — see teardown |
| Innovation Inc. Spaceship | 182 | 88.4M | 510K | 0.58% | 2015-12-13 | 2026-08-16 | 11-year-old roleplay/sandbox anchor. Social, not progression |
| Space Sailors | 130 | 79.4M | 492K | 0.62% | 2020-05-07 | 2026-09-19 | Free-flight sandbox. Wide, shallow, still maintained |
| Build a Rocket VS Mark Rober | 34 | 21.3M | 113K | 0.53% | 2023-08-29 | 2024-09-04 | 21M visits bought by a YouTuber brand. Abandoned 2 years. **Not repeatable** |
| 🚀 Build a Rocketship | 12 | 12.7M | 51.9K | 0.41% | 2025-08-03 | 2026-04-26 | Rode the "Build a ___" naming wave to 12.7M visits. 12 CCU |
| Launch Into Space Simulator | 9 | **80.8M** | 165K | **0.20%** | 2023-12-03 | 2026-09-14 | **The warning.** 80 million visits, nine players. Still being updated |
| Rocket Tester | 8 | 25.3M | 241K | 0.95% | 2015-03-05 | 2022-12-17 | The genre's ancestor. Dead since 2022 |
| Build A Rocket [BETA] | 0 | 576K | 4.0K | 0.69% | 2024-02-20 | 2024-08-28 | Abandoned |
| *(control)* Build A Boat For Treasure | 16,921 | 5.2B | 8.5M | 0.16% | 2016-11-02 | 2026-09-18 | The build-a-vehicle-and-launch-it archetype that actually worked — see §3 |

## 2. The verdict — read this before anything else

**The concept as described walks straight into the platform's best-documented graveyard.**

Six "build a rocket and launch it" titles. Between them, **141 million visits and 63 concurrent players.** Launch Into Space Simulator is the cleanest datapoint on the platform: 80.8M visits, still actively updated six days ago, **nine players online.** It is not a marketing failure. It got the traffic. It could not hold it.

The reason is mechanical, not artistic:

```
LAUNCH is a NOVELTY verb.        MINE / SELL / UPGRADE is a REPEATABLE verb.
  build → launch → read number     gather → bank → spend → visibly stronger → gather
  → the number is the whole         → the loop is the whole payload
    payload
  → second launch pays less         → second trip pays the same and costs less time
    than the first                  → and you can see the difference
  → leave                           → come back tomorrow
```

The 2026 discovery algorithm weights **return over ~28 days** (doctrine §7). A novelty verb produces a visit spike and a D1 near zero. That is exactly the shape of the eight rows above.

**The Space Simulator is the counter-example that proves it.** Same subject matter, 554 CCU, and a **favorite rate 30× the genre's** — because it is a collect-and-upgrade game with space as the skin. Mine → sell → upgrade ship → collect 34 orbs → Saturday reset. Nobody in it is launching anything.

## 3. Build A Boat For Treasure — the structural comp, not a space game

16,921 CCU and 5.2 **billion** visits, ten years old, updated two days ago. It is a build-a-vehicle-and-launch-it game that *worked*, and the reason is the thing every rocket game on the board is missing:

- **The launch is a run, not an ending.** You build, you sail, you break apart, you come back with gold and build a bigger one. The failure is the content.
- **Blocks are the currency.** Gold buys blocks; blocks are visible on your boat; your boat is your progress bar. Nothing is an invisible stat.
- **The stage is shared.** Everyone launches into the same water and watches each other fall apart. Free clips.

Note its favorite rate is 0.16% — this is a *session* game, not a keep game. It wins on raw volume of repeat sessions, not affection. That is a different business than The Space Simulator's, and both beat the rocket graveyard.

## 4. The blend — if a title gets built in this family

Ranked. **Everything below line 5 is cut for Pass 1.**

1. **The launch is a scored 90-second run, not the goal.** Apogee is the score. You always come back with something. (Build A Boat)
2. **A repeatable ground verb underneath it** — salvage/refuel/scrap at the pad between launches, which is what pays for parts. This is the loop the engine already runs (`LoopService`, sweepbank). (The Space Simulator)
3. **Parts are visible progress.** Every upgrade changes the silhouette of the rocket on the pad. No invisible stats. (Build A Boat)
4. **An altitude ladder that is a named collection** — Kármán line → LEO → docking → trans-lunar → Moon surface, each a tier you unlock and keep. This is `ChallengeService` verbatim. (The Space Simulator's 34 orbs)
5. **Real science as the upgrade vocabulary** — thrust-to-weight, stage mass, payload fraction, Δv. Nobody on the board does this; it is the wedge, and it is the thing Justin actually wants. It must be legible to a 10-year-old or it is a liability, not a wedge.

--- cut line for Pass 1 ---

6. Moon base with offline production (this is the **D1 hook** — build it at Wave 5, not Pass 1)
7. Weekly Saturday reset / launch-window event (Pass 2)
8. Server-wide paid boost, the one Robux item nobody resents (post-Gate B)
9. Docking as a skill minigame
10. NPC contract missions as the tutorial replacement
11. Multi-stage separation physics
12. Telemetry replay / flight trace you can share

## 5. What would kill it

- A build screen before a launch. **First launch inside 60 seconds, on a rocket that already exists**, or the first session is over.
- Free-flight 3D traversal. Space Sailors and Innovation Inc own that and it is dead air for a 10-year-old.
- Real science that reads as homework. The numbers must appear as *consequence* (it tipped over because it was top-heavy), never as a spreadsheet.
- A name in the "Build a Rocket" cluster — that exact phrase maps to four dead titles in search.

## Sources

- [The Space Simulator](https://www.roblox.com/games/15027718878/The-Space-Simulator) · [wiki](https://thespacesimulator.fandom.com/wiki/Roblox_The_Space_Simulator_Wiki) · [how to play](https://www.sportskeeda.com/roblox-news/how-play-the-space-simulator)
- [Launch Into Space Simulator](https://www.roblox.com/games/15535115259/Launch-Into-Space-Simulator) · [Rocket Tester](https://www.roblox.com/games/223399075/Rocket-Tester) · [Build a Rocketship](https://www.roblox.com/games/93574010626258/Build-a-Rocketship) · [Build A Rocket](https://www.roblox.com/games/16451161308/Build-A-Rocket) · [Build a Rocket Tycoon](https://www.roblox.com/games/110267092447284/Build-a-Rocket-Tycoon) · [Build a Rocket VS Mark Rober](https://www.roblox.com/games/14618179455/Build-a-Rocket-VS-Mark-Rober)
- [Innovation Inc. Spaceship](https://www.roblox.com/games/331811267/Innovation-Inc-Spaceship) · [Space Sailors](https://www.roblox.com/games/5000143962/Space-Sailors) · [Build A Boat For Treasure](https://www.roblox.com/games/537413528)

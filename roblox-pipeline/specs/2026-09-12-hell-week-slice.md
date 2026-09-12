> Governed by `docs/ROBLOX_SUCCESS_LOGIC.md` (standing orders).
> Doctrine check: this is the first session, the first gather→feed→hold-the-night cycle, stability, and the reason to open it tomorrow. It is the slice itself.

# Spec — Hell Week, Pass 1 slice (Gate A candidate)

**Deviation from `specs/TEMPLATE.md`, declared before coding:** one consolidated spec for the slice, as run 01 did for Fat Man Gets Rich, for the same reason (ten specs before a playtest is the anti-pattern doctrine §3 names).

**Brief:** `games/hell-week/brief.md`. **Cut list:** `games/hell-week/cut-list.md` (line kept as Justin drew it).

## 0. The loop

> A stranger, alone, can say after one minute: *"Feed the light. Don't go into the dark. Don't take the pile that looks too good."*

```
pick up ASHWOOD (sack cap 3)  →  walk it to the WICK  →  radius grows, fog peels
        ↑                                                       |
   tomorrow burns faster if you slacked or took the GIFT  <-----+  night: TEMPTER walks the edge
```

## 1. The engine change this title forced — and why it is generic

The engine was one-loop-shaped (sweep-and-bank). A second loop family is exactly the case `docs/GAME_FACTORY.md` §1 anticipates: *"the day a new game forces an engine change, that change is made generic and folded back."* Every addition below is nameable for a third title:

| Module | New / changed | Generic meaning |
|---|---|---|
| `ContentLoader` | validates only the shared contract; `config.loop` picks the loop module; `world.lighting` applied from data; parts take `shape` / `rotation` | any loop, any lighting rig, discs and cylinders |
| `LoopService` | its own `validate()` (moved out of the loader) | sweep-and-bank unchanged |
| `ClockService` | new | phase clock: day/night, rounds, waves |
| `BeaconService` | new | one shared server resource with a radius: campfire, generator, shrine |
| `StalkerService` | new | unkillable pursuer that respects a safe circle |
| `SurviveLoop` | new | binds the three above to gather → feed → hold |
| `PickupService` | `place()`, `clear()`, `nearest()`, `meta` on records | static pickups for any gather loop |
| `EconomyService` | `drainCarry()` | a carry that goes into a world sink, not a wallet |
| `StateSync` | `setBuilder()`, `requestAll()` | packet shape belongs to the loop |
| `AnalyticsService` | `configure(steps)` | funnel steps belong to the loop |
| `ZoneService` | radial test for vertical cylinders | a disc on the floor is a zone |
| `Net` | `S2C_Fx` | named client moments |
| client | `SurviveHud`; bootstrap branches on `theme.loop` | one HUD per loop family |

R7 holds: no engine module names a game.

## 2. Pack (`games/hell-week/`) — the only per-title work
`server/config.luau` (every number) · `server/world.luau` (the Shore + lighting rig) · `server/sku.luau` (draft, unwired) · `shared/theme.luau` (names, colours, the two toasts).

## 3. Threat model
**Zero client→server remotes.** Pickup = server proximity sweep on anchored server parts. Feed = server-detected zone entry. Clock, fuel, weight, stalker position = server numbers. The client receives a state packet and renders it. There is nothing to forge except where the character stands, and the Tempter is the answer to standing in the wrong place.

## 4. Persistence
Profile fields added by the loop: `bestDay`, `tutorialComplete`. `carry` is zeroed on join (fuel is per run). Store, lock, migration: unchanged `DataService`. **Unverified until the unlisted publish** (`docs/runs/PERSISTENCE_TEST.md`).

## 5. Acceptance (checked at playtest)
1. Spawn 30 studs from the Wick, facing it, three Ashwood on the line, first toast at +3 s.
2. Pick up within 60 s; sack refuses the fourth with the one toast.
3. Step onto the disc: fuel +n, radius 25→49, flame grows, Tempter appears on the light-line beyond the Wick, second toast once.
4. 8 fed: fog ring steps 175→280, Ring C spawns.
5. Night 1: light dims, Tempter still. Night 2: Tempter walks toward anyone outside the radius; touch = wake at the Wick, −20% fuel, Weight +1, fade.
6. Day 3: the Gift appears on the light-line with the wrong bloom; taking it feeds +5, Weight +1.
7. Fuel 0 at night → run ends, score shown, run restarts after 8 s. Night 7 survived → week done.
8. HUD shows exactly three numbers.
9. Console clean of errors across a full run.

## 6. Out of scope (deliberate)
Days 4–7 tuning · sound wiring · Store inserts · icon/thumb · classes · leaderboard UI · ReceiptService (no product exists) · a second zone.

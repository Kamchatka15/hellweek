# GAME BRIEF — Fat Man Gets Rich

> Input to the pipeline. Written before any code (`docs/GAME_FACTORY.md` §2).
> Status: **ACTIVE TITLE** as of 2026-09-11. Layer Mine is parked (research + SurfaceKiosk mesh kit retained).

| Field | Answer |
|---|---|
| Working title | Fat Man Gets Rich |
| Slug | `fat-man-gets-rich` |
| Loop verb | **Collect** (coin gathering) |
| Hook (2 seconds) | **Coin flood** — one action sends hundreds of coins cascading; the player sweeps them up |
| Reason to open it tomorrow | **Offline earnings** — coins accrue while away, collected on login |
| Session shape | **Snack** (3–5 minutes) |
| Monetization | **Full fair-play catalog** — one overdelivering first purchase (25–99 R$) + acceleration SKUs |
| Art seed | TBD — grey-box for the first slice |
| Title change | `peter-gets-rich` → `fat-man-gets-rich` on 2026-09-11 (Justin). The original reference was Peter Griffin; Family Guy is Fox/Disney IP and was refused at build time. The rename removes the conflict — the mascot is an original everyman. |

## What the first session must do

A stranger, with nobody in voice chat, completes: **collect coins → spend them → visibly progress** — and sees the coin flood at least once in the first 60 seconds.

## Notes that bind the build

- **Offline earnings respects bedtime.** No panic timers, no decay, no "log in or lose it." Accrual is capped, not punished (doctrine §8, and the Grow a Garden precedent in PIPELINE.md §1).
- **Snack shape means the loop closes fast.** Time-to-first-coin measured in seconds, first upgrade inside the first session.
- **Full catalog is the intent, not the slice's finish line.** One obvious, overdelivering first purchase before any acceleration SKU ladder (doctrine §4.4).
- **Coin flood is the clip.** If the flood does not read at 200px in 2 seconds, the hook has failed regardless of how the game plays.
- Server-authoritative coins. The client renders the flood; it never counts it.

## Open questions (answer at Gate A, not before)

- Does the flood come from a triggered event, a rare spawn, or a player action?
- Is the coin pile visible to other players (status), or private (HUD only)?
- What is the first purchase, concretely?

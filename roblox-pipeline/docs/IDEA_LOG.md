# Idea Log

> **Governed by `docs/ROBLOX_SUCCESS_LOGIC.md` (standing orders).** If this file fights that file, that file wins.

Standing order: **propose freely, switch rarely.** Any genuinely good game idea gets pitched the moment it is noticed — by Claude, unprompted, in any session, mid-build included. Holding a good idea back is a failure. Acting on one without Justin's call is a bigger one.

## Rules

1. Claude pitches the idea in the reply, in one paragraph, then logs it here — same session.
2. Logging an idea never pauses the active title, forks the repo, or spends a build session. Continue the current task in the same reply.
3. Only **Justin** moves an entry from `Logged` to `Active`. Claude never starts a second game on its own.
4. Entries are never deleted. Dead ideas move to `Parked` with one line on why — clone waves come back.
5. Re-read the top 3 logged ideas at every Gate B / kill decision. That is when a logged idea is allowed to become the next title.

## Status values

`Logged` → `Shortlisted` (Justin flagged it) → `Active` (it is the one title being built) → `Shipped` | `Parked` (with reason)

## Entry template — copy this

### YYYY-MM-DD — <Working title> — `Logged`

- **Hook (1 sentence):**
- **Why now:** (wave age, what changed on the platform, what is trending and how long it has been trending)
- **First-session moment:** (the thing that happens in the first 60 seconds that makes someone stay)
- **Reason to open it tomorrow:** (one mechanic, not a list)
- **Closest comps:** (2–3, with rough CCU / age of the wave)
- **Why it is not a clone:** (the shape we take vs. the stuff we do not)
- **Why it would look better than the comps:** (the specific visual bet — lighting, silhouette, VFX, readability at 200px)
- **Cheapest test:** (what would prove or kill this in under a day)
- **Confidence:** low / medium / high, and what would raise it

---

## Entries

### 2026-09-11 — Fat Man Gets Rich — `Active`

Promoted to Active by Justin on 2026-09-11. Brief: `games/fat-man-gets-rich/brief.md`.

- **Hook (1 sentence):** One action sends hundreds of coins cascading and you sweep them up — the payout is physical, not a number in a corner.
- **Why now:** Collect/sweep loops read instantly in a 2-second clip and survive the 2026 discovery re-weighting toward return rather than click, because the loop is repeatable rather than novelty-dependent.
- **First-session moment:** The first flood, inside 60 seconds.
- **Reason to open it tomorrow:** Offline earnings, collected on login. Capped, never punished.
- **Closest comps:** Mine a Mountain (bag-and-bank, 131K peak May–Aug 2026, now fading), Bee Swarm Simulator (the evergreen bag-and-bank feel), Grow a Garden (offline + appointment events, 22.3M peak). Teardowns in `research/patterns/`; blend in `research/2026-09-12-sweep-and-bank-comps.md` (filled 2026-09-12).
- **Why it is not a clone:** shape only — sweep-and-bank; no comp's assets, names, characters or thumbnails.
- **Why it would look better than the comps:** the flood is the visual bet — coin count, physics, light and audio tuned so it reads at 200px.
- **Cheapest test:** grey-box flood + bank + one upgrade, playtested in Studio.
- **Confidence:** medium — hook is strong and cheap to prototype; economy and the first purchase are unproven.

### 2026-09-11 — Layer Mine — `Parked`

Parked when Fat Man Gets Rich was promoted. Not killed and not a Gate decision — a title swap by Justin. Research (`research/2026-09-11-mining-genre-winners.md`) and the `LM_Station_SurfaceKiosk_01` mesh kit stay in the repo and are still valid if it comes back.

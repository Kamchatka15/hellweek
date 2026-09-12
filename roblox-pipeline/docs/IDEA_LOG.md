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

### 2026-09-12 — Hell Week — `Active`

Promoted to Active by Justin on 2026-09-12, arriving as a packet (`inbound/HellWeek-ClaudePack.zip`) worked out with Grok. Brief: `games/hell-week/brief.md`. Pass 1 built the same day (`docs/runs/2026-09-12-run-02.md`).

- **Hook (1 sentence):** The light thins and a tall silhouette is standing on the edge of it; feed the wick or the dark walks in.
- **Why now:** 99 Nights in the Forest is the #4 experience on the platform 18 months in (260K CCU, 2026-09-12) and its shape is the safest bet in the survive family; the genre has one anchor and a long tail under 25K, so a same-shape title competes for the floor, not the crown.
- **First-session moment:** first feed inside 20 seconds — the radius pops, the fog steps back, and the Tempter is suddenly standing on the line.
- **Reason to open it tomorrow:** a run is ~15 minutes and tomorrow burns faster if you slacked or took the Gift; bestDay persists.
- **Closest comps:** 99 Nights in the Forest (260K CCU, evergreen anchor), DOORS (59K, evergreen), Dead Rails (21K, fading-to-floor). Board: `games/hell-week/ccu-board.md`; teardowns in `research/patterns/`.
- **Why it is not a clone:** shape only — fire/clock/safe-radius/night-1-mercy; no deer, no kids, no classes, no meshes, no audio, and a wedge the comps lack (a shared light nobody can grief, a 15-minute run, one moral choice a day).
- **Why it would look better than the comps:** two colours plus one warm; the Gift's bloom is the only *wrong* warm, so the trap reads at 200px before a word is spoken.
- **Cheapest test:** Gate A with three kids on the Pass 1 slice: can they say the three-sentence gist, and do they call the glowing pile a trap.
- **Confidence:** medium — the machine is proven by the anchor; the wedge (Gift, short run) is untested; days 4–7 are un-tuned by design.

### 2026-09-11 — Fat Man Gets Rich — `Parked`

Promoted to Active by Justin on 2026-09-11; **parked 2026-09-12** when Justin promoted Hell Week ("I'm not doing Fat Man, I'm creating a new game called Hell Week"). Not a Gate decision and not a kill: the slice is playable, un-tuned, unpublished, before Gate A, with zero player evidence. Everything is retained under `games/fat-man-gets-rich/` and re-mounts by editing two paths in `default.project.json`. Brief: `games/fat-man-gets-rich/brief.md`.

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

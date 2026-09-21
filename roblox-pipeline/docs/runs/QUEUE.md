# QUEUE — what Claude does when Justin is away

> Read by any unattended session, including the nightly scheduled run. **Top first.** Only reversible work (`OPERATING_MANUAL.md` §8). Never Studio, never publish, never spend.
> Every unattended session: do the top item(s), tick them, append to `evidence/CHANGELOG.md`, and rewrite the "next attended move" line in `STATE.md`.

## Next attended move (rewrite this every unattended session)
**Publish SPACEHEX unlisted + API access on** (`docs/runs/PERSISTENCE_TEST.md`), then Claude runs the persist beat; `Lighting.Technology = Future`; `rokit add luau-lang/luau`; then Gate A. The four-beat is done (3 green, 2026-09-21 morning).

## Now
- [x] 2026-09-21 — **SPACEHEX four-beat** (attended): join · buy fins → launch → paid $834K · buy decoupler · two-stage separation · hold-down. 3 green, persist blocked on the publish — run log §1
- [ ] **Decide the seed** (2 min, Justin): the game gives $1,000,000 *and* the four starters free (brief.md's words; a new player must be able to afford the $108k fins or they are stuck); the sim deducts the starters and ignores the fins rule. Options: (a) keep the game's seed and re-run the sim with it — docking moves a launch or two earlier than 19, probably fine; (b) match the sim by starting at $88k and putting Tail Fins in the starter kit — the first purchase is then a Cone, not a fix. The overnight run picked (a) for the first session
- [ ] **Decide the fins** (same 2 min): the starter stack is deliberately missing fins so the first red line is the first purchase; if Gate A shows a kid stalling at that line, move `fins_basic` into `config.startingParts`
- [ ] `rokit add luau-lang/luau` (attended — a download), then `luau tools/spacehex_career.luau` with the game's seed; paste the table into `economy.md` under a dated heading; delete `tools/spacehex_flight_check.py` or keep it as the second opinion it says it is
- [ ] Gate A script for SPACEHEX, from `brief.md`'s question (*"tell me what this game is in three sentences, then what you would buy next"*) — `games/spacehex/gate-a-script.md`, modelled on Hell Week's
- [ ] If the sky is not black on Play: give the rig's `sky` six black texture ids
- [ ] SPACEHEX sound: ignition rumble, staging thump, payout sting — Creator Store IDs onto a shelf (`games/spacehex/shelf.md`), wiring waits on the publish
- [ ] A ghost line of the previous flight's altitude on the ribbon, so "the number is bigger" is visible live (feature, Pass 2)
- [ ] Teach `tools/survive_sim.py` about recipes and the three desert resources — it still walks a one-resource world, so every number in `games/hell-week/economy.md` is provisional
- [ ] Wardstone cost check: if Gate A testers never craft one, drop it to 1 Water + 1 Stone
- [ ] Wave-4 wiring patch for Hell Week, diff-ready: shelf IDs from `games/hell-week/shelf.md` mapped onto `world.luau` props (replace primitive trees/rocks/boat with inserts, recolored), so it applies in one step once InsertService is live
- [ ] Find a night-drop sting on the Creator Store ("low drone hit", "dark sting"); add to the shelf
- [ ] Wire the four audio moments (hush loop, feed flare, night creak, pickup) as pack data — `theme.audio` — and a tiny generic `SoundService`-side player in the engine (unattended: write it, do not sync to Studio)
- [ ] Re-run `tools/survive_sim.py` with co-op (2–4 sacks) and the Tempter penalty modelled; one page for G2
- [ ] Icon + thumbnail prompts written from the formula (one silhouette on the light-line, one giant Ashwood, ≤3 words); generation waits for G4

## Next
- [ ] Teardown 3 (Dead Rails or Forsaken) on the template — the board has the numbers, the shapes are not filled
- [ ] TestEZ installed + invariants for `BeaconService` (never negative, cap honoured) and `ClockService` (phase order)
- [ ] `src/core/client/` mount so UIKit and the two HUDs stop living in the game's client folder
- [ ] Fat Man Gets Rich closeout note (parked, not killed): what the engine learned from it, one page

## Standing (any spare unattended cycle)
- [ ] Keep `research/patterns/` growing — one teardown per spare cycle, any genre
- [ ] Re-verify a platform fact older than 2 months and file the result
- [ ] Read the ledger for anything at n=1 that a second title could reproduce

## Done
- [x] 2026-09-21 — SPACEHEX overnight build: BuildLoop (third loop family), BuildHud (three screens), launch playback with staging and hold-down, payout + milestones + missions as data, generated rocket silhouette, lighting rig; all gates green, never booted — `docs/runs/2026-09-21-spacehex-run.md`
- [x] 2026-09-12 — Hell Week intake (fast path), Wave 1 files, Pass 1 pack, engine generalised to two loop families, four-beat 3/4 green (persist blocked on publish) — `docs/runs/2026-09-12-run-02.md`

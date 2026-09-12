# QUEUE — what Claude does when Justin is away

> Read by any unattended session, including the nightly scheduled run. **Top first.** Only reversible work (`OPERATING_MANUAL.md` §8). Never Studio, never publish, never spend.
> Every unattended session: do the top item(s), tick them, append to `evidence/CHANGELOG.md`, and rewrite the "next attended move" line in `STATE.md`.

## Next attended move (rewrite this every unattended session)
**Justin's two clicks** — publish unlisted + Studio API access on (`docs/runs/PERSISTENCE_TEST.md`), and `Lighting.Technology = Future`. Then Claude runs the persist beat and Wave 4 dressing for Hell Week.

## Now
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
- [x] 2026-09-12 — Hell Week intake (fast path), Wave 1 files, Pass 1 pack, engine generalised to two loop families, four-beat 3/4 green (persist blocked on publish) — `docs/runs/2026-09-12-run-02.md`

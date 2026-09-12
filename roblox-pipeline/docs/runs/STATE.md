# STATE — the control panel

> Loaded into every Claude Code session by `.claude/hooks/session_start.py`. **One file. Keep it current.** Stale is worse than missing.

## Standing rule until further notice (2026-09-12)

**No further system work — no new hooks, agents, or restructuring — until Fat Man Gets Rich has been through Gate A with three fresh testers.** Only work that directly unblocks that test is allowed. The test of the factory is a game. (`docs/FACTORY_PLAN.md` Part 4.)

## Where we are

| Field | Value | Updated |
|---|---|---|
| Active title | **Fat Man Gets Rich** (`games/fat-man-gets-rich/`) | 2026-09-11 |
| Parked | Layer Mine (research + SurfaceKiosk mesh kit retained) | 2026-09-11 |
| Gate position | **Before Gate A.** Grey-box slice playable end to end; un-tuned; unpublished | 2026-09-12 |
| Economy | **Sim run: the ladder is exhausted by day 3 and offline is 82% of coins.** Candidate C proposed for G2 (`docs/runs/2026-09-12-economy-sim.md`, E-0006). Not yet applied to `config.luau` — G2 is Justin's | 2026-09-12 |
| Persistence | **Unverified.** Blocked on an unlisted publish (Justin's click). Test script ready: `docs/runs/PERSISTENCE_TEST.md` | 2026-09-12 |
| Engine | 11 modules. `ReceiptService` deliberately absent until a product is approved at G5. R7 keeps the engine generic | 2026-09-12 |
| Paid products | **None.** No `MarketplaceService` call in the repo. `sku.luau` is a draft ladder | 2026-09-12 |
| Art | Grey-box. **Style spec + Creator Store shelf ready** (`research/2026-09-12-style-spec-fat-man.md`) — Justin cuts from it at G4. Nothing inserted yet | 2026-09-12 |
| Enforcement | R1–R7 + loop cap + SessionStart + git backstop (now also rojo build / selene / stylua on the Mac) | 2026-09-12 |
| Evidence | 6 records (5 process, 1 economy). 0 player evidence — Gate B has not happened. 0 open contradictions | 2026-09-12 |

## The cut list is ready (`research/2026-09-12-sweep-and-bank-comps.md`)

Top-three teardowns done (Mine a Mountain, Bee Swarm, Grow a Garden). Ten shapes proposed, budget applied, **line drawn after #5**: named upgrade tiers, a timed golden flood (the clip), a visible coin pile. Rare coin variants, the magnet bomb, gifting, zones and trading parked. **Justin moves the line — two minutes.**

## Waiting on Justin (only the irreversible ones)

1. **Publish an unlisted place** so the save path can be tested — `docs/runs/PERSISTENCE_TEST.md` has the exact clicks and the test.
2. **G2 economy:** approve, adjust, or reject Candidate C from the sim before Gate A (the slice can be tested un-tuned, but the numbers in front of the kids should be the ones we mean).
3. **Approve the re-created weekly digest** (bound to this folder, writes to `research/`).
4. **Doctrine wording, §9 role split:** proposed one-line amendment — *"Human owns: ship / no-ship, money, and **the cut** — removing what confuses. Generative taste is not asked of the owner; the AI proposes, the owner prunes."* Yes / no / edit.
5. **Confirm** the doctrine's Gate B floor (~12%+ OK to test spend; under ~8–10% death) governs over the higher numbers in PIPELINE and SYSTEM-MAP — both files now say so; this is the confirmation.

## Next real move

**Gate A.** Hunter recruits three kids who have never seen it; runs `skills/playtest-comprehension.md` verbatim; Justin does the 10-minute fun-check separately. Output: the stop-and-patch list, the two budget questions answered, two hypotheses marked, and the first player evidence the ledger has ever held.

## Open gaps named on purpose

- No sound; no art seed (G4, after Gate A).
- Late-ladder wall in every deep tuning — needs a second sink, a G2/live-ops decision with Gate B numbers.
- No unattended disk→Studio path beyond `tools/studio_sync.py` (documented in `skills/studio-mcp.md`).
- TestEZ not installed; economy invariants exist only as the sim.

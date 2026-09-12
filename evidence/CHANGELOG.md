# Factory changelog

> Append-only. Never rewritten, never reordered. Every autonomous change to the factory lands here with the reason that caused it.
> This is how a system that modifies itself stays auditable by someone who was not in the room when it did.

---

## 2026-09-12 · Three open decisions closed by Claude, at Justin's direction

Justin's instruction: *"i dont know about this. make a logical decision about how to improve the process."* All three were sitting unanswered and blocking. Reasoning recorded in full because the decisions are reversible and should be arguable later.

### 1 · The complexity budget caps — REFRAMED, not decided

**Was:** "Justin should own the caps." **Now:** the caps are provisional defaults with an expiry, owned by nobody, moved by evidence.

Putting them to Justin was a category error on Claude's part. He stated he does not supply generative taste — and a cap is a generative taste judgment wearing a number's clothing. "Four systems" measures nothing; it is a guess about legibility. Ratifying a guess produces a guess with the owner's signature on it, which is *harder* to change than an unsigned one.

The decision that dissolves the question: **nobody has to be right today.** The caps hold until the first Gate A comprehension test, which asks two questions about the budget itself — did a cap block something the slice needed, and did testers get confused *inside* the caps. Both file evidence records. A cap surviving two titles reaches n=2 and becomes a real default.

→ `roblox-pipeline/docs/BUDGET.md`

### 2 · Who runs the comprehension test — DECIDED, with a correction Justin had not raised

**Decided:** three or more kids who have never seen the game. Hunter is the **operator**, not the subject.

The correction: **Hunter is contaminated the same way Justin is** for any title he helped design. He knows what the button does because he was in the room when it was decided. A co-designer passing a comprehension test is the easiest available way to convince yourself a confusing game is clear, and it would have quietly invalidated Gate A on every title he touched. He may be a subject only for titles he had no design input on.

Also fixed: the script is now verbatim and identical every time, because varying it makes results incomparable, which defeats the ledger.

→ `roblox-pipeline/skills/playtest-comprehension.md`

### 3 · The folder restructure — REVERSED

**Claude's previous position:** move the factory to the root now, "painful after a second title exists." **Now: do not move it. Enforce the boundary instead.**

The reversal, stated plainly so it can be argued with:

- The physical move rewrites every path and the Rojo project config. A broken Rojo project blocks **all** game work, and it would be broken in service of a second title **that does not exist**.
- Doctrine §3's "does not count" list and Justin's own incremental-cost discipline both say: do not build for a second game before there is one.
- **What actually makes the factory portable is the boundary, not the folder layout.** A generic engine in the wrong directory is portable. A game-aware engine in a beautiful directory is not.
- That boundary can be enforced *today*, mechanically, with the machinery already built — which is strictly better than a folder move that enforces nothing and could be violated the next morning.
- E-0002 supports the boundary being the valuable thing: the engine/pack split made a full title rename cost one commit. It says nothing about folder location.

**Therefore: hook R7.** Any module under `src/core/` that names a specific game is refused. The engine stays generic by force rather than by intention, and the physical move happens when a second title actually needs it — informed by a real second use instead of a guess about one.

Trade accepted: the move will cost more later. That cost is real and smaller than breaking the only working repo today for a speculative benefit.

→ `.claude/hooks/rbx_guard.py` R7, verified: clean across all 11 existing engine modules, fires on a module that names a game.

---

## 2026-09-12 (evening) · Second pass — solutions to the re-examination

Justin: *"come up with solutions to this … go over it twice, think of new ways or organize the entire plan, or solve the problems piece."* Everything below is either a document fix or something that unblocks Gate A. No new system.

| Change | Kind | Evidence / reason |
|---|---|---|
| `tools/econ_sim.py` + `docs/runs/2026-09-12-economy-sim.md` | Game-facing tool | PIPELINE §7.1 required a sim before anyone plays. It found the ladder exhausted by day 3 and offline at 82% of coins → **E-0006**. Candidate C proposed for G2; **not applied** — G2 is Justin's |
| `.githooks/pre-commit` now runs rojo build + selene + stylua | Backstop | Run 01 risk #5 — nothing enforced build/lint on commit |
| PIPELINE §4, SYSTEM-MAP §9: D1 numbers relabelled as tiers above the doctrine floor | Consistency fix | Three files disagreed; doctrine precedence rule |
| PIPELINE §7.5: Gate B = listed publish, zero spend; unlisted is for Gate A | Correction | An unlisted place meets no strangers; Gate B needs 200–500 of them |
| PIPELINE §13 checklist: first target ticked | Housekeeping | Decided 2026-09-11 |
| `skills/playtest-comprehension.md`: not the same test as the Hunter protocol | Clarification | Two valid tests, different subjects |
| `skills/studio-mcp.md`: studio_sync, the MCP-require rule, screen_capture edit-only | Rule from practice | Run 01 §3.2, §3.4, §3.5 — findings that never made it into a rule |
| `skills/rojo-map.md`: engine PascalCase, pack lowercase | Ruling | Run 01 gap #8 |
| `games/fat-man-gets-rich/brief.md`: two proposed hypotheses | Design (active title) | SYSTEM_ARCHITECTURE §5 — a closeout needs something to be wrong against |
| `docs/runs/STATE.md` rebuilt as the control panel | Structure | One file SessionStart loads: standing rule, position, what waits on Justin, next move |
| `docs/runs/PERSISTENCE_TEST.md` | Preparation | Run 01 risk #1; the click is Justin's, the test is ready |
| Weekly digest re-created Mac-bound, writing to `research/` + `DIGEST_LOG.md`; old chat-only task **disabled** (not deleted) | Rewiring an existing automation | It was Layer 3's only running mechanism and it fed nothing |
| `session_start.py` surfaces the latest digest line | 4-line hook change | So research actually reaches a session |
| FACTORY_PLAN v1.1: life-of-a-title timeline, Gate B correction, Grok confusion pass, onboarding-after-Gate-A rationale, status refreshed | Document | Second pass, as asked |

**Standing rule recorded in STATE.md:** no further system work until Fat Man Gets Rich has been through Gate A with three fresh testers.

**Decisions now waiting on Justin (in STATE.md):** unlisted publish for the persistence test; G2 economy (Candidate C); doctrine §9 wording ("the cut"); confirm the Gate B floor.

---

## 2026-09-12 (night) · Copy aggressively, folded into the factory

Justin: *"put this all into the game factory including all the scraping and copy other 3rd art, styles and colors and objects from other games, so I can quickly develop an initial testing model of the game."*

| Change | Kind | Reason |
|---|---|---|
| Doctrine §3.1 "Copy aggressively" | **Justin's decision** (a core doctrine position) | "Most of this stuff looks alike — if you can clone and copy something do it; I'll edit it out." Two tables: copy on sight vs. what deletes the title regardless of doctrine |
| `research/patterns/TEMPLATE.md` + three teardowns (Mine a Mountain, Bee Swarm, Grow a Garden) | Title research | The expansion step needs fuel; the idea log's comps field had said "to fill" since 09-11 |
| `research/2026-09-12-sweep-and-bank-comps.md` — ten-shape cut list, line after #5 | The build loop, run once by hand | Justin moves the line |
| `research/2026-09-12-style-spec-fat-man.md` + Creator Store shelf (~20 free IDs, models + audio) | Legal copying of existing assets | "Make the game look better in Phase 1 to keep the kids' interest" |
| `skills/audio-sourcing.md` | Ranked sources | Justin's "where is the best place to get music" |
| `art/reference/` board, git-ignored | Owner's mood board | Justin's request for a folder to rework comps' art by hand. The build feeds ORIGINAL work from it; it does not auto-download assets to make derivatives — a reworked rip fingerprints as the original and is pulled after Gate B |
| Dressing moved BEFORE Gate A | **Justin's decision** | A grey box cannot hold a kid long enough to produce metrics |
| FACTORY_PLAN v1.2: §1.1 thesis in Justin's words; §2.10 Copy aggressively (Fig. 17); teardowns + worked cut list; shelf + board + sound; §5.2 the initial testing model in six moves (Fig. 18); risk row for copying; status refreshed | Document | As asked — everything from tonight in one place |

**The coupling recorded everywhere it matters:** InsertService (dressing) and DataStores (saves) are both blocked until the unlisted publish with API access. One click unblocks dressing, persistence, and the comprehension test on a real build.

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

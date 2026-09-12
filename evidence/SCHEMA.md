# Evidence ledger — schema and rules

> One canonical home for everything the factory has learned. Read by every project, written back by every title.
> Governed by `roblox-pipeline/docs/ROBLOX_SUCCESS_LOGIC.md`.

## Why records, not documents

A closeout written as prose cannot be compared to anything. The point of this ledger is that a **new** situation can be matched against **past** ones automatically — so before a single line of a new game is designed, the relevant history is already on the table.

That only works if every record carries the same fields, and above all the same **context tags**. A finding without its context is not knowledge, it is a rumour: *"offline earnings beat daily login"* is not true in general. It was true for a snack-shape collect game aimed at 8–12 during a rising wave. Strip the context and it becomes confident bad advice.

## The seven context dimensions

These are what make two situations comparable. Keep the list small and fixed — a dimension added casually makes every existing record less matchable.

| Dimension | Values |
|---|---|
| `domain` | design · economy · retention · art · marketing · process · tech |
| `loop_verb` | collect · mine · steal · build · race · survive · fight · tycoon |
| `session_shape` | snack · sit-down |
| `audience` | age band, e.g. `8-12`, `13-16`, `broad` |
| `monetization` | none · cosmetics · full-catalog |
| `wave` | rising · peak · fading · evergreen |
| `scale` | pre-launch · u100 · 100-1k · 1k-10k · 10k+ |

`domain` is load-bearing: it stops an art finding being matched against an economy problem.

## Record format

One file per record, `ledger/E-####.md`, flat `key: value` front-matter (no nesting, so it parses with no dependencies), then free prose notes.

```
---
id: E-0001
claim: one sentence, specific enough to be wrong
domain: process
loop_verb: any
session_shape: any
audience: any
monetization: any
wave: any
scale: pre-launch
outcome: confirmed | refuted | inconclusive | observed
metric: what actually settled it
confidence: n=1
observed: 2026-09-12
source: roblox-pipeline/docs/runs/2026-09-12-run-01.md
status: active
---
Prose notes. Why it happened, what would change the answer.
```

`any` means the claim is not scoped on that dimension. Use it honestly — marking everything `any` produces a record that matches everything and means nothing.

## The three rules that keep it from rotting

**1 · Confidence is always visible.** `n=1` is one observation from one game, and it must never be read as a law. A claim earns `n=2` only when a *different* title reproduces it. Nothing becomes a default below `n=2`. This is the rule that stops the ledger laundering a single accident into doctrine.

**2 · Contradictions are kept, never resolved by overwriting.** When a new title refutes an old record, do **not** edit the old one. File the new one, link them with `contradicts:`, and leave both standing.

> A contradiction is the single most valuable thing in the ledger. Two honest results that disagree mean **a context dimension is missing** — something varied between the two games that nobody was tracking. Finding that variable is how the matrix actually gets smarter. Overwriting the loser destroys exactly that information.

**3 · Records go stale.** Roblox changed discovery, ads, gambling policy and testing tools inside fifteen months. Any record older than 12 months is flagged on retrieval and must be re-verified before it is relied on. A record invalidated by a platform change is marked `status: retired` with the reason — never deleted, because the reason is itself evidence.

## How it gets used

At intake, before any design work, `match.py` reads the new brief's context and returns the ledger records whose context overlaps, ranked, **with the reason each one matched**. The expansion step is then seeded by history instead of starting from a blank page. Explainable beats clever here: a match you cannot interrogate is a match you cannot overrule.

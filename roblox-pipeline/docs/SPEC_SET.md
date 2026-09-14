# The spec set — what must exist before I write code

> Reusable across every title. Hell Week has 17 markdown files and 1,829 lines, and I still had to
> guess at things while building. That is not a volume problem. It is a **kind** problem.

## The diagnosis

Those 17 files are mostly **records of things that already happened**: watch logs, audits, gap lists,
findings. Records are good and they accumulate forever. What is missing is a small, finite set of
**authoritative** documents that say what the game IS.

- A **record** answers *what did we learn*. It is append-only and grows without limit.
- A **spec** answers *what is true right now*. It is edited in place and never grows.

Mixing them is why the folder feels like it is multiplying. Separate them and the spec set stays at
eight files forever, however long the project runs.

---

# The eight

Each one exists because its absence **blocks code**. If a document does not block code, it is a
record, and it goes in `research/`.

## 1. `GAME.md` — what this is
The one I read first, every session.

- One sentence: what the player does and why
- Who it is for, and the age it is aimed at
- Session shape: how long is a run, what ends it, what winning means
- The wedge: what this does that the games it resembles do not
- The three things that must be true or the game is not worth making

**Blocks:** every scoping decision. Without it I cannot tell an essential feature from a nice one.

## 2. `LOOP.md` — the verbs and the cycles
- The core verb, the one thing the player does ten thousand times
- Second-to-second, minute-to-minute, run-to-run, and between-runs cycles, drawn
- What feeds what: the loop graph
- What the player is afraid of, and what they do about it

**Blocks:** all systems code. Hell Week's camp got built correctly only because this existed.

## 3. `CONTENT.md` — the bible
Every noun in the game, in one place.

- Items: name, what it is for, where it comes from, what it becomes
- Tools and weapons: what they do, what they cost, what they beat
- Creatures: what they want, what kills them, what they drop
- Structures and camp pieces
- Biomes: what is different about each

**Blocks:** content code, recipes, drop tables, spawn logic. Scattered content is the single biggest
cause of me inventing an item that already existed under another name.

## 4. `NUMBERS.md` — every tuning value, with reasoning
The one that most directly blocks code, and the one Hell Week most lacks.

- Every speed, time, radius, cost, cap, count, chance, in one table
- The **reason** next to each, because a number without a reason cannot be safely changed
- Which are **frozen** and which are **placeholders**

**Blocks:** literally every function with a constant in it. Hell Week's days 4 to 7 have been
labelled "PARKED" in a code comment for a week, which is exactly the information that should be here.

## 5. `ART.md` — the style guide
What makes a thing look like it belongs in this game.

- The locked palette, as hex, with names and what each is for
- Material vocabulary: which surfaces are which material, and why
- Scale hierarchy: landmark, structure, prop, detail, with stud ranges
- The silhouette rule: what must be nameable at what distance
- Lighting rigs for each phase, as values

**Blocks:** every generator, every prop, every import decision.

## 6. `UI.md` — what is on the screen
- Every readout: what it shows, where it sits, when it appears
- Every button and its key
- Every message: the trigger, the wording, the tone, the style
- What a new player sees versus what a late-run player sees

**Blocks:** all client code. Also the single largest source of "that is not what I meant".

## 7. `PROGRESSION.md` — what unlocks when
- Day by day: what is available, what is threatening, what the player should be doing
- What carries between runs and what resets
- The ladders: tools, capacity, materials, access

**Blocks:** gating, unlock logic, the difficulty curve.

## 8. `RULES.md` — what must never happen
- Safety and moderation limits
- IP: what may not be copied, named, or resembled
- Monetisation gates and what needs a human approval
- Engine boundaries

**Blocks:** nothing. It **prevents**. And anything here that truly must never happen belongs in a
hook, not a document, because a hook is enforcement and a document is a hope.

---

# Everything else

| Where | What goes there |
|---|---|
| `research/` | Watch logs, competitor teardowns, audits, findings. Append forever |
| `decisions.md` | One line per decision: what, when, why. Append-only |
| `gates/` | Test scripts and their results |

**The rule:** if a new document would be the ninth spec, it is not a spec. Either it belongs inside
one of the eight, or it is a record.

---

# Answering the other question, honestly

*Has the AI got better, or have you got better at explaining?*

Both, but the second is doing more of the work, and there is evidence in this week.

The most useful design input of the last seven days was not any analysis I produced. It was one
sentence your son said: *he builds his camp on day one so he can explore later.* The second most
useful was your correction that a creature dying in three swings destroys suspense. Neither came from
me, and both changed the architecture.

That is what specifying well looks like, and it is the higher-leverage variable. My analysis gets
better when it has something true to reason from. Give me the eight documents above and the gap
between what you meant and what I build closes a long way.

---

# Part 2 — Getting to 99 Nights graphics quality

## The uncomfortable finding

I watched that game for an hour. **Its prop art is not technically impressive.** Simple low-poly
shapes, flat colours, no fancy shading. Our rocks are not worse than their rocks.

What makes it look good is four things, and only one of them is modelling:

| What | Ours |
|---|---|
| **One consistent art language** everywhere | Close. Our generator already enforces this |
| **Lighting doing the heavy lifting** | Half there. Shadows were off until this week |
| **Painted ground** — decals for zones, paths, sites | **We cannot do this at all.** Engine has no decal support |
| **Rigged, animated characters** | **We have none.** This is the real gap |

**So "99 Nights quality" is mostly not fidelity. It is coherence, lighting, and animation.** A
beautifully modelled creature that slides across the ground looks worse than a crude one that walks.

## The order that actually closes the gap

### Step 1 — Animate one creature. This is the whole ballgame.
A rigged, animated scorpion will do more for perceived quality than re-texturing every rock in the
desert. Nothing else on this list comes close.

How, without Blender:
1. `generate_mesh` with `segmentation: explicit` and `partNames: "head, body, tail, claws, legs"`
2. Join the returned parts with **Motor6D** instead of welds. That is a rig
3. Animate it in Studio's built-in **Animation Editor**
4. Play it from code with `Animator:LoadAnimation`

Do this on the scorpion first, because it is small and nobody will mind if it looks odd. If it works,
the same path does the bosses.

### Step 2 — Give the engine decals
`ContentLoader.block()` reads eleven keys and none of them puts an image on a surface. That is why
our ground detail is rectangles of slightly different sand with hard corners. Painted ground is how
that game marks every important place, and we cannot do any of it.

### Step 3 — Write `ART.md` and enforce it in the generator
Nine base colours inside a four percent band is not a palette, it is one colour with noise. Widen it,
give each prop type two or three material variants, and two-tone every prop with a second part.

### Step 4 — Particles
There is one emitter in the entire engine and it is hardcoded to fire. The Still Wood's own design
note asks for "ash falling like snow" and there is no way to emit it.

### Step 5 — Hero assets only, by hand
One landmark per biome and the bosses. This is where Blender or an artist earns their place. Not
rocks. Rocks stay procedural forever.

## What I would not do
Do not try to match their fidelity prop for prop. They had a team and three months, and the
fidelity is not what you are responding to when you look at their game. You are responding to a
world that agrees with itself and has things moving in it.

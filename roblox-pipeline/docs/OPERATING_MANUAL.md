# The Game Factory — operating manual

> **Governed by `docs/ROBLOX_SUCCESS_LOGIC.md` (standing orders).** If this file fights the doctrine on safety, children, money or publishing, the doctrine wins.
> **This is the file a session runs.** `docs/FACTORY_PLAN.md` (and `The-Game-Factory.pdf`) is the constitution behind it — the why, the layers, the evidence design. This is the how, short enough to hold in one head.
> v1.0 · 2026-09-12 · built from FACTORY_PLAN v1.2 + Grok's v2.0 operating-manual pass + Justin's working hours.

---

## 0 · Two clocks, not one

The single most important fact about how this project actually runs, and the thing every earlier version of this document got wrong:

| Mode | Time available | What happens |
|---|---|---|
| **Attended** | **Up to ~4 hours a day**, more at the start | Justin is near the computer. Gates, the cut line, playtests with a human watching, the G5 clicks, anything needing Studio plus eyes. |
| **Unattended** | Everything else — overnight, away, between sessions | Claude works alone from `docs/runs/QUEUE.md`: research, teardowns, sims, shelf, specs, docs, prep. Reversible work only (autonomy contract). Never Studio, never publish, never spend. |

**The design rule that follows:** every wave below is tagged **[A]** attended or **[U]** unattended. A session that opens while Justin is away runs the [U] work and leaves the [A] work queued with everything prepared so it takes minutes when he sits down. A session that opens while he is there does the opposite — it spends his four hours only on things that need him.

*Superseded: PIPELINE.md's "~12-minute weekday review window." That was the wrong constraint. Four hours attended is a different project.*

---

## 1 · Who does what

| Role | Owns | Never |
|---|---|---|
| **Justin** | The name and four paragraphs. Moving the cut line (2 min). G2 numbers. G4 icon/thumb. G5 list / paid products / kill. The unlisted publish + API access, once per title. | Fills forms. Invents mechanics. Writes Luau. |
| **Hunter** | Gate A: three fresh kids, verbatim script. Fun-check beside Justin. | Is the test subject for a title he helped design. |
| **Claude** | Everything else. The only writer to `src/` and the live Studio DataModel. | Opens Open Cloud. Creates paid products. Writes while a second agent is in Studio. |
| **Grok** *(optional, never blocks)* | Extra teardowns, the confusion pass, art sheets, thumb variants, clip-hook lines, critique. Delivered as files. | `src/`, Studio, repo commits, or holding up a wave. |

**Grok never blocks.** If the tab is dark, Claude self-passes the same job in ten minutes and continues. A Grok job is a parallel bonus, never a gate. *(Grok's own correction, adopted.)*

---

## 2 · The six waves

If a title is already **Active**, do not open Wave 0 on a new slug — jump to the holes in the active one. Hopping is the failure the doctrine names.

| Wave | Mode | Claude must produce | Grok may add | Justin |
|---|---|---|---|---|
| **0 · Kick** | [A] 15 min | Slug. `brief.md` drafted **from the four paragraphs** — never a form to fill. Ledger queried for this context. **If the brief arrives as a packet** (a zip in `inbound/`, a GDD, a doc he worked out with Grok): it is Justin's brief in file form. Run `skills/inbound-intake.md` — extract, translate onto the file contracts, **keep going into Wave 1**. Do not audit it or hand back a form. Only platform blocks and the budget stop anything, and both would fire on his typing too. | — | Name + four paragraphs, **or** a packet in `inbound/`. Silence on the draft brief = accept. |
| **1 · Swarm** | **[U]** | Comp board: 5 live comps by CCU. **Three** filled teardowns (3 is enough; 10 is stalling). `wedge.md` from their complaints. `theme.md` five lines. `shelf.md` ≥12 model IDs + ≥4 audio IDs. `economy.md` + sim. `lighting.md`. | Teardowns 4–5, art sheet, thumb variants | None |
| **2 · Cut** | [A] 20 min | `cut-list.md` with the line drawn, Pass 1 vs Pass 2 named, parking list, two hypotheses in the brief. | Confusion pass — *"which of these loses a ten-year-old?"* If absent, Claude self-passes in 8 min. | **Move the line. 2 minutes.** Silence = keep the line. |
| **3 · Build** | [A] + [U] | Pass 1 on the engine: one verb, teach-the-sink, one return hook, onboarding artifact, instrumentation. R1–R7 clean. **No second verb.** | Pass 2 names, clip copy, thumb prompts, MCP script critique | None. *(Unlisted+API blocks honest persistence — see Wave 4.)* |
| **4 · Dress + prove** | [A] | Shelf inserted by ID, recolored to spec, lighting rig applied, one hero collectable, look-bar checks, MCP four-beat green, persist 7-row. | Extra thumb candidates | Publish unlisted + API on (once). G4 on icon/thumb — silence 30 min = ship the pair. |
| **5 · Packet** | [A] short | List-ready checklist. Gate A script printed for Hunter. Evidence records. `STATE.md` next move. Session-close. | Launch copy, clip-hook lines | G5 to list. No ads tonight. |

**Fan-in:** a missing teardown does not stall the cut. Three filled templates are enough. One writer per file; two writers on one file is a failed wave.

**On the clock:** attended waves fit inside a four-hour day with Wave 1 done overnight. The first real run gets **timed and filed**, and the measured number replaces this paragraph. Nobody's estimate — not mine, not Grok's — is evidence yet.

---

## 3 · File contracts — Claude writes these, nobody else

| Path | Wave | Stop condition |
|---|---|---|
| `games/<slug>/brief.md` | 0 | Six questions drafted from prose · two hypotheses · ledger matches appended |
| `games/<slug>/ccu-board.md` | 1 | 5 titles · CCU · wave stage · verb family |
| `research/patterns/<comp>.md` ×3 | 1 | TEMPLATE complete through **COPY THIS / DO NOT COPY** |
| `games/<slug>/wedge.md` | 1 | One clip/social hook the comps lack. Not a second verb |
| `games/<slug>/theme.md` + `shelf.md` + `lighting.md` | 1 | Five style lines · ≥12 model IDs · 4 audio IDs · lighting numbers |
| `games/<slug>/economy.md` | 1 | Ladder shape + candidate numbers + sim result |
| `games/<slug>/cut-list.md` | 2 | Line drawn · Pass 1 / Pass 2 / PARKED |
| `games/<slug>/` pack `.luau` | 3 | Loop boots. R1–R7 clean |
| `docs/runs/YYYY-MM-DD-<slug>-mcp.md` | 4 | Four beats + persist + four screenshots + one kid-confusion note |
| `docs/runs/CLOSEOUT-<slug>.md` | 5 | Hypotheses marked · evidence filed · engine candidates named |
| `docs/runs/STATE.md` + session-close | 5 | Next move in one line · what changed · evidence IDs |

---

## 4 · Pass 1 / Pass 2 — trace the machine, then make it ours

*(Grok's sequencing, adopted — it separates "does it work" from "does it look like ours," and Pass 2 can be prepared while Pass 1 builds.)*

| Pass 1 — built first | Pass 2 — prepared in Wave 1, snapped on in Wave 4 |
|---|---|
| One verb and its cadence | Theme names for the same upgrades — never their SKU names |
| How the bag / plot / hive teaches the sink in the first minute | Five-line style + shelf recolored to it |
| One return hook. **Our** sim numbers, not theirs | Clip / social surface from `wedge.md` |
| Generic Store stand-ins so MCP has something to look at | Hero collectable that reads at 200px |
| Onboarding artifact + instrumentation | Icon 512² + thumb 1920×1080, formula locked |
| R1–R7 green | Parked: zones, trading, gifts, rare variants — after Gate B |

**Copy matrix.** Copy freely: verbs, cadence, HUD density, first 60 seconds, colour logic, appointment rhythm, price-ladder *shape*, thumbnail formula, tracker stats. Never: meshes, textures, animations, scripts, audio files, names, mascots, logos, private endpoints, or a one-source visual clone. **If a step needs another creator's file, the step is wrong** — search the Store by silhouette, or generate in-style.

---

## 5 · The look bar — dress the slice so a kid stays

Kids compare readability, not triangle counts. A 200px tile, then a first minute. **Default lighting is why generated places look generated.**

| Job | Share | Claude does |
|---|---|---|
| Volume | ~80% | Store shelf by silhouette, insert by ID, **recolor every insert** to the two-colour spec |
| Light | (of that 80%) | `lighting.md`: Future lighting on a small slice, ClockTime for mood, Atmosphere haze, ColorCorrection contrast +0.1–0.2 and saturation slightly up, Bloom on gold/event only, warm PointLight on the destination |
| Hero | ~15% | 3–5 hero objects: one reference sheet (¾, clean ground, spec colours) → Cube short prompt or image-to-mesh, triangle cap, or Meshy/Tripo remeshed. Third regenerate = build from primitives |
| Icon + thumb | ~5% | Written from the formula, generated in an image tool. 512² and 1920×1080, readable at 200px |
| Destination | — | One Store vault/building as mass, facade painted to spec. **Must be readable from spawn** |

**Look-bar checklist — run before MCP, not after**

- [ ] 200px icon/hero: the collectable is nameable at phone-arm length
- [ ] Spawn shot: the destination building is pointable without a sentence
- [ ] Meter: exactly one filling number on screen
- [ ] Palette: two colours + ground; a third only on the event
- [ ] Set dressing: no adjacent Store packs from visibly different styles
- [ ] Light: default lighting gone; destination is the brightest thing that is not the event
- [ ] IP: no owned names or mascots (R6 is a Phase-1 block, not a warning)

*These proportions and numbers are **defaults with an expiry**, like the budget caps — asserted, not measured. The first Gate A moves them.*

---

## 6 · MCP four-beat — the definition of "built"

A compiling pack is not a game. **A green run log is.** Requires the unlisted place with Studio API access; without it, InsertService and DataStores are dark and the test lies.

| Beat | Claude via Studio MCP | Pass |
|---|---|---|
| 1 · Join | Start play, screenshot spawn, read console | No error spam · player can move · first action obvious |
| 2 · First earn | Drive the verb until a number goes up | Within 60 simulated seconds · screenshot the meter |
| 3 · First spend / sink | Walk to the destination, complete the sink | Server-side balance change · client cannot edit it (R1) |
| 4 · Upgrade + persist | Buy the first named tier, stop play, start play | Upgrade and currency survived · not a memory store |

Write the run log every time: commands, console excerpts, four screenshots, pass/fail per beat, **one sentence a kid would still not understand**. A red beat is patched in the same wave. **Never hand Justin a "built" slice with a red beat.**

**"Test it" returns two things**, not one: the four-beat run log *and* the Gate A script for Hunter. A mechanical pass is not a comprehension pass — four green beats can describe a game no child would play.

---

## 7 · What Justin can say

| He says | Claude runs | Done when |
|---|---|---|
| *"New game: [name]. [four paragraphs]"* | Waves 0–2, stop at the line | brief + board + 3 teardowns + cut-list in front of him |
| *"Keep the line. Build."* | Wave 3 Pass 1 | Pack boots. R1–R7 clean |
| *"Make it look like the top games."* | Wave 4 dress + look bar | Look bar green. G4 pair waiting |
| *"Test it."* | MCP four-beat + persist | Green run log **and** Hunter's Gate A script — or a patch list |
| *"List it."* | Packet only | Checklist. He clicks G5 |
| *"Kill it" / "Keep it."* | Closeout + evidence + engine candidates | Next title starts smarter |
| *"What can you do while I'm out?"* | Reads `QUEUE.md`, runs the top [U] items | Queue advanced, `STATE.md` updated, nothing irreversible touched |

---

## 8 · Working while Justin is away

`docs/runs/QUEUE.md` is the unattended backlog. Any session that opens without Justin present — including the scheduled nightly run — works down it, top first, and appends what it did to the changelog.

**Allowed unattended** (reversible, autonomy contract): research and teardowns · economy sims and re-tunes proposed · Store shelf searches · style and lighting specs · specs and templates · doc fixes · evidence records · ledger queries · closeout drafts · anything that ends in a file.

**Never unattended:** Studio (one writer, and nobody is watching) · publishing or listing · paid products · spending · killing or switching a title · lowering a bar · anything the autonomy contract puts in Justin's column.

**Every unattended session ends by writing** the next attended move in one line at the top of `STATE.md`, so his four hours start at the right place instead of with a status meeting.

---

## 9 · Settled — Claude does not re-litigate these; Justin always can

*(Grok's "locked" section, with the mechanism corrected. Nothing is closed to the owner — he reopened the IP ban tonight and was right to. This is a bar on Claude re-arguing them every session.)*

1. **Rip a game 100% and reskin? No.** Not squeamishness — speed. You throw away our engine, spend Pass 2 scrubbing IP, inherit their fading wave, and audio fingerprints anyway. Two-pass is faster and ours.
2. **Will MCP / Cube make it look like the #1s? No — and do not ask them to.** Cube is a prop shop: short prompt or reference image, bounding box, triangle cap. Over-detailing the prompt makes it worse. The look is volume + lighting + a few heroes + a good thumbnail.
3. **Marketable in a day? No — a dressed experiment.** Same-day is legitimate to claim only when the four-beat is green, the look bar passes, and the place is list-ready. D1 is tomorrow. Ads are after D1. Hobby DevEx is a real win; $10k/month from publish one is not a plan.

---

## 10 · Ten lines, pasted into CLAUDE.md

1. Four paragraphs in → draft `brief.md`, query the ledger, start Wave 1. Never ask him to fill a form.
2. Five comps by CCU; **three** filled teardowns; blend three sources. Never a one-source clone, never rip a place.
3. Auto-cut to the budget. Draw the line. Name Pass 1 vs Pass 2. Park the rest. He gets two minutes.
4. **Only Claude writes `src/` and Studio.** Grok jobs are optional disk files; if Grok is dark, self-pass in ten minutes and continue.
5. Pass 1 = the traced loop on our engine with Store stand-ins. Pass 2 snaps on after the loop is green.
6. Look = style spec + Store volume + lighting rig + one hero + image-tool thumb. **Default lighting is a fail.**
7. Not done when it compiles. Done when the look bar passes and the four-beat + persist are green.
8. Silence proceeds on reversible work. Silence never proceeds on listing, paid products, ads, title-kills or lowering a rule.
9. One active title. New ideas go in `IDEA_LOG.md`. Closeout before the next slug.
10. **Attended time is ~4h/day and scarce; unattended time is not.** Spend his hours only on what needs him; run `QUEUE.md` the rest of the time.

---

## 11 · Today's override — the factory's first proof is this title

**Hell Week** is Active (Justin, 2026-09-12); Fat Man Gets Rich is parked before Gate A. Pass 1 is built and four-beat tested on the scratch place (`docs/runs/2026-09-12-hell-week-mcp.md`). A session that opens a new slug while Hell Week is Active is the anti-pattern with better typography. Point every agent at the holes that already exist: **the unlisted publish + API access (Justin), the persist beat, Wave 4 dressing from `games/hell-week/shelf.md`, and Hunter's Gate A** (`games/hell-week/gate-a-script.md`).

**No v1.1 of this manual until a stranger has played.**

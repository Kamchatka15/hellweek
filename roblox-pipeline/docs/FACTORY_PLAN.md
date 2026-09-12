# The Game Factory — Business Plan & Technical Architecture

> **Governed by `docs/ROBLOX_SUCCESS_LOGIC.md` (standing orders).** If this file fights that file, that file wins.
>
> **This is the constitution. The runbook is `docs/OPERATING_MANUAL.md`** — six pages, loaded at the start of every session. When the two disagree on *process*, the manual wins because it is the one being run; on safety, children, money and publishing the doctrine outranks both.
>
> **Three forms, one source.** `FACTORY_PLAN.html` (beside this file, with `FACTORY_PLAN.assets/`) is the authored source. `The-Game-Factory.pdf` at the folder root is its print rendering — the one to *read*, with all eighteen figures. This `.md` is the generated text view. **Edit the .html; regenerate the other two.** Never edit the PDF or this file by hand.
>
> Written 2026-09-12 · v1.3 (two clocks, the operating manual, Grok's fresh-eyes pass adopted with corrections) · Re-verify platform facts by 2026-11-12.

Roblox Business · Justin & Hunter · v1.3

# The Game Factory

Business plan and technical architecture for a system that builds many Roblox games — and gets better at it every time.

A game is disposable. The factory is not. Every title that ships or dies must hand something back — a rule that hardened, a bar that rose, a piece of engine, a finding with its context attached — so the fourth game starts smarter than the third. This document says what that factory is, how its parts connect, where it could hurt a good game, and what is still missing.

Written  
12 September 2026 · v1.3 same night: two clocks (4h attended + unattended), the operating manual, and Grok's fresh-eyes pass adopted with corrections

For  
Justin (owner) · Hunter (design, playtest operations) · every future Claude and Grok session

Governed by  
docs/ROBLOX_SUCCESS_LOGIC.md — if this document fights that file, that file wins

Canonical  
roblox-pipeline/docs/FACTORY_PLAN.html → this PDF. **The runbook a session actually runs is docs/OPERATING_MANUAL.md** — this document is the constitution behind it

Compiled from  
the doctrine, PIPELINE, SYSTEM-MAP, GAME_FACTORY, SYSTEM_ARCHITECTURE, run log 01, the idea log, the evidence ledger, and today's session

Re-check by  
12 November 2026 — platform facts go stale in months

Part 0

## Why this document exists

You asked for it in one breath and it was the right ask: *"I need to understand that what we have created will improve games and learn from my work and not detract, limit, or distract from a good game project or opportunity."*

Here is why you want it, said back to you plainly. You are not a programmer. Over one long day you approved a great deal of infrastructure you cannot read directly — Python hooks that refuse code, a ledger schema, an architecture document, an autonomy contract, a changelog. Each piece was argued for on its own. Nobody has yet shown you the whole thing standing up together and asked the only question that matters: **does this make games better, or does it make a machine that admires itself?**

Your fear all day has been consistent and correct: that the system becomes the thing that gets in the way. That rules make games boring. That AI confuses a process. That Claude gets stuck on an old process. That goalposts hold you back. This document takes that fear as its test. Every mechanism in Part 2 is judged in Part 4 by two questions — *how could this hurt a good game?* and *what stops it?* — and where the honest answer is "nothing stops it yet," it says so.

### How to read it

- **Part 1** is the business plan — what we are building, for whom, how it makes money, and what the market actually rewards. No code.
- **Part 2** is the system — every layer, loop, gate and rule, each with a diagram. Skim the figures first; the text explains them.
- **Part 3** is the roster — every agent, mechanism and task, and how they connect. You asked for this list specifically.
- **Part 4** is the re-examination — where the system could detract, the contradictions found between our own documents, and the risks that outrank everything built today.
- **Part 5** is status and the build order — what exists, what is missing, what happens next, and the few decisions that are genuinely yours.
- **The glossary** at the back defines every technical word used here in one line. Nothing in this document requires reading code.

##### This document is the constitution. The runbook is six pages.

Forty-four pages is the wrong length for something a session loads at the start of every build. `docs/OPERATING_MANUAL.md` is the short version a session actually executes — six waves, file contracts, the look bar, the four-beat test, and the six things Justin can say out loud. It was built from this plan plus a fresh-eyes pass Grok did on it (§4.5). When the two disagree on *process*, the manual wins because it is the one being run; on safety, children, money and publishing the doctrine outranks both.

##### The one-paragraph answer

Yes, the system will improve games and learn from your work — *if* it is now used to build one. Everything built today is scaffolding around a build loop that does not yet exist and a game that has not yet met a stranger. The scaffolding is sound, and Part 4 shows where it could bite. But the single largest risk to this project as of tonight is not any rule in it. It is that the system becomes the project. The test of the factory is a game, and the next session should build one through it.

Part 1 · Business plan

## The intent

### 1.1 What we are building

In the owner's words: *the factory has two functions — build the game through a process designed to monetize and retain, well enough to confirm the metrics; and gain wisdom to make this game and the next ones better.* A four-paragraph description goes in, a working model comes out, the same questions and filters apply every time, and it does this for many games across many projects. The product is the factory. Any one game is a test case.

Two working rules were added tonight and run through everything below. **Copy aggressively:** blank slates are slow, most games in a category look alike because the shape works, so the top three comparable games are torn down and blended before a line of design is written (§2.10). **The first fifteen minutes must be solid, and the slice must look good enough to hold a kid** — not at G4, but before the first kid ever sees it — because a grey box cannot produce real metrics, and real metrics are the only thing that decides whether a title deserves more energy.

This distinction is not cosmetic. It decides where effort goes. A studio that treats each game as the product rebuilds its saving system, its shop, its security and its process every time, differently, and learns nothing transferable. A factory builds those once, keeps them, and spends each new title's effort on the only things that are actually new: the idea, the hook, the theme, the tuning, the art.

### 1.2 Who is building it, and how the work divides

Three parties, with a division of labour that was clarified today and now governs everything:

| Who    | Brings                                                                                                                                                                                                        | Does not bring, and is not asked to                                                                              |
|--------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------|
| Justin | Product ownership. The five gate decisions. **The cut** — removing what confuses. Every decision that spends money or ships to players. Up to ~4 hours a day at the keyboard.                                 | Code. Generative taste — inventing a mechanic from nothing.                                                      |
| Hunter | Design input. **Operating the comprehension test** — recruiting kids who have never seen the game and running the script. Playtesting titles he did not help design.                                          | Being the test subject for a game he helped make — he already knows the answers.                                 |
| Claude | The only writer of code and the only hand in Studio. Research, design, economy, Luau, documentation, orchestration. Proposing every applicable idea. Filing evidence. Operating within the autonomy contract. | Publishing. Creating paid products. Killing or switching a title. Spending money. Any of those is a human click. |
| Grok   | A coworker, not a competitor: research, art sheets, clip hooks, a second pass on design and economy, critique. Live X/Twitter discourse if Justin already has access.                                         | Writing to the repo or the live Studio DataModel while Claude is. No new paid tier is assumed.                   |

##### Two clocks — the constraint everything else is shaped around

**Attended: up to about four hours a day**, more at the start. Justin near the computer — gates, the cut line, playtests with a human watching, the publish clicks. **Unattended: everything else** — Claude works alone from a queue while he is away: research, teardowns, economy sims, the asset shelf, specs, docs, preparation. Reversible work only; never Studio, never publishing, never spending.

Every wave in the manual is tagged for one clock or the other. A session that opens while he is out runs the unattended work and leaves the attended work *prepared*, so it takes minutes when he sits down. **This supersedes the "~12-minute weekday review window" this plan inherited from PIPELINE.md** — that was the wrong constraint, and four hours is a different project.

##### The operating model, in one line

**The AI proposes everything applicable. Justin removes what is confusing. Neither role is the other one's job.**

Justin said today that he is "not sure he can supply the taste." He is supplying it — the subtractive half, which is the scarcer one. Almost anyone can add a feature. Almost nobody cuts one. What he is not asked for is invention, and the system is built so he never has to be.

### 1.3 The market we are actually in

These facts come from the doctrine and pipeline documents, verified against Roblox's own material in September 2026. They will need re-verifying by November. They are the reason the system is shaped the way it is.

- **It is a power-law market.** Most published experiences earn nothing. Of creators who reach the payout programme, the median is on the order of \$1,500 a year. A thin slice earns real money; a thinner slice earns \$10k+ a month. AI makes production cheaper for everyone at once, so extra content buys no attention. Attention is the scarce thing.
- **Discovery now pays for return, not for clicks.** Roblox's 2026 recommendation rework weights day-1, week-1 and week-4 return, session quality and spend-days — and explicitly devalues thumbnail-driven first clicks. A 200-player community that comes back beats a 5,000-player bounce house.
- **The platform removes manipulative games, including \#1.** *Steal an Egg* was the top game on the platform at roughly 800,000 concurrent players when it was taken down in August 2026 over a forced-engagement mechanic. Simulated gambling is banned at every rating. Paid random items need exact odds shown before purchase and are restricted outright in five countries.
- **The revenue proof points are generous games.** *Grow a Garden* (a 22-million-concurrent record) runs on offline growth that respects bedtime and Saturday events kids look forward to. *Steal a Brainrot* runs on drama kids clip for TikTok plus scheduled giveaways. The biggest games retain by being loved and monetise by being loved.
- **The audience is children, which is the most regulated corner of gaming.** The FTC took \$520 million from Epic over dark-pattern purchases and children's privacy. Parents control both the wallet and Roblox's parental spend controls. Every feature clears two bars: would Roblox allow it, and would we let Hunter pay for it without us in the room.
- **The money is small per unit and real in aggregate.** DevEx pays about \$0.0038 per Robux (\$0.0054 for spend from verified adults). 100,000 Robux is roughly \$380. Creator Rewards now pays per active spender who plays ten-plus minutes, and a share of the first \$100 spent by new players you bring to the platform — so retention and off-platform promotion are line items, not virtues.
- **Clone waves rise in weeks and fade in months.** *Steal a Fish*: launch, 192,000 peak concurrent, hundreds today — inside a few months. Enter weeks 0–3 or not at all. Speed is the moat, which is what the factory is for.

Join*first minute*

→

Hooked*first reward under 60s*

→

Daily return*one reason for tomorrow*

→

Weekly event*appointment viewing*

→

Collector*chasing completion, status*

→

Advocate*brings friends, makes clips*

↓  Two exits, both in the **first minute**: confused, or bored. Every retention system exists to push a player one state to the right.

**Figure 1 — The player lifecycle.** Compiled from SYSTEM-MAP §6. The first sixty seconds decide almost everything, which is why the factory's quality bar is comprehension rather than feature count.

### 1.4 How a game in this factory makes money

Revenue is a lagging indicator of two things: retention, and a fair shop. The doctrine's ordering is locked and this plan does not soften it: **build a loop people reopen → measure it → patch it → clip it → spend last.**

Justin's own thesis on why kids pay is drawn below as a loop, because it is the operating principle of everything after launch. Kids do not buy a bare catalogue row. A scheduled event creates a specific want; the product attaches to that moment; the payoff is visible to other players or felt in play; and that is what earns the next purchase. Every product is classified against one of four drivers — accelerate fun they already have, show status others see, complete a collection, participate socially — and if it maps to none, it does not ship.

Scheduled event*weekly drop, season*

→

A specific want*created by the moment*

→

Product attached to it*never a bare catalogue row*

→

Payoff visible or felt*status others see, or fun accelerated*

→

More play*more sessions*

→

Allegiance*to a game they love*

↺  Allegiance is what makes them show up for the **next** event. The loop closes.

**Figure 2 — The monetisation "why" loop.** Justin's thesis from SYSTEM-MAP §4. It is also why the factory refuses the coercion catalogue — panic timers, pay-to-stop-suffering, guilt loops — not on ethics alone but because on this platform in 2026 generosity is the winning strategy.

### 1.5 Every game is three loops stacked

A pitch that cannot fill all three boxes will not retain, whatever its art looks like. The core loop is the second-to-second fun. The meta loop is the reason to come back tomorrow. The social loop is the retention engine — it is what turned *Steal a Brainrot* into 25 million concurrent players, and Roblox's discovery system tracks intentional co-play directly.

Core loop · seconds

- Act: the verb
- Reward: a number goes up
- Upgrade
- ↺ back to the verb

Meta loop · days

- Collect, rebirth, build
- Unlock new content
- ↺ feeds the core loop

Social loop · the retention engine

- Play with friends
- Trade, steal, gift, show off
- Stories worth telling at school
- ↺ pulls them back in

**Figure 3 — The three nested loops.** From SYSTEM-MAP §2. The complexity budget in Part 2 allows exactly one core verb and one return hook in a first slice; the social loop is the one that is hardest to fake and the one that matters most.

### 1.6 A portfolio, built one title at a time

Most titles will be killed at a gate. That is the design, not a failure. The factory only compounds when a title reaches a closeout, so killing is done *at a gate, on evidence, with a learnings record* — never mid-build because something newer looks fun. That second pattern, twelve half-games that never get a real first session, is bad process labelled as bad luck, and the doctrine names it as the failure to avoid.

"Many games" and "one active title" do not conflict. The factory supports any number of titles — live, parked, waiting — across any number of projects. The scarce resource is not the machine; it is build attention. One title in active build; everything else in some other state.

Soft-launch numbers*unlisted, 200–500 cold players*

→

Does D1 clear the bar?*the portfolio decision*

→

Clears well*scale: events, creator spend, second product lane*

→

Close but short*iterate the hook, up to three times*

→

Three honest tries failed*kill: farewell event, closeout, reuse the engine*

**Figure 4 — Kill or scale.** From SYSTEM-MAP §9, with one correction made in Part 4: the three documents that set D1 thresholds disagree with each other, and the doctrine's numbers govern. A fast funeral is a win; it frees the slot for the next wave.

### 1.7 Targets, used as a compass and not a prophecy

1.  **Near-term:** a stranger completes the full earn → spend → progress loop with nobody in voice chat.
2.  **Next:** the Gate B table mostly green — cold players return.
3.  **Then:** DevEx-eligible earned Robux. Hobby money is a real win.
4.  **Not a plan:** \$10k a month from the first publish. That tier exists and it is as rare as it was before AI; Claude and Grok only cut the hours in the script editor.

### 1.8 What it costs

Net additional spend required to operate the factory today: **\$0.** Claude and its scheduled tasks run inside the plan already paid for; Studio, its built-in MCP server, Cube 3D, the Creator Store's licensed music, and Roblox's native A/B Experiments are free and first-party. Grok Build and Grok Bots were evaluated and not adopted: at this scale they add subscription cost and coordination overhead without a capability Claude lacks, and would be revisited only at three-plus live games. Optional spend arrives with real gates: an image tool at ≤ \$10 a month when a thumbnail matters at G4; a \$20–200 micro-creator test after Gate B; small sponsored tiles at Gate C, only after D1 has cleared the bar, and only on the icon that already won.

Interlude

## The same system, told as the life of one title

Part 2 explains the factory by component. This page explains it by time — what actually happens to one game from the four paragraphs to the closeout. If Part 2 is the wiring diagram, this is the story. Both describe the same machine.

**Hour 0 — four paragraphs.***Justin describes the game in prose. The intake step drafts the six-question brief from it; he corrects, never fills. The ledger is asked what it already knows about this kind of game.*

↓

**Hour 0–1 — tear down the top three, expand, then cut.***The three closest games get the same teardown form: first sixty seconds, loop, meta, social, return hook, price ladder, complaints, style. Claude and Grok propose every applicable shape from them. Grok runs a confusion pass — "which of these would lose a ten-year-old?" The budget auto-cuts to the caps. Justin moves the line in two minutes. Below it: the parking list. Alongside: the style spec and a Creator Store shelf, so the slice is dressed from hour one.*

↓

**Hour 1–3 — the slice.***Content pack on the engine, hooks enforcing R1–R7 on every write, one core verb, one return hook, the onboarding artifact. Economy simulated before anyone plays. Two hypotheses written into the brief.*

↓

**Day 1–3 — Gate A.***Hunter runs three fresh kids through the verbatim script. Justin does the ten-minute fun-check. Stop-and-patch until they can say what the game is and want a second go. The budget's two questions get answered. First player evidence enters the ledger.*

↓

**Week 1 — art, then cold players.***Icon and thumbnail readable at 200px (G4). Then a listed publish with zero spend — Gate B — because an unlisted place meets no strangers. Two hundred to five hundred of them, and the retention table fills in.*

↓

**Week 2–4 — iterate or kill.***D1 under the floor: rewrite the hook, up to three times. Still under: kill it at the gate, farewell event, closeout. D1 clears: G5, the human click, then shorts, micro-creators, and only then small ads on the icon that already won.*

↓

**Month 2 onward — live-ops.***Monday digest, Friday numbers, one-line yes, one drop a week. Events give purchases their why. Monthly economy audit. The game is never finished; it is operated.*

↓

**Closeout — the title pays back.***Hypotheses marked confirmed or refuted. Deviations recorded. Anything written twice moves into the engine. A bar that was beaten becomes the new floor. The next title starts here, not at zero.*

**Figure 16 — The life of a title.** Every purple box is where a human stops the machine. Every other box runs on stated defaults. The last box is the only reason the factory exists.

Part 2 · Technical architecture

## The system

Eight components. Each has a figure, a plain-language explanation, and a status. Nothing here requires reading code; the code that implements it is listed by path so a future session can find it.

### 2.1 The factory and the title are different things

The single most important idea in the architecture. A title is disposable by design. What must never be disposable is what the title leaves behind.

The factory · permanent

Gets better every cycle. One canonical copy.

- Engine src/core/ — 11 modules, reused untouched
- Rules CLAUDE.md + doctrine, enforced by hooks
- Process PIPELINE.md — the five gates
- Evidence evidence/ — the ledger, research, changelog
- Craft assets art kit, UI kit, hooks that landed — needs a home

A title · disposable

Most will be killed at a gate. That is the design.

- Content pack games/\<slug\>/
- Brief, theme, tuning numbers the specific game
- Map, products, icon, thumbnail never reused as-is

A new title starts from **all** of the left panel→and must hand **evidence** back when it ends→killed at a gate is **normal**, and still pays back

**Figure 5 — Factory versus title.** Rule: a title is finished when it has handed something back, not when it ships or dies. A title that taught the factory nothing was a wasted cycle even if it made money. Status: the boundary exists in code (engine/pack split, run 01) and is now enforced by hook R7.

### 2.2 Four layers of control

Everything that keeps quality up is one of four kinds of thing. They are not interchangeable, and the common mistake — the one that makes a system heavy without making games better — is trying to solve a higher layer with a lower one.

<span class="n">01</span>

##### Safety rails

Binary, machine-enforced, no judgment. Can't be exploited, can't lose saves, can't get banned. **A game that passes every one of these can still be boring.**

<span class="own">Owner: seven hooks + a git backstop · automatic, every session, every title</span>

<span class="chip built">Built</span>

<span class="n">02</span>

##### Quality bars

Numbers a build has to hit, so "is it good" is evidence rather than opinion. Gate B had hard bars already; Gate A — the gate that fires on every build — got its bars today via the comprehension test.

<span class="own">Owner: Gates A / B / C in the doctrine</span>

<span class="chip partial">Partial</span>

<span class="n">03</span>

##### The learning loop

Does game four start smarter than game three? The ledger that makes this possible exists as of today; the mechanisms that *feed* it — closeouts, the session-close hook, ledger-aware research — do not yet.

<span class="own">Owner: evidence/ — substrate built, feeders missing</span>

<span class="chip missing">Missing</span>

<span class="n">04</span>

##### The cut

Not "invent the fun" — **remove what confuses.** What is left has to be something we would let Hunter play and pay for with nobody in the room.

<span class="own">Owner: Justin, from a ranked list · never automated</span>

<span class="chip human">Human</span>

**Figure 6 — The four layers.** Higher layers need judgment; lower layers need none. Layers 1–3 exist to make Layer 4 cheap and fast: get a playable thing in front of real people quickly, then tell the truth about it.

##### Is the evidence ledger a fifth "wisdom layer"? No — and the reason matters

A control layer has a veto: safety refuses a write, quality passes or fails a build, the cut removes. **The ledger has no veto and must never be given one.** The moment past results can block a new idea, the system becomes conservatism with a database — one finding from one game vetoing the second game — which is exactly the "stuck on an old process" failure Justin named. The ledger is the substrate Layer 3 runs on. Wisdom is not stored in it; wisdom is *promoted* out of it when a finding is reproduced by a second title and becomes a default.

### 2.3 The pipeline and its gates

One line in at the top — *"create a \_\_\_ game"* — and a live, operated game at the bottom. Five human decisions stop the machine; everything else runs on stated defaults, and silence means proceed for everything except publishing and paid products, which wait forever.

Kickoff*~60s of questions, once*

→

R · Research sprint*market map, loop autopsy, wave timing, policy flags*

→

G1*pick 1 of 3 scored pitches*

→

D · Design*loop diagram, first-session script, economy workbook, KPI contract*

→

G2*approve prices, products, targets*

B · Build the slice*content pack on the engine*

→

T · Test*economy sim, auto-playtest, comprehension test*

→

G3 = Gate A*fun-check, 10 min · stop-and-patch*

→

A · Art direction*icon, thumbnail, one screenshot*

→

G4*approve the art*

Gate B · cold players*200–500 strangers · listed, zero spend*

→

D1 clears?*no → iterate hook ×3 → kill with closeout*

→

G5*publish + any paid product · ALWAYS a human click*

→

L · Launch*shorts, micro-creators, then Gate C ads*

→

O · Live-ops*weekly drop · repeats forever*

**Figure 7 — The master pipeline.** Compiled from SYSTEM-MAP §1 and PIPELINE §0. Purple boxes are the only places the machine stops for a human. Gate B has no G-number because the original plan assumed publish-then-promote; the doctrine inserted it: *cold-player proof happens before any money.*

| Doctrine | Pipeline            | What it is                                                                                                                                                                                                                                 | What passes it                                                                                                                                                                               |
|----------|---------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| —        | G1                  | Pick the pitch                                                                                                                                                                                                                             | Justin chooses one of three one-page pitches scored on session potential, spend clarity, build cost, wave timing, policy risk, differentiation, Hunter-testability                           |
| —        | G2                  | Approve the economy                                                                                                                                                                                                                        | Prices, products, KPI targets — one spreadsheet, one reply                                                                                                                                   |
| Gate A   | G3 (+G4 art)        | Internal playtest, no spend                                                                                                                                                                                                                | The comprehension test (§2.4) plus: earn → spend → progress unassisted, one full session with no softlock or data loss                                                                       |
| Gate B   | (between G4 and G5) | Cold players — **a listed publish with zero spend.** An unlisted place meets no strangers; Roblox's own new-experience impressions are the cheapest cold traffic there is and exactly the algorithm we want to test. Listing is a G5 click | Median first session completes the loop + one spend; D1 return ~12%+ (the doctrine floor — PIPELINE's 20/25% are tiers above it); favourites up; a few organic buys with no pleading; stable |
| Gate C   | after G5            | Paid traffic                                                                                                                                                                                                                               | Small sponsored test on the winning icon only, capped. High cost-per-play with no return → kill the campaign; the ad did not fail, the game did                                              |
| —        | G5                  | Publish · create paid products                                                                                                                                                                                                             | A human click. Never automated. Silence is not approval.                                                                                                                                     |

### 2.4 The build loop — describe, expand, prune

This is the stated purpose of the whole project, in Justin's words: *write four paragraphs describing a game, and have Claude and Grok put together a working model — asking the same questions and applying the same filters every time, so it moves fast.*

The risk that makes this hard is not that the rules are too strict. It is the opposite. **AI's failure mode on a creative brief is bloat.** Asked for a game, it adds every applicable idea, and the result is a slice nobody can read. A game rarely dies of being too plain; it dies of the player not understanding what to do in the first fifteen seconds. So the loop has an expansion step *and* a forced contraction step, and neither is optional.

1 · Four paragraphs*Justin, free prose, no form*

→

2 · The fixed interview*same six questions every time · answers drafted FROM the prose · Justin only corrects*

→

3 · Expansion*fuelled by the top-three teardowns in research/patterns/ plus the ledger · AI adds freely, Claude and Grok both propose, nothing rejected · then Grok's confusion pass: "which of these loses a ten-year-old?"*

4 · Complexity budget*the auto-cut, before Justin ever looks · a number, not a judgment*

→

5 · Ranked cut list*everything proposed, ordered, one reason each, recommended line drawn*

→

6 · Justin moves the line*~2 minutes, not 2 hours*

→

7 · Build*fixed filters apply automatically*

→

8 · Gates

↺  Everything below the line goes to a **parking list** — never deleted, re-read at the next title. That is what lets the AI propose freely without the slice getting worse.

**Figure 8 — The build loop.** Half exists: the six-question brief is GAME_FACTORY §2 and has been used once. Missing: the paragraphs-to-brief step, the expansion inventory, the budget as code, the ranked cut list. This is gap 0 in Part 5.

#### The complexity budget

A cap is a taste judgment wearing a number's clothing, so nobody is asked to be right about it today. The caps are **provisional defaults with an expiry**: they hold until the first Gate A, which asks two questions about the budget itself — did a cap block something the slice needed (loosen), and did testers get confused inside the caps (tighten). Both file evidence. A cap that survives two titles becomes a real default.

| Slot                  | First slice allows | Why this number                                        |
|-----------------------|--------------------|--------------------------------------------------------|
| Core verb             | exactly 1          | The one thing the player does second to second         |
| Return hook           | exactly 1          | Doctrine §4.5 — one, implemented well                  |
| Social / clip hook    | at most 1          | The thing a twelve-year-old films                      |
| Player-facing systems | at most 4          | Shop, upgrade, zone, collection — count them           |
| On-screen numbers     | at most 3          | A fourth counter is where the HUD stops being readable |
| Onboarding artifact   | 1, required        | Not "no explanation" — see the comprehension bar       |

The budget constrains the *first slice*, not the game. Games grow through live-ops; the budget is about legibility at first contact, which is where games die. → `docs/BUDGET.md`

#### The onboarding agent and the comprehension bar

Every game ships a walkthrough, intro or how-to, built by a dedicated agent — a standing requirement of the factory and a missing engine component today. The bar is not a stopwatch:

**A ten-year-old who has never seen the game understands it quickly enough to want to keep playing.**

"Fifteen seconds" sounds rigorous and measures the wrong thing — a game can be understood in five seconds and still be ignored. The real test is comprehension fast enough to produce engagement, and the only instrument for it is an actual ten-year-old. This gives Gate A the numbers it lacked:

| Gate A check       | Pass condition                                                   | How it is run                                     |
|--------------------|------------------------------------------------------------------|---------------------------------------------------|
| Goal comprehension | 2 of 3 testers say in their own words what they are trying to do | Ask after first exposure. Do not explain first    |
| First action       | 2 of 3 act meaningfully within 60s, unprompted                   | Watch. Say nothing                                |
| Pull               | 2 of 3 want a second go, unasked                                 | Watch. Do not prompt. Do not ask if they liked it |
| Loop completion    | Earn → spend → visible progress, unassisted                      | Existing doctrine bar                             |
| Stability          | One full session, no softlock, no data loss                      | Existing doctrine bar                             |

Subjects: three or more kids who have never seen the game and did not help design it. Operator: Hunter. Nobody: Justin. Verbatim answers matter more than the pass/fail — *"you collect the coins before the flood"* and *"you run from the water"* are both passes and describe two different games. → `skills/playtest-comprehension.md`

Caps as written*provisional guesses*

→

Build inside them

→

Gate A comprehension test*3 fresh testers*

→

Did the caps get it wrong?*confused inside → tighten · blocked something → loosen · neither → hold, n+1*

↺  Every outcome files an evidence record and returns to the caps. A cap surviving two titles reaches n=2 and stops being provisional. **Nobody has to be right today.**

**Figure 9 — The budget expiry loop.** How the goalposts set themselves from evidence instead of from anyone's opinion. Claude may move a cap on its own when a Gate A result justifies it (autonomy contract, §2.7), logging the change.

### 2.5 The enforcement layer

The non-negotiables in `CLAUDE.md` stopped being sentences a long session can drift past and became code that refuses the write. These seven are the rules that are both *catastrophic* and *detectable in a diff* — they fail silently, in production, after a human already approved the build. Nothing here has an opinion about whether a game is fun.

| ID  | Rule                                       | Effect                                  | The failure it prevents                                                                   |
|-----|--------------------------------------------|-----------------------------------------|-------------------------------------------------------------------------------------------|
| R1  | Client-authoritative economy               | <span class="chip missing">Block</span> | One player edits their own balance; the economy dies overnight                            |
| R2  | Raw remote handler                         | <span class="chip missing">Block</span> | An unvalidated, unthrottled entry point. Everything binds through RemoteGuard             |
| R3  | ProcessReceipt without a PurchaseId ledger | <span class="chip missing">Block</span> | Roblox retries receipts. Double-grant (we eat it) or drop it (a kid paid and got nothing) |
| R4  | DataStore access outside DataService       | <span class="chip missing">Block</span> | A second writer without the session lock — this is how saves get wiped                    |
| R5  | Gambling-shaped monetisation               | <span class="chip partial">Warn</span>  | Banned at every rating. A takedown risk, not a bug — needs a human decision               |
| R6  | Third-party IP                             | <span class="chip partial">Warn</span>  | Moderation removes it, and the takedown lands *after* the title is worth something        |
| R7  | Engine module names a specific game        | <span class="chip missing">Block</span> | The engine stops being reusable and nothing is portable to a second project               |

Session starts*SessionStart hook loads standing orders + STATE.md*

→

Claude writes code*PreToolUse guard reconstructs the resulting file and scans R1–R7 · exit 2 refuses*

→

Claude runs a command*loop cap: same command 3× warns, 5× blocks → escalate*

→

git commit*pre-commit runs the same scanner on staged files — catches anyone, any tool — and now rojo build + selene + stylua when the engine or a pack changed*

Escape hatch: **-- @rbx-allow: R4 reason** suppresses one rule for one file and is logged to docs/runs/hook-allow.log. An exception is allowed; a silent one is not.

**Figure 10 — Where enforcement fires.** One scanner, three triggers. Verified: zero findings across the 1,587 existing lines of engine and pack code; each rule proven to fire on a deliberately bad file; a correct receipt handler passes; the git backstop refused a real commit. → `.claude/hooks/`, `.githooks/pre-commit`, `skills/hooks.md`

##### The premise is untested, and it is filed that way

The whole layer rests on the claim that prose rules drift over a long session while enforced ones do not. The first scan of Justin's real code came back clean — consistent both with "prose works fine" and with "one careful run does not test drift." So the claim is filed in the ledger as **E-0005, n=0, an open hypothesis**, where it cannot be cited as a reason for anything. If the guard never fires across three titles, the layer is ceremony and should be simplified. Part 4 returns to this.

### 2.6 The evidence ledger

Justin asked for evidence *"recorded in context to that situation and then compared"* — a learning matrix, not a filing cabinet. A closeout written as prose cannot be compared to anything. So every finding is a record carrying seven fixed context dimensions, because a finding without its context is a rumour: *"offline earnings beat daily login"* is not true in general. It was true for a snack-shape collect game aimed at 8–12 during a rising wave. Strip the context and it becomes confident bad advice.

One record · evidence/ledger/E-####.md

- Claim one sentence, specific enough to be wrong
- Seven context tags domain · loop verb · session shape · audience · monetisation · wave · scale
- Outcome confirmed · refuted · inconclusive · observed
- Metric what actually settled it
- Confidence n=0 untested · n=1 one game · n=2 reproduced → eligible to become a default
- Source, date, status active · superseded · retired (with reason) · open-hypothesis

Asking it · evidence/match.py

- Give it a brief or a context --brief games/\<slug\>/brief.md
- It returns matching records, ranked and WHY each one matched — so it can be overruled
- Flags every single observation "n=1 — NOT a law"
- Flags stale records older than 12 months → re-verify
- Warns of unresolved contradictions touching any retrieved record
- Says so when nothing matches "this is new ground — file what you try"

**Figure 11 — The evidence ledger.** Built and running. At intake, before any design work, the ledger is asked what it knows about this context, and the expansion step is seeded by history instead of a blank page. Explainable on purpose: a match you cannot interrogate is one you cannot argue with.

#### Three rules that stop it rotting

1.  **Confidence is always visible.** One observation from one game is never a law. Nothing becomes a default until a *different* title reproduces it. This stops the ledger laundering a single accident into doctrine.
2.  **Contradictions are kept, never overwritten.** When a new title refutes an old record, both stand, linked. A contradiction is the most valuable thing in the ledger: two honest results that disagree mean *a context dimension is missing* — something varied between those games that nobody was tracking. Finding that variable is how the matrix gets smarter. Overwriting the loser destroys exactly that information.
3.  **Records go stale.** Roblox changed discovery, ads, gambling policy and testing tools inside fifteen months. Anything older than a year is flagged on retrieval; records killed by a platform change are retired with the reason, never deleted.

#### Contradictions: file always, ask rarely

Justin's instruction: a conflict comes to him as a question rather than being ignored or auto-resolved — *"less automation but more accuracy."* Adopted, with one refinement he approved: escalating *every* conflict would make him the bottleneck, and most conflicts ask him something he has no basis to answer. *"Did it fail because of the audience or because the wave was fading?"* is not owner knowledge; asking produces a guess with his name on it.

**A contradiction does not need resolving when it is found. It needs resolving when a decision depends on it.**

File both, linked*neither edited · always*

→

Diagnose*name the dimension that differs · always*

→

Queue it*evidence/OPEN_QUESTIONS.md · always*

→

Ask Justin*ONLY when a pending decision turns on it*

→

File the answer*as a new record · always*

An escalation arrives with the diagnosis done and three options: **A** follow one · **B** follow the other · **C** don't resolve it — make it the next title's hypothesis. C is usually the honest answer.

**Figure 12 — The contradiction protocol.** Verified against a synthetic pair: it named `wave` as the missing variable with no hints. The queue is currently empty — expected, since contradictions need two titles to have reported on the same thing. An empty queue means the ledger is young, not that the system works.

### 2.7 The compounding loop — how the factory learns

Justin's most important instruction of the day: *"part of your program is learning. Once you learn you record — and new sessions will learn from it and make changes and new tests to improve the process."* There is a hard constraint underneath it that shapes the whole design:

##### Claude does not persist between sessions

A session ends and everything it worked out is gone. So "Claude learns from it" can only ever mean one thing mechanically: **the session writes what it learned into the folder, and the next session is *forced* to read it.** Not "should read it" — forced. That is why the SessionStart hook exists. Memory that depends on someone remembering to look is not memory.

New title

→

Build on the engine

→

Gates A / B / C

→

Ships or is killed*both valid*

→

Evidence produced*what retained · what flopped · what took too long · what read at thumbnail size*

1 · Rules harden

Something went wrong no rule caught → a hook if it is visible in a diff, a gate question if it needs judgment.

2 · Engine grows

Anything written for the second time stops being per-game and moves into the shared engine.

3 · Bars rise

Gate numbers are a floor. Beat one by a wide margin and it becomes the new floor. Fixed bars stop improving the day you pass them.

4 · Craft accumulates

The hook that landed, the UI that read, the thumbnail that got clicked — a library, not a dead title's folder.

↺  **…so the next title starts higher than this one did.** That is the whole point of the system.

**Figure 13 — The compounding loop.** Today the four returns do not happen — a title ends, a document is written, nothing reads it. The ledger gives them somewhere to land; the mechanisms below make them happen.

| \#  | Mechanism                   | What it does                                                                                                                                                                                                                                                                        | Status                                    |
|-----|-----------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------|
| 1   | SessionStart load           | Every session begins holding the standing orders, the control panel (`STATE.md`: the standing rule, where we are, what is waiting on Justin, the next move) and the latest market digest                                                                                            | <span class="chip built">Built</span>     |
| 2   | The ledger + matcher        | Structured, context-scoped, queryable evidence with the contradiction protocol                                                                                                                                                                                                      | <span class="chip built">Built</span>     |
| 3   | Closeout                    | A title cannot end without a structured record the next title reads — ≤10 fields, mostly auto-filled from gate results, not an essay                                                                                                                                                | <span class="chip missing">Missing</span> |
| 4   | Hypotheses per title        | 1–2 predictions in the brief, instrumented at the gates, marked confirmed / refuted / inconclusive at closeout. Without a prediction, a closeout is storytelling                                                                                                                    | <span class="chip missing">Missing</span> |
| 5   | Scheduled research → folder | The Monday digest now runs bound to the Mac, reads `STATE.md` for the active title, checks the platform against the doctrine's own claims, and writes a dated drop to `research/` plus one line to `DIGEST_LOG.md`, which SessionStart surfaces. The old chat-only task is disabled | <span class="chip built">Rewired</span>   |
| 6   | Session-close hook          | A session cannot end without recording what changed and why                                                                                                                                                                                                                         | <span class="chip missing">Missing</span> |

#### Recording is not learning — every title carries a test

A closeout that only reports what happened produces stories, not knowledge. Given any outcome, a clever enough session can explain why it was always going to happen — that is how a system convinces itself it is learning while the games stay identical. So every title declares one or two hypotheses *before* it is built, specific enough to be wrong: *"We think offline earnings will beat a daily-login reward on D1 for a snack-shape game."* A prediction that failed is worth more than five pages of retrospective, and refuted tests are where the next title's tests come from. This is the "new tests" half of Justin's instruction.

#### The autonomy contract

"Make changes on your own" needs a boundary or it collides with the gates. The line is **reversibility**: anything that can be read, argued with and undone is autonomous. Anything that spends money, ships to players, or changes what the factory is aiming at is not.

| Claude changes on its own                                 | Claude proposes, Justin decides     |
|-----------------------------------------------------------|-------------------------------------|
| Add a hook rule after an incident a rule missed           | Remove or weaken an existing rule   |
| Raise a gate bar or move a budget cap that evidence moved | Lower a gate bar                    |
| Move twice-written code into the shared engine            | Kill or switch the active title     |
| Write research drops, pattern teardowns, evidence records | Promote an idea to the active title |
| Write the closeout and update STATE.md                    | Publish, or create any paid product |
| Correct a factual claim in a doc that went stale          | Change a core doctrine position     |
| Log an idea to IDEA_LOG.md                                | Anything that spends money          |

Every autonomous change is appended to `evidence/CHANGELOG.md` with the evidence that caused it — append-only, never rewritten. That is how a system that modifies itself stays auditable by someone who was not in the room. The failure it prevents is quiet drift: four titles from now, nobody — including Claude — knowing what the rules are supposed to be or which were ever tested.

### 2.8 Portability and the boundary

Justin will run multiple games, probably under different Claude projects, and needs the engine, rules, process, evidence and craft to be *already there* when a new title starts. Today the factory and the first title share a folder, so nothing travels. Two things follow, one done and one deliberately deferred.

**Done: the boundary is enforced.** What makes a factory portable is not where the folders sit; it is that the engine knows nothing about any particular game. A generic engine in an ugly directory is portable. A game-aware engine in a beautiful directory is not. Hook R7 refuses any engine module that names a game, so the engine stays generic by force rather than by intention.

**Deferred: the physical move.** Lifting the factory to the folder root rewrites every path and the Rojo configuration — breaking the only working repo in service of a second title that does not exist. The doctrine says do not build for a game you do not have. The move happens when a second title actually needs it and can say what it needs to support. It will cost more then; that cost is real and smaller than breaking today's repo for a speculative benefit.

**Non-negotiable when it does happen: evidence has one home.** If title 2 writes its learnings into its own project folder, title 3 never sees them and every project quietly relearns the same lessons in parallel. All closeouts, research and changelog entries write back to the single `evidence/` store at the root, whichever project produced them. That folder already lives at the root for exactly this reason.

#### Flexible without being formless

Two of Justin's requirements pull against each other and the tension is real: *"the same questions and the same filters every time"* versus *"each game will have different issues — Claude can't be stuck on an old process."* The resolution is that not everything in the process is the same kind of thing.

|              | Invariants                                                                                                                                                                                                       | Defaults                                                                                                 |
|--------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------|
| What         | Never change, whatever the game                                                                                                                                                                                  | The starting position, changed freely per game                                                           |
| Examples     | Server-authoritative economy · no third-party IP · no simulated gambling · publishing and paid products are a human click · a complexity budget exists · an onboarding artifact exists · a closeout gets written | *Which* six questions · *what* the caps are · which systems · which return hook · which research applies |
| Changing one | Requires Justin, explicitly                                                                                                                                                                                      | A title just does it, and says so in one line                                                            |

**The deviation rule** is what makes the process learn instead of ossify: a title that departs from a default declares it in one line with a reason, exactly like the existing spec-deviation rule. Those declarations land in the evidence store. **When the same deviation shows up in two titles, it stops being a deviation and becomes the new default.** A rigid-looking system is never more than two games away from correcting itself. A process that cannot be deviated from gets abandoned the first time it does not fit; a process that can be deviated from silently is not a process.

### 2.9 Who does each job best

Justin's standing rule, made concrete: the best tool wins, not Claude by default.

| Job                                        | Best tool                                                                 | Claude's role                             |
|--------------------------------------------|---------------------------------------------------------------------------|-------------------------------------------|
| Market stats, rankings, revenue estimates  | RoMonitor Stats · RoWatcher · Rolimon's · RTrack (free)                   | Read and synthesise                       |
| Luau, architecture, economy maths, docs    | **Claude**                                                                | Own it                                    |
| Quick in-Studio generation                 | Roblox Assistant + Cube 3D (free, first-party)                            | Direct it via MCP                         |
| Thumbnails and icons — the \#1 click lever | Ideogram / Recraft / Grok Imagine, or a Talent Hub artist when it matters | Spec and judge; cannot render             |
| 3D props                                   | Studio gen first → Meshy / Tripo / Hunyuan3D                              | Spec, import, wire                        |
| Music                                      | **Creator Store licensed library** (free, zero licensing risk)            | Pick and insert                           |
| A/B testing                                | **Roblox native Experiments**                                             | Design and read them                      |
| Kid and creator discourse                  | TikTok, YouTube comments, DevForum; X via Grok if already paid for        | Mine and synthesise                       |
| Is it fun? Is it understood?               | **Real kids, Hunter operating** — irreplaceable                           | Protocol and observation                  |
| Scheduled research and ops                 | Claude scheduled tasks (inside the existing plan)                         | Running — see Part 4 for the fix it needs |

### 2.10 Copy aggressively — shapes, style, colour, objects, sound

Added to the doctrine tonight as §3.1 at the owner's direction: *"most of this stuff looks alike — if you can clone and copy something, do it; I'll remove or edit it in the editing process; speed everything up."* The earlier "no scraping or cloning" line was protecting speed and costing it. What follows is the rule as written, then the machinery that does the copying.

Copy freely, on sight, unprompted

- Loops, verbs, reward cadence, the first sixty seconds, meta and social loops public, observable — the whole point of research
- Price ladders, product types, event rhythms, what players complain about same
- UI layout, HUD density, camera, colour logic, VFX cadence, silhouette language — the **style** from public video and the storefront
- **Creator Store models, textures, audio** (free or licensed) legal by construction — this IS copying existing assets, inserted by ID through Studio MCP
- Roblox Assistant / Cube 3D generations and Meshy / Ideogram outputs made *in the style of* the top three ours to use

Stays out — not as taste, as what deletes the title

- Meshes, textures, audio or scripts ripped out of someone else's place not possible through our tools; needs exploit tooling that bans the ACCOUNT, and the title is pulled the week it starts earning
- Names, mascots, logos, characters with an owner moderation removes on sight; the takedown lands after Gate B — Peter Griffin, 2026-09-11
- Roblox private endpoints terms-of-service violation → account risk; trackers give the same numbers legally
- "Free" Store audio named after another game's sound audio is fingerprinted on upload; free is not clear

**Figure 17 — What "copy" means.** The left column is the default and is done as much as possible without asking. The right column is enforced by Roblox and copyright whatever this document says. *"Don't worry about being sued, worry about being successful first"* — agreed, and it is the argument for the right column: on this platform the thing that stops success is moderation deletion, and it arrives exactly when the metrics finally exist.

#### The teardown — the same form for every comparable game

A comparable game is torn down on a fixed template (`research/patterns/TEMPLATE.md`) so teardowns are comparable and the expansion step can propose from them mechanically: numbers and wave stage, the first sixty seconds, core verb and cadence, meta loop, social loop, return hook, event cadence, the monetization catalogue with the first purchase named, complaints (the wedge), a style spec, Creator Store equivalents, and two closing lines — *copy this* and *do not copy this*. Tonight's three for Fat Man Gets Rich:

| Game                | What it proves                                                                                                                                  | Numbers, 12 Sep 2026                                                                | Wave                                                                         | Copy this                                                                                                                                           |
|---------------------|-------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------|------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------|
| Mine a Mountain     | Bag-and-bank in 2026: mine → bag full → sell → 12-tier named ladder + base-slot collection + hourly reset + a consumable sink                   | 131,867 peak two weeks ago → ~6–19K now · 136.6M visits · 96.8% likes · born May 18 | <span class="chip missing">Fading</span> — 4 months old, the graveyard month | bag-full teaches the bank · keep-vs-sell · hourly reset as appointment · bombs = the late-wall fix · every upgrade has a name kids say              |
| Bee Swarm Simulator | The evergreen bag-and-bank *feel*: the trip home is the rhythm; a collection you can see; no early wall                                         | ~20K CCU · 4.6B visits · 96%                                                        | <span class="chip built">Evergreen</span> since 2018                         | protect how the bank walk feels · one big bag meter · a visible collection · cheap first upgrade                                                    |
| Grow a Garden       | Offline progress capped not punished; restock timers and Saturday updates as appointments; the strongest gift-and-show-off loop on the platform | 22.3M peak — the record                                                             | <span class="chip built">Post-peak evergreen</span>                          | offline that respects bedtime · a countdown toward something good · weekly update as event · gift surfaces · rare variants of the thing you collect |

One fading wave and two evergreens bracket the title: Fat Man Gets Rich is Mine a Mountain's loop with Grow a Garden's return hook — and the thing neither Mine a Mountain nor our slice has yet is a social or clip surface. Mine a Mountain is the proof that this loop without one is a fading wave, not an evergreen. Seven more comps are on the reference board for style only.

#### The worked cut list — the build loop run once, by hand

Every applicable shape from the three, the complexity budget applied, the line drawn. This is what Justin sees, and moving the line is the whole of his job at this step.

| \#  | Shape                                                                                         | From                                | Verdict                                                                                           |
|-----|-----------------------------------------------------------------------------------------------|-------------------------------------|---------------------------------------------------------------------------------------------------|
| 1   | Bag-full teaches the bank — already built                                                     | MaM, BSS                            | <span class="chip built">In</span> · hypothesis 1 tests it                                        |
| 2   | Offline earnings, capped not punished — built; number wrong (sim)                             | GaG                                 | <span class="chip built">In</span> · at Candidate C's rate                                        |
| 3   | Named upgrade tiers — Duffel, Wheelbarrow, Dump Truck                                         | MaM's 12 pickaxes                   | <span class="chip built">In</span> · theme file only, big readability win                         |
| 4   | **A timed golden flood** — every N minutes the pad erupts ×5, server-wide countdown           | GaG restock timer, MaM hourly reset | <span class="chip built">In</span> · **this is the clip** — the one social/clip hook              |
| 5   | A coin pile you can see — banked coins render as a growing pile others walk past              | MaM base slots, BSS hive            | <span class="chip built">In</span> · system 3 of 4, the status surface with no cosmetic catalogue |
| —   | **Line drawn here.** 4 of 4 systems · 3 of 3 on-screen numbers · onboarding artifact present. |                                     |                                                                                                   |
| 6   | Rare coin variants (silver / gold / diamond)                                                  | GaG mutations                       | <span class="chip partial">Parked</span> · a fourth on-screen concept; after Gate A               |
| 7   | A consumable sink — the magnet bomb                                                           | MaM bombs                           | <span class="chip partial">Parked</span> · the economy sim's late-wall fix; G2 / live-ops         |
| 8   | Gift a flood to a friend                                                                      | GaG gifting                         | <span class="chip partial">Parked</span> · Gate B material                                        |
| 9   | Second area / zones by warmth                                                                 | MaM                                 | <span class="chip partial">Parked</span> · doctrine §3: not before area one retains               |
| 10  | Trading                                                                                       | GaG                                 | <span class="chip partial">Parked</span> · not before Gate B and not without scam-guards          |

#### Style, colour and objects — the shelf

Style is copyable; assets are inserted from the Creator Store by ID or generated in the style. The style spec for the title is five lines blended from the three teardowns — low-poly single-colour objects that read at 200px; gold on dark ground with the flood as the light source; one big readable bag meter; a bank that is a *building* you walk toward; cheerful, zero threat, the only countdown counting toward something good — plus the thumbnail formula all three agree on: one face, one giant version of the collectable, three words or fewer.

Under it sits a **Creator Store shelf**, found through Studio in one session and recorded by ID: low-poly gold coins and coin piles, a vault for the bank silhouette, cartoon tree packs, a fountain landmark, benches and lamps, a market stall for the upgrades zone, coin chimes, a cash-register cha-ching for banking, and three theme loops. All free. Nothing is pasted into the live place — assets are referenced from the content pack (`world.luau`, `theme.luau`) so the dressed slice rebuilds from disk like everything else. Justin cuts from the shelf; that is his G4, moved forward.

**The reference board** (`art/reference/`, git-ignored, never ships) is where the owner keeps public store images and audio notes from the ten comps to rework by hand — a mood board, which is normal practice. What the build does not do is auto-download other creators' assets to produce minor-edit derivatives, for the reason in Figure 17's right column: a reworked rip fingerprints as the original.

#### Sound

Same rule, same shelf. Ranked sources, sharpest first (`skills/audio-sourcing.md`): the **Creator Store audio library** for everything in Phase 1 — licensed by Roblox, free, no upload, no moderation wait; generated SFX or ElevenLabs for a specific sound the Store lacks; Suno or Udio on the paid tier for a throwaway loop only, because AI-music copyright is unsettled; royalty-free libraries and subscription services last, since they add an upload-rights burden for no quality gain at this stage. Free Store audio named after another game's sound is skipped — audio is fingerprinted, and free is not clear.

##### The coupling that turns three tasks into one click

Loading Store assets into a running place uses `InsertService`, which — like DataStores — does not work until the place is **published unlisted with Studio API access on**. So dressing the slice, verifying that saves survive a restart, and putting the game in front of a kid for real numbers are all behind the same three clicks in `docs/runs/PERSISTENCE_TEST.md`. Until then the shelf can be wired but cannot render.

Part 3 · Agents, mechanisms and tasks

## Who and what does the work, and how they connect

Justin asked for the list. Here it is in full — every human, AI, automated mechanism and Roblox-side tool that exists today, plus the ones that are designed but not yet built — followed by the map of how they connect and the one rule that keeps them from colliding.

### 3.1 The roster

| Agent / mechanism                                                | Kind                   | What it does                                                                                                                                                                                                                                                                                     | Status                                                  |
|------------------------------------------------------------------|------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------|
| Justin                                                           | Human                  | Owner. The five gate decisions. The cut. Everything that spends money or ships. Resolves escalated contradictions. ~12 minutes a weekday.                                                                                                                                                        | <span class="chip human">Human</span>                   |
| Hunter                                                           | Human                  | Design input. Operator of the comprehension test — recruits fresh testers, runs the verbatim script, records answers. Test subject only for titles he did not help design.                                                                                                                       | <span class="chip human">Human</span>                   |
| Fresh testers (3+ kids)                                          | Human                  | The only valid instrument for "is it understood." Never seen the game, no design input. Rotates per title.                                                                                                                                                                                       | <span class="chip human">Human</span>                   |
| Claude — primary engineer                                        | AI coworker            | The only writer to `src/` and the live Studio DataModel. Research, design, economy, Luau, docs, orchestration. Proposes every applicable idea. Files evidence. Works within the autonomy contract.                                                                                               | <span class="chip built">Active</span>                  |
| Grok chat                                                        | AI coworker            | Research, art sheets, clip hooks, second pass on design and economy, critique, live-ops copy. X/Twitter meme velocity if Justin already has access. **New standing job: the confusion pass before every cut** — a different model has different blind spots. Never writes to the repo or Studio. | <span class="chip built">Active</span>                  |
| Grok Build · Grok Bots · Automations                             | AI (evaluated)         | Second coding agent and paid automation tiers. Not adopted: cost and coordination overhead without a capability Claude lacks. Revisit at 3+ live games.                                                                                                                                          | <span class="chip accent">Not adopted</span>            |
| SessionStart hook                                                | Mechanism              | Loads the standing orders, the live hook list, `STATE.md`, idea-log and exception counts into every Claude Code session before it does anything.                                                                                                                                                 | <span class="chip built">Built</span>                   |
| PreToolUse guard (R1–R7)                                         | Mechanism              | Scans every file Claude is about to write, reconstructing the result so whole-file rules work on a one-line edit. Refuses on R1–R4, R7; warns on R5–R6.                                                                                                                                          | <span class="chip built">Built</span>                   |
| Debug-loop cap                                                   | Mechanism              | Same shell command 3× in a session warns; 5× blocks and demands a written escalation to Justin instead of a sixth attempt.                                                                                                                                                                       | <span class="chip built">Built</span>                   |
| Git pre-commit backstop                                          | Mechanism              | Runs the same scanner on staged files at every commit — catches code written by any agent, any tool, or by hand.                                                                                                                                                                                 | <span class="chip built">Built</span>                   |
| Evidence matcher (match.py)                                      | Mechanism              | Ranked, explained retrieval from the ledger; contradiction detection with the missing dimension named; matrix and open-questions generation.                                                                                                                                                     | <span class="chip built">Built</span>                   |
| Weekly Roblox market digest                                      | Scheduled task         | Mondays 8am, bound to the Mac: movers, clone waves and their stage, platform changes, one opportunity, and a **doctrine check** — anything found that contradicts a doctrine claim, quoted with its source. Writes to `research/`; never touches anything else.                                  | <span class="chip built">Rewired</span>                 |
| Studio MCP (built into Studio)                                   | Roblox-side tool       | Claude's hands in Studio: read/edit scripts, run Luau, start/stop play, screenshots, console, simulated input, mesh/material/texture generation, Creator Store insert. Inspect and playtest — never the primary home of code.                                                                    | <span class="chip built">Wired</span>                   |
| Playtest subagent (Roblox)                                       | Roblox-side tool       | Runs gameplay scenarios inside Studio and verifies outcomes. The candidate for automated Gate A smoke tests (join → first earn → first spend → first upgrade).                                                                                                                                   | <span class="chip partial">Available · not wired</span> |
| Roblox Assistant · Cube 3D · Experiments · Creator Hub analytics | Roblox-side tool       | First-party generation, native A/B testing, and the analytics ground truth. Used through MCP or in-Studio; Claude designs and reads, never re-implements.                                                                                                                                        | <span class="chip built">Available</span>               |
| Open Cloud                                                       | Roblox-side tool       | Publishing and product catalogue. **Human-gated, always.** No Claude action reaches it.                                                                                                                                                                                                          | <span class="chip human">G5 only</span>                 |
| studio_sync.py                                                   | Mechanism (workaround) | Serves the disk tree as JSON so Studio can pull it without a human click on the Rojo plugin — the only unattended disk→Studio path found in run 01. A test harness, not a Rojo replacement.                                                                                                      | <span class="chip partial">Workaround</span>            |
| Top-three teardowns · style spec · Creator Store shelf           | Resource (per title)   | The copy-the-shape library and the legal-copy asset list every title starts from. Stocked for Fat Man Gets Rich tonight: three teardowns, ten-shape cut list, a five-line style spec, ~20 free asset IDs across models and audio.                                                                | <span class="chip built">Stocked</span>                 |
| Reference board (art/reference/)                                 | Resource (owner's)     | Public store images and audio notes from ten comps, kept by Justin to rework by hand. Git-ignored. Never ships.                                                                                                                                                                                  | <span class="chip built">Set up</span>                  |
| Intake agent                                                     | Planned                | Four paragraphs → the six-question brief, drafted for Justin to correct rather than fill.                                                                                                                                                                                                        | <span class="chip missing">Missing</span>               |
| Expansion agent                                                  | Planned                | Reads the ledger and pattern library, proposes every applicable mechanic. Claude and Grok both contribute. Nothing rejected at this step.                                                                                                                                                        | <span class="chip missing">Missing</span>               |
| Budget + cut-list generator                                      | Planned                | Applies the caps, ranks what is left, draws the recommended line, writes the parking list.                                                                                                                                                                                                       | <span class="chip missing">Missing</span>               |
| Onboarding agent                                                 | Planned (engine)       | Builds the walkthrough / intro / how-to every game must ship with. A missing engine module, not a per-game task.                                                                                                                                                                                 | <span class="chip missing">Missing</span>               |
| Closeout writer + session-close hook                             | Planned                | A title cannot end without a structured closeout; a session cannot end without logging what changed. Both feed the ledger and changelog.                                                                                                                                                         | <span class="chip missing">Missing</span>               |

### 3.2 How they connect

*\[Figure 14 — the connection map — is a drawing; see the PDF rendering. Its roster is the table above.\]*

**Figure 14 — The connection map.** Read the arrows into Claude: humans give it briefs and decisions, hooks load it and refuse it, Grok advises it, the ledger informs it. Read the arrows out: it writes to Studio and to the ledger, and hands gates and cut lists back to Justin. The one arrow it does not have is to Open Cloud.

### 3.3 The one-writer rule

Everything in the map obeys one constraint that is not negotiable for speed: **Claude is the only writer to `src/` and to the live Studio DataModel.** Two agents editing Studio at once corrupts the DataModel. Grok researches and draws while Claude writes — in parallel, on disk and out-of-band, never in Studio. This is why Grok Build was not adopted and why every hand-off in the pipeline is a document, not a shared editor.

### 3.4 The tasks, phase by phase, and who owns each

| Phase        | Task                                                                                                                                                                     | Owner                                            | Justin's part                                      |
|--------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------|----------------------------------------------------|
| Kickoff      | Six questions, once: age band, scope, monetisation stance, art seed, budget caps, deadline hook — or four paragraphs the intake agent turns into them                    | Justin → Claude                                  | ~60 seconds                                        |
| R · Research | Market map from the trackers, loop autopsy of the top three, wave timing, policy flags, why-they-pay synthesis, three scored one-page pitches                            | Claude ‖ Grok                                    | G1: pick one                                       |
| D · Design   | One-page loop diagram, first-session script, economy workbook, retention systems from the fair-play catalogue, live-ops calendar to week 8, KPI contract, 1–2 hypotheses | Claude, Grok second pass                         | G2: approve numbers                                |
| Expand + cut | Ledger consulted; every applicable idea proposed; budget applied; ranked cut list with a line drawn                                                                      | Claude + Grok → Justin                           | Move the line, ~2 min                              |
| B · Build    | Content pack on the engine; hooks enforce R1–R7; specs before code; the onboarding artifact                                                                              | Claude alone                                     | None                                               |
| T · Test     | Economy Monte-Carlo, automated playtest via MCP, unit tests, comprehension test with fresh kids                                                                          | Claude · Hunter operates the test                | G3 fun-check, 10 min                               |
| A · Art      | Icon, thumbnail, one screenshot; readable at 200px; no third-party IP                                                                                                    | Claude specs, external tools render, Grok drafts | G4: approve                                        |
| Gate B       | Unlisted soft launch to 200–500 strangers; retention table vs the contract; iterate the hook up to three times                                                           | Claude measures, proposes                        | Read the table. Kill or proceed is a gate decision |
| G5           | Publish. Create paid products.                                                                                                                                           | **Justin**                                       | The click                                          |
| L · Launch   | Shorts and TikTok clips, Moments on the experience page, micro-creators in the genre, then small Gate C ads on the winning icon                                          | Claude drafts, Justin approves spend             | One-line approvals                                 |
| O · Live-ops | Monday digest → Friday KPI review → next-drop spec → build → publish. Weekly micro-drop, monthly theme, quarterly tentpole. Monthly economy audit                        | Claude runs the loop                             | One-line yes each week, G5 click                   |
| Closeout     | Hypotheses marked, evidence filed, deviations recorded, engine candidates extracted, budget questions answered                                                           | Claude                                           | None — but no new title starts without it          |

##### What Justin's week actually looks like when this runs

**Monday:** read the market digest, two minutes. **Any day:** a gate decision arrives as a one-page pitch, a spreadsheet, or a ranked list with the line already drawn — reply in one line, or say nothing and defaults proceed (except G5, which waits forever). **When a slice is ready:** ten minutes playing it with Hunter while Hunter separately runs three fresh kids through the script. **Occasionally:** a contradiction that a real decision depends on, arriving with the diagnosis done and three options. **Never:** babysitting a RemoteEvent, choosing a price ladder from scratch, or being asked to invent a mechanic. The doctrine's twelve-minute review window is the design constraint, and every escalation is shaped to fit inside it.

Part 4 · The re-examination

## Does it make sense? Where could it hurt a good game?

Justin asked for the whole system to be worked through again. This part does that with no salesmanship: what holds, where each mechanism could detract from a good game and what stops it, the places our own documents contradict each other, and the risks from the first real build that still outrank anything added today.

### 4.1 What holds

- **The doctrine is sound and was already ahead of anything published.** A survey of public Claude-for-Roblox scaffolding found knowledge libraries — how to write a DataStore, genre templates — and nothing that decides when to stop, what proves a game is worth money, or what kills a title. The doctrine had all three before today.
- **Every mechanism added today is title-agnostic.** None of the seven rules, the ledger schema, the budget, or the comprehension test mentions a game. A new title inherits all of it without anyone remembering to apply it.
- **The division of labour is coherent and matches the owner.** AI proposes, Justin cuts. The owner is asked only for the kind of judgment he actually has and never for the kind he said he does not.
- **Autonomy has a boundary that is the right one.** Reversibility. Claude changes what can be undone; Justin decides what cannot.
- **The stack is cheap.** \$0 additional spend; the expensive alternatives were evaluated and declined for stated reasons.

### 4.2 Where each mechanism could detract, limit, or distract — and what stops it

| Mechanism                   | How it could hurt a good game                                                                                                                                                               | What stops it                                                                                                                                                                                      | Residual risk                                                                                               |
|-----------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------|
| Safety hooks R1–R7          | A false block interrupts a build; a rule fires on legitimate code                                                                                                                           | Zero false positives across all 1,587 existing lines; each rule tested both ways; escape hatch with an audit log; new rules must pass the two-way test before landing                              | Low. The premise itself is untested (E-0005)                                                                |
| Complexity budget           | Caps a great idea that needed five systems; makes a first slice too thin to be fun                                                                                                          | Constrains the *first slice* only; nothing is deleted — parking list; a declared deviation is one line and two deviations make a new default; caps expire at the first Gate A and move on evidence | Medium until the first Gate A moves them. This is the mechanism to watch                                    |
| The gates                   | Slow shipping; Gate B needs 200–500 strangers, which is real effort for a two-person studio                                                                                                 | By design — the doctrine's whole thesis is that spending before Gate B rents empty visits. Unlisted soft launch, DevForum and Discord tester pools, and Hunter's cohort widen the pool for free    | Real. Gate B is the most labour-intensive step and has never been run                                       |
| Comprehension test          | Recruiting three fresh kids per Gate A is a logistical burden; a bad day skews the result                                                                                                   | Hunter operates and his cohort rotates — a kid is fresh for each new title; 2-of-3 thresholds absorb one outlier                                                                                   | Medium. Practical, not conceptual                                                                           |
| Evidence ledger             | False confidence from one observation; or nobody files anything and it dies quietly                                                                                                         | Confidence always visible; nothing becomes a default below n=2; no veto power; the closeout requirement and session-close hook (not yet built) are what keep it fed                                | **High until the feeders exist.** A ledger nobody writes to is a graveyard with a schema                    |
| Closeout + changelog        | Paperwork per title; the ritual becomes the work                                                                                                                                            | The closeout is a template of about ten fields, most auto-filled from gate results and hypotheses — never an essay. The changelog is append-only one-liners                                        | Low, if the template stays short                                                                            |
| Contradiction protocol      | Justin becomes the bottleneck; or conflicts pile up unread                                                                                                                                  | Escalate only when a pending decision depends on one; otherwise they wait in a visible queue; every escalation arrives with the diagnosis done and "make it the next test" as an option            | Low                                                                                                         |
| Fixed interview and filters | Rigidity — a game that does not fit the six questions gets forced into them                                                                                                                 | Invariants versus defaults: the questions are defaults and can be deviated from in one declared line                                                                                               | Low                                                                                                         |
| Copy aggressively           | One ripped asset, one owned name, or one re-uploaded song gets the title pulled — after Gate B, when it is finally worth something. And a single-source clone inherits its source's ceiling | Figure 17's right column; R6 warns on owned names; the "free is not clear" audio rule; the reference board never ships; blend three sources, never one                                             | **Medium.** Depends entirely on discipline at insert time — the shelf is vetted, the next search may not be |

##### The largest risk to this project tonight is not on that table

It is that **the system becomes the project.** Today was one hundred percent system and zero percent game. That was the right call for one day — the scaffolding needed to exist — and it is exactly the pattern the doctrine warns about if it continues: *"feature-complete before anyone has played,"* applied to process instead of content. A factory that produces documents about itself is the anti-pattern with better typography.

**The rule this document proposes, and the one it most wants Justin to hold it to:** no further system work — no new hooks, no new agents, no restructuring — until *Fat Man Gets Rich* has been through Gate A with the comprehension test and three fresh kids. The only exceptions are the items in Part 5 that directly unblock that test. The test of the factory is a game. Everything built today is a hypothesis until one has gone through it.

### 4.3 Contradictions found between our own documents

Working through the folder again surfaced six places where the documents disagree with each other or with what Justin said today. None is fatal. All of them would confuse a future session that read the wrong one first.

| \#  | The conflict                                                                                                                                                                                                                                                                                                                                                         | Resolution                                                                                                                                                                                                                                                                                                                                                                                                                                    | Who acts                                                                 |
|-----|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------|
| 1   | **Three different D1 scales.** The doctrine (Gate B) says ~12%+ is OK to test small spend and under 8–10% is death. PIPELINE §4's KPI contract says D1 ≥ 20% to proceed, ≥ 25% to spend on ads. SYSTEM-MAP §9 says kill under 15% after three tries, scale at 25%+. A game at 13% is simultaneously "OK to spend a little," "do not proceed," and "iterate or kill." | The doctrine governs by its own precedence rule. Its numbers are the *floor*. **Done:** PIPELINE §4 and SYSTEM-MAP §9 now say the 20/25% figures are tiers, not gates.                                                                                                                                                                                                                                                                        | <span class="chip built">Fixed</span> · Justin confirms the floor stands |
| 2   | **"The human owns taste"** (doctrine §0 and §9) versus Justin today: *"I'm not sure I can supply the taste."*                                                                                                                                                                                                                                                        | Read the doctrine's "taste" as *the cut* — subtractive judgment, which Justin does supply. Propose a one-line amendment to §9 so a future session does not ask him to invent mechanics.                                                                                                                                                                                                                                                       | Claude proposes; **Justin decides** (a doctrine position)                |
| 3   | **Doctrine §3 lists "extra agents" as effort that does not count.** This document proposes five new agents.                                                                                                                                                                                                                                                          | The doctrine's target is production capacity — more workers making more content, the "40th ore type" class. The agents proposed here remove work from the owner (intake, cut list, closeout) or are required by a quality bar (onboarding). The distinction is real but the tension is honest: **each new agent must justify itself against §3 before it is built, and the rule above (no system work until Gate A) applies to all of them.** | Standing test, applied by Claude, visible to Justin                      |
| 4   | **PIPELINE §7's "Hunter protocol"** has Hunter playing the game across three sessions. The comprehension skill says Hunter cannot be the primary subject for a title he helped design.                                                                                                                                                                               | Two different tests, both valid. The Hunter protocol is the G3 *fun-check*; the comprehension test is Gate A's *is-it-understood* check and needs fresh subjects. **Done:** the skill file now says so.                                                                                                                                                                                                                                       | <span class="chip built">Fixed</span>                                    |
| 5   | **The weekly market digest exists but is disconnected.** It runs Mondays in a fresh session with no access to the folder, its prompt says "no game is in active development," and its output lands only in a chat window — which the folder's own first rule says does not exist as a deliverable.                                                                   | **Done:** re-created bound to the Mac; reads `STATE.md`; writes a dated drop to `research/` and a line to `DIGEST_LOG.md`; runs a doctrine check each week. The old task is disabled, not deleted. SessionStart surfaces the latest line.                                                                                                                                                                                                     | <span class="chip built">Fixed</span> · first run Monday 8am             |
| 6   | **Small inconsistencies from run 01, still open:** two naming conventions (GAME_FACTORY lowercase pack files vs rojo-map PascalCase); engine UI code sitting in the game's client folder with no engine mount; the Phase 0 checklist in PIPELINE §13 still shows "decide first target" unchecked although Fat Man Gets Rich was chosen.                              | **Done:** naming ruled in rojo-map; checklist ticked; studio_sync and the MCP-require rule written into the studio-mcp skill. Still open: the `src/core/client/` mount, before the second game.                                                                                                                                                                                                                                               | <span class="chip built">Mostly fixed</span>                             |

### 4.4 The risks from the first build that outrank today's work

Run 01's own "blunt list of what was missing" is the most useful document in the folder for this question, and most of it is still open. These threaten the *game* directly, which none of today's system work does, and several of them should be fixed before the next hook is written.

| \#  | Risk                                                                                                                                                                                                                                                                                                                                                                                                             | Why it outranks system work                                                                                                                         | Fix · owner                                                                                                                                                                                                                                                                    |
|-----|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 1   | **Persistence is unverified.** Studio cannot reach DataStores until the place is published, so the save system fell back to memory. Kill-the-server-and-rejoin has never been run.                                                                                                                                                                                                                               | Data loss is the \#1 Gate A killer in the doctrine. Every hook in R4 protects a path that has never executed.                                       | Publish an *unlisted* place so the DataStore path can be exercised. This is Gate-5-adjacent and is **Justin's click**. Then Claude runs acceptance test 8                                                                                                                      |
| 2   | **Economy simulated — and it found the problem.** `tools/econ_sim.py` runs 300 players against the real config and the engine's own formulas. Result: first upgrade at 28 seconds (right), but the entire 27,925-coin ladder is maxed by **day 3**, offline earnings are **82%** of all coins, and a kid holds 1.38 million unspent by day 30. The second week is empty and playing is pointless versus waiting. | This is exactly the "week-2 billionaires" failure, caught as a spreadsheet problem. It is the single most important game-facing finding of the day. | <span class="chip built">Found</span> · Candidate C proposed for G2 (offline 0.5/hr, deeper ladders): nothing maxed inside 30 days, offline ~47%, first minute untouched. **Justin approves the numbers.** Late-ladder wall remains — needs a second sink, a live-ops decision |
| 3   | **No test framework, no CI enforcement.** TestEZ is named in the plan and not installed; nothing makes `rojo build`, Selene and StyLua run on a commit.                                                                                                                                                                                                                                                          | The first edit to a cost curve breaks something silently.                                                                                           | <span class="chip built">Half done</span> · pre-commit now runs rojo build + selene + stylua on the Mac. TestEZ still not installed; the sim is the only economy check                                                                                                         |
| 4   | **No unattended path from disk into Studio.** The Rojo plugin needs a human click in the editor that MCP cannot make. `studio_sync.py` is a workaround, not documented in the skill.                                                                                                                                                                                                                             | Every automated playtest depends on it. Run 01 called it the single highest-leverage fix in the repo.                                               | <span class="chip built">Documented</span> in `skills/studio-mcp.md`, with the two other run-01 rules. A cleaner path through the built-in MCP is still worth a look                                                                                                           |
| 5   | **No art seed, no sound.** The brief says TBD; the flood's readability at 200px rests on "neon yellow on a dark floor."                                                                                                                                                                                                                                                                                          | Blocks G4. Not urgent before Gate A, and the doctrine says grey-box first — but the thumbnail is the \#1 click lever and has no owner yet.          | Justin: one reference image or three adjectives, when Gate A passes                                                                                                                                                                                                            |

### 4.5 The outside read — what a second model found

Justin gave this plan to Grok cold and asked how it would actually design games from it. The result was a six-page operating manual. Most of it was better than this document *as a thing a session runs*, and it has been adopted. Recording it here because an outside read that changes the design is exactly the kind of evidence this system exists to keep.

| What the outside read added                                                                                                                                                    | Verdict                                                                                                                                                                                                   |
|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| A command vocabulary — six things Justin can say out loud, each mapped to waves and a definition of done                                                                       | <span class="chip built">Adopted</span> · the single best addition. This plan never gave him a way to drive it in one sentence                                                                            |
| "Grok never blocks Claude" — every Grok job is a parallel bonus; if the tab is dark, self-pass in ten minutes and continue                                                     | <span class="chip built">Adopted</span> · fixes a dependency v1.2 created by putting Grok's confusion pass before every cut. Grok removing itself from the critical path                                  |
| Pass 1 / Pass 2 — trace the loop on generic Store stand-ins, snap identity on after it is green                                                                                | <span class="chip built">Adopted</span> · better sequencing than ours, and Pass 2 prepares in parallel                                                                                                    |
| File contracts with stop conditions, per wave                                                                                                                                  | <span class="chip built">Adopted</span> · executable where prose sections are not                                                                                                                         |
| The look bar — ~80% Store volume + lighting rig, 15% hero objects, 5% icon and thumbnail, a seven-row checklist, and "default lighting is why generated places look generated" | <span class="chip built">Adopted</span> as *defaults with an expiry* — the proportions are asserted, not measured                                                                                         |
| Three filled teardowns, not ten. "Ten is stalling."                                                                                                                            | <span class="chip built">Adopted</span> · corrects both of us                                                                                                                                             |
| A 9.5-hour single-run clock                                                                                                                                                    | <span class="chip missing">Rejected</span> · invented, and it assumed one uninterrupted day. Replaced by the two clocks. The first real run gets *timed*, and the measured number replaces every estimate |
| "Locked so a future session cannot reopen them"                                                                                                                                | <span class="chip partial">Corrected</span> · Claude does not re-litigate; **Justin always can**. He reopened the IP ban tonight and was right to. Things get settled by evidence, not by declaration     |
| Replace FACTORY_PLAN with the manual; cap live subagents at six                                                                                                                | <span class="chip missing">Rejected</span> · the manual is a separate file, and the second writes rules for swarm machinery that does not exist                                                           |

##### Its last line indicts both documents

*"Do not add agents that produce more documents about the factory."* Two models have now written fifty pages of process for a game no stranger has played. Grok flagged it, §4.2 of this plan flagged it, and both kept typing. The rule in §4.2 stands and now has a second author: **no further process work until Fat Man Gets Rich has been through Gate A with three fresh kids.**

### 4.6 Untested premises, stated plainly

- **That prose rules drift and hooks do not** (E-0005, n=0). The enforcement layer rests on it. If no guard fires across three titles, simplify the layer.
- **That the complexity caps are near the right values.** They are guesses. The first comprehension test is the first evidence.
- **That three fresh ten-year-olds can be recruited per Gate A.** Hunter's cohort makes it plausible; it has not been done.
- **That evidence with seven context tags is comparable across titles.** The dimensions were chosen deliberately, and the first real contradiction will tell us whether one is missing.
- **That a two-hour "create a \_\_\_ game" is real.** GAME_FACTORY says it becomes real on the *next* game, now that the engine exists. It has never been timed.
- **The ledger holds zero player evidence.** Every record is about how the factory behaves. Nothing is known about real players because no title has met one. That is an accurate report, not a gap in the ledger — but it means every design conversation so far has been theory.

Part 5 · Status and build order

## Where it stands, and what happens next

### 5.1 Status board

**Doctrine + pipeline + diagrams**ROBLOX_SUCCESS_LOGIC · PIPELINE · SYSTEM-MAP · GAME_FACTORY · SYSTEM_ARCHITECTURE

**Engine — 11 modules**src/core/ · data, remotes, economy, progression, pickups, zones, rewards, analytics, loader, loop, sync

**First title — grey-box slice**Fat Man Gets Rich · playable end to end · before Gate A

**Enforcement layer**R1–R7 · SessionStart · loop cap · git backstop · escape hatch + log

**Evidence ledger + matcher**schema · 5 records · match.py · conflicts · matrix · open questions

**Operating manual + two clocks**six waves tagged attended/unattended · command vocabulary · look bar · four-beat · QUEUE.md

**Budget + comprehension test**BUDGET.md (defaults with expiry) · playtest-comprehension.md

**Gate A**bars defined today · never run with fresh testers

**Scheduled research**weekly digest rewired: Mac-bound, reads STATE.md, writes research/, doctrine check

**Persistence**DataService built · never exercised against a real DataStore

**The build loop — gap 0**paragraphs → brief · expansion · budget as code · ranked cut list

**Closeout · hypotheses · session-close**CLOSEOUT, CUT_LIST and MCP_RUN_LOG templates written · hypotheses in the brief · session-close hook still missing

**Onboarding agent**required by every game · no engine module

**Economy sim · tests · CI**sim built and run (ladder exhausted day 3) · build+lint in pre-commit · TestEZ still missing

**Style spec · Creator Store shelf · teardowns**defined and stocked for the first title · not yet wired into the pack · blocked on the publish

**Title registry · physical factory split**deferred until a second title exists

**Figure 15 — Status board, 12 September 2026, end of day.** Teal built, amber partial, red missing. Seven built, five partial, three missing — ordered below.

### 5.2 The initial testing model — Phase 1 in six moves

The owner's stated near-term goal, in his words: *"I just need the game to look better in Phase 1 initially, to keep the kids' interest, to get real metrics to see if I want to expend more energy on a project."* That is the definition of an initial testing model: a dressed, playable slice that survives fifteen minutes and a stranger, instrumented well enough to say whether to continue. Six moves, in order, three of them one afternoon's work.

**1 · Publish unlisted, API access on — Justin, three clicks.***Unblocks InsertService (the shelf renders), DataStores (saves persist), and the comprehension test on a real build. Move 2 is prepared unattended beforehand, so this costs minutes of his time, not an evening. docs/runs/PERSISTENCE_TEST.md.*

↓

**2 · Wire the shelf and the cut list into the pack — Claude.***Named tiers and audio IDs in theme.luau; fountain, trees, vault, stall and the golden-flood timer in world.luau and the loop; Candidate C's economy numbers pending G2. Everything rebuilds from disk.*

↓

**3 · Run the persistence test and an automated playtest — Claude.***Seven rows: real DataStore, restart, crash, double-join, migration. Then join → first flood → bank → upgrade with a clean console.*

↓

**4 · Gate A — Hunter operates, three fresh kids, Justin fun-checks.***Goal comprehension, first action, pull. The budget's two questions. Hypotheses 1 and 2 get their first data. The ledger gets its first player evidence.*

↓

**5 · Stop-and-patch, icon and thumbnail — Claude, Justin approves (G4).***One face, one giant coin, three words. Readable at 200px.*

↓

**6 · Gate B — listed, zero spend. The real metrics.***Two hundred to five hundred strangers from Roblox's own new-experience impressions. D1 against the doctrine floor. This is the number that decides whether the title deserves more energy — and the first thing the factory has ever actually learned from a player.*

**Figure 18 — The initial testing model.** Purple boxes are the owner's. Move 1 is the gate everything else is behind; moves 2–3 are ready to run the moment it is done.

### 5.3 The build order

Ordered by one principle: **get a real game through a real Gate A first, and build only what unblocks that until it has happened.** Everything after step 3 waits for the comprehension test's results, because those results are the first evidence the factory will ever hold about players, and several later items should be shaped by them.

| \#  | Move                                                                                       | Owner                                              | Size                                               | Why in this position                                                                                                                                                                                                                                                                                                                                                                                                                      |
|-----|--------------------------------------------------------------------------------------------|----------------------------------------------------|----------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 1   | Publish an unlisted place; verify persistence                                              | **Justin clicks**, Claude tests                    | Small                                              | Unblocks the \#1 Gate A killer. Nothing else about the slice can be trusted until saves survive a server restart                                                                                                                                                                                                                                                                                                                          |
| 2   | Economy Monte-Carlo; build + lint in the pre-commit; TestEZ                                | Claude                                             | <span class="chip built">Done</span> except TestEZ | The sim found the day-3 exhaustion; Candidate C is on Justin's list for G2. Build + lint now run on every Mac commit                                                                                                                                                                                                                                                                                                                      |
| 3   | **Gate A — the comprehension test on Fat Man Gets Rich**                                   | Hunter operates · 3 fresh kids · Justin fun-checks | One afternoon                                      | The first real evidence. Answers the budget's two questions. Proves or refutes the system's premise in one sitting                                                                                                                                                                                                                                                                                                                        |
| 4   | Closeout template, hypotheses in the brief template, session-close hook, changelog wiring  | Claude                                             | Small                                              | Gate A produces evidence with nowhere structured to land. Build the feeders right after the first thing worth feeding                                                                                                                                                                                                                                                                                                                     |
| 5   | Re-create the weekly digest bound to the folder                                            | Claude                                             | <span class="chip built">Done</span>               | First folder-bound run Monday 8am. The old chat-only task is disabled                                                                                                                                                                                                                                                                                                                                                                     |
| 6   | The intake loop — paragraphs → brief, expansion inventory, budget as code, ranked cut list | Claude                                             | Medium                                             | Gap 0. The stated purpose of the project. Positioned after Gate A so the first cut list is shaped by what real kids actually found confusing                                                                                                                                                                                                                                                                                              |
| 7   | Onboarding agent as an engine module                                                       | Claude                                             | Medium                                             | **Deliberately after Gate A, not before.** Fat Man Gets Rich was designed to teach itself — the first payout overfills the bag, which is supposed to teach banking with no tutorial. Testing the raw slice is the purest test of that design. If fresh kids understand it with no walkthrough, the onboarding agent's job is small; if they don't, we learn exactly what needs explaining. Building the agent first would hide the answer |
| 8   | Fix the six document contradictions (§4.3)                                                 | Claude; Justin on \#2                              | <span class="chip built">Done</span> except \#2    | \#2 is a doctrine wording — the exact line is in STATE.md for a yes / no / edit                                                                                                                                                                                                                                                                                                                                                           |
| 9   | Visual quality bar; craft library home                                                     | Claude proposes, Justin's art seed                 | Medium                                             | Blocks G4, not Gate A. "Visually professional" needs a definition before art enters the repo at volume                                                                                                                                                                                                                                                                                                                                    |
| 10  | Title registry; physical factory split                                                     | Claude                                             | Medium                                             | When the second title exists and can say what it needs. Not before                                                                                                                                                                                                                                                                                                                                                                        |

### 5.4 Decisions that are genuinely Justin's

Only the irreversible ones. Everything else in this document runs on stated defaults. The same list lives in `STATE.md`, which every session loads, so it cannot be forgotten.

1.  **Publish an unlisted place with API access on.** It is not a launch, but it is a publish action, and the doctrine makes every publish a human click. It now unblocks three things at once: the shelf rendering (InsertService), saves persisting (DataStores), and the comprehension test on a real build. `docs/runs/PERSISTENCE_TEST.md` has the three clicks — including the one everyone forgets, enabling Studio API access — and the seven-row test Claude runs the moment it is done.
2.  **G2 — the economy numbers.** The simulation proposes Candidate C. Approve, adjust, or reject before the kids see it; the slice can be tested un-tuned, but the numbers in front of them should be the ones we mean.
3.  **Two doctrine wordings:** the proposed §9 line is in STATE.md verbatim — *"Human owns: ship / no-ship, money, and the cut — removing what confuses. Generative taste is not asked of the owner; the AI proposes, the owner prunes."* Yes, no, or edit. And confirm the doctrine's Gate B floor governs; both other files now say it does.
4.  **Hold the line in §4.2:** no further system work until Fat Man Gets Rich has been through Gate A with fresh testers. This is the decision that protects the project from its own scaffolding, and it is the one Claude cannot make for you.

##### The answer to the question this document was written for

What has been created will improve games and learn from your work *if it is now used to make one*. It does not limit a good idea: nothing is deleted, every cap expires, every default can be deviated from in a line, and the ledger has no veto. It does not distract from an opportunity: ideas are pitched the moment they appear and logged without pausing the active title, and killing a title is a gate decision with a closeout, never a mid-build hop. Where it could detract — false blocks, a cap that is too tight, a ledger nobody feeds, or a system that keeps building itself — the safeguard is named, and where the safeguard does not exist yet, it is in the build order with an owner.

The factory is built enough. The next thing it should produce is evidence, and evidence only comes from a game in front of a stranger.

Appendix A

## Where everything lives

The `Roblox Business` folder on the Mac is the source of truth. The claude.ai project "RB – Business" is a read-only mirror. One canonical path per file; everything else links to it.

| Path                                            | What it is                                                                                                                                  |
|-------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------|
| START-HERE.md                                   | The map of the folder and the routing rule for where new files go                                                                           |
| system-map.html · roblox-pipeline/SYSTEM-MAP.md | The pipeline drawn as ten diagrams (render · source)                                                                                        |
| evidence/                                       | **The factory's memory.** SCHEMA.md, ledger/E-####.md, match.py, MATRIX.md, OPEN_QUESTIONS.md, CHANGELOG.md                                 |
| .claude/hooks/ · .claude/settings.json          | rbx_guard.py (R1–R7), pretooluse_guard.py, loop_cap.py, session_start.py; hook registration                                                 |
| .githooks/pre-commit                            | The git backstop (core.hooksPath is set)                                                                                                    |
| GrokBDownloads/                                 | Inbound only — approved Grok art (fbx, glb, previews)                                                                                       |
| roblox-pipeline/CLAUDE.md                       | What Claude loads at the start of every build session                                                                                       |
| roblox-pipeline/PIPELINE.md                     | The operating plan: what happens when you say "create a \_\_\_ game"                                                                        |
| roblox-pipeline/docs/ROBLOX_SUCCESS_LOGIC.md    | **Standing orders.** Outranks every other file                                                                                              |
| roblox-pipeline/docs/SYSTEM_ARCHITECTURE.md     | The factory across many titles: layers, build loop, compounding, portability, autonomy                                                      |
| roblox-pipeline/docs/GAME_FACTORY.md            | Engine / content-pack split; the six-question brief; the two-hour clock                                                                     |
| roblox-pipeline/docs/BUDGET.md                  | The complexity caps — provisional defaults with an expiry                                                                                   |
| roblox-pipeline/docs/FACTORY_PLAN.md            | This document, canonical text                                                                                                               |
| roblox-pipeline/docs/IDEA_LOG.md                | Every game idea. Logged → Shortlisted → Active → Shipped \| Parked                                                                          |
| roblox-pipeline/docs/runs/                      | One log per build session; STATE.md (read into every session); hook-allow.log                                                               |
| roblox-pipeline/skills/                         | Ten binding conventions: security, economy, art, live-ops, research-legal, rojo-map, studio-mcp, idea-intake, hooks, playtest-comprehension |
| roblox-pipeline/research/                       | Dated genre drops, the research playbook, patterns/ (mechanic teardowns)                                                                    |
| roblox-pipeline/specs/                          | Module specs, written before code, from TEMPLATE.md                                                                                         |
| roblox-pipeline/src/core/                       | **The engine.** Eleven services. A new game must not change it (R7 enforces)                                                                |
| roblox-pipeline/games/\<slug\>/                 | Content packs. One folder per title — brief, config, world, sku, theme. The only per-game work                                              |
| roblox-pipeline/tools/                          | build_map.mjs (renders the system map), studio_sync.py (unattended disk→Studio), meshimport/                                                |

### Appendix B — The comprehension script, verbatim

1.  **Say nothing.** Hand over the device. Do not explain, do not point.
2.  **Watch for 60 seconds.** Record: did they take a meaningful action unprompted? Which one? How long?
3.  **Ask, in these words:** *"What are you trying to do in this game?"* Write the answer verbatim.
4.  **Ask:** *"Do you want to play it again?"* Never "did you like it" — liking is politeness.
5.  **Only then** may the operator answer questions or explain anything.

### Appendix C — One evidence record, as written

--- id: E-0005 claim: Prose non-negotiables drift over long build sessions in a way that machine-enforced ones do not domain: process loop_verb: any session_shape: any audience: any monetization: any wave: any scale: pre-launch outcome: inconclusive metric: UNTESTED. The guard found zero true violations across 1,587 existing lines confidence: n=0 observed: 2026-09-12 status: open-hypothesis --- This record exists to be proven wrong. Filed at n=0 deliberately so it cannot be cited as a reason for anything.

The record the enforcement layer's own premise is filed under. A ledger that only records its wins is not evidence; it is advertising.

### Appendix D — Glossary for a non-programmer

Agent / subagent  
An AI instance given one narrow job. A subagent is spun off by another agent, does its task, reports back, and disappears.

CCU  
Concurrent users — how many people are in a game at the same moment. The number trackers show; not the number discovery rewards.

CI  
Continuous integration — checks that run automatically on every change (build, lint, tests) so nothing broken lands quietly.

Closeout  
The short structured record a title produces when it ships or dies: hypotheses marked, evidence filed, deviations noted.

Clone wave  
A genre that many studios copy at once after one hit. Rises in weeks, fades in months. Enter early or not at all.

Content pack  
Everything specific to one game — names, numbers, map, products, art — in one folder. The engine reads it at boot.

D1 / D7  
The share of new players who come back the next day / a week later. The number Roblox's discovery system now weights most.

DataStore  
Roblox's save system. The place where "a kid loses everything" happens if it is done wrong.

DevEx  
Developer Exchange — converting earned Robux to money. About \$0.0038 per Robux.

Engine  
The reusable code every game shares — saving, security, economy, progression. Written once, never per game.

Gate  
A checkpoint where the work stops for a decision or a measurement. Five are human decisions (G1–G5); Gates A/B/C are evidence bars.

Hook  
A small program that runs automatically on an event — before a file is written, when a session starts — and can refuse the action. A rule with a trip-wire instead of a sentence.

Ledger  
The evidence store: one record per finding, with the context that says when it applies.

Luau  
The programming language Roblox games are written in.

MCP  
Model Context Protocol — the plug that lets Claude reach into a running program. With Studio's MCP, Claude can read scripts, run code, press play and take screenshots instead of only writing text for a human to paste.

Onboarding / FTUE  
The first-time experience — the walkthrough, intro or how-to that gets a new player to understanding.

Pre-commit  
A check that runs when code is saved into the project's history. Ours refuses the save if a rule is broken.

Remote / RemoteEvent  
How a player's device talks to the server. The place cheaters attack. Every one is validated and rate-limited.

Robux  
Roblox's currency. Kids buy it with money; games earn it; DevEx converts it back.

Rojo  
The tool that keeps the game's code on disk (where it can be reviewed and versioned) and syncs it into Studio.

Session (Claude)  
One conversation. Claude keeps nothing between sessions except what is written to a file that the next session is made to read.

Skill  
A file of binding conventions Claude loads when a task matches. A reference shelf, not a trip-wire.

SKU / product  
One thing for sale in the game — a pass, a pack, a cosmetic.

Slice  
The smallest playable version of a game: one loop, one shop, one return hook. What Gate A tests.

Studio  
Roblox Studio — the editor where games are built and playtested.

### Appendix E — Sources compiled

ROBLOX_SUCCESS_LOGIC.md (doctrine) · PIPELINE.md · SYSTEM-MAP.md · GAME_FACTORY.md · SYSTEM_ARCHITECTURE.md · BUDGET.md · skills/hooks.md · skills/playtest-comprehension.md · docs/runs/2026-09-12-run-01.md · docs/runs/STATE.md · IDEA_LOG.md · evidence/SCHEMA.md and ledger E-0001–E-0005 · evidence/CHANGELOG.md · research/2026-09-12-claude-scaffolding-survey.md · the scheduled-task registry · the session of 12 September 2026 with Justin.

The Game Factory · v1.0 · 12 September 2026 · Re-verify platform facts by 12 November 2026.

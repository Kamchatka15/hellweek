# Roblox Game Pipeline — Operating Plan

**Owner:** Justin (product) + Hunter (design/playtest) · **Operator:** Claude (this workspace)
**Written:** Sept 11, 2026 · All platform facts below verified against current Roblox docs as of this date. Re-verify anything load-bearing before acting on it months from now — Roblox changed discovery, ads, gambling policy, and testing tools all within the last 15 months.

> **Precedence:** `docs/ROBLOX_SUCCESS_LOGIC.md` is standing orders and outranks this file. Where this plan and the doctrine disagree, the doctrine wins and this file gets corrected, not ignored. New game ideas: pitch immediately, log in `docs/IDEA_LOG.md`, never switch titles without Justin — see `skills/idea-intake.md`.

**What this is:** the standing process that turns a one-line command like *"create a meme coin game"* into a researched, built, tested, published, live-opped Roblox experience — with as little back-and-forth as possible, and with every job assigned to whichever tool does it best (not Claude by default).

---

## 0. The contract: what happens when you say "create a ___ game"

1. **One batched kickoff question round** (a single form, ~60 seconds of your time):
   - Target age band, and whether Hunter's friend group is the playtest pool
   - Scope: weekend jam (ride a clone wave) vs. 4–6 week v1 (own a niche)
   - Monetization stance: none / cosmetics-only / full fair-play catalog
   - Art style seed (one reference image or three adjectives)
   - Budget caps: Robux for sponsored ads, $ for asset tools, $ for creators
   - Deadline hook: school break, meme window, nothing
2. **Then five gates. Everything between them runs without you:**
   - **G1** — pick one of 3 researched pitches (scored, one page each)
   - **G2** — approve the economy: prices, SKUs, KPI targets (one spreadsheet)
   - **G3** — fun-check the vertical slice (you + Hunter play 10 minutes)
   - **G4** — approve art direction (icon + thumbnail + one screenshot)
   - **G5** — publish, and creation of ANY paid product. Always a human click. Never automated. No exceptions.
3. Between gates I deliver artifacts to this chat and the repo. You reply in one line or not at all — silence means I proceed on the stated defaults for everything **except** G5-class actions, which wait forever.
4. **Running alongside all of it, always on:** any good game idea I notice gets pitched on the spot and written to `docs/IDEA_LOG.md` — including mid-build, including for genres we are not in. I never hold one back to look focused. I also never act on one: the active title keeps getting built until you promote an idea yourself. The top 3 logged ideas get re-read at G3 and at every kill decision.

**Gate map** (the doctrine's letters vs. this file's numbers — same checkpoints, two vocabularies):

| Doctrine | This file | What it is |
|---|---|---|
| — | G1 | Pick the pitch |
| — | G2 | Approve economy + KPI targets |
| **Gate A** — internal playtest, no spend | G3 (+ G4 art) | You + Hunter play the slice; stop-and-patch list |
| **Gate B** — 200–500 cold players | (new: G4.5) | Real strangers, retention table, before any money |
| **Gate C** — paid traffic, capped | after G5 | Small sponsored test on the winning icon only |
| — | **G5** | Publish / create paid products — human click, always |

Gate B has no number in the original five because the original five assumed publish-then-promote. The doctrine inserts it: **cold-player proof happens before any spend.**

Why the gates exist: they're the five decisions where being wrong is expensive and taste matters. Everything else is reversible, so I don't bother you with it.

---

## 1. Ground rules (read once, they govern everything)

**The audience is kids and teens — including Hunter's cohort.** Every feature clears two bars: the **policy bar** (would Roblox moderation/monetization rules allow it) and the **Hunter bar** (would we be comfortable with Hunter playing and paying for it, without us in the room).

**A position I'm holding, and you should pressure-test it:** I will build you the full retention machine — live events, streaks, collections, status goods, price ladders, virality hooks. I won't build the coercion machine — panic timers, pay-to-stop-suffering, gambling-shaped mechanics, guilt loops, obfuscated pricing. That's not just ethics; on this platform in 2026 it's the *winning strategy*, for four specific reasons:

1. **Roblox's June 2026 discovery rework** explicitly re-weighted recommendations toward D1/D2–7/D8–28 retention, session quality, and spend-days — and explicitly *devalued* thumbnail-driven short-term clicks. The algorithm now pays for games people keep choosing, not games that trick a first click.
2. **Roblox bans manipulative engagement mechanics and will kill your game for them.** In Aug 2026 they took down *Steal an Egg* — then the #1 game on the platform at ~800K CCU — over its doomscroll-to-progress mechanic. Simulated gambling is prohibited at **every** rating (the Grok doc's "17+ carve-out" is wrong — verified against current Community Standards). Paid random items require exact numeric odds shown before purchase, and five countries (UK, AU, BE, NL, BR) restrict them entirely via PolicyService.
3. **The FTC took $520M from Epic Games** over dark-pattern purchases and children's privacy. Kid-directed games are the single most regulated corner of gaming, and parents control both the wallet and Roblox's parental spend controls.
4. **The revenue proof points are generosity-coded games.** Grow a Garden (22.3M peak CCU — an industry record) runs on *offline growth that respects bedtime* and Saturday update events kids look forward to. Steal a Brainrot (25.4M peak CCU, still ~$1.4M/mo by RoWatcher's estimate) runs on drama kids clip for TikTok, plus scheduled *giveaway* events ("Admin Abuse"). The biggest games on the platform retain by being loved, and monetize by being loved.

**Economics honesty.** DevEx pays $0.0038/Robux ($0.0054 for spend from verified US 18+ players — adults are now worth 42% more, a real argument for games with age-breadth). 100K Robux ≈ $380. Most experiences earn ~$0. What separates earners isn't code volume — it's genre timing, D1/D7 retention, weekly cadence, and merchandising. Also: Creator Rewards now pays 5 Robux/day per active-spender who plays you 10+ min, and 35% of the first $100 spent by new users you bring to the platform — retention and off-platform promotion are literally line items now. And the clone-wave math: waves rise in *weeks* and fade in *months* (Steal a Fish: launch June 13 → 192K CCU peak → hundreds today). Speed is the moat. This pipeline exists to make us fast. So: **ship fast, measure honestly, kill fast, keep learnings, next pitch.** Portfolio mindset, not masterpiece mindset. **With the doctrine's correction:** portfolio means *sequential*, not parallel. One active title at a time; "kill fast" means killing at a gate on evidence with a learnings doc, not abandoning mid-build for a newer idea. Ideas keep flowing into `docs/IDEA_LOG.md` the whole time — the log is how speed and focus coexist. (For morale: Grow a Garden was built in 3 days by a 16-year-old. The ceiling for a small, fast team is the top of the entire industry.)

---

## 2. The stack (this specific setup)

```
Justin + Hunter (product, taste, gates)
   │
   ├─ Claude (Cowork/this workspace + optionally Claude Code CLI on the Mac)
   │    ├─ research, GDD, economy sims, all Luau, docs, orchestration
   │    ├─ repo on Hunter's MacBook (folder connected to Cowork) ← SOURCE OF TRUTH
   │    │    git + Rojo (`rojo serve` ⇄ Studio plugin; CI = `rojo build`)
   │    ├─ Roblox Studio MCP ← LIVE STUDIO HANDS
   │    │    (built into Studio now: Assistant → ⋯ → Manage MCP Servers → enable;
   │    │     macOS binary: /Applications/RobloxStudio.app/Contents/MacOS/StudioMCP;
   │    │     connect via Claude Desktop config → proxied into Cowork sessions, and/or Claude Code)
   │    │    read/edit scripts, execute Luau, playtest start/stop, screenshots,
   │    │    console, simulated input, mesh/material gen, Creator Store insert
   │    └─ scheduled tasks (already running: Monday market digest)
   ├─ Roblox Studio Assistant (in-Studio, first-party) — quick generations, Cube 3D meshes,
   │    Texture Generator; use it INSIDE Studio for one-off assets
   ├─ Open Cloud API — publish + game passes/dev products. HUMAN-GATED (G5).
   └─ External asset tools (per job — see §11 tool table)
```

**Two layers, one rule:** all real code lives on disk in the Rojo repo (reviewable, diffable, revertable). Studio MCP is for inspecting, playtesting, screenshots, asset generation/upload, and surgical in-place edits — never the primary place code lives. Never run two agents writing the same live DataModel at once.

**The Grok decision (you asked me to make it on cost):** skip Grok Build and Grok Bots entirely.
- *Grok Build* is a second coding agent — at our scale it adds subscription cost plus coordination overhead and no capability Claude lacks. Revisit only if we're running 3+ games and I'm saturated.
- *Grok Bots* require the heavy tier (~$300/mo class) to do busywork my scheduled tasks already do inside the plan you already pay for. That's the opposite of saving money.
- *Grok Automations* = redundant with my scheduled tasks. Skip.
- **The one thing Grok genuinely does better:** live X/Twitter discourse — meme velocity, what kid-culture is about to do next, creator chatter. If you *already* have X Premium, use Grok chat for that during Phase R and for Grok Imagine thumbnails, and paste results to me. If you don't, don't buy it for this — I'll approximate meme-velocity from TikTok/YouTube/DevForum (somewhat worse, free), and thumbnails come from Ideogram (free tier / ~$8 mo, better at text-in-image anyway).
- Net additional spend required: **$0.** Optional: ≤$10/mo for an image tool when we reach G4 of a real build.

Keep the Grok handoff doc's good ideas (Rojo as source of truth, human-gated publishing, spec-driven modules, the seven skill files — all adopted into this repo). Discard its errors (gambling 17+ claim; DIY A/B assumption — Roblox has native Experiments now).

---

## 3. Phase R — the research sprint (per genre, ~1–2 days elapsed)

The point: answer *"why is this genre popular, why do players keep playing, and why do they pay"* with evidence, before designing anything. This is the part you called out as critical, and you're right — a SKU nobody understands is a SKU nobody buys.

**Questions I answer for the genre, in order:**
1. **Market map** — top 10–20 experiences: CCU now vs. peak, visits, like ratio, age of game, update cadence. Sources: RoMonitor Stats, RoWatcher (revenue estimates w/ confidence), Rolimon's, RTrack, Roblox charts. (These purpose-built trackers beat me re-scraping; I read them, not raw endpoints.)
2. **Loop autopsy of the top 3** (public info + watching gameplay videos):
   - the 30-second hook (what do you DO in your first half-minute)
   - core loop verb + reward cadence (what number goes up, how often)
   - meta loop (collection / rebirth / base-building / index completion)
   - social loop (trade, steal, gift, show off, co-op) — this is usually the retention engine
   - event cadence (which day, how announced, what's given away)
   - monetization catalog: every visible SKU with price, classified as *acceleration / status / content / social*
   - what players complain about (DevForum, YouTube comments, TikTok) ← **our wedge**
3. **Wave timing** — is this genre rising, peaking, or fading? Clone waves rise in weeks; entering month 3 of a wave is entering a graveyard.
4. **Policy flags** — gambling-shaped mechanics, paid-random-item odds obligations, regional PolicyService restrictions, IP landmines (real brands, real memes with owners, other games' mascots — *Steal a Brainrot's* unlicensed Fortnite-clone got sued).
5. **Why-they-pay synthesis** — for each top game, one sentence: "players pay because ___." If I can't complete that sentence, the game's revenue is luck, and we don't copy luck.

**Deliverables to the repo:** `research/genre-brief.md`, `research/competitor-matrix.csv`, `research/policy-flags.md`, and **three pitches**, each one page, scored 1–5 on: session-length potential, spend-loop clarity, build cost, wave timing, policy risk, differentiation-vs-wedge, Hunter-testability. → **G1: you pick.**

**Research rules (in `skills/research-legal.md`):** public storefront/tracker data and public videos only. No private-endpoint scraping, no place-file copies, no asset rips, no mascot clones. We steal *shapes* (loops, cadences, price ladders), never *stuff*.

---

## 4. Phase D — design (I write, you approve the numbers)

- **One-page loop diagram:** action → reward → upgrade → bigger action. If it needs two pages, the game is too complicated for a first session.
- **First-session script:** minute 0–3 (hook + first reward), 3–10 (loop internalized + first meaningful choice), 10–30 (meta revealed + reason to return tomorrow). Tourist loop (fun in one snack session) vs. local loop (why day-8 players stay) designed separately.
- **Economy workbook** (a real spreadsheet): currencies, earn rates/hr, sinks, and the price ladder —
  - first purchase 25–99 R$ and *screamingly* good value (it converts trust, not revenue)
  - mid-tier 199–499 R$; prestige/status items higher
  - repeatable developer products beat one-time passes for LTV; passes build trust early
  - **every SKU must answer: "what does this let me DO or SHOW?"** — your instinct, formalized. Acceleration SKUs touch the loop players already love; status SKUs must be *visible to other players* or they won't sell.
  - paid-random anything: exact odds pre-purchase, sum to 100%, PolicyService fallbacks for restricted countries — or (usually better) skip randomized purchases and sell direct + earnable.
- **Retention systems** chosen from the fair-play catalog (§10), each with a reason.
- **Live-ops calendar** to week 8 before launch: weekly micro-drop, monthly theme, one tentpole.
- **KPI contract** (what "working" means, agreed before code):
  - join → first reward < 60s for ≥90% of new players
  - D1 ≥ 20% to proceed, ≥ 25% to spend on ads (calibrate against Creator Hub's similar-game benchmarks once we have 100+ DAU — rules of thumb until then)
    *Reconciled 2026-09-12:* these are **tiers**, not gates. The doctrine's Gate B floor governs (§5: ~12%+ is enough to test small spend; under ~8–10% is death). Read 20% as "good" and 25% as "hit territory" — never as the bar a title must clear to continue.
  - avg session ≥ 8 min at v1; 19+ min is hit territory
  - D7 ≥ 8–10%; payer conversion and ARPDAU tracked from day one, judged at week 4, not day 3
→ **G2: you approve prices + targets.**

---

## 5. Phase B — build

- **Repo layout** (this scaffold): `src/server`, `src/client`, `src/shared` mapped by `default.project.json`; specs in `specs/` using the module-spec template (owns / doesn't own / public API / DataStore keys / threat model / acceptance tests / out of scope — kept from the Grok doc, it was good).
- **Non-negotiables** (in `skills/roblox-security.md`): server authority for everything valuable; no client-trusted prices; validated + rate-limited remotes; **idempotent ProcessReceipt with a durable receipt ledger** (double-grant and lost-grant bugs are how kid-game devs end up in refund hell); DataStore session locking + versioned schemas; BanAsync for dupers.
- **Tests:** TestEZ for economy invariants (earn rates, price math, receipt idempotency), Selene + StyLua, CI `rojo build` on every merge.
- **Alternative versions — two mechanisms:**
  1. *Design-level variants* (different hook, different first minute): git branches, each auto-playtested via Studio MCP (below), best one merges.
  2. *Tuning variants in production*: **Roblox's native Experiments** (shipped 2026 — `ConfigService:GetConfigForPlayerAsync`, up to 2 variants + control, 14–60 days, rollout %, auto-measured D1/D7/playtime/ARPU/payer-conversion with significance testing). No more hand-rolled feature flags for A/B; we use the platform's own. Conditional configs also allow live tuning without server restarts.

---

## 6. Phase A — graphics & sound (the "MCP?" answer: yes, three doors)

**Door 1 — Studio's own AI (free, moderation-aligned, try first):** Assistant + Cube 3D mesh generation (`/generate`), Material/Texture Generator, procedural models — driven by me over Studio MCP or by you in-Studio. Good for props and blockout; rough for hero assets.
**Door 2 — Creator Store (free/licensed, zero moderation risk):** 100K+ licensed music tracks and SFX, plus free models. Default source for music — licensing is Roblox's problem, not ours. Inserted by asset ID via MCP.
**Door 3 — external generation → upload via MCP/Open Cloud:**
- *Thumbnails/icons (the #1 CTR lever):* Ideogram 4.0 (best stylized text-in-image), Recraft, GPT-Image, or Grok Imagine if you have X Premium. **I can judge and spec images but not render them** — this is a place other tools are simply the tool. Format: icon 512×512, thumbnail 1920×1080, readable at 200px wide: one face, one verb, ≤3 words.
- *3D:* Meshy (~$20/mo) / Tripo (~$20/mo, auto-rigging) / Hunyuan3D (free 20/day) → FBX/OBJ into Studio. Props are production-usable; characters still want human cleanup.
- *SFX:* ElevenLabs SFX (commercial license from $6/mo) or jsfxr-style chiptune I can generate in code for free.
- *Music:* Creator Store first. Suno/Udio only with a paid commercial tier and eyes open — the licensing landscape settled some in late 2025 (Warner/UMG deals) but is still in flux; outputs may lack copyright protection.
**Rules (in `skills/art-pipeline.md`):** own audio uploads are private-by-default (fine — usable in our experiences; 7 min / 20MB / 48kHz caps; 100 uploads per 30 days, 2,000 if ID-verified). Textures png/jpg/tga/bmp, ≤4K, prefer 256–1024 for props. **No third-party IP — including real meme-coin logos and mascots** (Doge/Pepe/etc. have owners and lawyers; original coins are funnier anyway). Nothing photoreal involving minors. When budget exists and a thumbnail matters, a human artist from Talent Hub beats all of the above.

---

## 7. Phase T — testing

1. **Economy simulation before anyone plays:** I Monte-Carlo the economy in Python here — earn rates vs. sinks vs. price ladder over simulated player-days. Catches "week-2 players are billionaires" while it's still a spreadsheet bug.
2. **Automated playtest loop (Studio MCP), every build:** start playtest → spawn → reach first reward (timed — must be <60s) → open shop → test-mode purchase → verify receipt ledger → console clean of errors → screenshots at 0/1/3/10 min. I review the screenshots against one question: *would a 9-year-old know what to tap?*
3. **Unit tests** (TestEZ) green on every merge.
4. **The Hunter protocol (the irreplaceable part):** session 1 — Hunter plays, we watch silently, notes on the first 60 seconds; session 2 — think-aloud; session 3 — friends session (do they explain it to each other? what do they show off?). Three questions after: what was the best moment? what confused you? would your friends play this tomorrow? **No AI substitutes for this.** DevForum "looking for playtesters" + Discord tester servers widen the pool for free.
5. **Soft launch** → measure against the G2 KPI contract → iterate the hook until D1 clears the bar **before** any money goes to ads. *Clarified 2026-09-12:* **unlisted / link-only is for Gate A** (persistence test, friends, Hunter's cohort). **Gate B needs 200–500 strangers, and an unlisted place gets none** — so Gate B is a **listed publish with zero spend**: Roblox's own new-experience impressions are the cheapest cold traffic there is and exactly the algorithm we want to test, widened for free by DevForum playtest posts and tester Discords. Listing is a G5 click. If D1 sits under the doctrine's floor after three honest hook iterations: archive, write the closeout, next pitch.

---

## 8. Phase L — launch & growth ("getting kids to play, and to bring others")

**Reality check first:** self-serve Roblox ads deliver to 13+ only; under-13 ad inventory is exclusive to SuperAwesome direct deals (brand-scale, not indie-accessible). So for a young-skewing game the channels are, in order of leverage:
1. **Algorithmic Home discovery** — driven by exactly the §4 KPI contract (retention, session quality, spend-days). The best growth hack on Roblox in 2026 is a game people return to. That's the whole trick.
2. **Virality as content design, not coercion.** Kids recruit kids when the game *produces stories worth telling*: steal/prank/heist drama, jackpot moments, absurd humor, show-off surfaces (bases friends can visit, leaderboards, photo-worthy cosmetics). Steal a Brainrot's growth engine was TikTok clips of betrayal. Design "clippable moments" on purpose. Positive-sum social mechanics: co-play bonuses when friends join (Roblox's discovery literally tracks intentional co-play days), gifting SKUs, group goals. **Never** "invite 5 friends or your pet dies" — that's the coercion machine, and kids and Roblox both punish it.
3. **Creators:** micro YouTubers/TikTokers in the niche run $20–200/video (mid-tier $200–2K). A $200 creator test beats $200 of sponsored tiles for a kid audience. Codes + early access cost nothing.
4. **Sponsored tiles (13+)** — small budget only after D1 ≥ 25%, to buy data and seed the algorithm, at $0.01–0.05/visit.
5. **Creator Rewards audience expansion** — 35% of the first $100 spent by new/reactivated users we bring: off-platform promotion (YouTube, TikTok, even school-friend word of mouth via share links) now pays directly.
6. **Title/metadata for semantic search** — search is natural-language now; the title should say what the game *is*.

---

## 9. Phase O — live-ops (where the money actually is)

Your instinct — "if they don't understand why they're charging, kids won't buy" — is the operating principle here: **events give purchases their why.**

- **Cadence:** weekly micro-drop (one theme, one SKU, one fix — same day every week, announced in-game with a countdown; the Grow-a-Garden Saturday-morning-cartoon pattern), monthly bigger theme, quarterly tentpole/season.
- **Update-day-as-event pattern:** login gift for showing up, one new thing to want, one thing fixed, changelog written so a kid can read it. Scheduled *generosity* events (SaB's "Admin Abuse" giveaways, Taco Tuesday) — appointment viewing that gives instead of takes.
- **Automation already running:** my Monday market digest (genre movers, new clone waves, policy changes). Once a game is live, add: Friday KPI review vs. the contract → next-drop proposal → your one-line approval → I build it → G5 publish. Real-time performance alerts + player segmentation (tenure/spend/engagement) via the 2026 analytics platform; conditional configs for no-restart tuning.
- **Monthly economy audit:** inflation, first-purchase conversion, whale concentration — if >30% of revenue is 10 accounts, rebalance toward breadth. Kid whales are parent-card chargebacks and policy attention waiting to happen; breadth is the durable business.
- **Scale/kill:** doubling down looks like more events + creator spend + a second SKU lane. Killing looks like a farewell event, learnings doc, and the next pitch reusing the engine modules. Both are wins if fast.

---

## 10. Why kids play, why kids pay (used honestly)

**Play drivers → systems we build:**
| Driver | What it looks like in-game |
|---|---|
| Fast time-to-fun | core verb in <30s, zero tutorial walls |
| Number-go-up mastery | visible progression: bigger backpack, deeper mine, shinier pet |
| Social co-presence (**#1 on Roblox**) | play WITH friends: co-op goals, trading, visiting bases |
| Drama & stories | steal/heist/prank mechanics → things to tell at school |
| Collection & completion | index books, sets, rare tiers — direct-buy or earn, odds-honest if random |
| Status & identity | cosmetics *other players can see*, titles, leaderboards |
| Novelty cadence | weekly drops = appointment viewing |
| Humor/meme fluency | ship the joke while it's funny; speed is the feature |

**Pay drivers (every SKU maps to one):** accelerate fun they're already having · show status others see · complete a collection · gift/participate socially · support a game they love (allegiance is real — that's what a well-priced pass harvests). Kids pay when the purchase makes tomorrow's session better or today's status visible. They churn — and review-bomb — when payment is relief from engineered pain.

**The anti-catalog (won't build, with receipts):** pay-to-stop-suffering loops · panic timers & fake scarcity engineered at kids · simulated gambling in any form (banned platform-wide) · undisclosed-odds randomness (policy-illegal) · doomscroll/forced-engagement mechanics (*Steal an Egg*, killed at #1) · guilt/social-pressure recruitment · obfuscated pricing/currency confusion (FTC×Epic, $520M). Scarcity-lite is fine when honest: rotating shops where items *return eventually and say so*.

**Fair-play retention catalog (choose per game):** daily quests with catch-up mercy · streaks with freezes (reward returning, don't punish missing) · offline/idle progress (bedtime-proof — parents notice) · battle pass with earnable currency back · rotating shop (honest scarcity) · collection index · trading with scam-guards (confirm screens, value hints, cooldowns — a game that protects kids from scams earns parent trust, which is the actual wallet) · events-as-celebrations.

---

## 11. Tool honesty table (who beats me at what)

| Job | Best tool | My role |
|---|---|---|
| Market stats/rankings/revenue est. | RoMonitor Stats, RoWatcher, Rolimon's, RTrack (free) | read & synthesize |
| X/Twitter meme velocity | Grok (only if you already have X Premium) | consume the paste |
| Kid/creator discourse | TikTok, YouTube comments, DevForum (free) | mine & synthesize |
| Luau systems, architecture, economy math, docs | **me** | own it |
| Quick in-Studio generation | Roblox Assistant + Cube 3D (free, first-party) | direct it via MCP |
| Thumbnails/icons | Ideogram 4.0 / Recraft / Grok Imagine — or a Talent Hub human when it matters | spec & judge, can't render |
| 3D props | Studio gen first → Meshy/Tripo/Hunyuan3D (free tier) | spec, import, wire |
| SFX | ElevenLabs ($6/mo) or code-generated chiptune (free, me) | either |
| Music | **Creator Store licensed library** (free, zero risk) | pick & insert |
| A/B testing | **Roblox native Experiments** | design & read them |
| Analytics ground truth | Creator Hub dashboards + benchmarks | interpret weekly |
| Playtesting | **Hunter + real kids** > everything | protocol & observation |
| Scheduled research/ops | my scheduled tasks (in your existing plan) | already running |
| Turnkey "AI makes your game" rivals | PromptBlox (template-grade), SuperbulletAI (unproven claims), BloxBot (free MCP bridge, fine) | none replaces this pipeline; Studio's own agentic Assistant is the one to watch |

---

## 12. Worked example: "create a meme coin game"

What Phase R already found (Sept 2026): **the niche is open.** No meme-coin sim has broken out — only small crypto-themed tycoons (Bitcoin Miner, Crypto Tycoon, a "create your own meme coin" toy). Meanwhile the adjacent meme-game wave (GaG, SaB) proved the loops: passive income units + steal drama + rotating shops + weekly events.

**The policy trap, front and center:** a literal trading sim — stake currency on random price swings — is *simulated gambling*, banned at every rating. The Robux-adjacent version would also trip paid-random-item rules. So the design must make outcomes **readable and skill-timed, not wagered:**
- Hype cycles are *telegraphed in-world* (a giant ticker, NPC influencers "leaking" the next pump, visible countdowns) — profit comes from reading the room and timing, not from RNG staking.
- **Launch-your-own-coin** as the UGC hook: kids design a coin (name, mascot from safe parts, meme sound) and shill it on the trading floor — social status = your coin mooning because *other players* bought in. That's the clippable moment AND the retention engine.
- **Rug pulls as comedy PvE events,** not player losses: the scheduled "RUG PULL!" boss moment drains an NPC bank, sirens, everyone scrambles — drama without gambling and without griefing wallets.
- Collection: a Coin Index (every meme coin ever launched on your server, rarity tiers, direct-buy display cases). Status: golden trading desks, ticker skins, "Diamond Hands" titles.
- Monetization: cosmetic desk/office status goods · acceleration (faster research of the next hype window) · social SKUs (boost a friend's coin) · starter pack at 49 R$ that overdelivers.
- **No real crypto anywhere near it** (platform-banned), no real coin logos/mascots (IP).
- The G1 decision I'd bring you: pure all-ages comedy-tycoon framing vs. leaning "trading floor" harder — the first is safer and probably bigger; kids don't know what the SEC is and don't need to.

---

## 13. Phase 0 checklist — this setup, next session with the Mac

Done today: ☑ this plan · ☑ repo scaffold (this folder) · ☑ seven skill files + CLAUDE.md + Rojo template + spec template · ☑ Monday market digest scheduled.

Needs you + the Mac (~20 minutes, I'll drive when connected):
- [ ] Connect a projects folder in the Claude desktop app ("Add folder") → I place this scaffold there, `git init`
- [x] Install/verify Roblox Studio on the MacBook; enable **Assistant → ⋯ → Manage MCP Servers → Enable Studio as MCP server**; add to Claude Desktop config so it proxies into my sessions (fallback: Claude Code CLI in the repo; second fallback: I drive Studio by screen control)
  - *2026-09-11: DONE — Studio MCP enabled in Assistant settings; Claude Desktop wired via Studio quick-connect (restart the Claude app to load it); `.mcp.json` added to this repo so Claude Code CLI sessions pick it up automatically.*
- [ ] Install Rojo plugin in Studio + `rojo` CLI (or Aftman) on the Mac
- [ ] Creator Hub: confirm the group/account that will own experiences; Open Cloud API key (least privilege) stored in a password manager — never in chat, never in the repo
- [x] Decide first target — *2026-09-11: Fat Man Gets Rich (Justin). Layer Mine parked with its research and mesh kit retained. See `docs/IDEA_LOG.md`.*
- [ ] Optional: pick the image tool at G4 time, not before

*Standing rule for every future session: re-verify platform facts (§1–§2 numbers, policies) if more than ~2 months old, before acting on them.*

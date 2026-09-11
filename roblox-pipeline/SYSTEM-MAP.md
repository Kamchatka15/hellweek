# System Map — Roblox Game Pipeline

Visual model of the pipeline's recurring logic: the loops, flows, and charts behind PIPELINE.md.
This is the source of truth for the diagrams; open `system-map.html` to see them rendered.
Fenced `mermaid` blocks render automatically on GitHub and in VS Code (Markdown Preview Mermaid extension).

## 1 · Master pipeline — command to ship

The whole machine. One line in at the top; a live game at the bottom. Diamonds are the 5 human gates — the only places that stop for you. Everything else runs on stated defaults. Two loop-backs: the fun-check bounces to rebuild, and a game that can't clear D1 gets killed and feeds the next pitch.

```mermaid
flowchart TD
    CMD["One-line command: 'create a ___ game'"] --> KICK["Kickoff form (~60s, one time)"]
    KICK --> R["Phase R: research sprint"]
    R --> G1{"G1 HUMAN: pick 1 of 3 pitches"}
    G1 --> D["Phase D: design + economy + KPI contract"]
    D --> G2{"G2 HUMAN: approve prices, SKUs, targets"}
    G2 --> B["Phase B: build vertical slice"]
    B --> T["Phase T: economy sim + auto-playtest + tests"]
    T --> G3{"G3 HUMAN: fun-check 10 min with Hunter"}
    G3 -->|"fun"| A["Phase A: art direction"]
    G3 -->|"not fun"| B
    A --> G4{"G4 HUMAN: approve icon + thumbnail"}
    G4 --> SOFT["Soft launch (unlisted) + measure vs KPI"]
    SOFT --> DEC{"D1 clears the bar?"}
    DEC -->|"no, tries left"| HOOK["Iterate the hook"]
    HOOK --> SOFT
    DEC -->|"no, 3x failed"| KILL["Archive + learnings doc"]
    DEC -->|"yes"| G5{"G5 HUMAN: publish + create paid products"}
    G5 --> L["Phase L: launch + growth"]
    L --> O["Phase O: live-ops"]
    O -->|"repeat weekly"| O
    KILL -->|"reuse modules, next pitch"| CMD
```

## 2 · The three nested loops — the retention engine

Every game we build is these three loops stacked. The core loop is the second-to-second fun. The meta loop is the reason to come back tomorrow. The social loop is the retention engine — it's what turned Steal a Brainrot into 25M concurrent players. If a pitch can't fill all three boxes, it won't retain.

```mermaid
flowchart LR
    subgraph CORE["Core loop — seconds"]
      direction LR
      A1["Act: the verb"] --> A2["Reward: number goes up"]
      A2 --> A3["Upgrade"]
      A3 --> A1
    end
    subgraph META["Meta loop — days"]
      direction LR
      M1["Collect / rebirth / build"] --> M2["Unlock new content"]
      M2 --> M1
    end
    subgraph SOCIAL["Social loop — the retention engine"]
      direction LR
      S1["Play WITH friends"] --> S2["Trade / steal / gift / show off"]
      S2 --> S3["Stories worth telling at school"]
      S3 --> S1
    end
    A2 --> M1
    M2 --> A1
    A3 --> S2
    S3 --> A1
```

## 3 · Player psychology → the system that serves it

Left column is why a kid plays; right column is the feature we build for it. We never build a system that doesn't answer a real driver, and we never leave a driver unserved. Social co-presence is starred because Roblox's own discovery tracks co-play, and it's the single strongest retention driver on the platform.

```mermaid
flowchart LR
    D1p["Fast time-to-fun"] --> Sy1["Verb in under 30s, no tutorial wall"]
    D2p["Number-go-up mastery"] --> Sy2["Visible progression: bigger, deeper, shinier"]
    D3p["Social co-presence *"] --> Sy3["Co-op goals, trading, base visits"]
    D4p["Drama and stories"] --> Sy4["Steal / heist / prank mechanics"]
    D5p["Collection and completion"] --> Sy5["Index, sets, rarity tiers"]
    D6p["Status and identity"] --> Sy6["Cosmetics others can SEE, titles, leaderboards"]
    D7p["Novelty cadence"] --> Sy7["Weekly drops = appointment viewing"]
    D8p["Humor / meme fluency"] --> Sy8["Ship the joke while it is funny"]
```

## 4 · The monetization 'why' loop — your core thesis

Your instinct, drawn as a loop: kids don't buy a bare catalog row, they buy into a moment. The event creates a specific want, the SKU attaches to that want, and the payoff has to be visible to others or felt in play — that's what earns the next purchase. Every SKU is classified against one of four drivers; if it maps to none, it doesn't ship.

```mermaid
flowchart TD
    EV["Scheduled event: weekly drop / season"] --> WANT["Creates a specific want"]
    WANT --> SKU["SKU attached to the moment (never a bare catalog row)"]
    SKU --> BUY["Purchase"]
    BUY --> VIS["Payoff visible or felt: status others see, or fun accelerated"]
    VIS --> PLAY["More play, more sessions"]
    PLAY --> ALLEG["Allegiance to a game they love"]
    ALLEG --> EV
    SKU -.map to one.-> C1["Accelerate fun they already have"]
    SKU -.map to one.-> C2["Show status others see"]
    SKU -.map to one.-> C3["Complete a collection"]
    SKU -.map to one.-> C4["Gift / social participation"]
```

## 5 · Live-ops heartbeat — the recurring automation loop

This is the part that runs forever after launch and is where the money actually is. The weekly loop is already half-automated: my Monday market digest is live now; once a game ships, Friday KPI review → draft next drop → your one-line yes → I build → you publish becomes the recurring cycle. The content clock (weekly/monthly/quarterly) sets the theme; the monthly economy audit feeds the drops.

```mermaid
flowchart TD
    subgraph CLOCK["Content clock"]
      direction TB
      W["Weekly micro-drop: 1 theme, 1 SKU, 1 fix"]
      M["Monthly theme"]
      Q["Quarterly tentpole / season"]
    end
    subgraph LOOP["Weekly ops loop — recurring"]
      direction TB
      K1["MON: market digest (automated)"] --> K2["FRI: KPI review vs contract"]
      K2 --> K3["Draft next drop spec"]
      K3 --> K4["HUMAN: one-line approval"]
      K4 --> K5["Claude builds"]
      K5 --> K6["G5 HUMAN: publish"]
      K6 --> K2
    end
    W --> K3
    AUDIT["Monthly economy audit: inflation, first-buy conversion, whale concentration"] --> K3
```

## 6 · Player lifecycle — where players are won or lost

The states a player moves through, and the two exits. The first minute is the whole ballgame: reach the first reward in under 60 seconds or they churn. Every retention system exists to push a player one state to the right — toward Advocate, the player who brings friends and makes the clips that grow the game for free.

```mermaid
stateDiagram-v2
    [*] --> FirstMinute: join
    FirstMinute --> Hooked: first reward under 60s
    FirstMinute --> Churn: confused or boring
    Hooked --> DailyReturn: a reason to come back tomorrow
    DailyReturn --> WeeklyEvent: appointment viewing
    WeeklyEvent --> Collector: chasing completion / status
    Collector --> Advocate: brings friends, makes clips
    Advocate --> WeeklyEvent: keeps returning
    Churn --> [*]
```

## 7 · Clone-wave timing — when to enter, when to run

The chart you need before committing to a genre. Meme/clone waves rise in WEEKS and fade in MONTHS (Steal a Fish: 0 → 192K CCU peak → hundreds, inside a few months). Enter weeks 0–3 while it's climbing, harvest through week 8, and be out or diversified before month 3. Entering a wave in month 3 is building on a graveyard. Speed is the moat.

```mermaid
xychart-beta
    title "Typical clone-wave lifecycle (relative concurrent players)"
    x-axis ["wk0", "wk1", "wk2", "wk3", "wk4", "wk6", "wk8", "mo3", "mo4", "mo6"]
    y-axis "Relative CCU" 0 --> 100
    bar [2, 15, 45, 80, 100, 85, 60, 30, 12, 3]
    line [2, 15, 45, 80, 100, 85, 60, 30, 12, 3]
```

## 8 · Retention decay — loved game vs. trick game

Why the fair-play stance is the winning strategy, in one chart. Top curve is a game people love (gentle decay, a durable base). Bottom curve is a game that wins the first click with a trick and bleeds out (Roblox's June 2026 discovery rework actively devalues this pattern). The area between the curves is the entire business. We build the top curve.

```mermaid
xychart-beta
    title "Percent of new players still active (loved = upper, trick = lower)"
    x-axis ["D0", "D1", "D3", "D7", "D14", "D30"]
    y-axis "Percent still active" 0 --> 100
    line [100, 25, 18, 12, 10, 8]
    line [100, 12, 5, 2, 1, 0]
```

## 9 · Kill-or-scale decision — the portfolio gate

The unemotional rule that keeps us fast. Soft-launch D1 decides the game's fate. Above 25%, pour fuel on it. Below 15% after three honest hook rewrites, kill it the same week — farewell event, write the learnings, reuse the code modules on the next pitch. A fast funeral is a win: it's what frees us to catch the next wave.

```mermaid
flowchart TD
    SOFT["Soft-launch metrics"] --> Q1{"D1 retention?"}
    Q1 -->|"25%+"| SCALE["SCALE: creator spend + 2nd SKU lane + deeper events"]
    Q1 -->|"20-25%"| SHIP["SHIP: iterate weekly"]
    Q1 -->|"15-20%"| HOOK["ITERATE the hook (up to 3x)"]
    Q1 -->|"under 15%, 3x failed"| KILL["KILL: farewell event, learnings doc, reuse modules"]
    HOOK --> SOFT
```

## 10 · Tool routing — who does each job best

Your standing rule made concrete: the best tool wins, not Claude by default. I own architecture, Luau, and economy math. Everything else routes to whoever is better — trackers for market data, the platform's own A/B system for experiments, and Hunter plus real kids for the one thing no AI can do: tell us if it's actually fun.

```mermaid
flowchart LR
    J1["Market stats / revenue est."] --> T1["RoMonitor · RoWatcher · Rolimon's"]
    J2["Luau, architecture, economy math"] --> T2["Claude (me)"]
    J3["Thumbnails / icons"] --> T3["Ideogram / Recraft, or a human artist"]
    J4["3D props"] --> T4["Studio Cube 3D, then Meshy / Tripo"]
    J5["Music"] --> T5["Creator Store licensed library"]
    J6["A/B testing"] --> T6["Roblox native Experiments"]
    J7["Playtesting: is it fun?"] --> T7["Hunter + real kids (irreplaceable)"]
    J8["Scheduled research / ops"] --> T8["Claude scheduled tasks"]
```


# Pattern: Leaderboards

## What it is
A ranked, public display of players by some tracked metric. Global, friends-only, server-local, or per-category; all-time or reset on a cadence.

## Why it works (the psychology)
- **Social comparison + competence drive** — kids measure themselves against others; being ranked is intrinsically motivating (self-determination theory).
- **Status as a retention hook** — reaching #1 is a reason to keep playing AND to defend the spot. Status you can lose is stickier than status you keep.
- **Aspiration ladder** — a new player seeing #1 with a huge number learns "this is how deep the game goes." The board sells the long game.
- **Goal structure** — supplies a goal when the core loop doesn't have an obvious one yet.

## Real examples
- Effectively universal in simulators/tycoons — but the ones that RETAIN lean on **weekly/seasonal** boards, not all-time. Fresh reset = everyone has a real shot every week (pairs with the live-events pattern).
- Friends/social boards exploit Roblox's own social graph — competing against 5 real friends beats competing against a global stranger.

## Merit conditions (add it only if…)
- The tracked metric reflects **skill or investment players are proud of**, not just raw time or Robux spent.
- There is a **realistic path onto some board for a normal player** — a global all-time board alone fails this.
- The board **creates rivalry at the player's own level** (friends/server/weekly), not just crowns one god.
- The metric is **server-authoritative and hard to fake** (see failure modes).

## Failure modes (why naive leaderboards LOWER engagement)
- **Global all-time board = dead for newcomers.** Top spots lock to week-1 grinders; a new kid can't crack it, so it signals "you're too late" and demotivates the 95%.
- **Whale/"most spent" board** = pay-to-win chest-thumping. Demoralizes free players and invites parent/policy scrutiny. Avoid ranking on spend.
- **Cheater magnet.** Global boards are the #1 exploit target on Roblox. One dupe and the board is garbage and honest kids quit. Requires server authority + anomaly detection, or don't ship it.

## Better-practice moves
- **Weekly reset board + top-N reward** (a visible cosmetic/title) → recurring appointment AND status others can see (loops into monetization "why").
- **Category boards** so many players can each be "#1 at something" — spreads status around.
- **Friends & server boards** for personal, winnable rivalry.

## Applied to Layer Mine (Hunter's game)
Current: a saved all-time Top-N board of total money collected. Honest read — that's the WEAKEST option for ongoing engagement: it locks to whoever grinds first, and "total money" rewards hours-played over skill. Keep it as the aspiration ceiling, but add:
1. **Weekly "Most ore mined this week"** board, resets Mondays, cosmetic pickaxe/title for top 3 → the real recurring hook.
2. **"Deepest depth reached"** board → depth is Layer Mine's SKILL axis (heat damage, shields). Rewards mastery, not grinding, and advertises the danger loop to newcomers.
3. **Friends board** → Hunter vs. his actual friends is the strongest retention lever in a kid's game.

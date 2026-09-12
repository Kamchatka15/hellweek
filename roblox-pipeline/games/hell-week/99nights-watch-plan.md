# Watch plan — 99 Nights in the Forest, played live

> Purpose: correct and extend `research/patterns/hell-week-99nights.md`, which was built entirely
> from public sources. Three of its most important rows were never seen, only read about. This plan
> replaces reading with watching, and turns what we see into an add-list for Hell Week.

## What the tools can actually do

Getting this right first, because the obvious assumption is wrong.

| Tool | Can it watch 99 Nights? |
|---|---|
| Roblox Studio MCP | **No.** It attaches to Studio. 99 Nights is someone else's published place, so it cannot be opened, inspected, or read. Trying would also be ripping, which doctrine forbids |
| Studio `screen_capture` | **No.** Edit-time only. It returns a black frame in Play mode |
| computer-use `app_screenshot` | **Yes.** It photographs the Roblox player window on this Mac |

The third one is the instrument. It captures a named window in the background without taking over the
screen and without bringing the window forward, so it works while he plays fullscreen, and nothing I
do can touch his controls. I watch. I never press anything.

## The rule that governs every frame

We record **timings, shapes, and reactions**. We do not record assets.

No mesh, no texture, no audio, no UI layout traced, no script read. Screenshots are internal working
reference and are never shipped, never published, never handed to an art pass. This is the same line
the existing teardown already holds, and it is the line that makes watching a competitor legitimate
research instead of theft.

## Before he sits down

1. Roblox player open on this Mac, signed in as him, not as an adult account. Age-gated content and
   the shop both differ by account age, and his account is the one that matches our audience.
2. Fullscreen is fine. Another Space is fine. Minimized is fine.
3. **Do not tell him we are studying it.** A kid who knows he is being observed plays to be observed.
   Tell him he is playing 99 Nights, which is true.
4. Ask him to talk while he plays. Frame it as "say what you're doing", not "narrate for Claude".
5. One adult sentence I need in chat when he starts: *"he's starting, session 1"*, so I know to begin.

## Three sessions, three questions

Splitting this matters. One twenty-minute blur answers nothing; each session is aimed.

### Session 1 — the door, 5 minutes

**Question: how does a stranger get from launch to playing, and what does the game sell them?**

He launches cold, from the Roblox home page, and goes as far as the first log in the fire.

What I am watching for:

- The **team-size picker**. The teardown says 1 to 5, chosen in a box, and that difficulty locks to the
  starting number. Hell Week has no picker at all. I need to see where it sits, what it looks like, and
  whether a kid understands it or walks past it.
- The **class shop**: what it shows a player with zero diamonds, and whether it is reachable before the
  first run or only after.
- **Time to first reward.** I will stopwatch launch to first log in the fire against the 20 to 40
  seconds the public guides claim.
- Whether he reads anything on screen, or just moves.

Capture: dense for the first 90 seconds, then every 20 seconds.

### Session 2 — one full day and night, 10 minutes

**Question: what does the minute-to-minute machine actually look like, and how is it communicated?**

Two full cycles at 3:00 day and 1:30 night.

What I am watching for:

- **HUD density and the exact numbers shown.** Our teardown says four numbers and calls that a thing to
  not copy. I want to see whether the fourth number is actually noisy or whether we were wrong.
- **Fire level feedback.** The moment the radius pops and the fog peels is the single best teaching
  moment in the genre. I want to see exactly what the player is shown at that instant.
- **Night 1 mercy.** The Deer is supposed to stand at the light line and stare without attacking. This is
  the row Hell Week copied most directly into the stalker's `watch` mode, and it has never been
  verified by eye.
- **What he does during night.** Hide, build, or keep working. This decides whether Hell Week's 45
  second night is dead time or the best part.

Capture: every 15 seconds, plus immediately on anything he reacts to out loud.

### Session 3 — death and the return, open-ended

**Question: what makes him start a second run?**

This is the session that matters most, because it is the gap Hell Week actually has. He plays until he
dies. A death is the data. If he is too good at it, he plays solo on the hardest headcount.

What I am watching for:

- The **death screen**: what it says, what it offers, how fast it puts him back.
- **What carried over**, and how the game shows him that it carried. Diamonds earned, class unlocked,
  badge popped. The *presentation* of persistence matters more than the persistence.
- Whether a **badge notification** fires, and whether he notices it.
- The first thing he does on run two. If he shops, the meta loop works. If he just queues again, it
  does not, and we have been overrating it.

Then, and only then, three questions in these words:

1. *"What made you want to play again?"*
2. *"What would you buy first if you had money in that game?"*
3. *"What is the most annoying thing about it?"*

Verbatim answers. Number three is the wedge.

## What comes out of it

| Output | File |
|---|---|
| Corrections to anything the public sources got wrong | `research/patterns/hell-week-99nights.md`, marked **watched** rather than *snippet* |
| The add-list for Hell Week, ranked | `games/hell-week/loop-gaps.md` |
| His three verbatim answers | `evidence/ledger/` as a new record |

## The six gaps this is testing

Already written up in `games/hell-week/loop-gaps.md`. Each session is aimed at specific rows:

| Gap | Session that settles it |
|---|---|
| Power that carries between runs | 3 |
| Badge ladder as telemetry | 3 |
| Team-size picker | 1 |
| Scheduled appointment | 1, if an event banner is live |
| A second clip type | 2 |
| Lobby-side shop | 1 and 3 |

## What this is not

This is not Gate A. Gate A is three strangers playing **our** game in silence, scripted, in
`games/hell-week/gate-a-script.md`. This is competitive research with a ten-year-old as the
instrument, which is a different job and a better use of him right now, because he is allowed to talk.

He can still take Gate A later **only if** he has not seen Hell Week being built. If he has been
watching over a shoulder, he is contaminated and his Gate A run is a smoke test, not a result.

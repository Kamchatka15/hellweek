# Hell Week — Gate A script for Hunter

> Run `skills/playtest-comprehension.md` **verbatim**. Three kids who have never seen the game and did not help design it. Hunter operates; Justin is not in the room for the comprehension part. Same words every time.

## Before the kid sits down
- Studio, play mode, fresh session (or the unlisted place once published). Sound on if the shelf is wired; off is fine for Pass 1.
- Nothing said. No "it's like 99 Nights". Hand over the device.

## The 60 seconds — record, do not speak
| Watch for | Write down |
|---|---|
| First meaningful action | what and at what second (picked up Ashwood? walked to the light? walked away from it?) |
| Did they feed the Wick unprompted? | time to first feed |
| Did they notice the Tempter appear? | look / flinch / comment / nothing |
| Did they read either toast? | which one, or neither |

## Then ask, in these words
1. **"What are you trying to do in this game?"** — verbatim answer.
2. **"Do you want to play it again?"** — yes / no, verbatim.
3. *(Hell Week extra, after Day 3 has been reached at least once)* **"What is the pile with the weird glow?"** — verbatim answer.

Only after all three may Hunter explain anything.

## Pass conditions (from the skill, plus H1/H2)
- Goal comprehension: 2 of 3 describe feed-the-light / stay-in-the-light in their own words. **H1.**
- First action: 2 of 3 act meaningfully inside 60 s unprompted.
- Pull: 2 of 3 want a second go, unasked.
- Loop completion: pick up → feed → radius grows, unassisted.
- Gift read: 2 of 3 call the glowing pile a trap / bad / "don't take it". **H2.**
- Stability: one full run (Day 1 → Day 3 night) with no softlock; persistence only counts once the place is published.

## File afterwards
One evidence record per run in `evidence/ledger/` (even the boring ones), plus the two budget questions from `docs/BUDGET.md`: did a cap block something the slice needed? did testers get confused inside the caps?

## Capture — how the pictures get taken

**Claude cannot take them.** The Studio MCP `screen_capture` tool returns a black frame in Play mode;
it only works at edit time. Every image of the game actually being played has to come off a human
screen recording.

What to record:

| Setting | Value |
|---|---|
| Tool | Studio, F5 Play, macOS Shift-Cmd-5 recording the Studio window |
| Length | 3 minutes, unbroken, no pause |
| Audio | on, so the think-aloud is on the tape |
| Camera | leave it where the tester puts it, never fix it for them |

Three minutes is not arbitrary. One day is 100 seconds and one night is 45. Three minutes covers the
whole of Day 1, the whole of Night 1, and the first 35 seconds of Day 2. That is exactly the span
where a stranger either understands the game or does not.

The operator stays silent for the first 60 seconds of it. That silence is the instrument.

Hand the file back as a `.mov` or as stills at these five moments:

1. Spawn, before they move
2. First pickup, or the 60-second mark if there was none
3. First feed at the obelisk
4. The moment the night lighting lands
5. First sight of the stalker on the light line

**Who counts as a subject:** anyone who has never seen this game and had no hand in designing it. A
son who has been watching the build over someone's shoulder is contaminated the same way Justin is,
and his run is a useful smoke test but not a Gate A result. Gate A needs three clean strangers.

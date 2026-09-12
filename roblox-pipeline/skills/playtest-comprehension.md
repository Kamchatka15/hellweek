# Skill — the comprehension test (Gate A)

> **Governed by `docs/ROBLOX_SUCCESS_LOGIC.md` (standing orders).** If this file fights that file, that file wins.

**The bar:** a ten-year-old who has never seen the game understands it quickly enough to want to keep playing.

## Who runs it, and who cannot take it

| Role | Who | Why |
|---|---|---|
| **Subject** | 3+ kids who have never seen this game and did not help design it | The only valid instrument |
| **Operator** | Hunter | Recruits, runs the script, records answers. A real job, and the right one for him |
| **Nobody** | Justin | He designed it. He already knows the answer |
| **Usually nobody** | Hunter, as subject | See below |

**Hunter cannot be the primary tester for a game he helped design.** He is contaminated exactly the way Justin is — he knows what the button does because he was in the room when it was decided. This is not a small correction: a co-designer passing a comprehension test is the single easiest way to convince yourself a confusing game is clear. Hunter is far more useful running the test than taking it, and his cohort is the recruiting pool.

Hunter may be a subject for a title he had **no** design input on. That is worth tracking honestly in the result.

## Not the same test as the Hunter protocol

`PIPELINE.md` §7.4 ("the Hunter protocol": Hunter plays across three sessions, think-aloud, friends session, *what was the best moment / what confused you / would your friends play tomorrow*) is the **G3 fun-check** — is it fun, is it clippable. This file is **Gate A's comprehension check** — is it understood by someone with no context. Both run. Different subjects, different questions, and neither replaces the other.

## The script — run it exactly, every time

Same questions every time is the point. Deviating makes results incomparable, which defeats the ledger.

1. **Say nothing.** Hand over the device. Do not explain, do not point, do not say "try the thing over there."
2. **Watch for 60 seconds.** Record: did they take a meaningful action unprompted? Which one? How long?
3. **Then ask, in these words:** *"What are you trying to do in this game?"* Write down their answer verbatim — not your summary of it.
4. **Then ask:** *"Do you want to play it again?"* Do not ask if they liked it. Liking is politeness; wanting another go is not.
5. **Only then** may the operator answer questions or explain anything.

## Pass conditions

| Check | Pass |
|---|---|
| Goal comprehension | 2 of 3 testers describe the actual goal in their own words |
| First action | 2 of 3 act meaningfully within 60s, unprompted |
| Pull | 2 of 3 want a second go, unasked |
| Loop completion | Earn → spend → visible progress, unassisted |
| Stability | One full session, no softlock, no data loss |

Anything less is a stop-and-patch, not a debate.

## What gets filed afterwards

Every run produces at least one evidence record in `evidence/ledger/` — including the boring ones. A test where everything passed is still `n+1` on whatever the slice was betting. Plus the two budget questions from `docs/BUDGET.md`.

**Verbatim answers matter more than the pass/fail.** *"You collect the coins before the flood"* and *"you run away from the water"* are both passes on paper and describe two completely different games — and the gap between them is the most useful thing the test produces.

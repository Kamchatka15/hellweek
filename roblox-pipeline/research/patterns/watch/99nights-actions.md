# Session 3 — action watch, started 19:08:45Z

Method: dense sampling, tracking the SEQUENCE OF ACTIONS and the player's own words.
Not a UI audit. What he does, in what order, and why.

| t | where he is | what he is doing | what changed |
|---|---|---|---|
| t0 | LOBBY, pre-run | reading the four-panel intro comic | first sight of the door |

## t0 — THE LOBBY, at last

The screen I never saw. Everything listed as unobserved is on it.

**A four-panel black-and-white comic tells the whole premise before you play:**
1. Reports of a DEER standing on two legs, unnaturally, in the forest
2. The following week 4 CHILDREN went missing, something was very wrong with the forest
3. Police found no clues, the forest was locked to the public
4. **"You have 99 NIGHTS to unravel the mysteries of the forest and figure out what is going on"**

Red header: "THIS GAME IS BASED ON A TRUE STORY. SOME DETAILS HAVE BEEN CHANGED".

Then one big green **PLAY**.

### Why this matters more than any UI note I filed earlier
**The goal is stated in flat text before the game starts.** Panel four is a sentence a nine-year-old
can read. No tutorial, no NPC, no tooltip. The comic does the job, it takes about eight seconds, and
it also sets the tone.

Hell Week's opening act is atmosphere: a voice, blood-red English, the transliteration beneath. It
is a mood piece. **It never states the objective in plain words.** That is the difference between
"you awake as if from a dream" and "you have 99 nights to figure out what is going on".

Our Gate A pass condition is that two of three testers describe the actual goal. Right now nothing
in Hell Week ever tells them what it is.

### Lobby furniture visible
- **classes** button, badge icon
- Diamonds **40**, with a green + to buy more
- A counter reading **196** beside a calendar glyph
- **supply crate** on the right
- Event or quest boards along the right wall
- Other players standing around in a dark market-stall lobby

## t1 — the lobby is a status parade

Comic dismissed. The lobby proper is a dark market street full of other players, and:

- **Every player has a number floating above their head.** Seen at once: 196, 505, 615, **1015**.
  That is their day record, worn publicly. The lobby is where the ladder is displayed.
- Avatars are heavily cosmetic. A giant neon rainbow spider dominates the centre of frame, several
  players in bee costumes. People dress up here.
- Someone's nameplate reads **"Creating..."** in orange, so party or server creation happens in
  world, next to you, visibly.
- Left wall: **classes**. Right wall: **supply crate**, plus two named quest boards.
- Diamonds **40** with a green **+** bottom-left. The buy button is always on screen in the lobby
  and never during a run.

### The finding
**Progression is social, and it is displayed on your body.** A 1015 walking past you is the single
most effective advertisement the game has for playing another run. Nobody had to be told that
number matters; it is just there, over someone's head, larger than yours.

Hell Week persists `bestDay` and shows it to nobody. We have no lobby, so we have no place to wear
anything. That reframes the team-size-picker gap: the reason to build a lobby is not matchmaking,
it is **somewhere to be seen**.

## t2 — what exactly is worn

Clearer read on the floating nameplates. Each player carries **two** things above their head:

1. A **calendar glyph and a number**: 196, 222, 42, 445. Explicitly a day record.
2. A **class emblem** beside it, the same gold shield seen at run start.

So an avatar in the lobby advertises **how far you have got** and **what you have unlocked**. Both
are outputs of the between-runs meta loop, and both are legible to a stranger at a glance without
clicking anything.

The 42 standing next to the 445 is the entire retention pitch, delivered with no words.

## t3 — THE TEAM-SIZE PICKER, and it is a place, not a menu

He walked through a gate marked with yellow chevrons and stood on a **glowing pad on the ground**.
The pad has **1/5** written on it in large yellow letters. Nearby pads read **1/2** and **0/20**.
A red **exit** button floats in front of him to step back off.

### This is gap 3, solved, and the solution is better than the one I had in mind
I had this filed as "a team-size picker at the door" and was imagining a menu. It is not a menu.

- **Each party size is a physical square you stand on.** Bigger group, different square.
- **The number on the pad is both the capacity and the live count.** 1/5 means five-player mode with
  one person on it. You can see other pads filling from across the room.
- **Arrows on the wall point you at them.** The level design does the explaining.
- **Exit is a button, not a back gesture.** Stepping off is as explicit as stepping on.

A kid who cannot read still understands this, because it is just standing somewhere. A menu requires
reading. **Hell Week should copy the pad, not the picker.** We already build zone discs for the
beacon and the offering, so this is the same primitive we already have.

Note also: a **0/20** pad exists. The public sources all say 1 to 5. Larger modes are live now.

Lobby also shows a **0/5** counter and **906** next to the classes button, so there is a second
collection ladder there.

## t4-t5 — the lobby layout, then the commit

Wandering the lobby before committing. Layout reads as a street:

- **CLASSES** is a large red building with its name written on it in big letters, like a shop front
- The **matchmaking pads** sit in the middle of the street, several side by side, players standing
  on them, cones marking the lanes
- **supply crate** on the opposite wall
- Day counts over heads all around: 153, 222, 508

Then a **hard cut to black**. That is the teleport into the run.

### Action note
He stepped onto the **1/5** pad, stepped off, wandered, and then committed. He chose the
**five-player** pad while playing alone. Worth asking him why. The plausible reasons are all
interesting: hoping someone joins, better loot, or simply that it is the biggest number.

## t6 — the loading screen states the objective again

Black screen, centred, in a quiet serif:

> **· Survive 99 Nights**

So the goal is stated **twice before the player ever moves**:

1. Comic panel four: *"You have 99 NIGHTS to unravel the mysteries of the forest and figure out what
   is going on"*
2. Loading screen: *"Survive 99 Nights"* — three words, imperative, no decoration

The second one is the title of the game restated as an instruction. It is impossible to miss and
impossible to misread.

### The Hell Week problem, stated plainly
Our opening act is: you awake as if from a dream, a voice speaks, blood-red English over small
transliterated Egyptian. It is atmosphere and it is good atmosphere. **It never once says what the
player is supposed to do.**

Gate A's first pass condition is that two of three testers describe the actual goal in their own
words. As built, a Hell Week tester has been given mood and no objective. The fix is one line in the
same blood-red type, after the voice and before the world: **Survive seven nights.** Or whatever we
want the sentence to be, as long as there is one.

This is the cheapest single change on either list and it attacks the pass condition most likely to
fail.

## t7 — RUN 2 BEGINS. The action sequence, finally.

Spawn: Day 1, **"Equipped class Assassin"** again, hotbar back to **4 slots**, carry cap back to 5.

### Clarification this forces on an earlier finding
The 8 hotbar slots and the cap of 15 seen at Day 5 were **within-run progression, and they reset**.
The only thing that survives a run is the **class**. So:

| Layer | Persists? |
|---|---|
| Class | **Yes**, between runs |
| Hotbar slots, carry cap, tools, base | **No**, resets every run |

That is a cleaner and more copyable structure than I described before. The run has its own full
progression curve from 4 slots to 8 and 5 cap to 15, and it is thrown away every time. The meta
layer is deliberately thin: one class.

### The first action of the run
Within roughly ten to fifteen seconds of spawning: **selects the axe from slot 2 and chops the
nearest tree.** A felled log is already on the ground at his feet.

No hesitation, no looking around, no reading anything. Spawn, axe, tree.

## t8-t9 — felling is two steps, and his second decision is CRAFT not FEED

### A felled tree becomes physical logs you must haul
The tree he chopped left **three or four separate log segments lying on the ground where it fell**.
Felling and hauling are two different jobs. That is the entire reason a carry cap of 5 creates a
game instead of an annoyance: the wood exists in the world, at a distance, in pieces.

Hell Week's resource nodes yield straight into the sack on one interaction. There is no haul.

### The observed action sequence so far
| # | Action | Note |
|---|---|---|
| 1 | Select axe, chop nearest tree | ~10-15 s after spawn, no hesitation |
| 2 | Pick up the logs it dropped | carry reaches 3/5 |
| 3 | Walk to the **crafting bench** | **not** to the fire |

**He crafted before he fed.** On a fresh run with a dying fire, a veteran's priority is tooling up,
not survival. Worth asking him why directly. If the answer is "the fire is fine on day 1", that is
the night-1 mercy paying off in a way I could not have inferred from any screenshot.

Bench is a large flat table with a saw on it. Prompt is object-anchored: **"Craft Item"**.

## t10 — first feed, and the sack empties in one action

At the fire. **"level 1 progress: 69/100"** with a green bar, visible because he is standing close.
Carry goes **3/5 to 0/5** in a single interaction. Flame is now tall and bright.

**Feeding dumps the entire sack at once.** Not one item per press. Walk up, one action, everything
you are carrying goes in. That is what makes the round trip feel like a delivery rather than a chore.

### The first minute, complete
| # | Action | Approx. time from spawn |
|---|---|---|
| 1 | Select axe, chop nearest tree | 10-15 s |
| 2 | Haul the logs it dropped, 3/5 | 25-30 s |
| 3 | Crafting bench, "Craft Item" | 35-40 s |
| 4 | **Feed the fire, 3/5 to 0/5** | **40-50 s** |

Time to first reward lands inside the 20-40 second band the public sources claim, allowing for my
sampling gaps. The loop is established in under a minute with **nothing explaining any of it**.

### What Hell Week does differently at every one of these four steps
| Their step | Ours |
|---|---|
| Fell a tree, it drops logs on the ground | Node yields straight into the sack, no haul |
| Craft at a bench near spawn | Craft by offering at the obelisk, which is also the fire |
| Feed dumps the whole sack in one action | Feed is per-item |
| Fuel readout appears on approach | Fuel is permanently in the HUD |

## t11 — the fire wears a waypoint icon

Moved off from the fire, carry already back to 3/5. From this distance the campfire has a **yellow
flame icon in a rounded square floating above it**, a world-space marker sitting well above the prop
itself.

So the fire is findable three ways, at three ranges:

| Range | Cue |
|---|---|
| Far | The floating flame **icon**, readable over terrain |
| Middle | The **glow**, the only warm light at night |
| Close | The **dotted ring** and the proximity fuel readout |

**Three redundant layers for the single most important location in the game.** Hell Week's obelisk
has exactly one of these, the glow, and the desert is four times the area those lighting numbers were
set for. A floating icon above the obelisk is trivial and it means nobody is ever lost.

## t12 — the reward cadence, measured

**"FIRE REACHED 100%. The Map has grown bigger"** again, carry 0/5. That is the second feed
completing level 1.

### The flow, with clock
| Time from spawn | Beat |
|---|---|
| ~10 s | First swing of the axe |
| ~30 s | Sack at 3/5, hauling |
| ~40 s | Crafting bench |
| ~50 s | **First feed.** Fire lit, level 1 at 69/100 |
| ~75 s | Out again, sack refilling |
| **~100 s** | **Level 1 complete. The map grows.** |

**Under two minutes from cold spawn to the world visibly getting bigger.** Two round trips. That is
the hook, and it is the number Hell Week should be judged against.

### Where Hell Week stands against that clock
Our first beacon level needs feeding on a 100-second day with resources spread across a desert four
times the size of this forest pocket. A stranger's first visible world change is a long way past two
minutes, and the opening act spends time before that without stating a goal.

**The single most valuable tuning change available: make Hell Week's first beacon level reachable in
two round trips, and make completing it change the world visibly.** Everything else on both lists is
secondary to that number.

## t13-t15 — the steady-state rhythm

Out past the old fog line: rocks, a pumpkin, a distant shack, then back to chopping. A **small green
bar appears bottom-left while swinging**, almost certainly chop progress or stamina.

The rhythm, once established, is a three-beat cycle with no menus in it at all:

1. **Walk out** toward whatever the last peel revealed
2. **Chop or loot** until the sack caps
3. **Walk back** to the icon, dump everything in one action

Every peel he immediately spends walking further out. The reward is never banked, it is always
converted into the next trip. That is the whole game, and a stranger learns it without being told.

## t16 — animals, and the axe is the weapon

Standing beside a **white rabbit** with the axe out, a carrot on the ground nearby, a shack in the
fog behind.

**There is no separate weapon slot.** The axe chops trees and it is also what you swing at animals.
The same verb, the same tool, the same button. Combat is not a system, it is the harvest verb
pointed at something that moves.

### The bearing on Hell Week's open question
When asked about weapons and defending yourself, the answer built into Hell Week was **wards, not
kills**, on the reasoning that a survive-the-night threat which can be killed stops being a threat.
Watching this does not overturn that, and it sharpens it:

- 99 Nights lets you kill **animals**, which are resources, with the **harvesting tool**
- The actual night threat is a different thing entirely and is not handled this way

So the distinction to hold is **prey versus threat**. Prey can be harvested with the tool you already
have. The threat cannot be fought at all. Hell Week currently has no prey, which is why "weapons"
felt like a gap. The gap is not weapons. **It is that our desert has nothing alive in it.**

## t17 — the danger line is a recurring drumbeat, not a rare alarm

**"the campfire is almost out"** in red again, still Day 1, after two feeds that took it to 100%.

So the fire drains fast enough that the warning fires repeatedly inside a single day. It is not an
emergency message. **It is the metronome.** Every time it appears, it points you back at the fire and
restarts the three-beat cycle.

That reframes the earlier toast finding. The red line is not "you are about to lose". It is the game
saying *go again*, in the friendliest possible lowercase. The pressure is constant and gentle rather
than occasional and severe.

Hell Week's beacon warning fires near failure. Theirs fires constantly, and that is why the loop
never goes slack.

## t18 — landmark inventory, and a hunger warning zone

Out again at 0/5. Two more landmark types in the fog: a **stone well with a wooden roof**, and a
patch of **green crops** growing in the ground.

Running list of distinct landmarks seen across both sessions: crashed aeroplane, shack with a door,
wooden hut, stone well, crop patch, storage containers, crafting bench, signboards.

**That is eight kinds of thing to walk toward**, in a forest, before counting trees and rocks. Hell
Week's desert currently has rocks, trees, cactus and teepees. Four, and one of them is the only
structure.

The hunger bar has gained a **red segment at its right end**, presumably the danger zone marker, so
even the bar tells you where bad starts before you get there.

## t19 — DRAG is a second hauling system, parallel to the sack

Sack at **5/5 in red**, and at the same time he is **dragging a large object** across the ground with
**"Undrag"** showing bottom-right. Walking back toward the fire icon with both.

**There are two ways to move things, and they do not share a budget:**

| System | For | Limit |
|---|---|---|
| The sack | Small items, logs, loot | Hard cap, 5 at the start |
| **Drag** | Objects too big for a sack | One at a time, and it slows you |

This is the mechanic that makes base-building work. Furniture, planks and big props never compete
with your wood for sack space, so building never feels like it costs you survival progress. It is
also why he could build on Day 1 without falling behind on the fire.

**Hell Week has one hauling system.** Everything competes for the same five slots, which means any
building or decorating we ever add will directly tax survival. Adding drag is not decoration, it is
the thing that makes a second activity possible at all.

## t20 — refinement: the same resource comes in two sizes

The dragged object is a **large log**. So wood itself exists in both forms:

- **Small logs** go in the sack, five at a time
- **Large logs** are **dragged**, one at a time, slowly

That is better than I described a moment ago. It is not "sack for resources, drag for furniture". It
is the **same resource split across two hauling verbs by size**, which means every trip home is a
judgement: five small ones, or one big one dragged slowly, or both at once as he is doing now.

A five-year-old understands it because it is how real logs work. Nobody needs a tutorial for "that
one is too big to carry".

**For Hell Week:** our desert already has a size story sitting unused. A stone chip you pocket and a
boulder you drag. A cactus arm you carry and a whole cactus you drag. It costs one new verb and it
turns a flat carry cap into a decision on every trip.

A signboard stands near the fire with text on it, not yet readable from this angle. Worth catching.

## t21 — level 2 at 85/100, still Day 1

Dumped the whole haul. Readout reads **"2 progress: 85/100"**, rendered very large across the screen
because he is standing right at the fire.

So inside a single Day 1 he has gone: fire lit, level 1 complete with a map peel, and level 2 almost
complete. **Three visible progress events before the first night.**

### The onboarding shape, complete
| Device | Effect |
|---|---|
| Day 1 is several times longer than later days | No time pressure while learning |
| Threat does not attack on night 1 | No death while learning |
| Fire ladder's first rungs are cheap | Three rewards before anything is at stake |
| Goal stated twice before spawn | You know what the number means |

**Four separate mercies stacked on top of each other**, and none of them is a tutorial. Hell Week has
exactly one of the four, the day-1 `watch` mode on the stalker.

That is the real answer to "does 99 Nights have loops we are missing". The loops are mostly there.
**What is missing is the first five minutes being this forgiving.**

## t22-t23 — coal is dragged, and the flame is the level gauge

- Dragging a **black coal chunk**, outlined in white while dragged. Coal is the long-burn fuel, and
  it is a **drag-class** resource, so the good fuel costs you a slow walk. The better the fuel, the
  more awkward it is to move. That is an elegant, invisible balance lever we do not have.
- At the fire the flame is now **large and bright yellow**, plainly bigger than the level 1 flicker.
  Confirmed across both sessions: **the flame is the level gauge you read at range.**

Dragged objects get a **white outline** while held, so you always know what you have hold of.

## t24 — the complete toast taxonomy, and night is telegraphed

Two messages on screen at once:

> *night is approaching* — **purple** handwritten italic
>
> **FIRE REACHED 100%. The Map has grown bigger** — parchment plaque

So it is **three** styles, not two, and the third is the one that matters most:

| Style | Meaning | Example |
|---|---|---|
| Red handwritten italic | **Danger** | *the campfire is almost out* |
| **Purple handwritten italic** | **Time and phase** | *night is approaching* |
| Parchment plaque, serif | **Progress and reward** | *FIRE REACHED 100%...* |

### Night is announced before it falls
Same principle as the raid warning at Day 5. **Nothing bad in this game arrives unannounced.** You
are told night is coming, you are told a mysterious group is coming, and you are told the fire is
getting low. Every one of them gives you time to decide what to do.

**Hell Week's night simply falls**, and our stalker simply appears. We have been manufacturing
surprise where the genre leader manufactures *dread*, which is a different and better feeling,
and the entire difference is one line of purple text a few seconds early.

Also: level 2 complete, second map peel of the run, still Day 1.

## t25 — tents come in CLUSTERS, not singles

A camp of **three tents**, green, tan and blue, pitched together with loot visible inside, sitting in
the fog line. Not one tent. Three, arranged as a site.

This is the closest thing in 99 Nights to Hell Week's teepees, and the difference is arrangement:

- **Theirs is a scene.** Three tents together read as "people camped here", which raises a question
  and pulls you in. The colours differentiate them so you can tell which you have already searched.
- **Ours are scattered singles.** A lone teepee reads as terrain decoration, so there is nothing to
  wonder about and no reason to cross ground to reach it.

Same asset budget, completely different pull. **Cluster the teepees into camps of three and vary
their colour.** That is a generator parameter change, not new art.

## t26 — painted ground again, and the coin counter is RUN earnings

Two details at the tent camp.

### They paint the ground constantly
The camp sits on a **brown dirt decal** that marks the site out from the grass. Same technique as the
safe ring and the matchmaking pads. **Painted ground is this game's primary way of saying "something
is here"**, used for safety, for menus and for points of interest alike. It costs nothing, it works
at any camera angle, it works at night, and it needs no words.

Hell Week paints exactly one thing, the pentagram, and it is decoration rather than information.

### The in-run coin counter is what you earned THIS RUN
Bottom-left reads **5**. In the lobby, before the run, it read **40**. So the number on screen during
a run is **this run's earnings**, not your balance.

That is a live, ticking reason to stay out one more trip, and it turns every chest into a visible
deposit. A balance would be inert. **Run earnings are a scoreboard.**

Hell Week shows no currency at all in-run, because we have no currency. When we add one, show the
run's take, not the bank.

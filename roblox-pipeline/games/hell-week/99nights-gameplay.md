# How 99 Nights actually plays, and what Hell Week should change

> From a watched session on 2026-09-12 that followed the player's **actions** rather than the
> interface. Frame log: `research/patterns/watch/99nights-actions.md`. The earlier interface audit is
> in `99nights-watch-findings.md`. Timings, shapes and reactions only. No assets.

## The answer to the original question

You asked whether 99 Nights has loops Hell Week is missing. Having now watched it played from the
lobby through a full first day and into night:

**The loops are mostly there in Hell Week. What is missing is that the first five minutes are
forgiving, legible, and constantly rewarding.**

99 Nights stacks **four separate mercies** on a new player, none of which is a tutorial:

| Mercy | What it does |
|---|---|
| **Day 1 is several times longer than any later day** | You can be bad at it with no clock pressure |
| **The threat does not attack on night 1** | You cannot die while learning |
| **The first rungs of the fire ladder are cheap** | Three visible rewards before anything is at stake |
| **The goal is stated in plain words twice before you move** | You know what the number on screen means |

Hell Week has **one** of the four. Our stalker watches instead of hunting on day 1. Everything else
about our opening is as hard as day seven.

## The first minute, timed from spawn

| Time | Beat |
|---|---|
| ~10 s | Axe selected, chopping the nearest tree. No hesitation, nothing read |
| ~30 s | Sack at 3 of 5, hauling logs the tree dropped |
| ~40 s | Crafting bench |
| ~50 s | **First feed.** Fire lit |
| **~100 s** | **Level complete. The map visibly grows** |

Two round trips from cold spawn to the world getting bigger. **That is the number to build against.**

## The cycle, once it starts

Three beats, no menus anywhere in it:

1. Walk out toward whatever the last map peel revealed
2. Chop or loot until the sack caps
3. Walk back to the fire and dump everything in **one action**

He never banks a reward. Every peel is immediately spent walking further out. And the red line
*the campfire is almost out* recurs constantly, so the cycle never goes slack. **That line is not an
emergency. It is the metronome.**

## The five mechanics we do not have

### 1. Felling and hauling are separate jobs
A chopped tree drops three or four physical logs on the ground where it fell. You then have to carry
them. **Our nodes yield straight into the sack**, so there is no haul, which is most of the reason a
carry cap is interesting rather than annoying.

### 2. Two hauling systems that do not share a budget
The sack holds five small things. **Drag** moves one big thing at a time, slowly, with a white
outline while held. Large logs, coal and furniture are all drag-class.

This is what lets him build a base on day 1 without falling behind on the fire, because building
never competes with survival for sack space. **Hell Week has one hauling system**, so any building
we ever add taxes survival directly.

### 3. The same resource exists in two sizes
Small logs go in the sack. Large logs get dragged. Coal, the long-burn fuel, is drag-class, so the
best fuel costs you a slow walk. That is an invisible balance lever and it needs no explaining,
because everyone already knows some logs are too big to carry.

Our desert has this sitting unused. A stone chip you pocket and a boulder you drag. A cactus arm you
carry and a whole cactus you drag.

### 4. Feeding empties the whole sack in one action
Not one item per press. Walk up, one action, everything goes in. It makes the trip feel like a
delivery. **Ours is per item.**

### 5. Prey and threat are different things
There is **no weapon slot**. The axe chops trees and is also what you swing at rabbits. Animals are
resources harvested with the tool you already hold. The actual night threat is never fought at all.

So the ward-not-kill decision we made for Hell Week stands, and it sharpens: the gap was never
weapons. **It is that our desert has nothing alive in it.**

## Nothing bad ever arrives unannounced

Three message styles, split by meaning, and the third is the important one:

| Style | Meaning | Example |
|---|---|---|
| Red handwritten italic | Danger | *the campfire is almost out* |
| **Purple handwritten italic** | **Time and phase** | *night is approaching* |
| Parchment plaque, serif | Progress | *FIRE REACHED 100%. The Map has grown bigger* |

Night is announced before it falls. The Day 5 raid was announced before it arrived, by name, as
*"A mysterious group makes its way towards your Campfire"*, with a SKIP button for veterans.

**Hell Week's night simply falls and our stalker simply appears.** We manufacture surprise where they
manufacture dread. The difference is one line of purple text a few seconds early.

## The door, which I had never seen

### The goal is stated twice before you move
A four-panel comic ends with *"You have 99 NIGHTS to unravel the mysteries of the forest and figure
out what is going on"*. Then the loading screen says *"Survive 99 Nights"*.

Hell Week's opening act is atmosphere. A voice, blood-red English, transliteration beneath. It is
good, and **it never says what to do**. Gate A's first pass condition is that testers describe the
goal in their own words. As built, we never tell them. One line in the same type fixes it.

### The team-size picker is a place, not a menu
Glowing squares on the ground reading **1/5**, **1/2**, **0/20**, with arrows painted on the walls
pointing at them and an **exit** button to step off. The number is both the capacity and the live
count. A child who cannot read understands it, because it is just standing somewhere.

We already build zone discs for the beacon and the offering. Same primitive.

### Progression is worn on your body
Every player in the lobby has a **calendar glyph with their day record** and their **class emblem**
floating above their head. 196, 222, 445, 1015.

A 445 walking past a 42 is the entire retention pitch, delivered with no words. **We persist a best
day and show it to nobody**, which reframes the lobby gap: the reason to build one is not
matchmaking, it is somewhere to be seen.

## Two techniques worth stealing wholesale

### Painted ground is how they say "something is here"
The safe radius is a dotted ring on the grass. The matchmaking options are squares on the floor. The
tent camp sits on a dirt decal. Safety, menus and points of interest all use the same device. It
costs nothing, works at any camera angle, works at night, and needs no words.

**Hell Week paints exactly one thing, the pentagram, and it is decoration rather than information.**

### Places are scenes, not props
Three tents in different colours pitched together read as "people camped here". A crashed plane with
a fuel canister at its base explains itself. Eight distinct kinds of landmark seen across the
sessions, against our four.

**Our teepees are scattered singles**, which read as terrain. Clustering them in threes with varied
colour is a generator parameter, not new art.

## What I would change first

1. **Make Day 1 long.** One number, and it is the biggest onboarding win available.
2. **Say the goal in words** at the end of the opening act.
3. **Draw the safe ring** on the ground.
4. **Telegraph night and the stalker** a few seconds early, in their own message colour.
5. **Get the first beacon level to two round trips**, and make finishing it change the world visibly.
6. **Add drag**, and give the desert a big and small version of each resource.

The first four are hours. They are also the four that decide whether Gate A passes.

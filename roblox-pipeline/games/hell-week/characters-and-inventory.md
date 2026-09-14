# Characters, menace, and the bag — how each is actually built

> Answering four questions: why our enemies feel like stick figures, how Roblox games really make
> characters, how you show a player what they picked up, and how a chest becomes a choice.

---

# Part 1 — "Robotic stick figures" is two problems, and only one is art

This matters before spending a day on models, because the cheaper half is probably the bigger half.

## Problem A: nothing animates. This is the stick-figure feeling.

Our creatures are a rigid assembly of parts that **slides** across the ground. No legs move. No body
leans. Nothing anticipates a strike. A beautifully modelled monster that slides will still read as a
prop; a crude one that *walks* reads as alive.

Animation needs a **rig**: parts joined by `Motor6D` so they can rotate relative to each other. Ours
are welded solid, which is exactly why nothing can move.

## Problem B: the pursuit is a straight line at a constant speed

Our chase logic is, honestly, one line: point at the player, move at N studs per second, forever.
That is the definition of robotic and it has nothing to do with graphics.

Real menace is **variation**. Things that are frightening in games do this:

| Behaviour | Why it scares |
|---|---|
| **Pause and look** before committing | You get a beat to realise it has seen you |
| **Burst, then rest** | You almost escape, and then you do not |
| **Circle rather than charge** | It cuts you off instead of following |
| **Slow and inevitable** | It never hurries because it does not need to |
| **Stop at the light line and wait** | It is patient, which is worse than fast |

Each creature should get **its own grammar**. The scorpion skitters and freezes. The golem never
changes pace and never stops. Something later flanks and never takes the direct line.

None of that needs a single new model.

**Recommendation: fix B first.** It is a day of code, it works on the shapes we already have, and it
will tell you how much of the problem was ever art.

---

# Part 2 — How Roblox games actually make characters

Four routes, cheapest first. All four are real and available.

## Route 1 — Creator Store
`search_asset` then `insert_asset`, from inside Studio. Thousands of free rigged creatures, many with
animations already attached.

- **Cost:** free, minutes
- **Good for:** proving whether animation fixes the feel before investing in anything
- **Bad for:** it is not yours, and anyone can recognise it

## Route 2 — `generate_mesh` + `segment_mesh`, both inside Studio
This is the route most people do not know exists, and it is the one to try first for original work.

1. `generate_mesh` makes a **textured mesh from a text prompt**, up to 20,000 triangles, and it will
   split into **up to 8 named parts** if you ask ("head, torso, left arm, right arm, tail")
2. `segment_mesh` will cut an existing mesh into **up to 5 named sub-parts**
3. Those parts are separate MeshParts, so you join them with **Motor6D** and you have a rig
4. Studio's built-in **Animation Editor** animates that rig on a timeline
5. `generate_texture` re-skins any of it from a prompt

- **Cost:** free, no Blender, does upload an asset so it persists
- **Good for:** original creatures at our fidelity, fast
- **Bad for:** you do not get fine control over topology, and AI meshes can be lumpy

**This is my recommendation for the bosses.** Generate segmented, rig the segments, animate.

## Route 3 — Blender, then Studio's 3D Importer
What 99 Nights and Blox Fruits actually do, with artists.

1. Model in **Blender** (free)
2. Add an **armature** (bones) and skin the mesh to it
3. Export **FBX**
4. Studio, **3D Importer**, which brings it in as a rigged, skinned MeshPart
5. Animate in Studio's Animation Editor, or import animations from Blender or Mixamo

- **Cost:** free software, real learning time
- **Good for:** total control, the only route to a genuinely distinctive character
- **Bad for:** it is a craft, not an afternoon

## Route 4 — External AI 3D, then Route 3's import step
Meshy, Tripo, Hunyuan3D. Generate, download GLB or FBX, import through the 3D Importer.

- Middle ground: better meshes than in-Studio generation, still no modelling skill needed
- Still needs rigging before it can animate

## The gate that applies to all of them
Anything that must **survive a save** needs a real uploaded asset id. Generating a preview at runtime
renders fine and vanishes on reopen. Upload is a click a human makes in Studio. That is already
written down and it is why the magma golem needs your import click.

---

# Part 3 — How you show a player what they picked up

The question was "what is the engine for that". Here is the honest answer, and the good news is it
costs no art at all.

## The trick: `ViewportFrame`
A `ViewportFrame` is a UI element that **renders actual 3D parts inside a flat panel**. So the icon
for Ashwood is the literal Ashwood part, spinning slowly, at icon size.

- **No image uploads. No drawn icons. Ever.**
- The icon is always correct, because it *is* the item
- A new item invents its own icon the moment it exists
- Add a new resource next month and its icon appears for free

That is the whole inventory-art problem solved in one instance type, and it is why this should be
built before anyone draws anything.

## What a collection moment should do
Four beats, in this order:

1. **The item flies to the bag.** A tween from the world position to the bag icon
2. **The slot fills** with the ViewportFrame of that item
3. **The count ticks** with a small bump
4. **The name appears briefly** under the slot, which is how the player learns the vocabulary

We currently do roughly a quarter of this: the count changes.

## The bag itself
- Slots drawn as a **row of boxes**, filled and empty both visible, so the cap is a picture and not a
  number. Six boxes with two full says "four left" without arithmetic
- **The row gets longer** when you find a bigger bag. The HUD is the progress bar, which is exactly
  what the leader does: their carry went from 5 to 15 inside one run
- **Red when full**, which they also do, so the same element says both *how much* and *go home now*

---

# Part 4 — The chest as a choice, not a vacuum

This is the strongest idea in what was asked for, and it is right.

Right now a chest empties into your bag. That is a vending machine. Instead:

1. Open it. A panel shows **what is inside, as ViewportFrame icons with names**
2. Your bag is shown underneath, with its **empty slots visible**
3. **Take what you want. Leave the rest.** What you leave stays in the chest
4. You can come back for it, or a teammate can have it

Why it matters, and it is not decoration:

- **It is a decision**, and decisions are what people remember. A vacuum is not a decision
- **It makes the carry cap into a design feature** rather than an irritation. A cap only matters if
  you are choosing what to fill it with
- **It teaches the item names** at the exact moment the player cares
- **It creates co-op**, because leaving the water for whoever needs it is a social act
- **It creates a reason to return**, so a looted chest is not a dead landmark

---

# Part 5 — The danger curve. Our creatures are too easy, and that is my error.

The correction is right and it is important. A scorpion that dies to three bare-handed swings teaches
a player that nothing here is dangerous, which kills suspense in the first five minutes.

It should be the opposite shape:

| With | Against a scorpion | Against a golem |
|---|---|---|
| **Bare hands** | Barely scratches it. You should run | Hopeless |
| **A stick** | A long, risky fight | Still hopeless |
| **Bone knife** | Winnable | Dangerous |
| **A real weapon, made by offering** | Straightforward | Winnable |

**The point is that you are afraid of it until you have built the thing that answers it.** That fear
is the reason the obelisk matters, and it is the reason a stick is exciting.

Which means the weapon ladder comes through the obelisk, as offerings, exactly as described:

```
stick  ->  club  ->  wooden sword  ->  something with iron in it
```

And each rung should be **visibly different in the hand**, because the player needs to see that they
have got stronger.

It also means materials have to be tiered by distance first, which is the gap already written up. A
sword made of nothing is a skin. A sword made of iron you had to go and get is a story.

---

# The order I would build these

1. **Movement grammar.** Pure code, works on current shapes, tells you how much was ever art
2. **Danger curve.** Numbers only. Makes the world frightening today
3. **ViewportFrame bag with slots.** No art, unlocks every later item
4. **Chest as a choice.** Depends on 3
5. **Weapon ladder through the obelisk.** Depends on tiered materials
6. **Rig and animate one creature** via `generate_mesh` segmented, as a test of Route 2
7. **Then the bosses**, once Route 2 is proven on something small

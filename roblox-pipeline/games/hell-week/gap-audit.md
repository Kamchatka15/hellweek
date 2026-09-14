# Honest audit — what the watch taught, what got applied, what did not

> Asked directly: did watching produce a better game loop, and are the pieces there.
> This is the straight answer, checked against the code on 2026-09-14, not from memory.

## First: what I did NOT see

Worth saying before anything else, because two of the mechanics being asked about are two I
never actually observed.

| Mechanic | Did I see it? |
|---|---|
| Hooded raiders arriving at night | **No.** I saw the *announcement* on Day 5, a scroll reading "A mysterious group makes its way towards your Campfire", with lights approaching in the dark. I never saw them arrive or what they did |
| Flashlight making the deer back off | **No.** It is in the public teardown from written sources. I did not watch it happen |
| A death, the death screen, the return | **No.** He never died in either session |

He played well, stayed near the fire, and never got into trouble. That is exactly the run where
you learn the economy and learn nothing about the threat. **The threat half of that game is still
unobserved**, and it is the half being asked about.

## Why those two mechanics matter more than they look

### The flashlight is not a counter, it is a moment
Holding something that makes the threat back off converts it from *a thing you must avoid* into
*a resource you spend*. Three consequences, and all three are the game:

1. **Supplies start to matter.** You need the light and you need whatever keeps it lit
2. **Night stops being dead time.** You can choose to go out, which is a decision rather than a wait
3. **Teamwork gets a shape.** One player carries the light, the others carry everything else

Hell Week has a version of this already: the Brand is "light you can carry" and the Sigil is a wider
ward. **But ours is a passive aura and theirs is an act.** You do not point ours at anything. There
is no turn-and-face beat, so there is no moment, and no moment means no clip.

### A raid is a different animal from a stalker
Our stalker is a pane of glass. It keeps you *in*. It never comes for the thing you built.

A raid comes **to the fire**. It attacks what you made. That is what makes a camp worth building,
what makes players cluster together instead of scattering, and what turns night from "hide" into
"defend".

**I built the camp last session and nothing in the game ever attacks it.** A camp nothing lays siege
to is a storage locker. That is the single biggest hole in the design right now, and it is a hole I
made by adding the camp without adding the reason for it.

## What IS built, verified in the code today

| Thing | State |
|---|---|
| **Chests** | **Yes.** 9 in the desert, placed at teepee camps, weighted loot: ashwood 100%, cactus 80%, stone 70%, water 35%, emberwood 18%, heartwood 5% |
| **Safe zone you can see** | **Yes.** The beacon radius is now a dashed ring painted on the ground, redrawn as it grows. Braziers are second islands. Ward stakes hold a radius |
| **Items** | 9: ashwood, cactus, stone, water, emberwood, heartwood, wardstone, chitin, venom |
| **Tools** | 3: Knife (harvest), Brand (ward 9 + light), Sigil (ward 19) |
| **Feeding empties the sack in one action** | **Yes**, same as theirs |
| **Toasts split by meaning** | **Yes**, three tones rendered differently, and night is telegraphed 12s early |
| **Long tutorial day 1** | **Yes**, 300s against 100s for later days |
| **Prey with teeth** | **Yes.** Scorpion and magma golem, killable, glowing eyes, red after dark |
| **Camp that extends range** | **Yes.** Cache, brazier, ward stake, drying rack, salt line |
| **Resource rings gated by beacon level** | **Yes.** Each resource spawns in 3-4 rings, outer ones locked until the fire levels |

## What is NOT built, including everything named

### Named directly, and missing
| Missing | Note |
|---|---|
| **Hooded night raiders** | Nothing attacks the camp. The biggest hole |
| **Point-a-light-and-it-backs-off** | Only passive ward auras exist |
| **Gems, iron, ore** | No tiered or deep-only materials at all |
| **Slingshot, sword, stick** | No weapon class exists |
| **Strength / power / defence numbers** | Tools carry an *effect*, never a stat. No armour, no damage values |
| **Nights 4 through 7** | Explicitly **PARKED placeholder numbers** in the config. The back half of the week has a shape and not a tuning |

### Learned from watching, not yet applied
| Missing | Why it mattered there |
|---|---|
| Prompts anchored on the object | "Open Chest" floats on the chest. Ours are all corner buttons |
| Loot named where it lies | "Old Radio" on the ground teaches the whole item vocabulary |
| Carry counter big, on the avatar, red at cap | Ours is a quiet corner readout at one colour |
| Drag as a second hauling system | So building never competes with survival for sack slots |
| Same resource in two sizes | Small carried, large dragged. A decision every trip |
| Sprint | We have none, in a desert four times the size the movement was tuned for |
| Fuel readout only near the fire | Ours is permanently in the HUD, the one option they rejected |
| Carry cap growing during a run | Theirs went 5 to 15. The HUD itself is the progress bar |
| One large landmark per biome | A crashed plane you walk toward. Ours has teepees and nothing else |

## So: is the five-night collection loop good yet?

**No, and the reason is specific.** Days 1 to 3 are tuned and days 4 to 7 are placeholders. More
importantly there is **no reason to go deeper**. Every resource ring holds the same nine items; the
outer rings are just further away. Nothing is *better* out there, only more distant.

That is what gems and iron are for, and why they are worth adding: they give distance a payoff, they
give chests a reason to hold something you cannot dig up nearby, and they give tools something to be
made of. Right now the map is wide and flat in value.

## What I would do, in order

1. **Something attacks the camp at night.** Nights 3 onward. It is the reason the camp exists and I
   built the camp without it
2. **Make the light an act, not an aura.** Hold it up, the thing backs off, it costs you something
3. **Tier the materials.** Common near, iron mid, gems far and guarded. Distance has to pay
4. **Then tools with numbers.** Once materials are tiered, a sword made of iron means something. A
   sword made of nothing is a skin
5. **Then tune nights 4 to 7** against all of the above, because tuning them now would be tuning a
   loop that is about to change

## What I got wrong

Asked to watch and learn, I came back with a strong read on **legibility and economy** and a blank
on **threat**. The reason is that the run I watched never got dangerous, and I did not say at the
time that this made the sample one-sided. I should have said so then and asked for a run that ends
badly, which is still the one thing that would settle the rest.

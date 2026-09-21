# SPACEHEX — the warehouse catalogue

> Source of truth is `games/spacehex/server/parts.luau`. This file is the readable version.
> Every number below is read by `flight.luau`. There are no decorative stats in this game.

## The five metrics that decide everything

| Metric | What it is | Why the player cares |
|---|---|---|
| **Thrust (N)** | how hard the engine pushes | thrust ÷ weight is whether it leaves the pad at all |
| **Isp (s)** | specific impulse — engine efficiency | `Δv = Isp × 9.81 × ln(wet ÷ dry)`. The single biggest lever on how far you get |
| **Dry mass (kg)** | what the part weighs empty | every kilogram of structure is a kilogram you accelerate all the way up |
| **Propellant (kg)** | fuel in the tank | more Δv **and** more mass. This trade is the whole game |
| **Cd** | drag coefficient the nose imposes | a blunt cap costs you roughly 400 m/s against an ogive |

Two derived numbers appear on the pad card before every launch:

- **TWR** — thrust ÷ weight at ignition. **Under 1.00 it does not move.** Under 1.2 it flies but bleeds speed to gravity. Over ~3.2 it is burning fuel fighting the air. **1.4 : 1 is the sweet spot**, and that is the real answer too.
- **Δv** — how much velocity the whole stack can produce. **7,700 m/s after losses and you are in orbit.** Anything less and you come back down, however high you got.

## Engines

| Part | Thrust | Isp | Mass | Cost | Notes |
|---|---:|---:|---:|---:|---|
| RM-1 Hopper | 9 kN | 178 s | 110 kg | $696k | Welded garage motor. Gets you off the ground and not much else |
| RM-2 Pioneer | 31 kN | 238 s | 185 kg | $1.70M | The first engine that is actually efficient. Most first rockets fly on this |
| V-1 Vulcan | 78 kN | 268 s | 430 kg | $3.96M | Heavy lifter. Needs a big tank under it or it drinks the stage dry |
| **K-5 Kestrel [VAC]** | 36 kN | 322 s | 270 kg | $4.98M | Vacuum bell. **Poor at sea level.** Upper stages only |
| T-9 Titan | 205 kN | 288 s | 1,010 kg | $9.36M | The workhorse. Clusters well. This is the Kármán-line engine |
| RX-4 Raptor | 450 kN | 302 s | 1,650 kg | $18.6M | Full-flow staged combustion. The only way to orbit anything heavy |
| **N-V Nova [VAC]** | 118 kN | 348 s | 640 kg | $23.4M | Best Isp in the warehouse. Put it on the stage that does the insertion |

Engines can be **clustered** — up to four per stage. Four Raptors is 1.8 MN and a pad you do not own yet.

## Tanks

| Part | Propellant | Dry | Dry fraction | Cost |
|---|---:|---:|---:|---:|
| Micro Tank | 105 kg | 14 kg | 11.8% | $216k |
| Small Tank | 300 kg | 26 kg | 8.0% | $492k |
| Medium Tank | 1,250 kg | 82 kg | 6.2% | $1.18M |
| Large Tank | 3,500 kg | 205 kg | 5.5% | $2.94M |
| Heavy Tank | 9,200 kg | 505 kg | 5.2% | $7.56M |
| Core Tank | 23,000 kg | 1,210 kg | 5.0% | $17.2M |

Bigger tanks are **better than they look**: the dry fraction falls as they scale, which is why a real rocket is one enormous tank rather than ten small ones.

## Aerodynamics

| Part | Effect | Mass | Cost |
|---|---|---:|---:|
| Blunt Cap | Cd 0.42 — what you can afford on launch one | 18 kg | $48k |
| Cone | Cd 0.31 | 32 kg | $156k |
| Ogive Nose | Cd 0.22 | 48 kg | $552k |
| **Payload Fairing** | Cd 0.19, and **required** to carry a satellite through the atmosphere | 125 kg | $1.62M |
| Tail Fins | control 1.0 — without fins stage 1 tumbles | 26 kg | $108k |
| Grid Fins | control 2.2, and **reusable** — required by Landing Legs | 72 kg | $1.01M |

## Guidance — the cheapest Δv in the game

| Part | Turn efficiency | Mass | Cost |
|---|---:|---:|---:|
| Open Loop | 0.70 | 0 | $0 |
| Basic Guidance | 0.81 | 42 kg | $672k |
| Inertial Unit | 0.89 | 68 kg | $2.22M |
| **Full GNC** | 0.95 | 96 kg | $5.16M |

Turn efficiency multiplies your **entire** Δv. Going from Open Loop to Full GNC on a 10,000 m/s stack is worth **2,500 m/s** — more than most engine upgrades, for less money. This is the trap the game wants a player to fall into and then discover.

## Structure, recovery, mission

| Part | Effect | Mass | Cost |
|---|---|---:|---:|
| Light Decoupler | lets two stages separate | 16 kg | $96k |
| Heavy Decoupler | for stacks over ~20 t | 62 kg | $324k |
| Recovery Chutes | refunds 35% of the stage's refurbish | 92 kg | $864k |
| Landing Legs | refunds 65% — **needs Grid Fins** on the same stage | 310 kg | $4.20M |
| Ballast Mass | dead weight that proves you can lift something | 120 kg | $72k |
| Smallsat | pays a bonus — **needs a Fairing** | 340 kg | $2.28M |
| **RCS Pack** | translation thrusters. Without these you cannot line up on a port | 64 kg | $1.86M |
| **Docking Port** | the station goal. **Needs RCS** | 145 kg | $3.24M |

## The pad is an upgrade too

| Pad | Mass limit | Cost |
|---|---:|---:|
| Concrete Apron | 8 t | — |
| Reinforced Pad | 28 t | $2.88M |
| Flame Trench | 95 t | $13.2M |
| Heavy Complex | 320 t | $55.2M |

You cannot roll out a rocket heavier than the pad allows. This is the gate that stops a player skipping five tiers with one enormous stack.

## Assembly rules — "built properly" means these

`assembly.luau` refuses a rollout and **names the part that is wrong**, before launch, on the pad card:

1. Every stage needs an engine and a tank.
2. Every pair of stages needs a decoupler between them.
3. A vacuum engine on stage 1 is rejected — it is weak at sea level.
4. Stage 1 needs fins or it tumbles.
5. A nose cone or you are flying an open pipe.
6. A satellite needs a fairing.
7. A docking port needs RCS.
8. Landing legs need grid fins on the same stage.
9. Total mass ≤ the pad's limit.
10. TWR ≤ 1.00 is shown as **"IT WILL NOT LIFT"** before you spend the launch.

Rule 10 is the important one: the game tells you it will fail *first*. A player who launches anyway learns something; a player who is surprised by it learns nothing.

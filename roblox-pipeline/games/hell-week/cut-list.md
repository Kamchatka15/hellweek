# Hell Week — cut list (Wave 2, line adopted from the packet)

> Justin, 2026-09-12 in chat: **"Keep the line. Build Pass 1. Quiet Shore 350×350."** The line below is his; nothing was re-derived. Budget check: core verb 1/1 · return hook 1/1 · clip hook 1/1 (the Gift) · player-facing systems 4/4 (Wick+fuel, clock, Tempter, Sack) · on-screen numbers 3/3 (Day, Wick, Sack) · onboarding artifact: the Wick itself + one world prompt. **Inside budget as drawn.**


**Line: Pass 1 = Quiet Shore + Wick + Ashwood + Tempter + Gift. Everything else parked.**

## IN (Pass 1)

- Title: Hell Week
- Zone 1 only: The Quiet Shore (**350×350 starting disk**, 175 stud Day-1 fog wall; Ring A 0–50 is the one-minute teach; Wick peels Ring C/D)
- Core verb: pick Ashwood → carry (cap 3) → feed Wick
- Wick: fuel, warm radius, fog peel, PointLight
- Clock: Day 1–3 playable; 4–7 clock can exist but tuning parked
- Tempter: silhouette, Night 1 watch, Night 2+ chase outside light, touch = wake at Wick
- Gift: Day 3, wrong bloom, Weight raises next burn
- HUD: Day, Wick, Carry
- Onboarding: two one-line toasts max
- Shop stubs: Oil, Deep Pockets, Second Wind (optional, after Day 2)
- Look: 99 Nights bar, grey/gold, lighting rig
- Landmark prop: **HW-001 Obelisk** (black stone, gold glyphs, one skull per face, fire cap). Place in Ring B, visible from the Wick, not blocking Ring A teach. Ref: `GrokBDownloads/HW-001_Obelisk_01/2d/HW-001-obelisk-v3-oneskull-34.jpg`
- Fire jet on the cap from `2d/HW-002-fire-v1.jpg` (particle + short light)
- Persist: bestDay + tutorialComplete
- Instrumentation: day reached, death reason, gifts taken, fuel in/out

## IN, added by Justin after the line was drawn (2026-09-12)

- **Four worlds on four pentagram points** (`server/biomes.luau`): The Ashen Waste · The Still Wood · The Drowned Quarter · The Kiln. Each point's triangle is dark (locked), red (open), green (mastered). **The fifth point is the offering table.**
- **Seven trials per world**, listed in a pull-down at the upper right, completed ones struck through. The Quiet Shore's seven are wired to real signals; the other four worlds are data only.
- **The offering.** The fifth pentagram point: a waist-high stone table on four legs with a gold lip and a hollow sunk into it.
- **Teepees with chests**, 6–9 per world. A chest gives several things at once and is the only place crafted tiers appear unmade.
- **Held things:** Bone Knife (harvest), Brand (carried light + 9-stud ward), **Sigil** (the artifact of faith, 19-stud ward). Crafted at the obelisk. **None of them kill** — see below.
- **The 360° world swap.** Mastering a world rebuilds the ground and scenery around the player. All four worlds generated. Walk into it with a sack and the obelisk takes it; at dawn it lays out more than it took, one tier up (Ashwood → Emberwood → Heartwood). Burn it tonight or grow it for tomorrow — the same verb, and the decision is *where you stop walking*.

**Budget: this puts the slice over, and the caps are how Gate A is read, so it is written down rather than absorbed.**

| Slot | Cap | Now |
|---|---|---|
| Core verb | 1 | 1 |
| Return hook | 1 | 1 |
| Clip hook | ≤1 | 1 (the Gift) |
| Player-facing systems | ≤4 | **5** — beacon+fuel, clock, Tempter, Sack, **Trials** |
| On-screen numbers | ≤3 | **4** — Day, Obelisk, Sack, **Trials n/7** |
| Onboarding artifact | 1 | 1 (the obelisk + two toasts) |

The trials menu is collapsed by default, so what a new player actually sees is one extra button, not a fourth meter. That is an argument, not evidence. **Gate A answers it:** if a tester never opens the menu, or opens it and stops playing, the cap was right and the menu moves to a between-runs screen. `docs/BUDGET.md` says a cap moved by evidence is the system working.

## PARKED

- **Craft bench** — CUT 2026-09-12 (Justin: "so i dont need a workbench"). The obelisk absorbed it: offerings go in the bowl and come back worked, so a second crafting object would be a second answer to the same question. The art and its generator stay on disk (`server/bench.luau`, `tools/bench_from_blender.py`); cut is not deleted, and a later world may want a bench that is not this one.

- Zones named Gehenna, Tartarus, Abyss, Lake of Fire, Outer Darkness, Hades
- Scripture, sermons, salvation products, Satan by name
- Classes / diamond lobby shop
- Rescue sleepers, beds, day multiplier
- Weapons that KILL the Tempter, and combat. Reopened by Justin 2026-09-12 ("weapons and tools to defend himself") and answered with **wards, not kills**: in this genre the threat being unkillable is the game, and a weapon that ends it ends the loop with it. A real kill mechanic is a different night and wants rebuilding, not bolting on — say the word.
- Flashlight (the Brand replaced it)
- Extra bosses / biomes
- Weekly leaderboard UI (compute score only)
- Squad oil, collections
- 99 Nights assets, deer, kids, audio, UI

## Pass 2 (after Gate A)

- Days 4–7 burn curve
- Score board weekly
- Cosmetics
- One more trial type
- Second zone only if D1 lives

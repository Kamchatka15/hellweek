# Hell Week — economy — world 1, The Ashen Waste

> The currency is **fuel**, and from the desert on it is not the only resource. Ashwood burns; cactus and stone do not, and the obelisk is the only thing that turns them into something that does. `tools/survive_sim.py` models the fuel budget; it does **not** yet model recipes, which is named as a gap rather than papered over.

## Resources

| Item | Source | Fuel | What it is for |
|---|---|---|---|
| Ashwood | deadfall on the sand | 1 | the floor of the economy; burns as found |
| Cactus | cactus, 39 across the waste | 0 | the only source of **water** |
| Stone | boulders | 0 | Wardstones |
| Water | 2 Cactus, at the obelisk | 0 | the ingredient every good recipe needs |
| Emberwood | 1 Water + 2 Ashwood | 3 | three times the burn for two wood and a walk |
| Heartwood | 1 Water + 1 Emberwood | 8 | the deep tier; a night in one item |
| Wardstone | 1 Water + 2 Stone | 0 | fed to the fire, it lifts one **Weight** |

## Why water is not a thirst meter

A desert wants one, and the brief parked "hunger meter as a fourth HUD number" for the right reason: it is a number that punishes you for existing and teaches nothing. Water as the **ingredient** does the opposite — it makes the second and third resources matter, it gives the obelisk a reason to be a workbench, and it costs no HUD at all.

**Wardstone is the piece worth watching at Gate A.** Taking the Gift adds Weight and Weight raises tomorrow's burn; a Wardstone takes one back off. So the Gift is now a three-way choice — leave it, take it and eat the cost, or take it and spend a day's cactus undoing it. If testers never make a Wardstone, the recipe is too deep and the cost should drop to one stone.

## The clock

| Day | Day | Night | Burn | Tempter |
|---|---|---|---|---|
| 1 | 100 s | 45 s | 3 | watch only |
| 2 | 100 s | 50 s | 4 | hunts outside the light |
| 3 | 95 s | 55 s | 6 | hunts + the Gift appears |
| 4–7 | 90→75 s | 60→75 s | 8→14 | **PARKED tuning** |

Sack 6 · obelisk holds 15 · radius 25 + 8×fuel, cap 90 · Ring C opens at 8 fed, Ring D at 20 · Gift +5 now, Weight +1, next burn ×1.25 per Weight.

## The gap, named

`survive_sim.py` still walks a one-resource world: it counts trips for fuel and knows nothing about cactus, water or recipes. Its last honest reading (one resource, feed-edge trips) was that Days 1–3 are safe for everyone and the Gift is the only thing that kills. **The desert almost certainly makes that easier still**, because Emberwood and Heartwood multiply what a trip is worth. Extending the sim to model recipes is the first queue item, and no number here should be frozen until it has.

## Shop stubs (drafted, unwired — `server/sku.luau`)

Wick Oil 49 R$ (+4 fuel, this run) · Deep Pockets 99 R$ pass (sack 5, persists) · Second Wind 79 R$ (one wake with no fuel penalty). Offered only after a Day-2 survive. None locks a day. Nothing random. **G5 is Justin's click; no MarketplaceService call exists in the repo.**

## Assumptions not in config

Walk 16 studs/s, 0.4 s per pickup, 6 s of looking per trip, sack always filled to cap, inner rings first, ±15% effort noise, one player. Co-op makes it easier (four sacks, one wick); the Tempter's fuel penalty makes it harder. Neither is modelled yet.

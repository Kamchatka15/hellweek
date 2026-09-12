# Hell Week — Creator Store shelf (Wave 1)

> Found 2026-09-12 via Studio MCP `search_asset`, Creator Store, free only. Insert by ID in Wave 4, then **recolor every insert** to the two-colour spec (`theme.md`: grey sand / black water + wick gold). Nothing here ships as-is. Skipped on purpose: any asset whose tags name another game (one dead-tree listing spammed "Survive 99 Nights In The Forest" — not used).

## Models (12+)

| Silhouette | Asset ID | Name (creator) | Use | Recolor to |
|---|---|---|---|---|
| Driftwood / log | `5221228744` | Log (IndeedBunny) | Ashwood hero stand-in, driftwood piles | `colors.fuel` pale ash / `colors.driftwood` |
| Driftwood / log | `5260752083` | Modified Log (IndeedBunny) | second driftwood shape | `colors.driftwood` |
| Driftwood / log | `5221537867` | Log (IndeedBunny) | third variant so piles don't repeat | `colors.driftwood` |
| Dead tree | `5575673162` | Low Poly Dead Tree (Abby4leafclover) | pale tree clusters, Ring B/C | `colors.tree` |
| Dead tree | `126472679423331` | Low Poly Dead Tree Stump Branch (Arrow464Miner8760) | stumps near the boat | `colors.tree` |
| Dead tree | `137758346954846` | [2026] Low Poly Dead Tree (lightsoulbridge) | tall variant for Ring D edge | `colors.tree` |
| Dead tree | `105834484106013` | Low Poly Dead Tree Stump Branch Desert Prop (CharlesFrost39) | filler | `colors.tree` |
| Lantern post | `73537715428128` | Low Poly Street Lantern Lamp Post (FlashEcho2339) | Wick post silhouette candidate (strip the city head, keep the post + cage) | `colors.post` + `colors.flame` |
| Lantern post | `109295812621197` | Low Poly Street Lantern Lamp Post RP (PandaSkyWraith2016) | alternate | same |
| Rowboat | `2993679087` | Row Boat (With Paddles!) (Superkid3) | the ruined rowboat in Ring B | `colors.driftwood`, remove paddles |
| Rowboat | `5655285721` | Canoe (Mar1a_Legal) | alternate hull | `colors.driftwood` |
| Rock pack | `2128776869` | Low Poly Rock Pack [FREE] (FracturedSkies — asks for credit) | grey rocks, all rings | `colors.rock` |
| Rock pack | `138203649668150` | Low Poly Rock Pack (Vikinzito) | second pack so shapes vary | `colors.rock` |
| Candle | `7441002639` | Low Poly Candle Pack (ItsPlasmaRBLX) | Wick candle head | `colors.candle` + `colors.flame` |
| Candle | `94595240415263` | Low Poly Candle Set Flame Glow (WonRender) | alternate | same |

## Audio (4+, all free, Roblox-licensed where "Pro Sound Effects" is the creator)

| Moment | Asset ID | Name (creator) | Note |
|---|---|---|---|
| Hush bed (loop) | `93035214379043` | wind_loop (tientregua096) | audition; fall back to next row |
| Hush bed (loop, alt) | `112777481845857` | Winter Storm Ambience (iloveblake2345) | too heavy? then keep wind_loop |
| Wick feed flare | `9114446852` | Fire Whoosh 15 (Pro Sound Effects) | 0.9 s, one burst |
| Wick idle crackle (loop) | `9112780561` | Fire Whoosh 1 (Pro Sound Effects) | 49 s loop, low volume at the post |
| Night creak (distant) | `9126263691` | Wood Groan Creak Opening Wood Chest (Pro Sound Effects) | play at random on the fog line at night |
| Night creak (alt) | `118045282328349` | wood creak (Jansku020202) | |
| Pickup | `9117660383` | Plywood Cutout 2 (Pro Sound Effects) | the "pick up and stand upright" handle beat; trim to the first 0.6 s or find a softer one in Wave 4 |
| Night-drop sting | — | **not found this pass** | search "low drone hit" / "dark sting" in Wave 4 |

## Hero and Tempter (generated, not inserted)

- **Wick** (hero): Cube 3D short prompt from the brief — `low poly tall candle lantern on driftwood post, single colour, no text` — triangle cap, then paint the flame `colors.flame`. Third regenerate = the primitive post + candle + Neon ball already in `SurviveLoop.buildBeacon`.
- **Tempter**: stays primitive on purpose (tall block + ball, `colors.stalker`, no light, wrong proportions). No demon face, no horns.
- **Gift**: a cluster of three `5221228744` logs, Neon, `colors.lure`, with the pink PointLight from `config.lure`.

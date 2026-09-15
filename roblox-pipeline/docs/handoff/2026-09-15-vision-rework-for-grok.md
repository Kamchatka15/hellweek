# Hell Week — what Claude changed tonight (handoff for Grok)

Written 2026-09-15, 01:10. Audience: another AI reviewing the work, and Hunter.
Repo: `~/Desktop/Roblox Business/roblox-pipeline`, branch `vision-rework`. No remote exists yet, so nothing is on GitHub.

## The one-paragraph version

Between 19:09 and 00:12 Claude made eight commits. Three are gameplay (hotbar, pickaxe + dagger start, survivable night one — done before the VisionRework brief). Five are the **VisionRework**: a graphics-only pass under a brief whose hard rules were *no gameplay rewrites, no Toolbox models, no new UI, six colours only, everything undoable*. So the changes are deliberately not "giant": every loop (Feed, Pick Up, Sack, Trials, day counter) is the same loop it was at 7pm. What changed is what the same loop *looks like*, and it is gated behind one switch, `games/hell-week/server/vision.luau` → `return { on = true }`. Flip that to `false` and the old camp, palette and needle come back exactly.

## Why it can look like nothing changed

1. **Studio is running an 8-second day.** The Studio copy of `config.luau` has a test clock (`day = 8, night = 400`) so Claude could test night without waiting. That means ~95% of any Play session is night, the night rig is very dark by design (Brightness 0.12, Ambient 18,16,26), and the whole camp reads as a small fire on a black field. The real clock on disk is 180 s day / 40 s night. The day camp — the stone disc, gold eye inlay, six-terrace ziggurat, dead trees, distant pyramid — is only visible in the first 8 seconds after pressing Play.
2. **The Jackal is black-on-black.** Brief said charcoal 28,26,24 body, night void 18,16,26 sky, standing outside the firelight. That is a silhouette with no backlight: only its two amber eyes show. Hunter reported "can(t) see the jackal"; the fix Claude proposed is lifting the night ambient a touch (moonlight), which is a Phase 2 number change that needs Hunter's yes.
3. **The Studio place is not saved and was never synced.** This Studio instance is sandboxed (no HTTP, so Claude's normal Rojo/`studio_sync` push is blocked). Claude delivered every change by splicing `.Source` on existing scripts inside Studio and verified each splice hit exactly once. Those splices live only in the open session until Hunter presses Save. Disk (git) is the truth; Studio is a copy of it.
4. **The brief forbade the things that would read as "giant".** No new models, no new UI, no new mechanics, no music. The rework is palette, geometry built from plain Parts, lighting numbers, and one silhouette.

## Commit by commit

| Time | Commit | What |
|---|---|---|
| 19:09 | `8a7a674` | `docs/COLLABORATION.md` — how Justin collaborates through Studio (Team Create + git roles) without overwriting work. |
| 20:13 | `86c8ec6` | **Hotbar** (`src/client/Hotbar.luau`, 404 lines): slots 1/2 + SACK along the bottom like 99 Nights, ViewportFrame icons (the item is its own icon). `ToolService` became composable: `power` → strike, `kind`/`bonus` → harvest, `effect` → ward/light, `spot` → SpotLight. Tools: Dagger (power 2, harvests cactus), Pickaxe (stone), Club 3, Spear 5, Knife (any), Brand (spot light). |
| 20:19 | `bd21738` | **Start kit + survivable night one**: `startingTools = { "Pickaxe", "Dagger" }`, night one has `mercy = true` (an empty beacon on night one no longer ends the run), `nightWarning = 12` s telegraph, siege starts night 3 not night 1, `startingFuel = 2`. Ten-minute session for a ten-year-old. |
| 23:37 | `6a76aae` | **VisionRework Phase 1, day camp.** New `vision.luau` (the switch) and `ziggurat.luau` (187 lines): 48-stud stone disc with 40 slabs, a gold almond-eye inlay (32 arcs + 20-piece iris), six stepped terraces 22 studs tall with gold bands on tiers 2 and 4, a small orange cap fire with one shadow-casting light. Replaces the old neon needle when `vision.on`. `world.luau`: the whole ashen-waste scenery is remapped through `onPalette()` to the six colours (Mound/Wash → Ash, Mesa/Rubble/Tree → Charcoal, Bone → Bone); pentagram, star glow, obelisk glow, biome/offering markers are hidden (transparency 1, lights off, moved to `VisionRework_Hidden`); 12 dead trees, a pyramid on the horizon at bearing 250, four dressing props. Day lighting rig = the brief's numbers. `theme.luau` colours → the six-colour palette. |
| 23:40 | `e8365ac` | Phase 1 fixes from the camera check: `onPalette` was walking the wrapper not `.scenery` (green scrub in frame); pyramid was behind the camera (bearing 118 → 250); the resource *nodes* had their own colour literals separate from items (10 remapped). |
| 23:50 | `bd135e9` | **Phase 2, night.** Night rig (ClockTime 0.4, Brightness 0.12, Ambient 18,16,26, haze 3.8, bloom 0.8). Cap light day 18/1.1 → night 42/2.8 with a 0.3 s flicker loop. Gold safe ring goes Metal by day, Neon 0.35 by night. Old fog ring hidden when `vision.on`. Brand tool carries a SpotLight (lantern). Hooked on the existing `onPhase` → `setMood()` signal; the day timer was not rewritten. |
| 00:05 | `6d0d4ad` | **Phases 3, 4, 5.** *3:* `config.stalker.silhouette` — a 14-part Jackal (11.2 studs, 1.87× player) built by a new branch in `SurviveLoop.buildStalker()`, charcoal body, two Neon amber eyes with tiny lights, CanQuery/CanTouch off, `standOff = 22` so it stands past the safe ring in the trees, facing camp. Uses the existing StalkerService "watch" mode; no combat, no health, no rig copied. *4:* every Feed pulses the cap light +6 range for 1 s then keeps +2 (cap +24, range max 72) and cuts Atmosphere haze 0.15 (floor 1.2). HUD chrome charcoal 30,28,28, bars gold 212,168,62. No music. *5:* 17 `Bedroom_*` parts (desk, book, backpack, window) at 640,400,640 — built but **not wired**, because the current first-join sting is a full-screen black `OpeningAct` overlay and sequencing room → text → camp is a design call. |
| 00:12 | `c95ca4a` | Last off-palette HUD literals: bar track → night void, text → bone, muted → ash, good → gold, low-fuel warn → fire. |

Diffstat for the evening: 14 files, +3141 / −1625 (1,600 of the removed lines are the scenery chunks being regenerated in the new palette by `tools/gen_biome.py`).

## Engine files touched (shared by every game in the pipeline)

- `src/core/ContentLoader.luau` — `fire()` honours `shadows`; new `groundRing()`; props may name a `group` subfolder.
- `src/core/SurviveLoop.luau` — safe ring drawing, silhouette stalker branch, cap-light mood + flicker + feed pulse, mercy night, siege start night, kit on spawn.
- `src/core/ToolService.luau` — composable tool defs, SpotLight from `spot`.
- `src/client/Hotbar.luau` (new), `src/client/SurviveHud.luau` — hotbar mount, inspect panel, sack panel removed.

None of these name Hell Week (engine rule R7); the game-specific numbers all live in `games/hell-week/`.

## How to actually see it (60 seconds)

1. In Studio, **Stop**, then **Play**. Watch the first 8 seconds: that is the day camp (frame 1 of the vision). Screenshot from behind the player.
2. Night lands at second 8. Walk to the disc edge; the gold ring is now Neon. Look out past it: two amber dots at head height ≈ the Jackal.
3. Pick up any fuel item, press **FEED**, watch the cap fire flare and settle brighter.
4. To get a walkable day back: ask Claude to restore the real clock (one line in the Studio `config`), or open `games/hell-week/server/config.luau` on disk — it already has 180/40.

## Open decisions (Hunter's, not Claude's)

- Lift the night ambient slightly so the Jackal's body reads as a shape, or keep pure eyes-in-the-dark.
- Wire the bedroom sting (room first, then text, then camp — or text over the room).
- Restore the real day/night clock in Studio.
- `Lighting.Technology = Future` and **Allow HTTP Requests** in Game Settings are still unset; both are Hunter's clicks. HTTP is what would let Claude push from disk again instead of splicing.
- Save the place. Create a private GitHub remote so the branch can be pushed.

## What was NOT done, on purpose

- No gameplay loop rewritten. No script deleted. No Toolbox/marketplace model imported. No new UI system. No music. No 99 Nights assets. No publish. No paid product.

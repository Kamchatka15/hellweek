# Graphics — what is wrong, and the order to fix it

> From a read of the generators and pack data against what watching 99 Nights showed.
> Numbers here are measured from the emitted files, not estimated.

## The one-sentence diagnosis

**Nothing casts a shadow, and the landmark is shorter than the scenery.**

Everything else on this page is a refinement of those two.

## Tier 1 — free, and they change everything

### 1. Turn shadows on for the beacon light
Every `PointLight` in the game sets `Shadows = false`. All of them. In a game whose entire premise is
the edge of the light, the light produces **no cast shadows at all**.

Long shadows radiating outward from the obelisk, swinging as you walk, are the single highest-value
image the product can produce and they are currently switched off. This is one boolean.

Caveat: `PointLight` shadows need `Lighting.Technology` set beyond Voxel, which is the plugin-only
click already on Justin's list. **That click is now worth more than anything else on his list.**

### 2. Turn `castShadow` back on for the dunes
**572 of the desert's 1462 parts have `castShadow = false`**, including **all 96 mounds**, all scrub,
all wash slabs and all teepee hide panels. The mounds are the dominant large form in the biome.
With a low sun at `ClockTime 7.1` they should be throwing long shapes across the sand. Instead they
sit on a flat plane as unshaded balls with no contact shadow.

This is the primary reason the desert reads flat. It is one flag in the generator.

### 3. The obelisk loses the silhouette contest it exists to win

| Thing | Height |
|---|---|
| Mesa | up to **35** |
| Tree | up to **26** |
| Teepee | up to 18 |
| **The obelisk** | **19.4** |

The single landmark the whole loop orbits is shorter than the scenery around it.

**Do not fix this by raising the obelisk.** It was deliberately shortened so the flame reads and the
perspective works, and that call was right. Fix it by **lowering everything else**: cap mesas near
22 and trees near 19, and clear a wider radius around the obelisk so nothing tall stands near it.
The landmark wins by being alone and by being framed, not by being tall.

## Tier 2 — the desert is nine colours and three shapes

Measured from the generated data:

| | Count |
|---|---|
| Distinct base colours in the entire world | **9** |
| Distinct shapes | **3** (Block, Ball, Cylinder) |
| Materials | 6, and **each prop type is locked to exactly one** |

Every rock in the world is Slate. Every tree is Wood. Every scrub is a Grass ball. Within a type the
only variation is scale, Y-rotation and a ±4% colour jitter, which is not variation, it is noise.

**Fixes, in order of value per hour:**

1. **Two-tone every prop.** A mesa with a paler cap band. A tree with a darker base. One extra part
   per object doubles the apparent material budget.
2. **Give each prop type two or three material variants**, not one. Sandstone and Slate and
   Limestone are the same generator line.
3. **Widen the palette past nine.** Nine hues in a ±4% band is why it reads as one colour.
4. **Use the Wedge shape.** `Part.Shape` accepts it, no generator does. The biome point triangles are
   currently **14 stair-stepped boxes** each, visibly serrated up close, and a wedge fixes them today.

## Tier 3 — there is nowhere to walk toward

**544 objects scattered area-uniformly over a 350-stud disc.** No clustering, no clearings, no density
gradient. Every 26 by 26 patch of the waste looks exactly like every other one. The only navigational
features in 378,000 square studs are **nine teepees**.

Watching 99 Nights, I counted **eight distinct landmark types** in a comparable space: crashed plane,
shack, hut, well, crop patch, storage containers, crafting bench, signboards. Plus tents pitched in
**threes**, in different colours, so a camp reads as a place someone was.

| Theirs | Ours |
|---|---|
| 8 landmark types | 4 prop types, 1 of which is a structure |
| Tents clustered in threes, varied colour | Teepees scattered as singles, one colour |
| A crashed plane you can see from anywhere | Nothing taller than the scenery |

**Cluster the teepees into camps of three and vary the hide colour.** That is a generator parameter,
not new art, and it is the cheapest change on this page that makes the map navigable.

Then add **one large strange object per biome** whose loot explains it.

## Tier 4 — things that are quietly broken

### `FogEnd` is dead
Every lighting rig sets `FogEnd`, in nine places. Every rig also installs an `Atmosphere`, which
**overrides the legacy fog properties entirely**. All nine values are no-ops. Day and night falloff
has been tuned against a knob that is not connected to anything. Distance falloff is
`Atmosphere.Density` and `Haze` only.

### Two-thirds of the art is behind the wall
Fog level 0 sits at radius 200 against a 350-stud scenery radius, so **32.6% of the disc is visible**
until the player has fed the obelisk eight times. The generator spends its budget uniformly across
350 studs; the player spends most of the run seeing 200 of them.

Either spend the art budget where the player actually is, or open the rings sooner.

### The fog is forty opaque slabs
Not fog. A 40-sided ring of flat panels, 60 studs tall, with a hard top edge and a visible vertical
seam every nine degrees. At night `FogEnd` is 700, well past the wall, so the panels are fully
visible as panels.

### The floor is one flat 700-stud disc
Perfectly planar everywhere. Mounds are half-buried balls intersecting that plane with a hard,
unblended seam.

### The fire has two states and no life
Feeding changes light range, brightness and flame size. There is **no flicker**, no rate modulation,
no colour shift as it dies. A fire that does not move is a lamp.

## What the engine cannot do at all today

`ContentLoader.block()` reads eleven keys. There is no path for any of this:

- **Decals and textures.** `spec.face` makes a SurfaceGui with a text label. No image, no `Texture`,
  no tiling ground grime, no cracked mud, no bark
- **Meshes.** Deliberate, and it caps the whole game at three primitives
- **Beams.** No `Beam`, no `Attachment` anywhere. Rules out light shafts, ward tethers, a soft fog
  edge, lines between the pentagram points
- **Trails.** Rules out embers drifting, a wake behind the stalker
- **Generic particles.** `fire()` is the only emitter and it hardcodes two textures. The Still Wood's
  own design note asks for "ash falling like snow" and there is no way to emit it
- **Per-biome floor geometry.** `setFloor` changes colour and material of one part. The Drowned
  Quarter's black water cannot be water
- **Terrain.** Never referenced

**Cheapest engine additions, in order:** shadows on the beacon light, then `spec.decal`, then
`spec.beam` with attachments, then a generic `spec.particles`, then a floor that can change shape.

## Performance note

No `StreamingEnabled`. About **2,530 parts** replicate to every client at join, and a biome swap
rebuilds between 1,000 and 2,200 of them in one synchronous loop. That will be felt on a phone, and
the audience is on phones.

## Order of work

1. Shadows on, both kinds. One boolean and one flag
2. Lower the mesas and trees so the obelisk wins its own scene
3. Cluster the teepees, vary their colour
4. Two-tone the props, widen the palette
5. Wedge shape for the point triangles
6. Fix or delete the dead `FogEnd` values
7. `spec.decal` and `spec.beam` in the engine
8. `StreamingEnabled` before Gate A

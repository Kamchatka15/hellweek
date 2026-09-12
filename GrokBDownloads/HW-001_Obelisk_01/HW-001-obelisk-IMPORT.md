# HW-001 Obelisk — DRAFT mesh

Source 2D: `2d/HW-001-obelisk-v3-oneskull-34.jpg` (approved-2d)
Tool: Blender 4.5.8 primitives (no paid Meshy credits)
Status: `meshing` — not final Studio-ready

## Files
- HW-001-obelisk-DRAFT.blend
- HW-001-obelisk-DRAFT.glb
- HW-001-obelisk-DRAFT.fbx
- HW-001-obelisk-DRAFT.png

## Size
Built in Blender units ≈ studs. Shaft + base + flame ≈ **10.5 studs tall** as authored.
Scale in Studio to **24–32 studs** tall for a Ring B landmark.

## Import
1. Studio → Import 3D → `HW-001-obelisk-DRAFT.glb` (or FBX)
2. Facing: skulls sit on +X/-X/+Y/-Y. Rotate so one skull faces the Wick.
3. Collision: Hull or Box. Do not use Precise unless needed.
4. Delete or hide the Ground plane after import.
5. Recolor stone to charcoal, glyph planes to neon gold or SurfaceAppearance emission.
6. Replace the cone “fire” with a ParticleEmitter + PointLight using HW-002 as the look. The cone is a placeholder.

## Known defects
- Glyphs are gold slabs, not carved symbols.
- Skulls are blockout faces, not the 2D sculpt.
- Shaft is stacked boxes, not a single tapered mesh.
- Workbench render has no PBR.
- Triangle count is low (draft). Fine for a landmark.

Placement is Placement Advisor’s job. Suggested only: Ring B, 90–120 studs from Wick.

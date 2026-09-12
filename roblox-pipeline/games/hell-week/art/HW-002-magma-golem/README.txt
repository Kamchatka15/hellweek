Magma Stone Golem — DRAFT for in-game look test
================================================
9,000 triangles. About 6.1 x 9.8 x 4.5 studs. Y-up. +Z is the glowing face / belly.

This is NOT the painted concept. It is a playable blockout so you can judge
size, silhouette, and glow in Studio.

IMPORT (easiest)
1. Roblox Studio → File → Import 3D
2. Pick magma_golem.glb
3. Leave scale at 1. It should stand about 10 studs tall.
4. If it lies on its back: rotate the Model -90 on X.
5. CollisionFidelity = Hull (not Precise)
6. Anchor it. Move it onto your floor.

If the GLB comes in grey
1. Upload magma_golem_albedo.png as a Decal
2. Select the MeshPart → TextureID → paste that decal
3. Optional: add a small Neon part (color 255, 90, 20) in the mouth
   and another behind the belly if you want more glow than the texture.

Files
- magma_golem.glb                 textured, try this first
- magma_golem.obj + .mtl + pngs   fallback
- magma_golem_vertexcolor.glb     same mesh, colors in vertices
- magma_golem_albedo.png
- magma_golem_emissive.png

Keep the pngs next to the obj if you import the obj.

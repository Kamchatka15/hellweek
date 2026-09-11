# FBX/GLB drop → Layer Mine

Verified end-to-end on `LM_Station_SurfaceKiosk_01` (11 Sep 2026).

## The five steps

| # | Step | Who | Automated? |
|---|------|-----|------------|
| 1 | Art lands in `GrokBDownloads/<LM_id>/` (fbx + glb + preview) | LM Art bot | yes |
| 2 | Inspect + rebuild in Studio, eyeball it | Claude | **yes** |
| 3 | Upload mesh → Roblox asset id | *gated* | **no — see below** |
| 4 | Reference asset id from Rojo source | Claude | yes |
| 5 | Playtest, screenshot, PR | Claude | yes |

Step 3 is the only gate. Everything either side of it runs unattended.

## Step 2 — preview (no upload, no Roblox account touched)

```
python3 glb2rbx.py            # glb -> deduped, quantised json
python3 -m http.server 8731 --bind 127.0.0.1 --directory serve
```

Then run `build_in_studio.luau` through the Studio MCP in **Edit** mode.

It parses the glTF on disk, dedupes identical geometry, quantises positions to
int16, and rebuilds each unique shape in Studio with `AssetService:CreateEditableMesh()`
→ `AssetService:CreateMeshPartAsync()`. glTF materials map onto Roblox ones by
their PBR factors: `alpha < 0.95` → Glass, emissive → Neon, `metallic >= 0.6` →
Metal, rough → Slate/Wood, else SmoothPlastic.

Scale is fixed at **1 metre = 3.5714 studs** (Roblox's 0.28 m stud). glTF and
Roblox are both Y-up right-handed, so no axis flip is needed.

The script flips `HttpService.HttpEnabled` on to read localhost and always puts
it back — it is wrapped around a `pcall` so a failed fetch still restores it.
**Do not run the localhost fetch against a published place** without deciding
that deliberately; use a scratch place for previews.

### What this does NOT do

`CreateMeshPartAsync` geometry is **runtime only**. The MeshParts it returns have
`MeshId = ""` and `MeshContent` `SourceType=None`. They render, they collide,
they screenshot — and they vanish on save/reopen. This is an approval preview,
never a placement.

## Step 3 — the gate

To persist, the mesh has to become a real Roblox asset. Two doors:

**Door A — Studio 3D Importer (human, ~30 s).** `Avatar` tab → `3D Importer` →
pick the `.fbx` → Import. Studio uploads the mesh and hands back MeshParts with
real asset ids. Needs a human because Roblox has no scriptable hook into it.

**Door B — Open Cloud Assets API (unattended).** Needs an API key with
`asset:write` on the owning account/group. `PIPELINE.md` line 251 still lists
this key as an unchecked setup item, so Door B is not available yet. Key goes in
a password manager / env var — never in chat, never in the repo.

Either door produces the durable artifact: an **asset id**. Once it exists,
placement is source code and the rest of the pipeline is unattended.

## Step 4 — placement

With an asset id, the kiosk belongs in the Rojo source, not hand-placed in the
DataModel. `src/` is the source of truth for Layer Mine.

## Reference numbers for this drop

- 75 nodes → 53 unique geometries → 3,648 triangles (2,760 unique)
- 14 materials, 0 textures
- **6.78 × 7.93 × 3.66 studs** (player ≈ 6 studs, mine blocks are 8)

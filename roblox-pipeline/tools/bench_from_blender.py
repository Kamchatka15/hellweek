#!/usr/bin/env python3
"""
bench_from_blender.py — translate the crafting-bench Blender script into pack data.

The art bot delivered the Quiet Shore crafting bench as a Blender script that places
primitives (cubes, spheres, cylinders, cones) in units that are already studs. That is
a better source than the GLB: every part becomes a plain Roblox Part in the content
pack — permanent, diffable, no mesh upload, no Studio gate. This mirrors the script's
calls and writes games/hell-week/server/bench.luau.

Blender is Z-up, Roblox is Y-up: (x, y, z) -> (x, z, -y). Blender cylinders/cones point
along local Z; Roblox cylinders along local X, so cylinders get a local quarter-turn.
Cones do not exist in Roblox: flames become Neon balls, spikes thin cylinders.

  python3 tools/bench_from_blender.py
"""
import math, os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "games", "hell-week", "server", "bench.luau")

# --- tiny matrix helpers --------------------------------------------------------
def rot_x(a): c, s = math.cos(a), math.sin(a); return [[1,0,0],[0,c,-s],[0,s,c]]
def rot_y(a): c, s = math.cos(a), math.sin(a); return [[c,0,s],[0,1,0],[-s,0,c]]
def rot_z(a): c, s = math.cos(a), math.sin(a); return [[c,-s,0],[s,c,0],[0,0,1]]
def mul(a, b): return [[sum(a[i][k]*b[k][j] for k in range(3)) for j in range(3)] for i in range(3)]
def tr(a): return [[a[j][i] for j in range(3)] for i in range(3)]
M = [[1,0,0],[0,0,1],[0,-1,0]]          # Blender -> Roblox basis change
SWAP = [[0,-1,0],[1,0,0],[0,0,1]]       # Roblox local X <- Blender local Z (after M, that is local Y)

def blender_rot(rx, ry, rz):            # Blender XYZ Euler: R = Rz * Ry * Rx
    return mul(rot_z(rz), mul(rot_y(ry), rot_x(rx)))

def to_roblox(R):                        # R_r = M R M^T
    return mul(M, mul(R, tr(M)))

def cframe(loc, R):
    x, y, z = loc
    px, py, pz = x, z, -y
    r = R
    return "CFrame.new(%.3f, %.3f, %.3f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f)" % (
        px, py, pz, r[0][0], r[0][1], r[0][2], r[1][0], r[1][1], r[1][2], r[2][0], r[2][1], r[2][2])

# --- materials (Blender linear floats -> RGB) ------------------------------------
def rgb(c): return "Color3.fromRGB(%d, %d, %d)" % tuple(int(round(min(1, v ** (1/2.2)) * 255)) for v in c)
MATS = {
    "wood":       (rgb((0.14, 0.07, 0.04)), "Wood"),
    "wood_dark":  (rgb((0.07, 0.04, 0.02)), "Wood"),
    "stain":      (rgb((0.08, 0.02, 0.02)), "SmoothPlastic"),
    "rust":       (rgb((0.35, 0.12, 0.04)), "CorrodedMetal"),
    "bone":       (rgb((0.78, 0.72, 0.58)), "SmoothPlastic"),
    "bone_dark":  (rgb((0.12, 0.10, 0.09)), "SmoothPlastic"),
    "plate_brown":(rgb((0.38, 0.24, 0.14)), "Wood"),
    "plate_char": (rgb((0.07, 0.06, 0.06)), "SmoothPlastic"),
    "flame":      (rgb((1.0, 0.38, 0.05)), "Neon"),
    "iron":       (rgb((0.18, 0.18, 0.20)), "Metal"),
    "saw_orange": (rgb((0.85, 0.32, 0.08)), "SmoothPlastic"),
    "saw_grey":   (rgb((0.22, 0.23, 0.24)), "Metal"),
    "rope":       (rgb((0.45, 0.35, 0.22)), "Fabric"),
    "ember":      (rgb((1.0, 0.22, 0.04)), "Neon"),
    "white":      (rgb((0.95, 0.95, 0.92)), "SmoothPlastic"),
}

parts = []
def emit(name, shape, size, loc, R, mat, extra=""):
    color, material = MATS[mat]
    parts.append("\t{ name = %r, shape = Enum.PartType.%s, size = Vector3.new(%.3f, %.3f, %.3f), cframe = %s, color = %s, material = Enum.Material.%s%s }"
                 % (name, shape, size[0], size[1], size[2], cframe(loc, R), color, material, extra))

def cube(name, size, loc, rot=(0,0,0), mat="wood", extra=""):
    sx, sy, sz = size
    emit(name, "Block", (sx, sz, sy), loc, to_roblox(blender_rot(*rot)), mat, extra)

def sphere(name, r, loc, mat="bone", scale=(1,1,1)):
    d = 2 * r * max(scale)
    emit(name, "Ball", (d, d, d), loc, [[1,0,0],[0,1,0],[0,0,1]], mat)

def cylinder(name, r, depth, loc, rot=(0,0,0), mat="iron"):
    R = mul(to_roblox(blender_rot(*rot)), SWAP)
    emit(name, "Cylinder", (depth, 2*r, 2*r), loc, R, mat)

def cone(name, r, depth, loc, rot=(0,0,0), mat="flame"):
    if mat == "flame":                       # flames read as glowing blobs
        emit(name, "Ball", (r*1.7, r*1.7, r*1.7), loc, [[1,0,0],[0,1,0],[0,0,1]], mat)
    else:                                    # spikes: thin rods
        cylinder(name, r*0.55, depth, loc, rot, mat)

# --- the bench, mirroring blender_craft_bench.py (Ground/camera/lights/text omitted) ---
cube("Tabletop", (8.0, 3.2, 0.4), (0, 0, 3.0), mat="wood")
for i, (x, y) in enumerate(((-3.5, -1.25), (3.5, -1.25), (-3.5, 1.25), (3.5, 1.25))):
    cube(f"Leg_{i}", (0.45, 0.45, 2.6), (x, y, 1.3), mat="wood_dark")
cube("Shelf", (7.4, 2.6, 0.2), (0, 0, 1.15), mat="wood")
# The two metric plates carry a SurfaceGui "0" on the player-facing side (design note:
# bench stores, never a fourth HUD number). Pass 1 is store-only: the graphic exists.
FACE = ', face = { text = "0", side = Enum.NormalId.Back, align = Enum.TextXAlignment.Right, color = Color3.fromRGB(242, 242, 235), pixelsPerStud = 40 }'  # Back = +Z = the player-facing side
cube("PlateBones", (2.3, 0.12, 1.15), (-1.35, -1.68, 2.15), mat="plate_brown", extra=FACE)
cube("PlateFire", (2.3, 0.12, 1.15), (1.35, -1.68, 2.15), mat="plate_char", extra=FACE)
cylinder("BoneIcon", 0.09, 0.85, (-1.95, -1.76, 2.35), rot=(0, math.radians(55), 0), mat="bone")
for sx, sz in ((-0.28, 0.18), (0.28, -0.18)):
    sphere(f"BoneKnob_{sx:+.2f}", 0.13, (-1.95 + sx * 0.7, -1.76, 2.35 + sz), mat="bone")
cone("FlameIcon", 0.22, 0.45, (0.85, -1.76, 2.38), mat="flame")

def skull(prefix, loc, scale=1.0):
    x, y, z = loc
    sphere(f"{prefix}_Cranium", 0.42 * scale, (x, y, z), mat="bone", scale=(0.92, 1.05, 1.08))
    for i, dx in enumerate((-0.16 * scale, 0.16 * scale)):
        sphere(f"{prefix}_Eye_{i}", 0.11 * scale, (x + dx, y - 0.36 * scale, z + 0.04 * scale), mat="bone_dark")
    cube(f"{prefix}_Nose", (0.07 * scale, 0.10 * scale, 0.12 * scale), (x, y - 0.38 * scale, z - 0.10 * scale), mat="bone_dark")
    cube(f"{prefix}_Jaw", (0.38 * scale, 0.28 * scale, 0.16 * scale), (x, y - 0.12 * scale, z - 0.38 * scale), mat="bone")
    for i, dx in enumerate((-0.12 * scale, 0.0, 0.12 * scale)):
        cube(f"{prefix}_Tooth_{i}", (0.06 * scale, 0.06 * scale, 0.07 * scale), (x + dx, y - 0.26 * scale, z - 0.46 * scale), mat="bone")

skull("SkullLeg", (-3.55, -1.55, 1.62), scale=0.78)
for z in (1.25, 1.42, 1.58):
    cylinder(f"Rope_{z}", 0.28, 0.06, (-3.50, -1.25, z), rot=(0, math.radians(90), 0), mat="rope")
skull("SkullTop", (3.15, 0.15, 3.72), scale=1.05)
cylinder("Bowl", 0.55, 0.18, (-0.15, 0.55, 3.32), mat="iron")
cone("FireA", 0.28, 0.55, (-0.15, 0.55, 3.62), mat="flame")
cone("FireB", 0.16, 0.38, (-0.05, 0.50, 3.72), mat="flame")
cube("SawBody", (1.35, 0.55, 0.55), (-2.6, 0.15, 3.48), mat="saw_orange")
cube("SawBar", (1.7, 0.12, 0.28), (-4.05, 0.15, 3.48), mat="saw_grey")
for i in range(6):
    cube(f"SawTooth_{i}", (0.12, 0.16, 0.10), (-3.4 - i * 0.22, 0.15, 3.66), mat="saw_grey")
cube("SawHandle", (0.35, 0.12, 0.55), (-2.15, 0.15, 3.85), mat="saw_grey")
cube("Stain1", (1.8, 0.9, 0.02), (-1.2, 0.4, 3.21), mat="stain")
cube("Stain2", (1.1, 0.6, 0.02), (1.6, -0.5, 3.21), mat="stain")
for i, x in enumerate((-3.9, 3.9)):
    cube(f"Strap_{i}", (0.12, 3.2, 0.12), (x, 0, 3.18), mat="iron")
for i, (x, y) in enumerate(((-3.9, -1.5), (3.9, -1.5), (-3.9, 1.5), (3.9, 1.5))):
    cone(f"Spike_{i}", 0.09, 0.45, (x, y, 3.42), mat="iron")
for i, x in enumerate((-3.2, -2.4, -0.2, 0.6, 2.4, 3.2)):
    cylinder(f"Nail_{i}", 0.04, 0.18, (x, -1.55, 3.28), mat="rust")
for i, x in enumerate((2.55, 2.75)):
    cylinder(f"Chain_{i}", 0.05, 1.1, (x, -1.55, 2.35), mat="iron")
    sphere(f"Link_{i}", 0.09, (x, -1.55, 1.75), mat="iron")
cylinder("HookArm", 0.05, 0.7, (3.7, -1.4, 2.55), rot=(math.radians(25), 0, 0), mat="iron")
sphere("HookTip", 0.08, (3.7, -1.7, 2.15), mat="iron")
cylinder("FemurA", 0.08, 1.4, (-1.6, 0.4, 1.38), rot=(0, math.radians(70), math.radians(20)), mat="bone")
cylinder("FemurB", 0.07, 1.2, (-0.6, 0.2, 1.36), rot=(0, math.radians(-55), math.radians(-15)), mat="bone")
sphere("FemurKnobA", 0.14, (-2.2, 0.55, 1.42), mat="bone")
skull("SkullShelf", (2.2, 0.35, 1.62), scale=0.62)
for i, x in enumerate((-2.8, -2.2, -1.6)):
    cylinder(f"Rib_{i}", 0.04, 1.15, (x, 0.0, 2.15), rot=(math.radians(55), 0, 0), mat="bone")
cylinder("Candle", 0.08, 0.45, (1.15, 1.2, 3.45), mat="bone")
cone("CandleFlame", 0.07, 0.18, (1.15, 1.2, 3.72), mat="flame")
cube("WaxDrip", (0.05, 0.05, 0.35), (1.22, 1.2, 3.28), mat="bone")
cube("Embers", (2.2, 1.4, 0.08), (0.0, 0.0, 0.55), mat="ember")
cylinder("HangBone", 0.06, 0.7, (-3.2, -0.2, 2.0), rot=(0, 0, math.radians(15)), mat="bone")

header = '''-- bench — the Quiet Shore crafting bench, as data. GENERATED by
-- tools/bench_from_blender.py from the art bot's blender_craft_bench.py
-- (RB BUSINESS/HELLWEEK, 2026-09-12). Do not edit by hand; edit the generator.
--
-- Every entry is a plain Part in the bench's own frame: origin on the sand under the
-- tabletop centre, +Z is the player-facing front (the two plates). world.luau places
-- the whole thing with one CFrame. Pass 1 = set dressing: the plates read "0" and
-- nothing is deposited (crafting is PARKED on the cut list). The chainsaw is a prop,
-- never a Tool. Skulls are stylised, dark-inset eyes, no gore.
--
-- Bench frame parts: %d. Tabletop 8 x 0.4 x 3.2 at y=3, legs 2.6 tall.

return {
'''
body = ",\n".join(parts)
open(OUT, "w").write(header % len(parts) + body + ",\n}\n")
print("wrote", OUT, len(parts), "parts")

#!/usr/bin/env python3
"""
obelisk_from_blender.py — translate HW-001 Obelisk (blender_obelisk.py, the art bot's
primitive build of the approved 2D v3) into pack data: games/hell-week/server/obelisk.luau.

Why the script and not the GLB: it is ~120 primitives in stud units, so every piece
becomes a plain Roblox Part — permanent, diffable, no mesh upload, no Studio gate.

Owner instructions applied (CLAUDE_PASTE_OBELISK.md, 2026-09-12):
  - Ground plane dropped.  - scale x3: stone+cap 9.0 -> 27 studs (24-32 asked).
  - Cap cones dropped; the cap is a stone pyramid stump with an HW-002 fire jet (data
    `fire` spec -> ParticleEmitter + short PointLight).  - shaft charcoal, glyphs Neon
    gold, skulls bone-cream.  - collision on base + shaft only.
  - Roblox has no cone: glyph triangles -> Wedge, birds -> Wedge + Ball head.

Blender Z-up -> Roblox Y-up: (x, y, z) -> (x, z, -y). Cylinders get the local quarter-turn.

  python3 tools/obelisk_from_blender.py
"""
import math, os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "games", "hell-week", "server", "obelisk.luau")
S = 2.0  # scale (was 3: Justin wants the flame in frame from spawn and more perspective)

def rot_x(a): c, s = math.cos(a), math.sin(a); return [[1,0,0],[0,c,-s],[0,s,c]]
def rot_y(a): c, s = math.cos(a), math.sin(a); return [[c,0,s],[0,1,0],[-s,0,c]]
def rot_z(a): c, s = math.cos(a), math.sin(a); return [[c,-s,0],[s,c,0],[0,0,1]]
def mul(a, b): return [[sum(a[i][k]*b[k][j] for k in range(3)) for j in range(3)] for i in range(3)]
def tr(a): return [[a[j][i] for j in range(3)] for i in range(3)]
M = [[1,0,0],[0,0,1],[0,-1,0]]
SWAP = [[0,-1,0],[1,0,0],[0,0,1]]
I3 = [[1,0,0],[0,1,0],[0,0,1]]
def blender_rot(rx, ry, rz): return mul(rot_z(rz), mul(rot_y(ry), rot_x(rx)))
def to_roblox(R): return mul(M, mul(R, tr(M)))
def cframe(loc, R):
    x, y, z = (v * S for v in loc)
    return "CFrame.new(%.3f, %.3f, %.3f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f)" % (
        x, z, -y, R[0][0], R[0][1], R[0][2], R[1][0], R[1][1], R[1][2], R[2][0], R[2][1], R[2][2])

STONE = ("Color3.fromRGB(28, 28, 32)", "Slate")          # charcoal
GOLD = ("Color3.fromRGB(255, 196, 64)", "Neon")           # reads at night
BONE = ("Color3.fromRGB(226, 214, 190)", "SmoothPlastic")
SOCKET = ("Color3.fromRGB(16, 14, 14)", "SmoothPlastic")

parts = []
def emit(name, shape, size, loc, R, mat, collide=False, extra=""):
    color, material = mat
    parts.append("\t{ name = %r, shape = Enum.PartType.%s, size = Vector3.new(%.3f, %.3f, %.3f), cframe = %s, color = %s, material = Enum.Material.%s, canCollide = %s%s }"
                 % (name, shape, size[0]*S, size[1]*S, size[2]*S, cframe(loc, R), color, material, "true" if collide else "false", extra))

def cube(name, size, loc, rot=(0,0,0), mat=STONE, collide=False, extra=""):
    sx, sy, sz = size
    emit(name, "Block", (sx, sz, sy), loc, to_roblox(blender_rot(*rot)), mat, collide, extra)

def sphere(name, r, loc, mat=GOLD):
    emit(name, "Ball", (2*r, 2*r, 2*r), loc, I3, mat)

def cyl(name, r, d, loc, rot=(0,0,0), mat=GOLD):
    emit(name, "Cylinder", (d, 2*r, 2*r), loc, mul(to_roblox(blender_rot(*rot)), SWAP), mat)

def wedge(name, w, h, loc, rot=(0,0,0), mat=GOLD):
    # A Roblox Wedge is a triangular prism, thin along local Z: the triangle reads on the face.
    emit(name, "Wedge", (w, h, 0.06), loc, to_roblox(blender_rot(*rot)), mat)

# --- base + shaft (collidable) --------------------------------------------------------
cube("Base0", (5.2, 5.2, 0.45), (0, 0, 0.22), collide=True)
cube("Base1", (4.2, 4.2, 0.40), (0, 0, 0.64), collide=True)
cube("Base2", (3.4, 3.4, 0.35), (0, 0, 1.00), collide=True)
levels = [(3.0, 1.6), (2.7, 2.7), (2.4, 3.8), (2.1, 4.9), (1.85, 6.0), (1.6, 7.0), (1.35, 7.9)]
prev = 1.18
for i, (w, top_z) in enumerate(levels):
    h = top_z - prev
    cube(f"Shaft_{i}", (w, w, h), (0, 0, prev + h / 2), collide=True)
    prev = top_z
# Cap: the cone becomes a stone stump + a lip, and the fire sits on it (no gold spike).
cube("Cap", (1.2, 1.2, 0.5), (0, 0, 8.15), collide=True)
cube("CapTop", (0.9, 0.9, 0.35), (0, 0, 8.55), collide=True)
cyl("CapLip", 0.55, 0.16, (0, 0, 8.78), mat=STONE)
# The flame core: the loop scales this Neon ball with fuel and hangs the HW-002 jet on
# it. The obelisk IS the beacon (Justin, 2026-09-12): this is the light that holds the
# night, so its jet is generous; the gameplay radius light sits at the base (loop).
sphere("CapFlame", 0.42, (0, 0, 9.15), mat=("Color3.fromRGB(255, 176, 56)", "Neon"))
parts[-1] = parts[-1].replace(" }", ", fire = { size = 2.6, height = 9, range = 16, brightness = 1.6, rate = 40, sparkRate = 10 } }", 1)

# --- glyphs ------------------------------------------------------------------------
def face_point(axis, sign, u, z, bump=1.22):
    return (u, sign * bump, z) if axis == "y" else (sign * bump, u, z)

def face_rot(axis, sign):
    # glyph wedges/reeds lie flat against the face: rotate so their thin axis is the face normal
    if axis == "y":
        return (0, 0, 0) if sign < 0 else (0, 0, math.pi)
    return (0, 0, math.radians(-90)) if sign > 0 else (0, 0, math.radians(90))

def g_eye(name, loc, fr):
    sphere(name + "_r", 0.16, loc); sphere(name + "_p", 0.07, loc, mat=SOCKET)
def g_sun(name, loc, fr):
    sphere(name + "_c", 0.12, loc)
    for i, (du, dz) in enumerate(((0.20, 0), (-0.20, 0), (0, 0.20), (0, -0.20))):
        l = list(loc); l[0 if fr[2] in (0, math.pi) else 1] += du; l[2] += dz
        cube(name + f"_r{i}", (0.05, 0.05, 0.12), tuple(l), rot=fr, mat=GOLD)
def g_tri(name, loc, fr):
    wedge(name, 0.28, 0.22, loc, rot=fr)
def g_bird(name, loc, fr):
    wedge(name + "_b", 0.2, 0.22, loc, rot=(fr[0], fr[1], fr[2] + math.radians(20)))
    sphere(name + "_h", 0.07, (loc[0], loc[1], loc[2] + 0.12))
def g_reed(name, loc, fr):
    for tag, du, d in (("a", -0.06, 0.28), ("b", 0.0, 0.34), ("c", 0.06, 0.24)):
        l = list(loc); l[0 if fr[2] in (0, math.pi) else 1] += du
        cyl(name + "_" + tag, 0.03, d, tuple(l), rot=(math.radians(90), 0, 0) if False else (0, 0, 0))
def g_wave(name, loc, fr):
    for tag, du, dz in (("1", 0.0, 0.06), ("2", 0.06, -0.06)):
        l = list(loc); l[0 if fr[2] in (0, math.pi) else 1] += du; l[2] += dz
        cube(name + "_" + tag, (0.22, 0.05, 0.05), tuple(l), rot=fr, mat=GOLD)

makers = [g_eye, g_sun, g_tri, g_bird, g_reed, g_wave]
zs = (2.35, 2.85, 3.35, 3.85, 5.55, 6.05, 6.55, 7.05, 7.50)
cols = (-0.42, 0.42)
gid = 0
for axis, sign, tag in (("y", -1, "S"), ("y", 1, "N"), ("x", 1, "E"), ("x", -1, "W")):
    fr = face_rot(axis, sign)
    for ci, u in enumerate(cols):
        for zi, z in enumerate(zs):
            makers[(gid + zi + ci) % len(makers)](f"G{tag}{ci}{zi}", face_point(axis, sign, u, z), fr)
    gid += 3

# --- one skull per face ---------------------------------------------------------------
def skull(prefix, loc, scale, yaw):
    R = blender_rot(0, 0, yaw)
    def local_(dx, dy, dz):
        x, y, z = loc
        lx = dx * R[0][0] + dy * R[0][1]; ly = dx * R[1][0] + dy * R[1][1]
        return (x + lx, y + ly, z + dz)
    sphere(f"{prefix}_Cranium", 0.42 * scale * 1.04, loc, mat=BONE)
    for i, dx in enumerate((-0.15 * scale, 0.15 * scale)):
        sphere(f"{prefix}_E{i}", 0.11 * scale, local_(dx, -0.34 * scale, 0.04 * scale), mat=SOCKET)
    cube(f"{prefix}_Nose", (0.06 * scale, 0.08 * scale, 0.10 * scale), local_(0, -0.36 * scale, -0.08 * scale), rot=(0, 0, yaw), mat=SOCKET)
    cube(f"{prefix}_Jaw", (0.34 * scale, 0.24 * scale, 0.14 * scale), local_(0, -0.10 * scale, -0.36 * scale), rot=(0, 0, yaw), mat=BONE)

skull("SkullS", (0, -1.55, 4.7), 1.05, 0)                 # -Y: faces Roblox +Z (the "front")
skull("SkullN", (0, 1.55, 4.7), 1.05, math.pi)
skull("SkullE", (1.55, 0, 4.7), 1.05, math.radians(-90))
skull("SkullW", (-1.55, 0, 4.7), 1.05, math.radians(90))

header = '''-- obelisk — HW-001 Obelisk, as data. GENERATED by tools/obelisk_from_blender.py from
-- the art bot's blender_obelisk.py (GrokBDownloads/HW-001_Obelisk_01, 2026-09-12).
-- Do not edit by hand; edit the generator.
--
-- Parts in the obelisk's own frame, x3 the authored size: base on the sand at y=0,
-- +Z is the face whose skull looks at the Wick once world.luau places it. Charcoal
-- shaft (collidable), Neon-gold glyphs (invented marks: eyes, suns, triangles, birds,
-- reeds, waves — nothing written), bone-cream skull in each of the four faces, and an
-- HW-002 fire jet on the cap instead of the draft's gold cone. THE OBELISK IS THE BEACON
-- (Justin, 2026-09-12): the loop builds it at the origin from config.beacon.parts and
-- players feed it at the base; CapFlame is the core the loop scales with fuel.
--
-- Parts: %d. Stone + cap ≈ 18 studs tall.

return {
'''
open(OUT, "w").write(header % len(parts) + ",\n".join(parts) + ",\n}\n")
print("wrote", OUT, len(parts), "parts")

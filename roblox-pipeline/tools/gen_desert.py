#!/usr/bin/env python3
"""
gen_desert.py — build The Ashen Waste as pack data.

Writes games/hell-week/server/desert.luau: the static scenery of a 700-stud desert,
generated from a fixed seed so the file is reproducible and diffable. Harvestable
nodes (cactus, boulders, deadfall) are NOT here — the loop places and respawns those.

Everything is a plain Roblox primitive, so the biome saves, diffs and needs no mesh
upload. Shape comes from stacking and burying rather than from detail: dunes are
mostly-buried spheres so only a smooth crest shows, mesas are shrinking slabs, dead
trees are a tapered trunk plus a few angled limbs.

  python3 tools/gen_desert.py
"""
import math
import os
import random

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT_DIR = os.path.join(ROOT, "games", "hell-week", "server", "desert")
CHUNK_BYTES = 140_000  # Studio refuses a script Source at 200,000 characters

RADIUS = 350.0          # the playable disk
CLEAR_R = 46.0          # nothing inside this: the obelisk, its stone, and the teach
SEED = 20260912

rng = random.Random(SEED)
parts = []


def c(r, g, b):
    return f"C({r},{g},{b})"


def jitter(base, spread):
    return tuple(max(0, min(255, v + rng.randint(-spread, spread))) for v in base)


# The Ashen Waste palette: bleached, dead, never golden-hour warm. The obelisk's
# charcoal and gold are the only saturated things in the world.
SAND = (168, 150, 122)
ROCK = (78, 68, 60)
ROCK_PALE = (104, 92, 80)
DEADWOOD = (104, 90, 74)
BONE = (214, 204, 182)
SCRUB = (74, 74, 58)
RUIN = (92, 84, 74)


def emit(name, size, pos, *, shape="Block", rot=None, color=SAND, material="Sand",
         collide=True, shadow=True, transparency=None):
    # Short aliases (V/C/P/M) are defined at the top of each chunk. At ~1,200 parts the
    # long spellings cost ~65KB of pure boilerplate, and Studio caps a script's Source.
    bits = [
        f"name = {name!r}",
        f"shape = P.{shape}",
        "size = V(%.1f, %.1f, %.1f)" % size,
        "position = V(%.1f, %.1f, %.1f)" % pos,
    ]
    if rot:
        bits.append("rotation = V(%.1f, %.1f, %.1f)" % rot)
    bits.append(f"color = {c(*color)}")
    bits.append(f"material = M.{material}")
    if not collide:
        bits.append("canCollide = false")
    if not shadow:
        bits.append("castShadow = false")
    if transparency is not None:
        bits.append("transparency = %.2f" % transparency)
    parts.append("\t{ " + ", ".join(bits) + " }")


def scatter(count, inner, outer, fn, clear=CLEAR_R):
    """Even-density placement in an annulus (sqrt keeps it from bunching inward)."""
    placed = 0
    guard = 0
    while placed < count and guard < count * 40:
        guard += 1
        theta = rng.random() * math.tau
        r = math.sqrt(rng.random() * (outer**2 - inner**2) + inner**2)
        if r < clear:
            continue
        x, z = math.cos(theta) * r, math.sin(theta) * r
        fn(placed, x, z, r)
        placed += 1


# ---------------------------------------------------------------- dunes
def dune(i, x, z, r):
    w = rng.uniform(46, 135)
    h = rng.uniform(9, 22)
    # Buried to the waist: only the crest shows, so a sphere reads as a dune.
    emit(f"Dune{i}", (w, h * 2, w * rng.uniform(0.6, 1.0)), (x, -h * 0.62, z),
         shape="Ball", color=jitter(SAND, 8), material="Sand", collide=True, shadow=False)


# ---------------------------------------------------------------- mesas
def mesa(i, x, z, r):
    base_w = rng.uniform(16, 34)
    layers = rng.randint(3, 6)
    y = 0.0
    yaw = rng.uniform(0, 360)
    for k in range(layers):
        w = base_w * (1 - k / (layers + 1.4))
        h = rng.uniform(3.4, 7.0)
        emit(f"Mesa{i}_{k}", (h, w, w * rng.uniform(0.75, 1.05)), (x + rng.uniform(-1.4, 1.4), y + h / 2, z + rng.uniform(-1.4, 1.4)),
             shape="Cylinder", rot=(0, yaw + k * rng.uniform(-14, 14), 90),
             color=jitter(ROCK if k % 2 == 0 else ROCK_PALE, 6), material="Slate")
        y += h * rng.uniform(0.82, 0.95)
    for b in range(rng.randint(1, 3)):
        s = rng.uniform(3.5, 8)
        bx, bz = x + rng.uniform(-base_w, base_w), z + rng.uniform(-base_w, base_w)
        emit(f"Mesa{i}_b{b}", (s, s * 0.7, s * 0.85), (bx, s * 0.22, bz),
             shape="Ball", color=jitter(ROCK, 8), material="Slate")


# ---------------------------------------------------------------- dead trees
def dead_tree(i, x, z, r):
    h = rng.uniform(11, 26)
    lean = rng.uniform(-7, 7)
    emit(f"Tree{i}_t", (h, 1.5, 1.5), (x, h / 2, z),
         shape="Cylinder", rot=(lean, rng.uniform(0, 360), 90),
         color=jitter(DEADWOOD, 10), material="Wood")
    emit(f"Tree{i}_u", (h * 0.45, 2.3, 2.3), (x, h * 0.22, z),
         shape="Cylinder", rot=(lean * 0.5, rng.uniform(0, 360), 90),
         color=jitter(DEADWOOD, 10), material="Wood")
    for b in range(rng.randint(2, 4)):
        bl = rng.uniform(3.5, 9)
        by = h * rng.uniform(0.45, 0.92)
        emit(f"Tree{i}_b{b}", (bl, 0.75, 0.75), (x, by, z),
             shape="Cylinder", rot=(rng.uniform(-30, 30), rng.uniform(0, 360), rng.uniform(28, 62)),
             color=jitter(DEADWOOD, 10), material="Wood", collide=False)


# ---------------------------------------------------------------- scrub + stones
def scrub(i, x, z, r):
    s = rng.uniform(1.4, 3.4)
    emit(f"Scrub{i}", (s * 1.6, s, s * 1.5), (x, s * 0.3, z),
         shape="Ball", color=jitter(SCRUB, 10), material="Grass", collide=False, shadow=False)


def stone(i, x, z, r):
    s = rng.uniform(1.8, 5.5)
    emit(f"Stone{i}", (s, s * 0.66, s * 0.85), (x, s * 0.2, z),
         shape="Ball", rot=(rng.uniform(-20, 20), rng.uniform(0, 360), rng.uniform(-20, 20)),
         color=jitter(ROCK_PALE, 10), material="Slate")


# ---------------------------------------------------------------- ruins + bones
def ruin(i, x, z, r):
    yaw = rng.uniform(0, 360)
    for k in range(rng.randint(3, 6)):
        w = rng.uniform(4, 13)
        h = rng.uniform(2.5, 9)
        off = rng.uniform(-11, 11)
        a = math.radians(yaw)
        emit(f"Ruin{i}_{k}", (w, h, rng.uniform(1.1, 2.2)),
             (x + math.cos(a) * off, h / 2 - rng.uniform(0.3, 1.6), z + math.sin(a) * off),
             rot=(rng.uniform(-6, 6), yaw + rng.uniform(-12, 12), rng.uniform(-8, 8)),
             color=jitter(RUIN, 8), material="Slate")


def bones(i, x, z, r):
    for k in range(rng.randint(2, 4)):
        bl = rng.uniform(2.2, 6.5)
        emit(f"Bone{i}_{k}", (bl, 0.5, 0.5), (x + rng.uniform(-3, 3), 0.3, z + rng.uniform(-3, 3)),
             shape="Cylinder", rot=(0, rng.uniform(0, 360), 90),
             color=jitter(BONE, 8), material="SmoothPlastic", collide=False)
    if rng.random() < 0.45:
        emit(f"Bone{i}_s", (1.7, 1.5, 1.8), (x, 0.75, z),
             shape="Ball", color=jitter(BONE, 6), material="SmoothPlastic", collide=False)


# ---------------------------------------------------------------- the pass
# Density falls off outward a little so the near ground reads busy and the far ground
# reads empty — that is what makes a flat disk feel like distance.
scatter(96, CLEAR_R, RADIUS, dune)
scatter(30, 70, RADIUS, mesa)
scatter(64, CLEAR_R, 240, dead_tree)
scatter(22, 240, RADIUS, dead_tree)
scatter(150, CLEAR_R, RADIUS, scrub)
scatter(110, CLEAR_R, RADIUS, stone)
scatter(16, 90, RADIUS, ruin)
scatter(26, CLEAR_R, RADIUS, bones)

# A dry wash: a shallow darker channel that gives the eye a line to follow.
wash_yaw = math.radians(28)
for k in range(34):
    t = (k / 33) * 2 - 1
    d = t * RADIUS * 0.96
    wob = math.sin(k * 0.7) * 16
    wx = math.cos(wash_yaw) * d - math.sin(wash_yaw) * wob
    wz = math.sin(wash_yaw) * d + math.cos(wash_yaw) * wob
    if math.hypot(wx, wz) < CLEAR_R + 6:
        continue
    emit(f"Wash{k}", (rng.uniform(20, 34), 0.45, rng.uniform(15, 26)), (wx, 0.12, wz),
         rot=(0, math.degrees(wash_yaw) + rng.uniform(-18, 18), 0),
         color=jitter((142, 126, 104), 6), material="Sand", collide=False, shadow=False)

CHUNK_HEAD = """-- desert/%s — GENERATED by tools/gen_desert.py (seed %d). Do not edit by hand.
-- One chunk of The Ashen Waste's scenery. Studio caps a script's Source at 200,000
-- characters and the whole biome is larger than that, so it is split and `init.luau`
-- stitches the chunks back into one list.

local V, C = Vector3.new, Color3.fromRGB
local P, M = Enum.PartType, Enum.Material

return {
"""

os.makedirs(OUT_DIR, exist_ok=True)
for stale in os.listdir(OUT_DIR):
    if stale.endswith(".luau"):
        os.remove(os.path.join(OUT_DIR, stale))

chunks, current, size = [], [], 0
for line in parts:
    if size + len(line) > CHUNK_BYTES and current:
        chunks.append(current)
        current, size = [], 0
    current.append(line)
    size += len(line) + 2
if current:
    chunks.append(current)

names = []
for i, chunk in enumerate(chunks, 1):
    name = f"chunk{i}"
    names.append(name)
    with open(os.path.join(OUT_DIR, f"{name}.luau"), "w") as f:
        f.write(CHUNK_HEAD % (name, SEED) + ",\n".join(chunk) + ",\n}\n")

init = """-- desert — The Ashen Waste, as static scenery. GENERATED by tools/gen_desert.py
-- (seed %d). Do not edit by hand; edit the generator.
--
-- A 700-stud disk of bleached dead sand: dunes, rock mesas, dead trees, scrub,
-- half-buried ruins, bone scatter, and one dry wash cutting across to give the eye a
-- line. Nothing inside %.0f studs of the centre — that belt is the obelisk, its
-- pentagram stone and the one-minute teach.
--
-- HARVESTABLE nodes are NOT in here. Cactus, boulders and deadfall are placed by the
-- loop from config.resources so they can respawn; this file is the world that stays.
--
-- %d parts across %d chunks, because Studio refuses a script Source over 200,000
-- characters. This stitches them back into one list.

local out = {}
for _, chunk in { %s } do
\tfor _, spec in require(chunk) do
\t\ttable.insert(out, spec)
\tend
end
return out
""" % (SEED, CLEAR_R, len(parts), len(chunks), ", ".join("script." + n for n in names))

with open(os.path.join(OUT_DIR, "init.luau"), "w") as f:
    f.write(init)
print("wrote", OUT_DIR, len(parts), "parts in", len(chunks), "chunks")

#!/usr/bin/env python3
"""
gen_biome.py — build every world's scenery as pack data. Supersedes gen_desert.py.

Writes games/hell-week/server/scenery/<world-id>/ (chunked, because Studio refuses a
script Source over 200,000 characters). One generator, four palettes and four mixes:
the shapes are shared, what changes is the ground, the colours, the density and which
silhouettes dominate. That is what lets the world swap 360 degrees around a player who
never leaves the obelisk.

Shared vocabulary across worlds: mounds, mesas, standing dead things, scrub, rubble,
ruins, bone scatter, a wash line, and TEEPEES with a chest inside (the reason to walk
out to a silhouette rather than past it).

  python3 tools/gen_biome.py
"""
import math
import os
import random

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT_ROOT = os.path.join(ROOT, "games", "hell-week", "server", "scenery")
CHUNK_BYTES = 140_000

RADIUS = 350.0
CLEAR_R = 46.0          # the obelisk, its stone and the teach
CORRIDOR_HALF = 17.0    # the walk-in line from spawn; nothing tall stands on it
CORRIDOR_R = 110.0


# ---------------------------------------------------------------- the four worlds
BIOMES = {
    "ashen-waste": dict(
        seed=20260912,
        ground=(168, 150, 122), ground_mat="Sand",
        rock=(78, 68, 60), rock_pale=(104, 92, 80),
        wood=(104, 90, 74), bone=(214, 204, 182),
        scrub=(74, 74, 58), ruin=(92, 84, 74),
        hide=(150, 122, 96),
        mounds=96, mesas=30, trees=78, scrub_n=150, rubble=110, ruins=16, bones=26,
        teepees=9, wash=True, tree_h=(10, 18),
    ),
    "still-wood": dict(
        seed=771020,
        ground=(76, 80, 68), ground_mat="Ground",
        rock=(66, 68, 64), rock_pale=(88, 90, 84),
        wood=(118, 116, 108), bone=(206, 200, 186),
        scrub=(52, 60, 48), ruin=(80, 82, 76),
        hide=(104, 98, 84),
        mounds=34, mesas=10, trees=260, scrub_n=190, rubble=70, ruins=10, bones=34,
        teepees=8, wash=False, tree_h=(16, 34),
    ),
    "drowned-quarter": dict(
        seed=330451,
        ground=(58, 62, 66), ground_mat="Slate",
        rock=(54, 58, 62), rock_pale=(74, 78, 82),
        wood=(78, 76, 72), bone=(198, 196, 186),
        scrub=(46, 56, 56), ruin=(72, 78, 82),
        hide=(88, 92, 92),
        mounds=26, mesas=8, trees=54, scrub_n=90, rubble=90, ruins=54, bones=22,
        teepees=6, wash=False, tree_h=(10, 22), pools=70,
    ),
    "the-kiln": dict(
        seed=910077,
        ground=(74, 48, 42), ground_mat="Basalt",
        rock=(52, 36, 34), rock_pale=(88, 56, 46),
        wood=(62, 44, 38), bone=(196, 178, 160),
        scrub=(70, 40, 30), ruin=(64, 44, 40),
        hide=(112, 66, 50),
        mounds=48, mesas=34, trees=26, scrub_n=70, rubble=120, ruins=14, bones=30,
        teepees=6, wash=False, tree_h=(9, 18), embers=90,
    ),
}


def build(world_id, cfg):
    rng = random.Random(cfg["seed"])
    parts = []

    def c(col):
        return "C(%d,%d,%d)" % col

    def jitter(base, spread):
        return tuple(max(0, min(255, v + rng.randint(-spread, spread))) for v in base)

    def emit(name, size, pos, *, shape="Block", rot=None, color=None, material="Slate",
             collide=True, shadow=True, transparency=None):
        bits = [
            "name = %r" % name,
            "shape = P.%s" % shape,
            "size = V(%.1f, %.1f, %.1f)" % size,
            "position = V(%.1f, %.1f, %.1f)" % pos,
        ]
        if rot:
            bits.append("rotation = V(%.1f, %.1f, %.1f)" % rot)
        bits.append("color = %s" % c(color or cfg["ground"]))
        bits.append("material = M.%s" % material)
        if not collide:
            bits.append("canCollide = false")
        if not shadow:
            bits.append("castShadow = false")
        if transparency is not None:
            bits.append("transparency = %.2f" % transparency)
        parts.append("\t{ " + ", ".join(bits) + " }")

    def in_corridor(x, z):
        return z > 0 and abs(x) < CORRIDOR_HALF and math.hypot(x, z) < CORRIDOR_R

    def scatter(count, inner, outer, fn, clear=CLEAR_R):
        placed, guard = 0, 0
        while placed < count and guard < count * 40:
            guard += 1
            theta = rng.random() * math.tau
            r = math.sqrt(rng.random() * (outer**2 - inner**2) + inner**2)
            x, z = math.cos(theta) * r, math.sin(theta) * r
            if r < clear or in_corridor(x, z):
                continue
            fn(placed, x, z, r)
            placed += 1

    # ---- shapes ----
    def mound(i, x, z, r):
        w, h = rng.uniform(46, 135), rng.uniform(9, 22)
        # Shadow ON. The dunes are the dominant large form; with the sun low, they are
        # what gives the ground relief. Switched off, the desert reads as flat sand.
        emit(f"Mound{i}", (w, h * 2, w * rng.uniform(0.6, 1.0)), (x, -h * 0.62, z),
             shape="Ball", color=jitter(cfg["ground"], 8), material=cfg["ground_mat"], shadow=True)

    def mesa(i, x, z, r):
        # Capped so the obelisk wins its own scene. The landmark is 19.4 studs and was
        # deliberately shortened so the flame reads; the fix is to lower the scenery,
        # not to raise the monument.
        base_w, layers, y, yaw = rng.uniform(14, 27), rng.randint(3, 5), 0.0, rng.uniform(0, 360)
        for k in range(layers):
            w = base_w * (1 - k / (layers + 1.4))
            h = rng.uniform(3.4, 7.0)
            emit(f"Mesa{i}_{k}", (h, w, w * rng.uniform(0.75, 1.05)),
                 (x + rng.uniform(-1.4, 1.4), y + h / 2, z + rng.uniform(-1.4, 1.4)),
                 shape="Cylinder", rot=(0, yaw + k * rng.uniform(-14, 14), 90),
                 color=jitter(cfg["rock"] if k % 2 == 0 else cfg["rock_pale"], 6))
            y += h * rng.uniform(0.82, 0.95)

    def tree(i, x, z, r):
        lo, hi = cfg["tree_h"]
        h, lean = rng.uniform(lo, hi), rng.uniform(-7, 7)
        emit(f"Tree{i}_t", (h, 1.5, 1.5), (x, h / 2, z), shape="Cylinder",
             rot=(lean, rng.uniform(0, 360), 90), color=jitter(cfg["wood"], 10), material="Wood")
        emit(f"Tree{i}_u", (h * 0.45, 2.3, 2.3), (x, h * 0.22, z), shape="Cylinder",
             rot=(lean * 0.5, rng.uniform(0, 360), 90), color=jitter(cfg["wood"], 10), material="Wood")
        for b in range(rng.randint(2, 4)):
            emit(f"Tree{i}_b{b}", (rng.uniform(3.5, 9), 0.75, 0.75), (x, h * rng.uniform(0.45, 0.92), z),
                 shape="Cylinder", rot=(rng.uniform(-30, 30), rng.uniform(0, 360), rng.uniform(28, 62)),
                 color=jitter(cfg["wood"], 10), material="Wood", collide=False)

    def scrub(i, x, z, r):
        s = rng.uniform(1.4, 3.4)
        emit(f"Scrub{i}", (s * 1.6, s, s * 1.5), (x, s * 0.3, z), shape="Ball",
             color=jitter(cfg["scrub"], 10), material="Grass", collide=False, shadow=False)

    def rubble(i, x, z, r):
        s = rng.uniform(1.8, 5.5)
        emit(f"Rubble{i}", (s, s * 0.66, s * 0.85), (x, s * 0.2, z), shape="Ball",
             rot=(rng.uniform(-20, 20), rng.uniform(0, 360), rng.uniform(-20, 20)),
             color=jitter(cfg["rock_pale"], 10))

    def ruin(i, x, z, r):
        yaw = rng.uniform(0, 360)
        for k in range(rng.randint(3, 6)):
            w, h, off = rng.uniform(4, 13), rng.uniform(2.5, 9), rng.uniform(-11, 11)
            a = math.radians(yaw)
            emit(f"Ruin{i}_{k}", (w, h, rng.uniform(1.1, 2.2)),
                 (x + math.cos(a) * off, h / 2 - rng.uniform(0.3, 1.6), z + math.sin(a) * off),
                 rot=(rng.uniform(-6, 6), yaw + rng.uniform(-12, 12), rng.uniform(-8, 8)),
                 color=jitter(cfg["ruin"], 8))

    def bones(i, x, z, r):
        for k in range(rng.randint(2, 4)):
            emit(f"Bone{i}_{k}", (rng.uniform(2.2, 6.5), 0.5, 0.5),
                 (x + rng.uniform(-3, 3), 0.3, z + rng.uniform(-3, 3)), shape="Cylinder",
                 rot=(0, rng.uniform(0, 360), 90), color=jitter(cfg["bone"], 8),
                 material="SmoothPlastic", collide=False)
        if rng.random() < 0.45:
            emit(f"Bone{i}_s", (1.7, 1.5, 1.8), (x, 0.75, z), shape="Ball",
                 color=jitter(cfg["bone"], 6), material="SmoothPlastic", collide=False)

    def pool(i, x, z, r):
        w = rng.uniform(14, 46)
        emit(f"Pool{i}", (w, 0.4, w * rng.uniform(0.6, 1.2)), (x, 0.05, z),
             rot=(0, rng.uniform(0, 360), 0), color=(16, 22, 28), material="Glass",
             collide=False, shadow=False, transparency=0.25)

    def ember(i, x, z, r):
        w = rng.uniform(3, 11)
        emit(f"Ember{i}", (w, 0.3, w * rng.uniform(0.3, 0.8)), (x, 0.08, z),
             rot=(0, rng.uniform(0, 360), 0), color=(255, 104, 32), material="Neon",
             collide=False, shadow=False)

    # ---- teepees: a silhouette worth walking to, with something inside ----
    # The chest is NOT a part here — the loop places a lootable node at the teepee's
    # mouth from `teepees.luau`, so it can be looted once and restock between runs.
    teepee_spots = []

    def teepee(i, x, z, r, tint=(0, 0, 0)):
        teepee_spots.append((x, z))
        h = rng.uniform(13, 18)
        base = h * 0.34
        poles = 9
        yaw0 = rng.uniform(0, 360)
        for k in range(poles):
            a = math.radians(yaw0 + k * (360 / poles))
            # poles lean in: foot on the circle, head at the apex
            fx, fz = x + math.cos(a) * base, z + math.sin(a) * base
            emit(f"Tee{i}_p{k}", (h, 0.5, 0.5), ((fx + x) / 2, h / 2, (fz + z) / 2),
                 shape="Cylinder", rot=(math.degrees(math.atan2(base, h)) * math.sin(a),
                                        yaw0 + k * (360 / poles),
                                        90 - math.degrees(math.atan2(base, h)) * math.cos(a)),
                 color=jitter(cfg["wood"], 8), material="Wood", collide=False)
        # the hide: a cone of overlapping panels, open on the side facing the obelisk
        facing = math.degrees(math.atan2(-z, -x))
        panels = 11
        for k in range(panels):
            a = facing + 40 + k * ((360 - 80) / (panels - 1))
            ar = math.radians(a)
            for lay in range(3):
                t = (lay + 0.5) / 3
                pr = base * (1 - t * 0.86)
                py = h * t
                pw = 2 * math.pi * max(pr, 0.6) / panels * 1.5
                emit(f"Tee{i}_h{k}_{lay}", (pw, h / 3 * 1.12, 0.35),
                     (x + math.cos(ar) * pr, py + h / 6, z + math.sin(ar) * pr),
                     rot=(0, -a + 90, rng.uniform(-3, 3)),
                     color=jitter(tuple(max(0, min(255, c + t)) for c, t in zip(cfg["hide"], tint)), 7),
                     material="Fabric", collide=False, shadow=True)
        # a smoke pole and two stakes at the mouth so it reads as lived-in
        emit(f"Tee{i}_top", (h * 0.22, 0.4, 0.4), (x, h + h * 0.07, z), shape="Cylinder",
             rot=(0, 0, 90), color=jitter(cfg["wood"], 8), material="Wood", collide=False)
        for k, side in enumerate((-1, 1)):
            sa = math.radians(facing + side * 26)
            emit(f"Tee{i}_s{k}", (3.2, 0.34, 0.34),
                 (x + math.cos(sa) * (base + 1.6), 1.6, z + math.sin(sa) * (base + 1.6)),
                 shape="Cylinder", rot=(0, 0, 90), color=jitter(cfg["wood"], 8),
                 material="Wood", collide=False)

    # ---- the pass ----
    scatter(cfg["mounds"], CLEAR_R, RADIUS, mound)
    scatter(cfg["mesas"], 70, RADIUS, mesa)
    scatter(int(cfg["trees"] * 0.75), CLEAR_R, 240, tree)
    scatter(cfg["trees"] - int(cfg["trees"] * 0.75), 240, RADIUS, tree)
    scatter(cfg["scrub_n"], CLEAR_R, RADIUS, scrub)
    scatter(cfg["rubble"], CLEAR_R, RADIUS, rubble)
    scatter(cfg["ruins"], 90, RADIUS, ruin)
    scatter(cfg["bones"], CLEAR_R, RADIUS, bones)
    if cfg.get("pools"):
        scatter(cfg["pools"], CLEAR_R, RADIUS, pool)
    if cfg.get("embers"):
        scatter(cfg["embers"], CLEAR_R, RADIUS, ember)
    # Camps, not singles.
    #
    # A lone teepee reads as terrain decoration, so there is nothing to wonder about
    # and no reason to cross ground to reach it. Three pitched together in different
    # hides read as "people were here", which is a question. Watched live in 99
    # Nights: their tents come in threes, in three colours, on a dirt patch.
    #
    # Same asset budget, completely different pull. This is a parameter change.
    HIDE_TINTS = ((0, 0, 0), (-20, -12, 2), (16, 6, -10), (-10, 10, 14))

    def camp(i, x, z, r):
        n = 3 if rng.random() < 0.75 else 2
        yaw0 = rng.uniform(0, 360)
        for k in range(n):
            a = math.radians(yaw0 + k * (360 / n) + rng.uniform(-20, 20))
            spread = rng.uniform(13, 22)
            teepee(i * 10 + k,
                   x + math.cos(a) * spread,
                   z + math.sin(a) * spread,
                   r, tint=HIDE_TINTS[(i + k) % len(HIDE_TINTS)])

    scatter(max(2, round(cfg["teepees"] / 3)), 90, 300, camp, clear=112)

    if cfg.get("wash"):
        yaw = math.radians(28)
        for k in range(34):
            t = (k / 33) * 2 - 1
            d = t * RADIUS * 0.96
            wob = math.sin(k * 0.7) * 16
            wx = math.cos(yaw) * d - math.sin(yaw) * wob
            wz = math.sin(yaw) * d + math.cos(yaw) * wob
            if math.hypot(wx, wz) < CLEAR_R + 6 or in_corridor(wx, wz):
                continue
            emit(f"Wash{k}", (rng.uniform(20, 34), 0.45, rng.uniform(15, 26)), (wx, 0.12, wz),
                 rot=(0, math.degrees(yaw) + rng.uniform(-18, 18), 0),
                 color=jitter(tuple(int(v * 0.86) for v in cfg["ground"]), 6),
                 material=cfg["ground_mat"], collide=False, shadow=False)

    # ---- write ----
    out_dir = os.path.join(OUT_ROOT, world_id)
    os.makedirs(out_dir, exist_ok=True)
    for stale in os.listdir(out_dir):
        if stale.endswith(".luau"):
            os.remove(os.path.join(out_dir, stale))

    head = ('-- scenery/%s/%%s — GENERATED by tools/gen_biome.py (seed %d). Do not edit.\n'
            '-- One chunk of this world\'s scenery; init.luau stitches the chunks back into\n'
            '-- one list, because Studio caps a script Source at 200,000 characters.\n\n'
            'local V, C = Vector3.new, Color3.fromRGB\n'
            'local P, M = Enum.PartType, Enum.Material\n\nreturn {\n') % (world_id, cfg["seed"])

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
        with open(os.path.join(out_dir, f"{name}.luau"), "w") as f:
            f.write(head % name + ",\n".join(chunk) + ",\n}\n")

    teepee_lines = ",\n".join("\tVector3.new(%.1f, 0, %.1f)" % t for t in teepee_spots)
    init = ('-- scenery/%s — GENERATED by tools/gen_biome.py (seed %d). Do not edit by hand.\n'
            '--\n'
            '-- %d parts across %d chunks. Teepee mouths are exported so the loop can put a\n'
            '-- chest in each one — the scenery says where a thing IS, the loop decides what\n'
            '-- is in it and when it comes back.\n\n'
            'local scenery = {}\n'
            'for _, chunk in { %s } do\n'
            '\tfor _, spec in require(chunk) do\n'
            '\t\ttable.insert(scenery, spec)\n'
            '\tend\n'
            'end\n\n'
            'return {\n'
            '\tscenery = scenery,\n'
            '\tteepees = {\n%s,\n\t},\n'
            '}\n') % (world_id, cfg["seed"], len(parts), len(chunks),
                      ", ".join("script." + n for n in names), teepee_lines)
    with open(os.path.join(out_dir, "init.luau"), "w") as f:
        f.write(init)
    return len(parts), len(chunks), len(teepee_spots)


os.makedirs(OUT_ROOT, exist_ok=True)
for world_id, cfg in BIOMES.items():
    n, ch, tee = build(world_id, cfg)
    print(f"{world_id:18} {n:5} parts  {ch} chunks  {tee} teepees")

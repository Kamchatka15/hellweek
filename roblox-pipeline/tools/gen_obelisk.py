#!/usr/bin/env python3
"""
gen_obelisk.py — build HW-001 Obelisk as pack data, properly.

Supersedes `tools/obelisk_from_blender.py`, which translated the art bot's Blender
blockout (kept for provenance). That version was a stack of seven boxes with visible
steps, a boxy cap and glyphs made of floating spheres — it read as low-resolution from
any distance, which is exactly what it was.

What changed and why:
  * the SHAFT is 52 thin slices instead of 7 blocks, so the taper is smooth rather
    than a staircase — at 0.25 studs a slice the step is below a pixel in play;
  * the CAP is a real pyramid (22 shrinking slices), matching the 2D lock, instead of
    a stump with a flame balanced on it;
  * the BASE has five fine steps instead of three chunky ones;
  * the GLYPHS are recessed panels with carved marks on them — vertical columns of
    small bright blocks inset into a dark channel — instead of spheres and cones stuck
    to the outside. Panels follow the taper, so they sit ON the face all the way up.
  * no skulls (owner call, 2026-09-12: invisible under the shaft wash).

Everything is still plain Roblox primitives: the obelisk saves, diffs, and needs no
mesh upload.

  python3 tools/gen_obelisk.py
"""
import math
import os
import random

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "games", "hell-week", "server", "obelisk.luau")

rng = random.Random(77345)
parts = []

# ---------------------------------------------------------------- proportions (studs)
BASE_STEPS = [(13.4, 0.55), (12.0, 0.5), (10.6, 0.45), (9.4, 0.4), (8.4, 0.35)]
SHAFT_BOTTOM_W = 7.3
SHAFT_TOP_W = 3.7
SHAFT_SLICES = 52
CAP_SLICES = 22
CAP_TOP_W = 0.45

STONE = ("Color3.fromRGB(46, 47, 58)", "Slate")
STONE_DARK = ("Color3.fromRGB(32, 33, 42)", "Slate")
CHANNEL = ("Color3.fromRGB(20, 19, 25)", "Slate")
GOLD = ("Color3.fromRGB(255, 196, 64)", "Neon")
GOLD_DIM = ("Color3.fromRGB(150, 108, 30)", "SmoothPlastic")


def emit(name, size, pos, mat, *, shape="Block", collide=False, extra=""):
    color, material = mat
    parts.append(
        "\t{ name = %r, shape = Enum.PartType.%s, size = Vector3.new(%.3f, %.3f, %.3f), "
        "cframe = CFrame.new(%.3f, %.3f, %.3f), color = %s, material = Enum.Material.%s, canCollide = %s%s }"
        % (name, shape, size[0], size[1], size[2], pos[0], pos[1], pos[2],
           color, material, "true" if collide else "false", extra)
    )


# ---------------------------------------------------------------- base
y = 0.0
for i, (w, h) in enumerate(BASE_STEPS):
    emit(f"Base{i}", (w, h, w), (0, y + h / 2, 0), STONE if i % 2 == 0 else STONE_DARK, collide=True)
    y += h
BASE_TOP = y

# ---------------------------------------------------------------- shaft
SHAFT_H = 12.6
slice_h = SHAFT_H / SHAFT_SLICES


def shaft_width(t):
    """t in 0..1 from the shaft's foot to its shoulder."""
    return SHAFT_BOTTOM_W + (SHAFT_TOP_W - SHAFT_BOTTOM_W) * t


for i in range(SHAFT_SLICES):
    t = (i + 0.5) / SHAFT_SLICES
    w = shaft_width(t)
    # +0.02 overlap so no seam shows between slices
    emit(f"Shaft{i}", (w, slice_h + 0.02, w), (0, BASE_TOP + i * slice_h + slice_h / 2, 0),
         STONE, collide=True)
SHOULDER = BASE_TOP + SHAFT_H

# ---------------------------------------------------------------- pyramid cap
CAP_H = 3.4
cap_slice = CAP_H / CAP_SLICES
for i in range(CAP_SLICES):
    t = (i + 0.5) / CAP_SLICES
    w = SHAFT_TOP_W + (CAP_TOP_W - SHAFT_TOP_W) * t
    emit(f"Cap{i}", (w, cap_slice + 0.02, w), (0, SHOULDER + i * cap_slice + cap_slice / 2, 0),
         STONE_DARK, collide=True)
APEX = SHOULDER + CAP_H

# ---------------------------------------------------------------- glyph panels
# Two recessed channels per face, running most of the shaft. Each channel is a dark
# inset strip with bright marks carved along it. Everything follows the taper, so a
# panel sits flat on the stone at every height instead of floating off it near the top.
PANEL_LOW, PANEL_HIGH = 0.10, 0.93   # as a fraction of the shaft
CHANNEL_W = 1.45
COLUMN_OFFSET = 1.55                  # sideways from the face centre, at the foot
MARKS_PER_COLUMN = 17

FACES = [
    ("S", (0, 0, 1)),   # +Z, the face that meets the walk in from spawn
    ("N", (0, 0, -1)),
    ("E", (1, 0, 0)),
    ("W", (-1, 0, 0)),
]


def face_point(normal, up_t, across):
    """A point on the tapered face: `up_t` along the shaft, `across` sideways in studs
    at the foot, shrunk by the taper so it stays on the stone."""
    w = shaft_width(up_t)
    shrink = w / SHAFT_BOTTOM_W
    half = w / 2
    y = BASE_TOP + SHAFT_H * up_t
    nx, _, nz = normal
    # sideways runs along the OTHER horizontal axis from the normal
    sx, sz = (0, 1) if nx != 0 else (1, 0)
    return (nx * half + sx * across * shrink, y, nz * half + sz * across * shrink), shrink


for tag, normal in FACES:
    nx, _, nz = normal
    for ci, across in enumerate((-COLUMN_OFFSET, COLUMN_OFFSET)):
        # the channel itself, as a few tall segments so it tapers with the stone
        SEGMENTS = 10
        for s in range(SEGMENTS):
            t = PANEL_LOW + (PANEL_HIGH - PANEL_LOW) * (s + 0.5) / SEGMENTS
            pos, shrink = face_point(normal, t, across)
            seg_h = SHAFT_H * (PANEL_HIGH - PANEL_LOW) / SEGMENTS
            size = (CHANNEL_W * shrink if nx != 0 else CHANNEL_W * shrink, seg_h + 0.02, 0.18)
            if nx != 0:
                size = (0.18, seg_h + 0.02, CHANNEL_W * shrink)
            emit(f"Chan{tag}{ci}{s}", size, pos, CHANNEL)

        for m in range(MARKS_PER_COLUMN):
            t = PANEL_LOW + (PANEL_HIGH - PANEL_LOW) * (m + 0.5) / MARKS_PER_COLUMN
            pos, shrink = face_point(normal, t, across)
            # a mark is one to three small bars: enough variety to read as writing
            kind = rng.randint(0, 4)
            bars = {0: [(0.62, 0.20)], 1: [(0.30, 0.20), (0.30, 0.20)], 2: [(0.85, 0.14)],
                    3: [(0.22, 0.36)], 4: [(0.55, 0.16), (0.24, 0.16)]}[kind]
            span = sum(b[0] for b in bars) + 0.12 * (len(bars) - 1)
            cursor = -span / 2
            for bi, (bw, bh) in enumerate(bars):
                off = (cursor + bw / 2) * shrink
                sx, sz = (0, 1) if nx != 0 else (1, 0)
                p = (pos[0] + sx * off, pos[1], pos[2] + sz * off)
                size = (bw * shrink, bh, 0.26) if nx == 0 else (0.26, bh, bw * shrink)
                emit(f"G{tag}{ci}{m}_{bi}", size, (p[0] + nx * 0.05, p[1], p[2] + nz * 0.05), GOLD)
                cursor += bw + 0.12

    # a dim gold band top and bottom of each face, to close the columns off
    for t, name in ((PANEL_LOW - 0.035, "lo"), (PANEL_HIGH + 0.035, "hi")):
        pos, shrink = face_point(normal, t, 0)
        w = shaft_width(t) * 0.86
        size = (w, 0.22, 0.22) if nx == 0 else (0.22, 0.22, w)
        emit(f"Band{tag}{name}", size, (pos[0] + nx * 0.04, pos[1], pos[2] + nz * 0.04), GOLD_DIM)

# ---------------------------------------------------------------- the fire
# A stone lip at the apex and the flame core the loop scales with fuel. The HW-002 jet
# hangs off the core; its light is generous because this IS the beacon.
emit("CapLip", (1.15, 0.3, 1.15), (0, APEX + 0.12, 0), STONE_DARK, collide=True)
emit("CapFlame", (0.95, 0.95, 0.95), (0, APEX + 0.75, 0),
     ("Color3.fromRGB(255, 176, 56)", "Neon"), shape="Ball",
     extra=", fire = { size = 2.6, height = 9, range = 44, brightness = 3, rate = 44, sparkRate = 12 }")

header = '''-- obelisk — HW-001 Obelisk, as data. GENERATED by tools/gen_obelisk.py.
-- Do not edit by hand; edit the generator.
--
-- Parts in the obelisk's own frame: base on the sand at y=0, +Z the face that meets
-- the walk in from spawn. A stepped base, a shaft of %d thin slices so the taper is
-- smooth instead of a staircase, a real pyramid cap, and four faces of recessed gold
-- glyph channels that follow the taper. No skulls (owner call, 2026-09-12).
--
-- THE OBELISK IS THE BEACON: the loop builds it at the origin from config.beacon.parts,
-- players feed it at its foot, and `CapFlame` is the core the loop scales with fuel.
--
-- Parts: %d. Overall height ~%.1f studs before scaling.

return {
'''

open(OUT, "w").write(header % (SHAFT_SLICES, len(parts), APEX + 1.2) + ",\n".join(parts) + ",\n}\n")
print("wrote", OUT, len(parts), "parts, height %.1f" % (APEX + 1.2))

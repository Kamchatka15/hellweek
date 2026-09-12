#!/usr/bin/env python3
"""HW-001 Obelisk DRAFT — matches approved 2D v3 (one skull per face, fire cap)."""
import math
import os
import bpy
from mathutils import Vector, Euler

OUT = os.environ.get("HW_OUT", os.path.dirname(os.path.abspath(__file__)))
os.makedirs(OUT, exist_ok=True)


def reset():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    for o in list(bpy.data.objects):
        bpy.data.objects.remove(o, do_unlink=True)


def mat(name, color, roughness=0.6, metallic=0.0, emission=None, e_str=0.0):
    m = bpy.data.materials.new(name)
    m.diffuse_color = (*color, 1)
    m.use_nodes = True
    nt = m.node_tree
    for n in list(nt.nodes):
        nt.nodes.remove(n)
    out = nt.nodes.new("ShaderNodeOutputMaterial")
    bsdf = nt.nodes.new("ShaderNodeBsdfPrincipled")
    bsdf.inputs["Base Color"].default_value = (*color, 1)
    bsdf.inputs["Roughness"].default_value = roughness
    if "Metallic" in bsdf.inputs:
        bsdf.inputs["Metallic"].default_value = metallic
    if emission and "Emission Strength" in bsdf.inputs:
        if "Emission Color" in bsdf.inputs:
            bsdf.inputs["Emission Color"].default_value = (*emission, 1)
        bsdf.inputs["Emission Strength"].default_value = e_str
    nt.links.new(bsdf.outputs["BSDF"], out.inputs["Surface"])
    return m


def cube(name, size, loc, rot=(0, 0, 0), material=None):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc, rotation=rot)
    o = bpy.context.active_object
    o.name = name
    o.scale = size
    bpy.ops.object.transform_apply(scale=True)
    if material:
        o.data.materials.append(material)
    return o


def sphere(name, r, loc, material=None, seg=12, rings=8):
    bpy.ops.mesh.primitive_uv_sphere_add(radius=r, location=loc, segments=seg, ring_count=rings)
    o = bpy.context.active_object
    o.name = name
    if material:
        o.data.materials.append(material)
    return o


def cone(name, r, d, loc, rot=(0, 0, 0), material=None, verts=8):
    bpy.ops.mesh.primitive_cone_add(radius1=r, radius2=0, depth=d, location=loc, rotation=rot, vertices=verts)
    o = bpy.context.active_object
    o.name = name
    if material:
        o.data.materials.append(material)
    return o


def cyl(name, r, d, loc, rot=(0, 0, 0), material=None, verts=12):
    bpy.ops.mesh.primitive_cylinder_add(radius=r, depth=d, location=loc, rotation=rot, vertices=verts)
    o = bpy.context.active_object
    o.name = name
    if material:
        o.data.materials.append(material)
    return o


def make_skull(prefix, loc, scale, bone, dark):
    x, y, z = loc
    cr = sphere(f"{prefix}_Cranium", 0.42 * scale, (x, y, z), bone, 14, 9)
    cr.scale = (0.92, 0.95, 1.08)
    bpy.ops.object.transform_apply(scale=True)
    parts = [
        sphere(f"{prefix}_E0", 0.11 * scale, (x - 0.15 * scale, y - 0.34 * scale, z + 0.04 * scale), dark, 8, 6),
        sphere(f"{prefix}_E1", 0.11 * scale, (x + 0.15 * scale, y - 0.34 * scale, z + 0.04 * scale), dark, 8, 6),
        cube(f"{prefix}_Nose", (0.06 * scale, 0.08 * scale, 0.10 * scale), (x, y - 0.36 * scale, z - 0.08 * scale), material=dark),
        cube(f"{prefix}_Jaw", (0.34 * scale, 0.24 * scale, 0.14 * scale), (x, y - 0.10 * scale, z - 0.36 * scale), material=bone),
    ]
    for p in parts:
        p.parent = cr
        p.matrix_parent_inverse = cr.matrix_world.inverted()
    return cr


def build():
    reset()
    stone = mat("Stone", (0.07, 0.07, 0.08), 0.85)
    gold = mat("GoldGlow", (0.85, 0.62, 0.15), 0.35, metallic=0.4, emission=(1.0, 0.72, 0.2), e_str=3.0)
    bone = mat("Bone", (0.82, 0.76, 0.62), 0.45)
    dark = mat("Socket", (0.05, 0.04, 0.04), 0.6)
    flame = mat("Flame", (1.0, 0.38, 0.05), 0.3, emission=(1.0, 0.4, 0.05), e_str=8.0)
    flame2 = mat("Flame2", (1.0, 0.72, 0.15), 0.3, emission=(1.0, 0.7, 0.1), e_str=6.0)
    sand = mat("Sand", (0.18, 0.16, 0.13), 0.95)

    cube("Ground", (16, 16, 0.12), (0, 0, -0.06), material=sand)

    # Stepped base — 3 slabs
    cube("Base0", (5.2, 5.2, 0.45), (0, 0, 0.22), material=stone)
    cube("Base1", (4.2, 4.2, 0.40), (0, 0, 0.64), material=stone)
    cube("Base2", (3.4, 3.4, 0.35), (0, 0, 1.00), material=stone)

    # Tapering shaft via stacked shrinking boxes (Roblox-friendly)
    # height from z=1.18 to z=8.2
    levels = [
        (3.0, 1.6),
        (2.7, 2.7),
        (2.4, 3.8),
        (2.1, 4.9),
        (1.85, 6.0),
        (1.6, 7.0),
        (1.35, 7.9),
    ]
    prev = 1.18
    for i, (w, top_z) in enumerate(levels):
        h = top_z - prev
        cube(f"Shaft_{i}", (w, w, h), (0, 0, prev + h / 2), material=stone)
        prev = top_z

    # Cap
    cone("Cap", 0.85, 1.15, (0, 0, 8.45), material=stone, verts=4)

    def face_point(axis, sign, u, z, bump=1.22):
        """axis 'x' or 'y': u is the side-to-side offset on the face."""
        if axis == "y":
            return (u, sign * bump, z)
        return (sign * bump, u, z)

    def g_eye(name, loc, gold):
        sphere(name + "_r", 0.16, loc, gold, 10, 6)
        sphere(name + "_p", 0.07, loc, gold, 8, 6)

    def g_sun(name, loc, gold):
        sphere(name + "_c", 0.12, loc, gold, 10, 6)
        for i, (dx, dz) in enumerate(((0.20, 0), (-0.20, 0), (0, 0.20), (0, -0.20))):
            cube(name + f"_r{i}", (0.05, 0.05, 0.12), (loc[0] + dx, loc[1], loc[2] + dz), material=gold)

    def g_tri(name, loc, gold):
        cone(name, 0.14, 0.22, loc, material=gold, verts=3)

    def g_bird(name, loc, gold):
        cone(name + "_b", 0.10, 0.22, loc, rot=(0, 0, math.radians(20)), material=gold, verts=5)
        sphere(name + "_h", 0.07, (loc[0], loc[1], loc[2] + 0.12), gold, 8, 6)

    def g_reed(name, loc, gold):
        cyl(name + "_a", 0.03, 0.28, (loc[0] - 0.06, loc[1], loc[2]), material=gold, verts=6)
        cyl(name + "_b", 0.03, 0.34, (loc[0], loc[1], loc[2]), material=gold, verts=6)
        cyl(name + "_c", 0.03, 0.24, (loc[0] + 0.06, loc[1], loc[2]), material=gold, verts=6)

    def g_wave(name, loc, gold):
        cube(name + "_1", (0.22, 0.05, 0.05), (loc[0], loc[1], loc[2] + 0.06), material=gold)
        cube(name + "_2", (0.22, 0.05, 0.05), (loc[0] + 0.06, loc[1], loc[2] - 0.06), material=gold)

    makers = [g_eye, g_sun, g_tri, g_bird, g_reed, g_wave]
    # two columns per face, skip the skull band (z 4.2–5.3)
    zs = (2.35, 2.85, 3.35, 3.85, 5.55, 6.05, 6.55, 7.05, 7.50)
    cols = (-0.42, 0.42)
    gid = 0
    for axis, sign, tag in (("y", -1, "S"), ("y", 1, "N"), ("x", 1, "E"), ("x", -1, "W")):
        for ci, u in enumerate(cols):
            for zi, z in enumerate(zs):
                loc = face_point(axis, sign, u, z)
                makers[(gid + zi + ci) % len(makers)](f"G{tag}{ci}{zi}", loc, gold)
        gid += 3

    # One skull per face, mid-height, facing out
    # South (-Y) faces camera
    s_s = make_skull("SkullS", (0, -1.55, 4.7), 1.05, bone, dark)
    s_n = make_skull("SkullN", (0, 1.55, 4.7), 1.05, bone, dark)
    s_n.rotation_euler = Euler((0, 0, math.pi), "XYZ")
    s_e = make_skull("SkullE", (1.55, 0, 4.7), 1.05, bone, dark)
    s_e.rotation_euler = Euler((0, 0, math.radians(-90)), "XYZ")
    s_w = make_skull("SkullW", (-1.55, 0, 4.7), 1.05, bone, dark)
    s_w.rotation_euler = Euler((0, 0, math.radians(90)), "XYZ")

    # Fire jet on cap
    cone("FireA", 0.55, 2.2, (0, 0, 9.55), material=flame, verts=6)
    cone("FireB", 0.32, 1.5, (0.08, -0.05, 9.85), material=flame2, verts=5)
    cone("FireC", 0.22, 1.0, (-0.1, 0.08, 10.05), material=flame, verts=5)

    # Camera
    bpy.ops.object.camera_add(location=(9.5, -11.5, 7.2))
    cam = bpy.context.active_object
    cam.data.lens = 35
    look = Vector((0, 0, 5.0))
    cam.rotation_euler = (look - Vector(cam.location)).to_track_quat("-Z", "Y").to_euler()
    bpy.context.scene.camera = cam

    bpy.ops.object.light_add(type="AREA", location=(6, -5, 12))
    k = bpy.context.active_object
    k.data.energy = 220
    k.data.size = 8
    k.data.color = (1.0, 0.8, 0.6)
    bpy.ops.object.light_add(type="POINT", location=(0, 0, 10.2))
    f = bpy.context.active_object
    f.data.energy = 250
    f.data.color = (1.0, 0.45, 0.1)
    bpy.ops.object.light_add(type="AREA", location=(-7, 4, 4))
    fl = bpy.context.active_object
    fl.data.energy = 40
    fl.data.size = 10
    fl.data.color = (0.4, 0.45, 0.6)

    world = bpy.data.worlds.new("W")
    bpy.context.scene.world = world
    world.use_nodes = True
    bg = world.node_tree.nodes.get("Background")
    if bg:
        bg.inputs[0].default_value = (0.05, 0.05, 0.06, 1)
        bg.inputs[1].default_value = 0.2

    scene = bpy.context.scene
    scene.render.engine = "BLENDER_WORKBENCH"
    sh = scene.display.shading
    sh.light = "STUDIO"
    sh.color_type = "MATERIAL"
    sh.show_shadows = True
    scene.render.resolution_x = 1280
    scene.render.resolution_y = 1600
    scene.render.filepath = os.path.join(OUT, "HW-001-obelisk-DRAFT.png")
    scene.render.image_settings.file_format = "PNG"

    blend = os.path.join(OUT, "HW-001-obelisk-DRAFT.blend")
    bpy.ops.wm.save_as_mainfile(filepath=blend)
    bpy.ops.render.render(write_still=True)
    glb = os.path.join(OUT, "HW-001-obelisk-DRAFT.glb")
    bpy.ops.export_scene.gltf(filepath=glb, export_format="GLB")
    fbx = os.path.join(OUT, "HW-001-obelisk-DRAFT.fbx")
    bpy.ops.export_scene.fbx(filepath=fbx, use_selection=False, object_types={"MESH"})
    print("WROTE", blend)
    print("WROTE", scene.render.filepath)
    print("WROTE", glb)
    print("WROTE", fbx)


if __name__ == "__main__":
    build()

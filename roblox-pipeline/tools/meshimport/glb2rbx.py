import struct, json, base64, hashlib, sys

SRC = "/Users/home/Desktop/Roblox Business/GrokBDownloads/LM_Station_SurfaceKiosk_01/LM_Station_SurfaceKiosk_01.glb"
OUT = "/private/tmp/claude-501/-Users-home-Downloads/cc52ad0d-ffb5-45a8-85ac-10334feb950f/scratchpad/serve/kiosk.json"

d = open(SRC,'rb').read()
_, _, length = struct.unpack_from('<III', d, 0)
off = 12; chunks = []
while off < length:
    clen, ctype = struct.unpack_from('<II', d, off)
    chunks.append((ctype, off+8, clen)); off += 8 + clen
J = json.loads(d[chunks[0][1]:chunks[0][1]+chunks[0][2]].decode('utf-8'))
BIN = d[chunks[1][1]:chunks[1][1]+chunks[1][2]]

CT = {5120:('b',1),5121:('B',1),5122:('h',2),5123:('H',2),5125:('I',4),5126:('f',4)}
NC = {'SCALAR':1,'VEC2':2,'VEC3':3,'VEC4':4}

def accessor(i):
    a = J['accessors'][i]
    bv = J['bufferViews'][a['bufferView']]
    fmt, sz = CT[a['componentType']]; n = NC[a['type']]
    base = bv.get('byteOffset',0) + a.get('byteOffset',0)
    stride = bv.get('byteStride') or sz*n
    out = []
    for k in range(a['count']):
        out.append(struct.unpack_from('<'+fmt*n, BIN, base + k*stride))
    return out

# ---- collect unique geometry ----
geoms = {}      # hash -> {"id":int,"pos":[...], "idx":[...]}
order = []
meshinfo = []   # per glTF mesh index -> (geomId, material)
for mi, m in enumerate(J['meshes']):
    pr = m['primitives'][0]
    pos = accessor(pr['attributes']['POSITION'])
    idx = [v[0] for v in accessor(pr['indices'])]
    key = hashlib.sha1(repr((pos, idx)).encode()).hexdigest()
    if key not in geoms:
        gid = len(order)
        geoms[key] = {"id": gid, "pos": pos, "idx": idx}
        order.append(key)
    meshinfo.append((geoms[key]["id"], pr.get('material', 0)))

# ---- quantize each unique geometry to int16 in its own bbox ----
STUDS = 3.5714286   # 1 metre = 3.5714 studs (Roblox: 1 stud = 0.28 m)
G = []
for key in order:
    g = geoms[key]
    xs = [p[0] for p in g["pos"]]; ys = [p[1] for p in g["pos"]]; zs = [p[2] for p in g["pos"]]
    mn = (min(xs), min(ys), min(zs)); mx = (max(xs), max(ys), max(zs))
    ext = [max(mx[i]-mn[i], 1e-9) for i in range(3)]
    qb = bytearray()
    for p in g["pos"]:
        for i in range(3):
            q = int(round((p[i]-mn[i]) / ext[i] * 65535)) - 32768
            qb += struct.pack('<h', max(-32768, min(32767, q)))
    ib = bytearray()
    for v in g["idx"]:
        ib += struct.pack('<H', v)
    G.append({
        "v": len(g["pos"]), "t": len(g["idx"])//3,
        # decode:  world = (q+32768)/65535 * ext + mn     (then * STUDS)
        "mn": [round(mn[i]*STUDS, 5) for i in range(3)],
        "ext":[round(ext[i]*STUDS, 5) for i in range(3)],
        "p": base64.b64encode(bytes(qb)).decode(),
        "i": base64.b64encode(bytes(ib)).decode(),
    })

# ---- materials -> Roblox ----
def c3(v): return [round(v[0],4), round(v[1],4), round(v[2],4)]
MATS = []
for m in J['materials']:
    pbr = m.get('pbrMetallicRoughness', {})
    base = pbr.get('baseColorFactor',[1,1,1,1])
    em = m.get('emissiveFactor')
    metal = pbr.get('metallicFactor',0); rough = pbr.get('roughnessFactor',1)
    alpha = base[3] if len(base)>3 else 1
    name = m.get('name','Mat')
    if alpha < 0.95:
        mat, tr = "Glass", round(1-alpha, 3)
    elif em and max(em) > 0.02:
        mat, tr = "Neon", 0
    elif metal >= 0.6:
        mat, tr = "Metal", 0
    elif rough > 0.6:
        mat, tr = "Wood" if "wood" in name.lower() else "Slate", 0
    else:
        mat, tr = "SmoothPlastic", 0
    # Neon renders the raw colour: push emissive tint in
    col = c3(em) if (mat == "Neon" and em) else c3(base)
    MATS.append({"n": name, "c": col, "m": mat, "tr": tr})

# ---- nodes ----
NODES = []
for n in J['nodes']:
    if n.get('mesh') is None: continue
    gid, mat = meshinfo[n['mesh']]
    t = n.get('translation',[0,0,0])
    NODES.append({"n": n.get('name','Part'), "g": gid, "m": mat,
                  "t": [round(t[0]*STUDS,5), round(t[1]*STUDS,5), round(t[2]*STUDS,5)]})

doc = {"name":"LM_Station_SurfaceKiosk_01","scale":STUDS,"geoms":G,"mats":MATS,"nodes":NODES}
s = json.dumps(doc, separators=(',',':'))
open(OUT,'w').write(s)

ys = [n["t"][1] for n in NODES]
print(f"unique geoms: {len(G)} (from {len(J['meshes'])} meshes)   nodes: {len(NODES)}   mats: {len(MATS)}")
print(f"total unique verts: {sum(g['v'] for g in G)}  tris: {sum(g['t'] for g in G)}")
print(f"payload: {len(s)} bytes  ({len(s)/1024:.1f} KB)")

"""
spacehex_flight_check.py — a VERIFICATION PORT, not the game.

The game's physics is games/spacehex/server/flight.luau and the validated career curve is
tools/spacehex_career.luau, which needs the `luau` CLI. That CLI was not installed on the
build machine on 2026-09-21 and the brief said not to install it unattended, so this file
is a straight Python port of flight.luau (resolve + simulate), the refurbish rule, the
payout formula in config.luau, and the playback timeline BuildLoop.beginFlight builds.

It reads the catalogue LIVE from parts.luau, so prices and stats cannot drift. The ~80
lines of physics are a copy and CAN drift: if flight.luau changes, change this file the
same day or delete it. Once `luau` is installed, tools/spacehex_career.luau is the truth
and this file is only a second opinion.

  python3 tools/spacehex_flight_check.py
"""
import math, re, sys
ROOT = "/Users/home/Desktop/Roblox Business/roblox-pipeline"
src = open(f"{ROOT}/games/spacehex/server/parts.luau").read()
parts = {}
for m in re.finditer(r"\{\s*id\s*=\s*\"(\w+)\"([^}]*)\}", src):
    pid, body = m.group(1), m.group(2)
    d = {"id": pid}
    for k, v in re.findall(r"(\w+)\s*=\s*([^,]+)", body):
        v = v.strip()
        if v.startswith('"'): d[k] = v.strip('"')
        elif v in ("true", "false"): d[k] = v == "true"
        else:
            try: d[k] = float(v)
            except ValueError: d[k] = v
    parts[pid] = d
G = G0 = 9.80665; RHO0 = 1.225; SCALE_H = 8500; AREA = 2.4; DT = 1/20; MAX_T = 400; ORBIT_DV = 7700
def density(h): return RHO0 * math.exp(-h / SCALE_H)
def ispAt(e, h):
    p = density(h) / RHO0
    return e["isp"] * (0.70 + 0.30 * (1 - p)) if e.get("vacuum") else e["isp"] * (1.00 + 0.15 * (1 - p))
def resolve(asm):
    nose = parts.get(asm.get("nose")); gnc = parts.get(asm.get("gnc")); payload = parts.get(asm.get("payload"))
    rcs = parts["rcs"] if asm.get("rcs") else None; dock = parts["dock_port"] if asm.get("dock") else None
    top = sum(x["mass"] for x in (nose, gnc, payload, rcs, dock) if x)
    stages, control = [], 0
    for i, s in enumerate(asm["stages"]):
        eng, tank = parts[s["engine"]], parts[s["tank"]]
        dec = parts.get(s.get("decoupler")); fin = parts.get(s.get("fins")); rec = parts.get(s.get("recovery"))
        n = s.get("engineCount", 1)
        dry = eng["mass"]*n + tank["mass"] + (dec["mass"] if dec else 0) + (fin["mass"] if fin else 0) + (rec["mass"] if rec else 0)
        stages.append(dict(engine=eng, count=n, dry=dry, prop=tank["prop"], thrust=eng["thrust"]*n,
                           burnRate=(eng["thrust"]*n)/(eng["isp"]*G0), recovery=rec))
        if i == 0 and fin: control += fin["control"]
    cd = nose["cd"] if nose else 0.55
    turn = (gnc["turn"] if gnc else 0.70) * (0.86 + 0.14 * min(control, 2.2) / 2.2)
    total = top + sum(st["dry"] + st["prop"] for st in stages)
    return dict(stages=stages, topMass=top, cd=cd, turn=turn, totalMass=total, hasRcs=rcs is not None, hasDock=dock is not None, payload=payload)
def massFrom(v, i, fuel):
    m = v["topMass"] + fuel
    for k in range(i, len(v["stages"])): m += v["stages"][k]["dry"]
    for k in range(i+1, len(v["stages"])): m += v["stages"][k]["prop"]
    return m
def simulate(v):
    s1 = v["stages"][0]; twr = s1["thrust"] / (v["totalMass"] * G)
    if twr <= 1.0: return dict(apogee=0, held=True, twr=twr, deltaV=0, effectiveDV=0, orbit=False, docked=False, trace=[])
    dv, repH = 0, 0
    for i, st in enumerate(v["stages"]):
        dv += ispAt(st["engine"], repH) * G0 * math.log(massFrom(v, i, st["prop"]) / massFrom(v, i, 0)); repH += 60000
    gl = 1450 * min(2.2, (1.40 / twr) ** 0.95); dl = 340 * (v["cd"] / 0.31) * min(2.0, max(0.6, twr / 1.40))
    eff = dv * v["turn"] - gl - dl
    h = vel = t = apogee = 0; stage, fuel = 0, v["stages"][0]["prop"]; trace = []
    while t < MAX_T:
        st = v["stages"][stage]; burning = fuel > 0; mass = massFrom(v, stage, fuel)
        thrust = st["thrust"] * (ispAt(st["engine"], h) / st["engine"]["isp"]) if burning else 0
        drag = 0.5 * density(h) * vel * abs(vel) * v["cd"] * AREA
        vel += ((thrust - drag) / mass - G) * DT; h = max(0, h + vel * DT)
        if burning: fuel = max(0, fuel - st["burnRate"] * DT)
        if fuel <= 0 and stage < len(v["stages"]) - 1: stage += 1; fuel = v["stages"][stage]["prop"]
        t += DT
        if h > apogee: apogee = h
        if not trace or t - trace[-1][0] >= 0.25: trace.append((t, h, vel))
        if h <= 0 and vel < 0 and t > 2: break
    apogee *= (0.55 + 0.45 * (1 - v["turn"]))
    orbit = eff >= ORBIT_DV
    if orbit: apogee = max(apogee, 400000)
    return dict(apogee=apogee, held=False, twr=twr, deltaV=dv, effectiveDV=eff, orbit=orbit, docked=orbit and v["hasRcs"] and v["hasDock"], trace=trace, seconds=t)
def refurb(asm):
    c = 0
    for s in asm["stages"]:
        base = parts[s["engine"]]["cost"] * s.get("engineCount", 1) + parts[s["tank"]]["cost"]
        c += base * (0.01 if s.get("recovery") else 0.04)
    return math.floor(c + parts[asm["nose"]]["cost"] * 0.04)
MILES = [("alt_5k",5000,180000),("alt_20k",20000,420000),("alt_50k",50000,900000),("karman",100000,2200000),("alt_250k",250000,4500000)]
DVM = [("dv_2k",2000,300000),("dv_3500",3500,900000),("dv_5k",5000,2400000),("dv_6500",6500,5000000),("dv_8k",8000,9000000)]
def payout(r, best, hit):
    ap, dv = r["apogee"], r["effectiveDV"]
    rec = ap > best["ap"] or dv > best["dv"]
    alt = 700000 * (ap/1000) ** 0.38; dvp = 300000 * (dv/1000) ** 1.85 if dv > 0 else 0
    pay = max(alt, dvp) * (1 if rec else 0.62); tags = []
    for mid, at, p in MILES:
        if ap >= at and mid not in hit: hit.add(mid); pay += p; tags.append(mid)
    for mid, at, p in DVM:
        if dv >= at and mid not in hit: hit.add(mid); pay += p; tags.append(mid)
    if r["orbit"] and "orbit" not in hit: hit.add("orbit"); pay += 26000000; tags.append("ORBIT")
    if r["docked"] and "docked" not in hit: hit.add("docked"); pay += 60000000; tags.append("DOCKED")
    best["ap"] = max(best["ap"], ap); best["dv"] = max(best["dv"], dv)
    return math.floor(pay), rec, tags
def timeline(v, r):
    """Exactly what BuildLoop.beginFlight builds."""
    if r["held"]: return [("prelaunch",3),("ascent",4),("recovery",6)], None
    burnouts, t = [], 0
    for st in v["stages"]: t += st["prop"]/st["burnRate"]; burnouts.append(t)
    rawMax = apT = endT = 0
    for (tt, hh, vv) in r["trace"]:
        if hh > rawMax: rawMax, apT = hh, tt
        endT = tt
    scale = r["apogee"]/rawMax if rawMax > 0 else 1
    lastBurn = min(burnouts[-1], apT); ascent = max(lastBurn, 0.25); coast = max(0, apT - ascent)
    ph = [("prelaunch",3),("ascent",min(max(ascent,0.5),24))]
    if coast > 0.05: ph.append(("coast", min(max(coast,0.5),12)))
    if not r["orbit"]: ph.append(("descent", min(max(apT*0.35,2),8)))
    ph.append(("recovery",6))
    return ph, dict(burnouts=burnouts, apogeeT=apT, endT=endT, rawMax=rawMax, scale=scale)

# ---- the first session, as a player would play it -------------------------------
cash = 1_000_000; owned = {"eng_hopper","tank_micro","nose_blunt","gnc_none"}
best = {"ap":0,"dv":0}; hit = set()
def buy(pid):
    global cash
    cash -= parts[pid]["cost"]; owned.add(pid); print(f"  buy {parts[pid]['label']:<16} -{parts[pid]['cost']:>9,}  cash {cash:>12,}")
def launch(asm, label):
    global cash
    v = resolve(asm); r = simulate(v); rf = min(cash, refurb(asm)); cash -= rf
    pay, rec, tags = payout(r, best, hit); cash += pay
    ph, info = timeline(v, r)
    print(f"LAUNCH {label}: twr {r['twr']:.2f} apogee {r['apogee']/1000:.2f} km dv {r['deltaV']:.0f} eff {r['effectiveDV']:.0f} held {r['held']} orbit {r['orbit']}")
    print(f"  refurb -{rf:,}  pay +{pay:,} {'RECORD' if rec else 'repeat'} {tags}  -> cash {cash:,}")
    print(f"  phases {[(n, round(l,1)) for n,l in ph]}  total wall {sum(l for _,l in ph):.1f}s")
    if info: print(f"  burnouts {[round(b,1) for b in info['burnouts']]} apogeeT {info['apogeeT']:.1f} endT {info['endT']:.1f} rawMax {info['rawMax']:.0f} scale {info['scale']:.3f} traceLen {len(r['trace'])}")
    assert cash >= 0, "cash went negative"
    return r
starter = {"stages":[{"engine":"eng_hopper","tank":"tank_micro","engineCount":1}],"nose":"nose_blunt","gnc":"gnc_none"}
print("== starter stack has no fins: rule 4 blocks rollout; the player buys Tail Fins first ==")
buy("fins_basic"); starter["stages"][0]["fins"] = "fins_basic"
launch(starter, "1 (hopper+micro+blunt+fins)")
buy("dec_light")
asm2 = {"stages":[{"engine":"eng_hopper","tank":"tank_micro","engineCount":1,"fins":"fins_basic","decoupler":"dec_light"},{"engine":"eng_hopper","tank":"tank_micro","engineCount":1}],"nose":"nose_blunt","gnc":"gnc_none"}
launch(asm2, "2 (two hopper stages)")
buy("tank_small")
asm3 = {"stages":[{"engine":"eng_hopper","tank":"tank_small","engineCount":1,"fins":"fins_basic","decoupler":"dec_light"},{"engine":"eng_hopper","tank":"tank_micro","engineCount":1}],"nose":"nose_blunt","gnc":"gnc_none"}
launch(asm3, "3 (small tank below)")
launch(asm3, "4 (same stack again -> repeat pay)")
print("== the teaching failure: a Medium Tank under one Hopper ==")
buy("tank_medium")
heavy = {"stages":[{"engine":"eng_hopper","tank":"tank_medium","engineCount":1,"fins":"fins_basic"}],"nose":"nose_blunt","gnc":"gnc_none"}
r = launch(heavy, "5 (hopper + medium: should be HELD)")
assert r["held"], "expected a hold-down"
print("== four hoppers under the medium tank ==")
cluster = {"stages":[{"engine":"eng_hopper","tank":"tank_medium","engineCount":4,"fins":"fins_basic"}],"nose":"nose_blunt","gnc":"gnc_none"}
launch(cluster, "6 (4x hopper + medium)")
print("== payout formula against economy.md rows (apogee, effDV, record, milestones fresh) ==")
for label, ap, dv in [("row 1", 1700, -1), ("row 7", 545900, 2724), ("row 16 orbit", 400000, 8123)]:
    b = {"ap":0,"dv":0}; h = set()
    p, _, tags = payout(dict(apogee=ap, effectiveDV=dv, orbit=dv>=7700, docked=False), b, h)
    print(f"  {label}: pay ${p/1e6:.2f}M {tags}")
print("OK")

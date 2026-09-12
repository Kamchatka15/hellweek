#!/usr/bin/env python3
"""
survive_sim.py — fuel-budget simulation for a survive-the-night pack, before anyone plays.

Reads games/<slug>/server/config.luau (days, rings, sack, beacon, lure) and simulates a
player who gathers Ashwood by day at a chosen effort, feeds the Wick, and burns through
the night. Answers the two questions the brief's §6 table cannot: does a slacker still
see Day 2, and does a sloppy Day 3 actually feel tight?

  python3 tools/survive_sim.py --slug hell-week
  python3 tools/survive_sim.py --slug hell-week --effort 0.5 --gifts 1

Assumptions NOT in config (stated so they can be argued with):
  WALK          16 studs/s (Roblox default)
  PICK_TIME     0.4 s to pick a piece up once you reach it
  effort        share of the day the player actually spends gathering (1.0 = whole day)
  route         average trip = walk out to the ring's mean radius, 3 pieces, walk back
"""
import argparse, math, os, re, statistics, random

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
WALK, PICK_TIME = 16.0, 0.4

def parse(path):
    t = open(path, errors="replace").read()
    days = [dict(day=float(a), night=float(b), burn=float(c))
            for a, b, c in re.findall(r"\{\s*day\s*=\s*([\d.]+),\s*night\s*=\s*([\d.]+),\s*burn\s*=\s*([\d.]+)", t)]
    rings = [dict(id=i, inner=float(a), outer=float(b), level=int(c), count=int(d), path=int(e or 0))
             for i, a, b, c, d, e in re.findall(
                 r'id\s*=\s*"(\w)",\s*inner\s*=\s*([\d.]+),\s*outer\s*=\s*([\d.]+),\s*level\s*=\s*(\d+),\s*count\s*=\s*(\d+)(?:,\s*path\s*=\s*(\d+))?', t)]
    g = lambda k: float(re.search(rf"\b{k}\s*=\s*([\d.]+)", t).group(1))
    thresholds = [float(x) for x in re.search(r"levelThresholds\s*=\s*\{([^}]*)\}", t).group(1).split(",") if x.strip()]
    lure = re.search(r"lure\s*=\s*\{(.*?)\n\t\}", t, re.S).group(1)
    lv = lambda k: float(re.search(rf"\b{k}\s*=\s*([\d.]+)", lure).group(1))
    return dict(days=days, rings=rings, cap=g("cap"), fuelCap=g("fuelCap"), thresholds=thresholds,
                startingFuel=g("startingFuel"), lureValue=lv("value"), burnMult=lv("burnMultiplier"))

def trip_seconds(mean_r):
    return 2 * mean_r / WALK + 3 * PICK_TIME + 6.0  # 6 s of looking around per trip

def simulate(cfg, effort, gifts_on_day, rng):
    fuel, fed, weight = cfg["startingFuel"], 0.0, 0
    out = []
    for d, day in enumerate(cfg["days"], 1):
        level = sum(1 for th in cfg["thresholds"] if fed >= th)
        floor = [r for r in cfg["rings"] if r["level"] <= level]
        pieces = sum(r["count"] + r["path"] for r in floor)
        budget = day["day"] * effort * rng.uniform(0.85, 1.15)
        gathered = 0
        while budget > 0 and pieces > 0:
            # nearest ring with pieces left, weighted toward inner rings
            ring = min(floor, key=lambda r: r["inner"])
            mean_r = (ring["inner"] + ring["outer"]) / 2
            take = min(int(cfg["cap"]), pieces)
            cost = trip_seconds(mean_r) * take / 3
            if cost > budget: break
            budget -= cost; pieces -= take; gathered += take
            accepted = min(take, cfg["fuelCap"] - fuel); fuel += accepted; fed += accepted
            if pieces <= 0: break
            floor = [r for r in cfg["rings"] if r["level"] <= sum(1 for th in cfg["thresholds"] if fed >= th)]
        if d in gifts_on_day:
            fuel = min(cfg["fuelCap"], fuel + cfg["lureValue"]); weight += 1
        burn = day["burn"] * cfg["burnMult"] ** weight
        survived = fuel >= burn
        fuel_after = max(0.0, fuel - burn)
        out.append(dict(day=d, gathered=gathered, fuel_before_night=fuel, burn=burn, survived=survived, fuel_after=fuel_after))
        if not survived: break
        fuel = fuel_after
    return out

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--slug", default="hell-week")
    ap.add_argument("--runs", type=int, default=300)
    a = ap.parse_args()
    cfg = parse(os.path.join(ROOT, "games", a.slug, "server", "config.luau"))
    print(f"# Survive sim — {a.slug} — {a.runs} runs per row\n")
    print("Cap %d · Wick holds %d · rings open at fed=%s · lure +%g, burn ×%g per Weight\n" % (cfg["cap"], cfg["fuelCap"], cfg["thresholds"], cfg["lureValue"], cfg["burnMult"]))
    print("| player | gifts | median days survived | P(see Day 2) | P(see Day 4) | P(week) | Day-3 fuel before night (median) |")
    print("|---|---|---|---|---|---|---|")
    for label, effort in [("slacker (25% of day)", 0.25), ("casual (50%)", 0.5), ("engaged (75%)", 0.75), ("sweat (100%)", 1.0)]:
        for gifts in [(), (3,), (3, 4, 5)]:
            res = [simulate(cfg, effort, gifts, random.Random(i)) for i in range(a.runs)]
            days = [r[-1]["day"] if r[-1]["survived"] else r[-1]["day"] - 1 for r in res]
            p = lambda n: 100 * sum(1 for x in days if x >= n) / len(days)
            d3 = [r[2]["fuel_before_night"] for r in res if len(r) >= 3]
            print(f"| {label} | {len(gifts)} | {statistics.median(days):.0f} | {p(1):.0f}% | {p(3):.0f}% | {p(7):.0f}% | {statistics.median(d3) if d3 else float('nan'):.1f} |")
    print("\nAssumptions: walk 16 studs/s, 0.4 s per pickup, 6 s of looking per trip, sack always filled to cap, inner rings first, effort ±15%, no downed penalties, no co-op (one player).")

if __name__ == "__main__":
    main()

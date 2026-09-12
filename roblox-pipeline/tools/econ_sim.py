#!/usr/bin/env python3
"""
econ_sim.py — Monte-Carlo the economy before anyone plays (PIPELINE.md §7.1).

Reads the REAL numbers from games/<slug>/server/config.luau and simulates a player
against the engine's own formulas (ProgressionService.costAt / effectAt, LoopService
burst + bank, RewardService offline). Finds "week-2 billionaires" and "nothing left
to buy by Thursday" while they are still a spreadsheet problem.

  python3 tools/econ_sim.py                       # active title, snack sessions
  python3 tools/econ_sim.py --slug fat-man-gets-rich --session 900 --days 30

Assumptions that are NOT in config (stated so they can be argued with):
  BANK_TRIP_S   seconds lost walking to the bank and back
  collectFrac   share of a burst actually swept up, rising with the magnet radius
Everything else is the game's own arithmetic.
"""
import argparse, math, os, random, re, statistics, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BANK_TRIP_S = 6.0
RUNS = 300

def parse_config(path):
    t = open(path, errors="replace").read()
    num = lambda k, blk: float(re.search(rf"\b{k}\s*=\s*([\d.]+(?:\s*\*\s*[\d.]+)?)", blk).group(1).replace(" ", "").replace("*", "*") if re.search(rf"\b{k}\s*=\s*([\d.]+)", blk) else eval(re.search(rf"\b{k}\s*=\s*([\d.*\s]+)", blk).group(1)))
    def block(name):
        m = re.search(rf"\b{name}\s*=\s*\{{(.*?)\n\t\}}", t, re.S)
        return m.group(1) if m else ""
    flood, offline, collect = block("flood"), block("offline"), block("collect")
    cfg = {
        "cooldown": float(re.search(r"cooldown\s*=\s*([\d.]+)", flood).group(1)),
        "capSeconds": eval(re.search(r"capSeconds\s*=\s*([\d.*\s]+),", offline).group(1)),
        "burstsPerHour": float(re.search(r"burstsPerHour\s*=\s*([\d.]+)", offline).group(1)),
        "baseRadius": float(re.search(r"baseRadius\s*=\s*([\d.]+)", collect).group(1)),
        "upgrades": {},
    }
    ups = re.search(r"upgrades\s*=\s*\{(.*)\n\t\},?\s*\n\}", t, re.S).group(1)
    for m in re.finditer(r"\{\s*id\s*=\s*\"(\w+)\"(.*?)\n\t\t\}", ups, re.S):
        b = m.group(2)
        g = lambda k: float(re.search(rf"\b{k}\s*=\s*([\d.]+)", b).group(1))
        cfg["upgrades"][m.group(1)] = dict(maxLevel=int(g("maxLevel")), baseCost=g("baseCost"),
                                           costGrowth=g("costGrowth"), base=g("base"), perLevel=g("perLevel"))
    roles = dict(re.findall(r"(\w+)\s*=\s*\"(\w+)\"", block("roles")))
    cfg["roles"] = roles
    return cfg

# --- the engine's own formulas ------------------------------------------------
def effect(d, lvl): return d["base"] + d["perLevel"] * (lvl - 1)
def cost(d, lvl):   return math.floor(d["baseCost"] * d["costGrowth"] ** (lvl - 1) + 0.5)

class Player:
    def __init__(s, cfg):
        s.cfg = cfg; s.u = cfg["upgrades"]; s.r = cfg["roles"]
        s.lvl = {k: 1 for k in s.u}
        s.balance = 0.0; s.carry = 0.0
        s.spent = 0.0; s.earned_active = 0.0; s.earned_offline = 0.0
        s.purchases = []  # (t_total_seconds, id, level)
    def eff(s, role): return effect(s.u[s.r[role]], s.lvl[s.r[role]])
    def cap(s): return s.eff("carryCap")
    def per_burst(s): return math.floor(s.eff("burstCount")) * s.eff("pickupValue")
    def collect_frac(s, noise):
        added = s.eff("collectRadius")
        return max(0.35, min(1.0, 0.5 + 0.04 * added + noise))
    def income_per_min(s, noise=0.0):
        # steady-state coins/min if playing: bursts every cooldown until bag full, then bank trip
        per = s.per_burst() * s.collect_frac(noise)
        if per <= 0: return 0.0
        bursts_per_bag = max(1, math.ceil(s.cap() / per))
        cycle = bursts_per_bag * s.cfg["cooldown"] + BANK_TRIP_S
        return min(s.cap(), bursts_per_bag * per) / cycle * 60.0
    def try_buy(s, t):
        # greedy: best income gain per coin, among affordable
        best = None
        for k, d in s.u.items():
            L = s.lvl[k]
            if L >= d["maxLevel"]: continue
            c = cost(d, L)
            if c > s.balance: continue
            before = s.income_per_min(); s.lvl[k] += 1; after = s.income_per_min(); s.lvl[k] -= 1
            gain = (after - before) / c
            if best is None or gain > best[0]: best = (gain, k, c)
        if best:
            _, k, c = best
            s.balance -= c; s.spent += c; s.lvl[k] += 1; s.purchases.append((t, k, s.lvl[k]))
            return True
        return False
    def all_max(s): return all(s.lvl[k] >= d["maxLevel"] for k, d in s.u.items())

def play_session(p, seconds, t0, rng):
    t = 0.0; noise = rng.uniform(-0.12, 0.12)
    first_upgrade_at = None
    while t < seconds:
        if p.carry >= p.cap():
            t += BANK_TRIP_S
            p.balance += p.carry; p.earned_active += p.carry; p.carry = 0
            while p.try_buy(t0 + t):
                if first_upgrade_at is None: first_upgrade_at = t0 + t
            continue
        got = min(p.cap() - p.carry, p.per_burst() * p.collect_frac(noise))
        p.carry += got
        t += p.cfg["cooldown"]
    # bank what you have at the end of a session (players do)
    p.balance += p.carry; p.earned_active += p.carry; p.carry = 0
    while p.try_buy(t0 + t):
        if first_upgrade_at is None: first_upgrade_at = t0 + t
    return first_upgrade_at

def run(cfg, session_s, days, rng):
    p = Player(cfg)
    first_up = None; stall = 0; max_stall = 0; day_max = None
    for day in range(1, days + 1):
        if day > 1:
            elapsed = min(24 * 3600, cfg["capSeconds"])
            rate = p.per_burst() * cfg["burstsPerHour"] / 3600
            off = rate * elapsed
            p.balance += off; p.earned_offline += off
        n_before = len(p.purchases)
        f = play_session(p, session_s * rng.uniform(0.7, 1.3), (day - 1) * 86400, rng)
        if first_up is None and f is not None: first_up = f
        if len(p.purchases) == n_before: stall += 1; max_stall = max(max_stall, stall)
        else: stall = 0
        if day_max is None and p.all_max(): day_max = day
    return dict(first_upgrade_s=first_up, day_all_max=day_max, max_stall_sessions=max_stall,
                offline_share=p.earned_offline / max(1, p.earned_active + p.earned_offline),
                income_day1=Player(cfg).income_per_min(), income_end=p.income_per_min(),
                balance_end=p.balance, spent=p.spent, levels=dict(p.lvl))

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--slug", default="fat-man-gets-rich")
    ap.add_argument("--session", type=int, default=240, help="seconds per daily session (snack=240, sit-down=900)")
    ap.add_argument("--days", type=int, default=30)
    ap.add_argument("--set", action="append", default=[], metavar="KEY=VAL",
                    help="override a number: burstsPerHour=1  bag.costGrowth=2.2  payout.maxLevel=12")
    ap.add_argument("--quiet", action="store_true", help="one-line summary only (for comparing tunings)")
    a = ap.parse_args()
    cfg = parse_config(os.path.join(ROOT, "games", a.slug, "server", "config.luau"))
    for kv in a.set:
        k, v = kv.split("="); v = float(v)
        if "." in k:
            up, field = k.split("."); cfg["upgrades"][up][field] = int(v) if field == "maxLevel" else v
        else:
            cfg[k] = v
    total_cost = sum(cost(d, L) for d in cfg["upgrades"].values() for L in range(1, d["maxLevel"]))

    if a.quiet:
        res = [run(cfg, a.session, a.days, random.Random(i)) for i in range(RUNS)]
        m = lambda k: statistics.median([r[k] for r in res if r[k] is not None]) if any(r[k] is not None for r in res) else None
        dm = m("day_all_max")
        print(f"| {' '.join(a.set) or 'AS CONFIGURED':<58} | {m('first_upgrade_s'):>5.0f}s | {('day %d' % dm) if dm else ('> %d d' % a.days):>8} | {100*m('offline_share'):>4.0f}% | {m('max_stall_sessions'):>3.0f} | {m('balance_end'):>11,.0f} |")
        return
    print(f"# Economy simulation — {a.slug} — {a.days} days × {a.session}s sessions × {RUNS} runs\n")
    print("## Ladder (engine formulas, real config)\n")
    print("| upgrade | max | cost L1→2 | cost to max | effect L1 → max |")
    print("|---|---|---|---|---|")
    for k, d in cfg["upgrades"].items():
        print(f"| {k} | {d['maxLevel']} | {cost(d,1)} | {sum(cost(d,L) for L in range(1,d['maxLevel']))} | {effect(d,1):g} → {effect(d,d['maxLevel']):g} |")
    print(f"\n**Total cost to max everything: {total_cost:,} coins.**\n")

    res = [run(cfg, a.session, a.days, random.Random(i)) for i in range(RUNS)]
    med = lambda k: statistics.median([r[k] for r in res if r[k] is not None]) if any(r[k] is not None for r in res) else None
    pct = lambda k, v: 100 * sum(1 for r in res if r[k] is not None and r[k] <= v) / RUNS
    fu = med("first_upgrade_s"); dm = med("day_all_max")
    print("## What the runs say (medians)\n")
    print("| measure | result | bar | verdict |")
    print("|---|---|---|---|")
    print(f"| Time to first upgrade | {fu:.0f}s | < 60s (doctrine §4.2, brief) | {'PASS' if fu and fu < 60 else 'FAIL'} |")
    dm_txt = f"day {dm:.0f}" if dm else f"> {a.days} days"
    print(f"| Everything maxed by | {dm_txt} ({pct('day_all_max', 7):.0f}% of runs by D7) | after D7, ideally D14+ | {'FAIL — meta loop exhausted before the retention window' if dm and dm <= 7 else 'OK'} |")
    os_ = med("offline_share")
    print(f"| Offline share of all coins | {100*os_:.0f}% | 20–50% (bedtime-proof, but playing still matters) | {'FAIL — playing is pointless' if os_ > 0.6 else ('LOW — return hook is weak' if os_ < 0.15 else 'OK')} |")
    ms = med("max_stall_sessions")
    print(f"| Longest stretch with nothing to buy | {ms:.0f} sessions | ≤ 2 | {'FAIL — a wall' if ms > 2 else 'OK'} |")
    i0 = med("income_day1"); i1 = med("income_end")
    print(f"| Income/min, day 1 → day {a.days} | {i0:.0f} → {i1:.0f} coins/min ({i1/max(1,i0):.1f}×) | 5–20× over a month | {'FAIL — flat' if i1/max(1,i0) < 3 else ('WATCH — steep' if i1/max(1,i0) > 40 else 'OK')} |")
    be = med("balance_end")
    print(f"| Unspent balance at day {a.days} | {be:,.0f} coins | small vs total ladder ({total_cost:,}) | {'FAIL — inflation, nothing to spend on' if be > total_cost else 'OK'} |")
    print("\n## Assumptions not in config\n")
    print(f"- Bank trip costs {BANK_TRIP_S:.0f}s; collection fraction 0.5 + 0.04 × added magnet radius (±12% per session); session length ±30%; one session a day, every day (no churn — this measures content depth, not retention).")
    print("- Greedy buyer: always buys the affordable upgrade with the best income gain per coin. Real kids buy the shiny one. That makes the sim slightly optimistic about progression speed.")

if __name__ == "__main__":
    main()

> Governed by `docs/ROBLOX_SUCCESS_LOGIC.md` (standing orders).
> Doctrine check: this is the first session, the first earn→spend→progress cycle, stability, and the one daily reason to return. It is the slice itself, so every module below touches all four.

# Spec — Fat Man Gets Rich, playable slice (Gate A candidate)

**Deviation from `specs/TEMPLATE.md`, declared before coding:** one consolidated spec for the slice instead of ten per-module specs. Ten specs before any playtest is the "feature-complete before players" anti-pattern (doctrine §3). Per-module specs get written when a module is extracted and frozen into the engine (`docs/GAME_FACTORY.md` §5 step 4).

**Brief:** `games/fat-man-gets-rich/brief.md`. **Factory split:** `docs/GAME_FACTORY.md` §1.

---

## 0. The loop this slice must deliver

> A stranger, alone, completes **collect → spend → visibly progress**, and sees the coin flood inside 60 seconds.

```
stand on PAYOUT PAD  →  coin flood erupts  →  sweep coins into carry
        ↑                                              ↓
   upgrade is visible ← buy upgrade ← COINS ← stand on BANK PAD
```

Carry is capped, so the bag fills on the first flood and *teaches the bank* without a tutorial. Banking is the sell beat. Upgrades make the next flood visibly bigger — progression is physical, not a number in a corner.

**Return hook (exactly one, per doctrine §4.5):** offline earnings, capped at 8h, no decay, no panic timer.

## 1. Answers to the brief's open questions

The brief says "answer at Gate A, not before." Read as: *decided by watching a playtest, not by argument.* Blocking the build on them would stall the session, so each is a **config switch with a stated default**, cheap to flip at Gate A.

| Open question | Default shipped | Why | Flip cost |
|---|---|---|---|
| Flood from event, spawn, or player action? | **Player action** — stand on the pad, 4s recharge | A stranger must trigger it inside 60s without being told; a timed event can't guarantee that, a rare spawn definitely can't | `config.flood.cooldown` + zone kind |
| Coin pile public or private? | **Public world objects** — real parts everyone sees, HUD mirrors the count | The flood *is* the clip; a HUD-only number cannot be filmed | already world-side |
| What is the first purchase? | **No Robux purchase in this slice.** First *soft* purchase is Carry Capacity at 50 coins (~2 floods, ~30s) | Creating any paid product is Gate 5, human-only. `sku.luau` drafts the ladder unwired | — |

## 2. Module map

Engine (`src/core/` → `ServerScriptService.Core`) — generic, no title-specific content:

| Module | Owns | Does not own |
|---|---|---|
| `Signal` | pure-Lua signal (table payloads survive, unlike BindableEvent) | anything else |
| `DataService` | DataStore, session lock, schema version + migration, autosave, retry/backoff, Studio memory fallback | what is *in* a profile beyond the default shape |
| `RemoteGuard` | remote registry, arg validation, per-player token-bucket rate limit, fail-closed | business logic |
| `EconomyService` | coins + carry balances, earn/spend, cap enforcement | prices, upgrade curves |
| `ProgressionService` | upgrade levels, cost curve, effect curve — all from pack config | what the upgrades *do* |
| `PickupService` | spawning a burst of physics pickups, server-side proximity collection, collision groups, lifetime despawn, global cap | why a burst happened |
| `ZoneService` | server-side proximity zones → enter/leave callbacks | zone meaning |
| `RewardService` | offline accrual, capped, granted server-side on load | the rate (pack config) |
| `AnalyticsService` | funnel timers join→flood→collect→bank→upgrade | dashboards |
| `ContentLoader` | read + validate the pack, build the grey-box world | game rules |
| `LoopService` | binds zone kinds to loop verbs (payout/bank/shop) | tuning numbers |
| `StateSync` | pushes authoritative state to clients, debounced | deciding state |

Pack (`games/fat-man-gets-rich/`) — the only per-title work:
`server/config.luau` (tuning) · `server/world.luau` (grey-box layout) · `server/sku.luau` (**draft, unwired**) · `shared/theme.luau` (names, colors, copy)

**Naming rule:** engine modules PascalCase (`skills/rojo-map.md`); pack files lowercase (`docs/GAME_FACTORY.md` §1 names them `config.luau` / `theme.luau`).

## 3. Public API (load-bearing only)

```
DataService.get(player) -> profile?          DataService.profileLoaded: Signal(player, profile)
DataService.update(player, fn)               DataService.save(player, release)
RemoteGuard.bind(name, opts, handler)        RemoteGuard.fire(player, name, ...)
EconomyService.addCarry(player, value) -> accepted    EconomyService.bank(player) -> banked
EconomyService.trySpend(player, n, reason) -> ok      EconomyService.changed: Signal(player)
ProgressionService.effect(player, id) -> number       ProgressionService.buy(player, id) -> ok, err
ProgressionService.catalogFor(player) -> {rows}       PickupService.burst(cframe, spec)
ZoneService.create(part, {onEnter, onLeave})          RewardService.grantOffline(player, profile)
```

## 4. DataStore keys + schema

Store `PlayerProfiles_v1`, key `p_<userId>`. Schema v1:

```
{ schemaVersion=1, coins=0, carry=0, upgrades={carryCap=1, floodSize=1, magnet=1, coinValue=1},
  stats={floods=0, banks=0, collected=0}, firstJoin=<epoch>, lastSeen=<epoch>,
  lock={jobId=<string>, t=<epoch>} }
```

`MIGRATIONS[n]` maps v_n → v_n+1; unknown-version records are refused, never silently overwritten. Session lock is refreshed on autosave and cleared on release; a lock older than `LOCK_TIMEOUT` (90s) is dead and may be taken.

## 5. Threat model — what the client must never be able to do

The slice exposes **exactly one** client→server remote: `C2S_Buy(upgradeId)`.

- Coins, carry, upgrade levels, and coin values exist only on the server. The client is told; it never tells.
- Collection is a **server-side proximity check** on server-owned parts (`SetNetworkOwner(nil)`). There is no "I touched a coin" message to forge — the trust surface is the player's replicated position, not a currency claim.
- Flood and bank are **server-detected zone entries**, not remotes. Nothing to spam.
- `C2S_Buy` validates: id ∈ catalog · level < max · coins ≥ cost · rate-limited 6/10s · fails closed and silent.
- Prices are never sent from the client; the catalog is pushed server→client for display only.
- Offline earnings are computed and granted server-side on profile load. The client receives a number to render after the grant.

## 6. Acceptance tests (checked at playtest, not asserted in prose)

1. Join a fresh profile → payout pad reachable and legible; flood triggered within 60s of spawn.
2. One flood visibly fills the carry bar; carry cap blocks further collection and toasts the reason.
3. Bank pad converts carry → coins, carry returns to 0, toast shows the amount.
4. Carry Capacity purchasable at 50 coins within the first session; the bar visibly grows.
5. Flood Size purchase makes the *next* flood visibly larger — progression readable without reading a number.
6. Rejoin → offline earnings panel shows a capped, non-zero amount after a wait; never negative, never decayed.
7. Console clean of errors across a full cycle.
8. Killing the server mid-session and rejoining does not lose banked coins.
9. A forged `C2S_Buy` with a junk id, a maxed id, or an unaffordable id changes nothing.

## 7. Out of scope (deliberate, with reasons)

| Deferred | Why |
|---|---|
| `ReceiptService` / `ProcessReceipt` | No Robux product exists and none may be created without Gate 5. An untested receipt path written now is the anti-pattern, not diligence. First engine module after a product is approved. |
| Robux SKUs | Gate 5 is a human click. `sku.luau` is a draft ladder, not wired to MarketplaceService. |
| Art, audio, icon, thumbnail | Gate 4 / doctrine §6. Grey-box reads the hook or the hook is wrong. |
| Second area, more coin tiers, cosmetics | Doctrine §3 "does not count" list. World one has not retained anyone yet. |
| Tuned economy | These are first-pass numbers for a playtest, not a G2-approved ladder. |
| Any marketing | Gate A is not passed. Doctrine §10 rule 2. |
| Durable earn/spend ledger | In-memory ring + analytics events for now; durable ledger lands with `ReceiptService`. |

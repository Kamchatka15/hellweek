# Style spec — Fat Man Gets Rich — copied from the top three, built from the Creator Store — 2026-09-12

> Doctrine §3.1. Style is copyable; assets are inserted from the Creator Store by ID (legal by construction) or generated in this style. **Nothing here is inserted yet** — G4 is Justin's approval of art direction; this is the shelf he cuts from. Asset IDs were found through Studio MCP `search_asset` on 2026-09-12 (free, Creator Store scope) and must be inserted through the content pack (`world.luau`), never pasted into the live place.

## The look, in five lines (blended from the three teardowns)

1. **Low-poly, single-colour objects** — every thing is one saturated colour so it reads at 200px (Grow a Garden, Mine a Mountain).
2. **Gold on dark ground** — coins are the brightest thing on screen, always. Ground is desaturated slate; the flood is the light source (our own grey-box finding, kept).
3. **One big readable meter** — bag fill, top-centre, oversized (Bee Swarm).
4. **A home silhouette** — the bank is a *building* you walk toward, not a pad (Bee Swarm hive, Mine a Mountain lobby).
5. **Cheerful, zero threat.** No darkness, no timers that punish. The only countdown counts *toward* something good (the golden flood).

**Thumbnail formula** (all three agree): one face, one giant version of the collectable, ≤3 words, an emoji in the title.

## Creator Store shelf — free, found 2026-09-12 (insert via the pack, not by hand)

| Need | Candidate asset | ID | Notes |
|---|---|---|---|
| The coin itself | Low-Poly Gold Coin (lenjaigor) | `11711422429` | Clean single mesh; test at 0.25×1.4×1.4 vs our neon part |
| The coin (alt) | Collectable Low-Poly Gold Coin | `5148690467` | Named "collectable" — may include a script; strip it |
| The coin (alt) | Low Poly Gold Coin (V3ng3r_2024) | `136348700341066` | Newer upload |
| Banked-coin pile (system #3) | Low-poly Gold Pile Coins Cash Money Props | `91885327699615` | Made in Studio, generic tags, good fit for the visible pile |
| Banked-coin pile (alt) | Low-Poly Gold Pile Medium Loot Treasure | `134056550786849` | Medium size — the mid tier of the pile |
| The bank building | Vault (onyok888) | `1524598331` | Silhouette candidate; recolour to the palette |
| The bank (alt) | Vault Door [FREE] | `17023877` | Door only — pair with a grey-box building |
| Coin collect chime | Coin Collecting Sound (HiyomaOfficial) | `116120982042508` | Generic |
| Coin collect chime (alt) | Coin Collect Sound Effect (b1ruh1) | `105872195812251` | Generic |
| Multi-coin sweep | multiple coin collect sound effect | `5437842453` | Description references another game ("mm2") — **verify it is original before use; skip if not** |

**Skipped on purpose:** "M64 Red Coin Collect Sound" and "Jetpack_Joyride_powerup_collect" — named after other games' audio. That is exactly the asset that gets a title flagged. Free does not mean ours.

**Not found in one search, next searches to run:** `low poly duffel bag` (the bag meter icon), `cartoon plaza fountain` (a landmark for the map), `stylized wooden sign` (upgrade shop), `low poly dump truck` (the top bag tier, if the named ladder lands).

## Generate in this style (when G4 opens)
- Cube 3D / Assistant prompt seed: *"low-poly, single flat colour, chunky, cheerful, no texture detail, cartoon proportions"*.
- Ideogram thumbnail prompt seed: *"one round cheerful cartoon man knee-deep in a cascade of oversized gold coins, low-poly, bright, three words of chunky text"* — no likeness of anyone.

---

## Shelf expansion — 2026-09-12 (dress the slice now, for metrics)

All free, Creator Store, found via `search_asset`. Insert through `world.luau` (models) and `theme.luau` (audio ids), never by hand into the live place. **Blocked until the place is published unlisted with API access** — `InsertService:LoadAsset` behaves like DataStores.

### Environment (make the plaza read as a place, not a grey box)
| Need | Asset | ID |
|---|---|---|
| Fountain landmark (map centre) | ⛲ Low Poly Fountain RP Decor Park Plaza | `111780507079923` |
| Fountain (alt) | Water Fountain Park Garden Plaza Low Poly | `106734587943012` |
| Tree pack | Low Poly Tree - Cartoon Pack Forest Nature | `106015195336756` |
| Tree pack (alt) | 🌳 Low Poly Cartoon Tree Bush Forest Pack | `102586503302985` |
| Bench + lamp (edge dressing) | Lamp & Bench | `18907927816` |
| Shop stall (the UPGRADES zone) | Market Stand (WoodReviewer) | `388036950` |

### Audio (see skills/audio-sourcing.md)
| Need | Asset | ID |
|---|---|---|
| Coin chime | Coin Collecting Sound / Coin Collect SFX | `116120982042508` / `105872195812251` |
| Bank cha-ching | cash-register-sound-fx / Cha Ching HD | `120891770644830` / `101396758527961` |
| Theme / shop loop | Shop Theme / Main Theme / Retro Radiance | `80923297953231` / `125536723574585` / `100333487341753` |

### Verify-before-use (names hint at other IP — audition, keep only if generic)
- `5437842453` "multiple coin collect ... mm2" — references Murder Mystery 2. Skip unless clearly original.
- Any "Hangout Spawn" model with a tag-wall naming Grow a Garden / Steal a Brainrot / Brookhaven — those are tag-spam re-uploads; skip.

### Skipped (named after other games' assets — the flaggable kind)
`106323564379687` M64 Red Coin · `105416725635496` Jetpack Joyride powerup.

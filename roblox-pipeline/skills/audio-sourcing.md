# Skill: where game audio comes from (music, theme, SFX)

> **Governed by `docs/ROBLOX_SUCCESS_LOGIC.md` (standing orders).** If this file fights that file, that file wins.
> Amended into the art pipeline 2026-09-12 on Justin's question "where is the best place to get music."

## The order, and why

| Rank | Source | Use for | Cost / risk | Speed |
|---|---|---|---|---|
| 1 | **Roblox Creator Store audio** (in Studio, insert by ID) | theme beds, shop/menu loops, coin chimes, bank "cha-ching", UI blips | free · **zero licensing risk** (Roblox cleared it) · no upload, no moderation wait | fastest — this is the default |
| 2 | **Studio-generated SFX / code chiptune** | coin pings, whooshes, one-shots | free | fast |
| 3 | **ElevenLabs SFX** (~$6/mo, commercial license) | a specific SFX the Store lacks | small $ · upload + moderation once | medium |
| 4 | **Suno / Udio** (PAID tier only) | an original background loop the Store can't match | AI-music copyright is **unsettled** — fine for a throwaway loop, risky for a signature theme; needs the paid commercial tier | medium |
| 5 | **Royalty-free libraries** — Pixabay Music, Incompetech (CC-BY, attribution), YouTube Audio Library | fallback beds | free · **you** must hold upload rights · Roblox moderation | slow |
| 6 | Epidemic Sound / Artlist (subscription) | later, when a track is a real differentiator | $ · **verify game re-upload is permitted** before relying on one | slow |

## Rules
- **Phase 1 (chasing first metrics): Creator Store only.** No upload step, no risk, and quality is fine for a slice. Save Suno for when a theme is a differentiator, not a placeholder.
- Uploaded audio is **private by default** — usable in our own experiences, which is all we need. Caps: 7 min / 20 MB / ~48 kHz; 100 uploads per 30 days (2,000 if ID-verified).
- **Free is not clear.** A Creator Store result named after another game's sound (a console coin jingle, a mobile-game pickup) is a re-upload of someone else's audio; moderation fingerprints audio and pulls it. Skip anything named after a known game/song. Prefer generic titles and verified creators.
- Never upload a track you do not have the right to upload, however "royalty-free" the page says.

## The slice's audio shelf (free Creator Store, found 2026-09-12 via search_asset)
Wired through the pack, never pasted into the live place. IDs in `research/2026-09-12-style-spec-fat-man.md`.
- Coin collect chime: `116120982042508`, `105872195812251`
- Bank / sell "cha-ching": `120891770644830` (cash-register-sound-fx), `101396758527961` (Cha Ching HD)
- Shop / theme loops: `80923297953231` (Shop Theme), `125536723574585` (Main Theme), `100333487341753` (Retro Radiance) — audition in Studio, keep one
- **Skipped on purpose:** "M64 Red Coin", "Jetpack_Joyride_powerup_collect" — named after other games' audio.

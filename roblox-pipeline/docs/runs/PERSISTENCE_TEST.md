# Persistence test — acceptance test 8, ready to run

> Governed by `docs/ROBLOX_SUCCESS_LOGIC.md`. Data loss is the #1 Gate A killer (§5). This has **never been run**, because Studio cannot reach DataStores until the place is published (run 01 §3.3). `DataService` falls back to memory with a loud warning; everything it protects is unexercised.

## Why it needs Justin's click

Publishing — even unlisted, even to an empty audience — is a publish action. The doctrine makes every publish a human click and silence is not approval. So Claude does not do it. Everything below the click is Claude's.

## The clicks (about two minutes, in Studio)

1. Open the place in Studio. **File → Publish to Roblox.** Name it anything; it is not the launch name.
2. Leave it **Private** (unlisted). Do not tick "public". This is Gate A territory, not Gate B.
3. **Game Settings → Security → Enable Studio Access to API Services → ON.** Without this, Studio still cannot reach DataStores even after publishing. This is the step everyone forgets.
4. Say "published" in the session. That is the whole job.

## The test (Claude runs it over Studio MCP; ~5 minutes)

| # | Step | Pass |
|---|---|---|
| 1 | Start play. Confirm the console shows `DataService` using the **real** DataStore, not the memory fallback | No fallback warning |
| 2 | Collect and bank until the balance is a distinct number (e.g. 137). Buy one upgrade | Balance and upgrade visible on the HUD |
| 3 | Wait for autosave, or trigger a save through the engine's own path | A save is recorded |
| 4 | **Stop play. Start play again** (new server, same test account) | Balance = 137 minus the upgrade; upgrade level preserved; offline credit granted once and only once |
| 5 | Stop mid-session **without** a clean leave (simulate a crash: stop play immediately after a bank) | On rejoin, the last banked amount is present — nothing rolled back past the last successful write |
| 6 | Join twice quickly (session-lock probe) | Second join does not clobber the first; one writer, loud warning on the second |
| 7 | Bump the schema version in `DataService` by one and rejoin | Migration runs once; profile still loads; no data lost |

Any red row is a **stop-and-patch** before Gate A — not a note, a blocker.

## What gets filed

One evidence record either way (`domain: tech`, `scale: pre-launch`). A clean pass at n=1 is the first time R4 has protected a path that actually ran.

# Grok + Claude handoff: monetizable Roblox pipeline

Use this as a project brief for Claude Code / a Claude Project. Claude owns most Luau, architecture, and Studio-side coding. Grok (chat), Grok Build (local coding agent), and Grok Bots (cloud computer agents) take research, market intelligence, image/UI concepting, parallel code slices, scheduled live-ops, and human-in-the-loop publishing.

This is a division of labor, not a claim that any model can autonomously ship a hit game.

---

## 1. What each Grok product actually is

### A. Grok (this chat / grok.com / API)

Best at:

- Live web + X research (trending genres, competitor CCU, creator discourse, policy changes)
- Product design: loops, economy, onboarding, thumbnails, store merchandising
- Specs, GDD sections, CLAUDE.md / AGENTS.md, evaluation rubrics
- Image generation and image editing (icons, thumbnails, UI mockups, texture concepts)
- Writing prompts, skill files, MCP configs, and agent playbooks for Claude
- Multi-agent research via `grok-4.20-multi-agent` on the API
- GitHub-connected work if the user authorizes the GitHub connector
- Scheduled jobs via Grok Automations (describe a job once; run daily/weekly or on email)

Limits in this chat:

- Cannot attach to the user’s local Roblox Studio MCP session
- Cannot click Creator Hub or Studio for them
- Cannot publish places, create game passes, or upload assets to their account
- Sandbox file work here is not their machine; deliver files they download or commit

### B. Grok Build (`grok` CLI / TUI + `grok-build-0.1` API)

xAI’s agentic coding harness (open-source runtime). Same class of tool as Claude Code.

Best at:

- Editing a Rojo repo on disk: `.luau`, `default.project.json`, tests, CI
- Plan mode → approved diffs before writes
- Up to ~8 parallel subagents in isolated git worktrees
- MCP clients: can connect to **official Roblox Studio MCP** the same way Claude Code does
- Skills, hooks, plugins, AGENTS.md, `/skillify` to capture a session as a reusable skill
- Headless mode for scripts/CI
- ACP so an IDE can host it
- Fast/cheap coding model (`grok-build-0.1`, public beta API): agentic coding, debugging, MCP; ~100+ tok/s; $1/M in, $2/M out

Use Grok Build when:

- Work is file-system + git shaped (Rojo source of truth)
- You want a second agent reviewing Claude’s diffs
- You want parallel slices (UI module + datastore module + monetization module) without colliding
- You want a cheaper/faster worker for mechanical refactors while Claude does architecture

Do not expect Grok Build to replace Claude for the hardest Luau systems. Treat it as a specialist coworker in the same repo.

### C. Grok Bots (early beta, cloud VM teammates)

Each named Bot has a persistent cloud computer (browser, filesystem, terminal). They sign into real apps, finish multi-step jobs, and only ping a human for approval. Multiple Bots can message each other. Teach-a-task → reusable skill → routine (schedule or event).

Best at work that is **not** “edit this ModuleScript”:

- Creator Hub analytics scrape-by-hand (with user logged in)
- Competitor playthrough notes from public game pages
- Weekly genre / CCU / thumbnail research packets
- Drafting DevForum posts, group shouts, update changelogs
- Watching YouTube / X for clone waves and feature theft
- Filling Open Cloud key setup checklists (human pastes secrets)
- Operating sites that have no MCP

Access is gated (historically SuperGrok Heavy / Cursor Ultra-class). Confirm current entitlement before promising Bots in a pipeline.

### D. Grok Automations (grok.com/automations)

Not a coding agent. Recurring Grok jobs: schedule or email trigger, optional connectors. Good for:

- Daily “top 50 games in our genre + what changed”
- Weekly monetization KPI digest from pasted Creator Hub exports
- Alerting when Roblox policy / DevEx / Creator Rewards docs change

---

## 2. Recommended stack (Claude-primary)

```
You (product owner)
    │
    ├─ Claude Project + Claude Code     ← primary engineer
    │     MCP: official Roblox Studio MCP
    │     Disk: Rojo repo (source of truth)
    │
    ├─ Grok chat / Automations          ← research, design, images, briefs
    │
    ├─ Grok Build (optional coworker)   ← parallel repo work, review, CI
    │     same Rojo repo + same Studio MCP if Studio is open
    │
    └─ Grok Bots (optional ops)         ← Creator Hub, scheduled research,
                                          live-ops drafts, computer-use tasks
```

Two layers of Studio connection:

| Layer | Tool | What it is good for |
|---|---|---|
| **Source of truth** | Rojo (`rojo serve` + plugin) | Git, PRs, Claude/Grok Build editing `.luau` on disk, CI `rojo build` |
| **Live Studio brain** | Official Studio MCP | Read DataModel, write scripts in-session, generate mesh/material, insert assets, playtest, screenshot, simulate input |
| **Cloud / publish** | Open Cloud API (+ optional Open Cloud MCP) | Asset upload, place publish, game passes / developer products, DataStores, messaging |

Official Studio MCP is built into Studio (Assistant → Manage MCP Servers → Enable Studio as MCP server). Roblox’s older standalone rust server is no longer the recommended path.

Claude Code is on Roblox’s official quick-connect list. Grok Build speaks MCP, so it can use the same server if configured in its MCP settings.

---

## 3. Official Roblox Studio MCP — what agents can actually do

Documented tools (Roblox Creator Hub, Studio MCP):

**Scripts:** `script_read`, `multi_edit`, `script_search`, `script_grep`

**Assets / gen:** `generate_mesh`, `generate_material`, `generate_procedural_model`, `wait_job_finished`, `search_asset`, `insert_asset`, `upload_image` (from HTTP URL), `store_image` (local image → URI for other tools)

**Explore:** `search_game_tree`, `inspect_instance`, `subagent` (`explore` / `playtest`)

**Runtime:** `execute_luau` (Edit / Client / Server), `get_studio_state`, `start_stop_play`, `get_console_output`, `screen_capture`

**Input:** `character_navigation`, `user_keyboard_input`, `user_mouse_input`

**Docs:** `http_get` (allowed Roblox docs only), `skill`

**Session:** `list_roblox_studios`

Implications for the pipeline:

- Claude or Grok Build can generate a thumbnail/UI image elsewhere, host or pass a URL, then `upload_image` into the place.
- Agents can playtest and screenshot; that is the automated QA loop.
- Studio MCP is local and requires an open Studio session. No cloud agent can drive Studio unless Studio is running on a machine that agent can reach (Grok Bot cloud VM is not the user’s Studio box unless you install Studio there, which is usually the wrong idea).

---

## 4. How Grok specifically assists Claude (give this list to Claude)

### 4.1 Research and “scraping good games” (legal version)

Do **not** scrape private endpoints, copy places, rip assets, or automate ToS-violating harvests. Do this instead:

Grok chat / multi-agent research:

- Genre maps: simulators, tycoons, RPG, lobby+match, social hangout, etc. — CCU, session length, like ratio, update cadence
- Feature inventories of public pages: description, thumbnails, game pass names/prices visible on the storefront, badges, social links
- DevForum + X discourse: what players complain about, what creators copy this week
- Official docs watch: Creator Rewards, DevEx rate, Wallet, ads, policy
- Thumbnail / icon pattern language (colors, character pose, 3-word promise)

Grok Automations:

- Daily or weekday brief: “games matching keywords X with rising CCU; new passes; policy diffs”

Grok Bots:

- Logged-in Creator Hub competitor notes the user already has access to
- Structured playtest notes (human plays or Bot browses public pages; Bot does not pirate the place file)

Deliverable to Claude: a `research/` folder:

- `genre-brief.md`
- `competitor-matrix.csv` (name, universe id, CCU snapshot, visits, like ratio, monetization visible, loop hypothesis, steal-nothing / inspire-from)
- `positioning.md` (one sentence promise, tourist vs local loop, first-session hook)

### 4.2 Game design that is actually monetizable

Grok should write, Claude should implement:

- Core loop on a one-page diagram (action → reward → upgrade → new action)
- First 3 / 10 / 30 minutes
- Tourist loop (session snack) vs local loop (retention + spend)
- Economy: sinks/sources, first purchase under ~50–100 Robux, repeatable developer products, status cosmetics for whales
- Live-ops calendar (weekly theme, not random dump)
- KPI contract before code: D1/D7, session length band (19+ min is the “hit” band in recent benchmark reporting), 7-day spend days / Robux spent (these feed discovery), PCR, ARPDAU
- Anti-patterns Roblox players punish: paywalls that kill fun, appointment timers that feel mobile-gacha, loot boxes without transparency

Honest constraint: most experiences earn $0. Genre + retention + update cadence + merchandising beat “AI wrote a lot of Luau.”

### 4.3 Specs Claude can execute without asking

Grok output format that reduces Claude burden:

```
## Module: EconomyService
Path: src/server/EconomyService/init.luau
Owns: currency grant, product receipt, idempotent ProcessReceipt
Does not own: UI
Public API: ...
DataStore keys: ...
Threat model: client cannot grant currency
Acceptance tests: ...
Out of scope: ...
```

Plus `CLAUDE.md` / `AGENTS.md` conventions: Rojo map, naming, server authority, no client-trusted prices.

### 4.4 Images, UI, textures (Grok Imagine + Studio MCP)

Grok chat can generate:

- Thumbnail concepts (1024-class marketing art; then resize to Roblox thumbnail specs)
- Game icon
- Loading screen
- Shop card art, currency icons, button 9-slices
- Albedo-style texture concepts (then convert to Roblox-legal formats)

Studio MCP can then:

- `store_image` / `upload_image`
- `generate_material`, `generate_mesh`, `generate_procedural_model` from text or reference image
- Built-in Studio Texture Generator (prompt + optional style image) for meshes

Recommended image pipeline:

1. Grok: 4–8 thumbnail variants + a style lock (palette, character silhouette, one verb)
2. Human picks 1–2
3. Claude or Grok Build: export PNG specs, write ImageLabel refs
4. Studio MCP: upload and wire
5. A/B later with Roblox ads / listing art, not with 40 random AI thumbs

Roblox texture rules to put in the skill file: png/jpg/tga/bmp; up to 4K but prefer 256–1024 for small props; PBR maps have specific channel formats.

Grok cannot guarantee moderation pass. No third-party IP, no photoreal minors, no confusingly similar clones of a top game’s mascot.

### 4.5 Code assistance without stealing Claude’s job

Grok Build (in the Rojo repo):

- Implement a module from Grok’s spec while Claude implements another
- Write TestEZ tests, Selene config, styLua
- Review Claude PRs for exploit holes (RemoteEvent trust, rate limits)
- Generate sourcemaps / fix Rojo project.json drift
- Headless: `rojo build` + lint on CI

Grok chat:

- Explain a cryptic Studio error dump Claude pasted
- Draft Luau snippets as **proposals**, not as the live place
- Translate “this competitor does X” into an original mechanic spec

Do not run two write-agents on the same Studio DataModel at once. Rojo disk + one MCP writer, or worktrees.

### 4.6 Playtest / QA agents

Studio MCP playtest subagent + screenshots + console:

- Claude or Grok Build starts play, navigates, clicks shop, checks receipt logs
- Capture viewport after onboarding; Grok vision-reviews “would a 10-year-old know what to tap”
- Checklist: first death, first currency, first offer, first 60 seconds of dopamine

Grok Bot cannot replace this unless Studio runs where the Bot can see it.

### 4.7 Publishing and commerce (human-gated)

Open Cloud (API key on Creator Hub → Credentials):

- Upload images/models
- Publish place versions (Saved vs Published)
- Create/list game passes and developer products
- DataStores, MessagingService, config flags

Community Open Cloud MCP servers exist (e.g. wrappers that expose `roblox_upload_asset`, product CRUD, publish). Treat them as optional. **Never** let an agent publish to live players or create paid products without an explicit human approval step.

Grok Bot role: walk through Creator Hub forms if Open Cloud does not cover a field; still pause for 2FA / publish.

### 4.8 Live-ops after launch (highest ROI automation)

This is where Grok reduces Claude load permanently:

| Cadence | Owner | Output |
|---|---|---|
| Daily | Automation or Bot | CCU / likes / comments themes; broken-server reports from group wall |
| 2–3x week | Grok design + Claude implement | Small content drop spec (1 theme, 1 product, 1 bugfix) |
| Weekly | Grok | Thumbnail refresh concepts; shop merchandising order |
| Monthly | Human + Grok | Economy audit (inflation, first-pack conversion, whale items) |

Roblox’s own guidance: weekly updates ideal, monthly minimum; theme each update; tourists vs locals; repeatable products monetize better than one-shot passes; first packs cheap; discovery now watches 7-day spend behavior.

### 4.9 Skills / agents you should actually create

Put these in the repo so both Claude Code and Grok Build auto-load them:

1. `roblox-security.md` — server authority, ProcessReceipt idempotency, BanAsync, no client prices
2. `roblox-economy.md` — product matrix, price bands, receipt handler contract
3. `rojo-map.md` — folder → service mapping
4. `studio-mcp.md` — when to use MCP vs when to only edit disk
5. `art-pipeline.md` — image sizes, naming, upload_image flow
6. `liveops.md` — update template
7. `research-legal.md` — public pages only; no place-file theft; no IP clones

Grok can draft all seven in one session. Claude maintains them.

Optional: install community `roblox-dev-skill` knowledge packs (Luau version-tracked) for both agents.

---

## 5. Concrete automation architecture

### Phase 0 — one-time setup (human + Claude)

1. `rojo init` (or roxlit) + git
2. Enable Studio MCP; `claude mcp add` official server
3. Optionally add same MCP to Grok Build config
4. Open Cloud API key with **least privilege**; store in secret manager, not chat
5. CLAUDE.md + AGENTS.md + the skill files above
6. Empty `research/`, `art/`, `liveops/` folders

### Phase 1 — decide what to build (Grok-heavy)

- Multi-agent research packet
- 3 concept pitches scored on: session length potential, spend loop, production cost, clone-risk, policy risk
- Human picks one
- Grok writes GDD + module specs
- Claude builds vertical slice (first 10 minutes + one paid product + analytics print)

### Phase 2 — build loop (Claude-primary)

```
Grok: spec / art / review
Claude Code + Rojo: implement
Studio MCP: playtest + screenshot
Grok: critique screenshot + economy
Human: ship checkpoint
```

Grok Build only if Claude is saturated or you want a reviewer worktree.

### Phase 3 — release (human-gated)

- Claude: `rojo build` + save
- Open Cloud: publish Saved version
- Human plays on production
- Human says publish
- Create passes/products
- Listing copy + thumbnail from Grok, uploaded via MCP or Hub

### Phase 4 — always-on (Automations + Bots)

- Scheduled research and KPI digest
- Grok drafts next update; Claude implements; human publishes
- Never auto-publish

---

## 6. What Grok cannot (or should not) do

- Guarantee revenue. Hits correlate with retention + live-ops + merchandising, not with lines of generated Luau.
- Drive the user’s Studio from grok.com chat.
- Safely scrape Roblox at scale against ToS or copy other games’ source/assets.
- Bypass asset moderation.
- Hold API keys in prompts.
- Be the only engineer. Roblox security and replication bugs are expensive.
- Replace playtesting with real players.

---

## 7. Prompt block to paste into a Claude Project

```
You are the primary engineer on a Rojo-managed Roblox experience.

Grok (xAI) is a coworker, not a replacement:
- Grok chat: market research, GDD, economy design, thumbnails/UI concepts,
  CLAUDE.md/skills, PR critique, live-ops copy.
- Grok Build: optional second coding agent on this same repo; isolated
  worktrees; may also use Studio MCP if Studio is open. Do not both write
  the live DataModel at once.
- Grok Bots / Automations: scheduled research and Creator Hub busywork.
  They must not publish or create paid products without the human.

Source of truth is the Rojo filesystem. Studio MCP is for inspect,
playtest, screenshots, asset gen/upload, and surgical in-place edits.
Open Cloud is for publish and catalog, always human-gated.

Never trust the client. ProcessReceipt must be idempotent. Do not clone
competitor IP. Prefer original loops inspired by public market data.

When Grok drops a spec in /research or /specs, implement it as written
or list concrete deviations before coding.
```

---

## 8. First week checklist

- [ ] Rojo repo + git + CLAUDE.md
- [ ] Official Studio MCP connected to Claude Code
- [ ] Grok produces genre brief + 3 pitches
- [ ] Human locks pitch and monetization matrix
- [ ] Grok produces thumbnail set + style lock
- [ ] Claude ships 10-minute slice + 1 developer product + receipt handler
- [ ] Playtest via MCP screenshots; Grok reviews UX
- [ ] Decide whether Grok Build is worth adding (only if parallel work exists)
- [ ] Schedule a Grok Automation: weekly competitor + policy digest
- [ ] Explicit publish protocol: Saved vs Published, human only

---

## Sources to keep current

- Roblox Studio MCP: https://create.roblox.com/docs/studio/mcp
- Monetization docs: https://create.roblox.com/docs/production/monetization
- Open Cloud: https://create.roblox.com/docs/cloud
- Rojo: https://github.com/rojo-rbx/rojo
- Grok Build: https://github.com/xai-org/grok-build and https://x.ai/build
- Grok Build 0.1 API: https://x.ai/news/grok-build-0-1
- Grok Bot: https://x.ai/news/introducing-grok-bot
- Grok Automations: https://x.ai/news/grok-automations

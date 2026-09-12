# Skill: Studio MCP usage

> **Governed by `docs/ROBLOX_SUCCESS_LOGIC.md` (standing orders).** If this file fights that file, that file wins.

- Enable: Studio → Assistant → ⋯ → Manage MCP Servers → "Enable Studio as MCP server". macOS binary: /Applications/RobloxStudio.app/Contents/MacOS/StudioMCP (wire into Claude Desktop config / Claude Code).
- Use MCP for: DataModel inspect, playtest start/stop, screenshots, console output, simulated input, mesh/material/procedural generation, Creator Store search+insert, image store/upload, surgical in-place script fixes.
- Do NOT use MCP as the home of code — code lives in the Rojo repo. After any surgical MCP edit, mirror it to disk same session.
- One writer at a time on the live DataModel.
- Standard playtest QA script per build: start play → spawn clean → first reward reached <60s → open shop → test-mode purchase → receipt ledger verified → console error-free → screenshots at 0/1/3/10 min → review: "would a 9-year-old know what to tap?"


## Getting code into Studio unattended (run 01 finding)

The Rojo plugin's **Connect** button is editor UI. Studio MCP's `user_mouse_input` only reaches **play mode**, so Claude cannot press it, and the documented "edit on disk → `rojo serve` → plugin syncs" loop needs a human click every time.

`tools/studio_sync.py` closes that gap for playtests: it serves the Rojo tree flattened as JSON and one `execute_luau` call rebuilds it in the DataModel — no human step. It is a **test harness, not a Rojo replacement**: disk stays the source of truth and `rojo build` is still the check. Use it for automated playtest loops; use the plugin for the real edit session.

## Never verify runtime state by requiring an engine module over MCP (run 01 finding)

`execute_luau` has its **own** `require` cache. `require(Core.DataService)` from an MCP call returns a fresh module instance, not the running one — it will report empty state and look like a data bug that does not exist. **Observe the DataModel instead**: the HUD, Workspace, the console, leaderstats. If you require the module, you are measuring a second, empty universe.

## `screen_capture` is edit-time only (run 01 finding)

It returns a black frame during play. To photograph a play-mode state, stage it in Edit (anchored parts) and tear it down, or accept that Gate A still needs a human to look at the screen.

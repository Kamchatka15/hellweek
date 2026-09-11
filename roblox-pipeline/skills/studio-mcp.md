# Skill: Studio MCP usage

> **Governed by `docs/ROBLOX_SUCCESS_LOGIC.md` (standing orders).** If this file fights that file, that file wins.

- Enable: Studio → Assistant → ⋯ → Manage MCP Servers → "Enable Studio as MCP server". macOS binary: /Applications/RobloxStudio.app/Contents/MacOS/StudioMCP (wire into Claude Desktop config / Claude Code).
- Use MCP for: DataModel inspect, playtest start/stop, screenshots, console output, simulated input, mesh/material/procedural generation, Creator Store search+insert, image store/upload, surgical in-place script fixes.
- Do NOT use MCP as the home of code — code lives in the Rojo repo. After any surgical MCP edit, mirror it to disk same session.
- One writer at a time on the live DataModel.
- Standard playtest QA script per build: start play → spawn clean → first reward reached <60s → open shop → test-mode purchase → receipt ledger verified → console error-free → screenshots at 0/1/3/10 min → review: "would a 9-year-old know what to tap?"

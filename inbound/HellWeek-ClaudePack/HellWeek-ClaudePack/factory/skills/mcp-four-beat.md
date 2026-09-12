# Skill: mcp-four-beat

Trigger: "test the game", end of every build session, before anyone says done.

Via Studio MCP, on a place that is published unlisted with API access on:

1. Join — screenshot spawn, console clean, player can move.
2. First earn — a number goes up within 60s. Screenshot the meter.
3. First spend / bank — server-side sink. Client cannot edit currency (R1).
4. First upgrade + persist — stop play, start play, upgrade and currency survived.

Write `docs/runs/YYYY-MM-DD-<slug>-mcp.md` with commands, console, four screenshots, pass/fail per beat, and the one thing a kid would still not understand.

Any red beat = not built. Patch in the same session and re-run.

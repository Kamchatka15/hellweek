# Skill: Rojo repo conventions

> **Governed by `docs/ROBLOX_SUCCESS_LOGIC.md` (standing orders).** If this file fights that file, that file wins.

- Map: src/server → ServerScriptService.Server; src/shared → ReplicatedStorage.Shared; src/client → StarterPlayerScripts.Client (see default.project.json).
- One module = one folder with init.luau; services are ModuleScripts required from a single server bootstrap.
- Naming: PascalCase modules, camelCase locals, SCREAMING_SNAKE constants. Shared types in src/shared/Types.
- Workflow: edit on disk → `rojo serve` + Studio plugin syncs → commit small, message says the player-visible change.
- CI/check: `rojo build -o build.rbxlx` must succeed + Selene + StyLua before merge.
- Studio-side-only artifacts (terrain, placed maps) live in the place file; scripts never do.

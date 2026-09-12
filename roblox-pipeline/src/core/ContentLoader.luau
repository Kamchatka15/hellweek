-- ContentLoader — reads the content pack, refuses a bad one, and builds the grey-box.
--
-- GAME_FACTORY §1: a new game adds files under `games/<slug>/` and changes nothing in
-- here. The pack is mounted at a fixed path (`ServerScriptService.Pack` /
-- `ReplicatedStorage.Pack`) so only `default.project.json` ever names the slug.
--
-- The world is built at run time from a data spec rather than placed by hand in Studio.
-- That means a fresh place file plus this repo is a playable game — no .rbxl to keep in
-- sync, and the layout is diffable like everything else.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ContentLoader = {}

local WORLD_FOLDER = "World"

local function fail(message: string): never
	error(`[ContentLoader] invalid content pack: {message}`, 0)
end

local function expect(condition: any, message: string)
	if not condition then
		fail(message)
	end
end

local function validate(config: any, world: any, theme: any)
	expect(typeof(config) == "table", "config.luau must return a table")
	expect(typeof(config.flood) == "table", "config.flood is required")
	expect(typeof(config.flood.cooldown) == "number", "config.flood.cooldown must be a number")
	expect(typeof(config.upgrades) == "table" and #config.upgrades > 0, "config.upgrades must be a non-empty array")
	for _, def in config.upgrades do
		expect(typeof(def.id) == "string", "every upgrade needs a string id")
		expect(typeof(def.maxLevel) == "number" and def.maxLevel >= 1, `upgrade {def.id} needs maxLevel >= 1`)
		expect(typeof(def.baseCost) == "number" and def.baseCost > 0, `upgrade {def.id} needs a positive baseCost`)
	end
	-- Roles are how the engine stays ignorant of this game's vocabulary: the pack says
	-- which of its upgrades fills each engine slot.
	expect(typeof(config.roles) == "table", "config.roles is required")
	local byId = {}
	for _, def in config.upgrades do
		byId[def.id] = true
	end
	for _, role in { "carryCap", "collectRadius", "burstCount", "pickupValue" } do
		local target = config.roles[role]
		expect(typeof(target) == "string", `config.roles.{role} must name an upgrade id`)
		expect(byId[target], `config.roles.{role} points at '{target}', which is not in config.upgrades`)
	end

	expect(typeof(config.offline) == "table", "config.offline is required (the return hook)")
	expect(config.offline.capSeconds and config.offline.capSeconds > 0, "config.offline.capSeconds must be positive")

	expect(typeof(world) == "table", "world.luau must return a table")
	expect(typeof(world.floor) == "table", "world.floor is required")
	expect(typeof(world.zones) == "table" and #world.zones > 0, "world.zones must be a non-empty array")
	local kinds = {}
	for _, zone in world.zones do
		expect(typeof(zone.id) == "string", "every zone needs a string id")
		kinds[zone.kind] = true
	end
	-- The loop does not close without both halves of earn -> spend.
	expect(kinds.payout, "world.zones needs at least one zone of kind 'payout'")
	expect(kinds.bank, "world.zones needs at least one zone of kind 'bank'")
	expect(typeof(world.spawn) == "table", "world.spawn is required")

	expect(typeof(theme) == "table", "theme.luau must return a table")
	expect(typeof(theme.currencyName) == "string", "theme.currencyName is required")
end

local function label(part: BasePart, text: string, subtext: string?, theme: any)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "Label"
	billboard.Size = UDim2.fromOffset(280, 96)
	billboard.StudsOffset = Vector3.new(0, 7, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 250
	billboard.Adornee = part

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Size = UDim2.fromScale(1, 0.6)
	title.Font = Enum.Font.GothamBlack
	title.TextScaled = true
	title.Text = text
	title.TextColor3 = theme.uiText or Color3.new(1, 1, 1)
	title.TextStrokeTransparency = 0.2
	title.Parent = billboard

	if subtext then
		local sub = Instance.new("TextLabel")
		sub.BackgroundTransparency = 1
		sub.Position = UDim2.fromScale(0, 0.6)
		sub.Size = UDim2.fromScale(1, 0.4)
		sub.Font = Enum.Font.GothamMedium
		sub.TextScaled = true
		sub.Text = subtext
		sub.TextColor3 = theme.uiMuted or Color3.fromRGB(220, 220, 220)
		sub.TextStrokeTransparency = 0.4
		sub.Parent = billboard
	end

	billboard.Parent = part
end

local function block(spec: any, parent: Instance): BasePart
	local part = Instance.new("Part")
	part.Name = spec.name or "Part"
	part.Anchored = true
	part.Size = spec.size
	part.Position = spec.position
	part.Color = spec.color or Color3.fromRGB(120, 120, 120)
	part.Material = spec.material or Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Transparency = spec.transparency or 0
	part.CanCollide = if spec.canCollide == nil then true else spec.canCollide
	part.Parent = parent
	return part
end

local function buildWorld(world: any, theme: any)
	local existing = workspace:FindFirstChild(WORLD_FOLDER)
	if existing then
		existing:Destroy() -- run-time only; the saved place file is never touched
	end

	local folder = Instance.new("Folder")
	folder.Name = WORLD_FOLDER
	folder.Parent = workspace

	local floor = block({
		name = "Floor",
		size = world.floor.size,
		position = world.floor.position,
		color = world.floor.color,
		material = world.floor.material,
	}, folder)

	-- Walls keep the flood in the arena. A coin that slides off the edge is a coin the
	-- player watched disappear, which reads as the game taking something back.
	if world.walls then
		local height = world.walls.height
		local thickness = world.walls.thickness
		local halfX = world.floor.size.X / 2
		local halfZ = world.floor.size.Z / 2
		local y = world.floor.position.Y + world.floor.size.Y / 2 + height / 2
		local sides = {
			{ size = Vector3.new(world.floor.size.X, height, thickness), offset = Vector3.new(0, 0, -halfZ) },
			{ size = Vector3.new(world.floor.size.X, height, thickness), offset = Vector3.new(0, 0, halfZ) },
			{ size = Vector3.new(thickness, height, world.floor.size.Z), offset = Vector3.new(-halfX, 0, 0) },
			{ size = Vector3.new(thickness, height, world.floor.size.Z), offset = Vector3.new(halfX, 0, 0) },
		}
		for index, side in sides do
			block({
				name = `Wall{index}`,
				size = side.size,
				position = Vector3.new(side.offset.X, y, side.offset.Z),
				color = world.walls.color,
				material = world.walls.material,
				transparency = world.walls.transparency,
			}, folder)
		end
	end

	for _, prop in world.props or {} do
		block(prop, folder)
	end

	local zoneParts: { [string]: BasePart } = {}
	for _, zone in world.zones do
		local part = block({
			name = `Zone_{zone.id}`,
			size = zone.size,
			position = zone.position,
			color = zone.color,
			material = zone.material or Enum.Material.Neon,
			canCollide = true,
		}, folder)
		if zone.label then
			label(part, zone.label, zone.sublabel, theme)
		end
		zoneParts[zone.id] = part
	end

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "Spawn"
	spawn.Anchored = true
	spawn.CanCollide = true
	spawn.Size = Vector3.new(8, 1, 8)
	spawn.Transparency = 0.4
	spawn.Color = theme.accent or Color3.fromRGB(255, 255, 255)
	spawn.Material = Enum.Material.SmoothPlastic
	spawn.TopSurface = Enum.SurfaceType.Smooth
	-- Face the spawn at the first thing we want a stranger to walk toward.
	spawn.CFrame = CFrame.lookAt(world.spawn.position, world.spawn.lookAt)
	spawn.Parent = folder

	local _ = floor
	return folder, zoneParts
end

export type Pack = {
	config: any,
	world: any,
	theme: any,
	folder: Folder,
	zoneParts: { [string]: BasePart },
}

function ContentLoader.load(): Pack
	local serverPack = ServerScriptService:FindFirstChild("Pack")
	local sharedPack = ReplicatedStorage:FindFirstChild("Pack")
	expect(serverPack, "ServerScriptService.Pack is missing — check default.project.json")
	expect(sharedPack, "ReplicatedStorage.Pack is missing — check default.project.json")

	local config = require((serverPack :: Instance).config)
	local world = require((serverPack :: Instance).world)
	local theme = require((sharedPack :: Instance).theme)

	validate(config, world, theme)
	local folder, zoneParts = buildWorld(world, theme)

	print(`[ContentLoader] pack '{theme.title}' loaded — {#world.zones} zones, {#config.upgrades} upgrades`)
	return { config = config, world = world, theme = theme, folder = folder, zoneParts = zoneParts }
end

return ContentLoader

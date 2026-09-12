-- ContentLoader — reads the content pack, refuses a bad one, and builds the grey-box.
--
-- GAME_FACTORY §1: a new game adds files under `games/<slug>/` and changes nothing in
-- here. The pack is mounted at a fixed path (`ServerScriptService.Pack` /
-- `ReplicatedStorage.Pack`) so only `default.project.json` ever names the slug.
--
-- The world is built at run time from a data spec rather than placed by hand in Studio.
-- That means a fresh place file plus this repo is a playable game — no .rbxl to keep in
-- sync, and the layout is diffable like everything else.
--
-- What this module validates is only the contract EVERY loop family shares: a config,
-- a world with a floor and a spawn, a theme with a title. Each loop family validates
-- its own numbers at start (`LoopService.validate`, `SurviveLoop.validate`), because
-- the loader must not know what a flood cooldown or a burn schedule is.

local Lighting = game:GetService("Lighting")
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

ContentLoader.expect = expect

local function validate(config: any, world: any, theme: any)
	expect(typeof(config) == "table", "config.luau must return a table")
	expect(config.loop == nil or typeof(config.loop) == "string", "config.loop must be a string if set")

	expect(typeof(world) == "table", "world.luau must return a table")
	expect(typeof(world.floor) == "table", "world.floor is required")
	expect(typeof(world.zones) == "table", "world.zones must be an array (may be empty)")
	for _, zone in world.zones do
		expect(typeof(zone.id) == "string", "every zone needs a string id")
		expect(typeof(zone.kind) == "string", `zone {zone.id} needs a kind`)
	end
	expect(typeof(world.spawn) == "table", "world.spawn is required")

	expect(typeof(theme) == "table", "theme.luau must return a table")
	expect(typeof(theme.title) == "string", "theme.title is required")
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

ContentLoader.label = label

local function block(spec: any, parent: Instance): BasePart
	local part = Instance.new("Part")
	part.Name = spec.name or "Part"
	part.Anchored = true
	part.Shape = spec.shape or Enum.PartType.Block
	part.Size = spec.size
	local rotation = spec.rotation
	if spec.cframe then
		part.CFrame = spec.cframe -- a fully-specified placement (imported props)
	elseif rotation then
		part.CFrame = CFrame.new(spec.position)
			* CFrame.Angles(math.rad(rotation.X), math.rad(rotation.Y), math.rad(rotation.Z))
	else
		part.Position = spec.position
	end
	-- A sign: text on one face. Signs are set dressing, so they are data here rather
	-- than a script per sign.
	if spec.face then
		local gui = Instance.new("SurfaceGui")
		gui.Name = "Face"
		gui.Face = spec.face.side or Enum.NormalId.Front
		gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		gui.PixelsPerStud = spec.face.pixelsPerStud or 50
		gui.LightInfluence = 0
		local text = Instance.new("TextLabel")
		text.BackgroundTransparency = 1
		text.Size = UDim2.fromScale(1, 1)
		text.Font = spec.face.font or Enum.Font.GothamBlack
		text.TextScaled = true
		text.Text = spec.face.text
		text.TextColor3 = spec.face.color or Color3.new(1, 1, 1)
		text.TextXAlignment = spec.face.align or Enum.TextXAlignment.Center
		text.Parent = gui
		gui.Parent = part
	end
	part.Color = spec.color or Color3.fromRGB(120, 120, 120)
	part.Material = spec.material or Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Transparency = spec.transparency or 0
	part.CanCollide = if spec.canCollide == nil then true else spec.canCollide
	part.CastShadow = if spec.castShadow == nil then true else spec.castShadow
	if spec.fire then
		ContentLoader.fire(part, spec.fire)
	end
	-- A bare light. Useful on an invisible anchor: a light inside a solid prop lights
	-- nothing, so the way to make a prop glow is to ring it with these.
	if spec.light then
		local light = Instance.new("PointLight")
		light.Name = "Light"
		light.Color = spec.light.color or Color3.fromRGB(255, 255, 255)
		light.Brightness = spec.light.brightness or 1
		light.Range = spec.light.range or 16
		light.Shadows = spec.light.shadows == true
		light.Parent = part
	end
	part.Parent = parent
	return part
end

--- A fire jet from data: a chunky orange-gold flame, sparks, and a short warm light.
--- The look is the pack's (colour, size, range); the machinery is the same for a cap,
--- a bench edge, or a beacon. Range is the caller's — a landmark must not out-light the
--- beacon the loop is built around.
function ContentLoader.fire(part: BasePart, spec: any)
	local size = spec.size or 1.5
	local height = spec.height or 5
	local orange = spec.color or Color3.fromRGB(255, 122, 24)
	local gold = spec.tip or Color3.fromRGB(255, 208, 96)

	local flame = Instance.new("ParticleEmitter")
	flame.Name = "Flame"
	flame.Texture = "rbxasset://textures/particles/fire_main.dds"
	flame.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, gold),
		ColorSequenceKeypoint.new(0.35, orange),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 30, 8)),
	})
	flame.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, size * 0.9),
		NumberSequenceKeypoint.new(0.4, size * 1.25),
		NumberSequenceKeypoint.new(1, size * 0.25),
	})
	flame.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(0.7, 0.35),
		NumberSequenceKeypoint.new(1, 1),
	})
	flame.Lifetime = NumberRange.new(0.55, 0.95)
	flame.Speed = NumberRange.new(height * 0.7, height * 1.1)
	flame.Rate = spec.rate or 28
	flame.SpreadAngle = Vector2.new(8, 8)
	flame.Rotation = NumberRange.new(-20, 20)
	flame.RotSpeed = NumberRange.new(-40, 40)
	flame.LightEmission = 1
	flame.LightInfluence = 0
	flame.EmissionDirection = Enum.NormalId.Top
	flame.Acceleration = Vector3.new(0, height * 0.6, 0)
	flame.Parent = part

	local sparks = Instance.new("ParticleEmitter")
	sparks.Name = "Sparks"
	sparks.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparks.Color = ColorSequence.new(gold, orange)
	sparks.Size = NumberSequence.new(size * 0.12, 0)
	sparks.Transparency = NumberSequence.new(0, 1)
	sparks.Lifetime = NumberRange.new(0.9, 1.6)
	sparks.Speed = NumberRange.new(height * 0.9, height * 1.6)
	sparks.Rate = spec.sparkRate or 6
	sparks.SpreadAngle = Vector2.new(30, 30)
	sparks.LightEmission = 1
	sparks.Acceleration = Vector3.new(0, -2, 0)
	sparks.Parent = part

	local light = Instance.new("PointLight")
	light.Name = "FireLight"
	light.Color = orange
	light.Brightness = spec.brightness or 1.4
	light.Range = spec.range or 12
	light.Shadows = false
	light.Parent = part
end

ContentLoader.block = block

--- Apply a lighting rig from data. "Default lighting is why generated places look
--- generated" (OPERATING_MANUAL §5), so the rig is part of the pack, not a Studio
--- click. Properties that need plugin security (Technology) are skipped with a note.
local function applyLighting(spec: any)
	if typeof(spec) ~= "table" then
		return
	end
	for key, value in spec do
		if typeof(value) ~= "table" then
			local ok = pcall(function()
				(Lighting :: any)[key] = value
			end)
			if not ok then
				warn(`[ContentLoader] Lighting.{key} could not be set from a script (plugin-only?)`)
			end
		end
	end
	local function effect(className: string, name: string, props: any?)
		if typeof(props) ~= "table" then
			return
		end
		local existing = Lighting:FindFirstChild(name)
		if existing then
			existing:Destroy()
		end
		local instance = Instance.new(className)
		instance.Name = name
		for key, value in props do
			pcall(function()
				(instance :: any)[key] = value
			end)
		end
		instance.Parent = Lighting
	end
	effect("Atmosphere", "Atmosphere", spec.atmosphere)
	effect("ColorCorrectionEffect", "ColorCorrection", spec.colorCorrection)
	effect("BloomEffect", "Bloom", spec.bloom)
	effect("DepthOfFieldEffect", "DepthOfField", spec.depthOfField)
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
		shape = world.floor.shape,
		rotation = world.floor.rotation,
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
			shape = zone.shape,
			rotation = zone.rotation,
			size = zone.size,
			position = zone.position,
			color = zone.color,
			material = zone.material or Enum.Material.Neon,
			transparency = zone.transparency,
			canCollide = if zone.canCollide == nil then true else zone.canCollide,
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
	spawn.Transparency = world.spawn.transparency or 0.4
	spawn.Color = world.spawn.color or theme.accent or Color3.fromRGB(255, 255, 255)
	spawn.Material = Enum.Material.SmoothPlastic
	spawn.TopSurface = Enum.SurfaceType.Smooth
	-- Face the spawn at the first thing we want a stranger to walk toward.
	spawn.CFrame = CFrame.lookAt(world.spawn.position, world.spawn.lookAt)
	spawn.Parent = folder

	applyLighting(world.lighting)

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

	print(`[ContentLoader] pack '{theme.title}' loaded — loop '{config.loop or "sweepbank"}', {#world.zones} zones`)
	return { config = config, world = world, theme = theme, folder = folder, zoneParts = zoneParts }
end

--- Which engine loop module runs this pack. The pack says `loop = "survive"`; the
--- default is the sweep-and-bank loop so the first title needs no change.
function ContentLoader.loopModuleName(config: any): string
	local loop = config.loop or "sweepbank"
	if loop == "sweepbank" then
		return "LoopService"
	elseif loop == "survive" then
		return "SurviveLoop"
	end
	return fail(`unknown config.loop '{loop}' — engine knows: sweepbank, survive`)
end

return ContentLoader

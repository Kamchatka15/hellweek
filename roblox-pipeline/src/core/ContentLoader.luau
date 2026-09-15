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
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ContentLoader = {}

local WORLD_FOLDER = "World"
local SCENERY_FOLDER = "Scenery"

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
	part.Reflectance = spec.reflectance or 0
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
	light.Shadows = spec.shadows == true
	light.Parent = part
end

--- Move the lighting toward `spec` over `seconds`. Same shape as the boot rig, so a
--- pack can describe day and night as two complete rigs rather than as a base plus a
--- couple of overrides — which is the only way a world gets to look like a DIFFERENT
--- place at night rather than the same place with the lamp turned down.
function ContentLoader.tweenLighting(spec: any, seconds: number)
	if typeof(spec) ~= "table" then
		return
	end
	local info = TweenInfo.new(seconds, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	local goal: { [string]: any } = {}
	for key, value in spec do
		if typeof(value) ~= "table" then
			goal[key] = value
		end
	end
	pcall(function()
		TweenService:Create(Lighting, info, goal):Play()
	end)
	for name, props in
		{
			Atmosphere = spec.atmosphere,
			ColorCorrection = spec.colorCorrection,
			Bloom = spec.bloom,
		}
	do
		local instance = Lighting:FindFirstChild(name)
		if instance and typeof(props) == "table" then
			pcall(function()
				TweenService:Create(instance, info, props):Play()
			end)
		end
	end
end

--- Replace everything in World/Scenery with `specs`. The fixtures — the stone, the
--- pentagram, the table, the light — are NOT in here and survive the swap, which is
--- what lets a world change 360 degrees around a player who has not moved.
function ContentLoader.buildScenery(pack: any, specs: { any })
	local existing = pack.folder:FindFirstChild(SCENERY_FOLDER)
	if existing then
		existing:Destroy()
	end
	local folder = Instance.new("Folder")
	folder.Name = SCENERY_FOLDER
	folder.Parent = pack.folder
	for _, spec in specs do
		block(spec, folder)
	end
	return folder
end

--- Draw a dashed circle flat on the ground.
---
--- The single highest-value readability device in the survive genre, and the one we
--- had missed entirely: the leader PAINTS the safe radius on the terrain rather than
--- implying it with light. A drawn ring is legible in flat noon daylight from well
--- outside it, legible on dark ground at midnight, and it needs no words, no icon and
--- no camera angle. Light falloff does none of those things.
---
--- Returns the folder so the caller can destroy and redraw it when the radius changes;
--- watching the circle GROW is how a player learns that feeding the beacon did
--- something.
function ContentLoader.groundRing(spec: any, parent: Instance): Folder
	local folder = Instance.new("Folder")
	folder.Name = spec.name or "GroundRing"

	local radius = spec.radius or 30
	local dashes = spec.dashes or math.clamp(math.floor(radius * 1.6), 24, 96)
	local width = spec.width or 1.2
	local length = spec.length or (2 * math.pi * radius / dashes) * (spec.fill or 0.55)
	local centre = spec.centre or Vector3.zero
	local y = spec.y or (centre.Y + 0.06)

	for index = 1, dashes do
		local theta = (index - 1) / dashes * math.pi * 2
		local x = centre.X + math.cos(theta) * radius
		local z = centre.Z + math.sin(theta) * radius
		local dash = Instance.new("Part")
		dash.Name = "Dash"
		dash.Anchored = true
		dash.CanCollide = false
		dash.CanTouch = false
		dash.CastShadow = false
		dash.Size = Vector3.new(length, 0.08, width)
		dash.CFrame = CFrame.new(Vector3.new(x, y, z)) * CFrame.Angles(0, -theta, 0)
		dash.Color = spec.color or Color3.fromRGB(226, 214, 176)
		dash.Material = spec.material or Enum.Material.Neon
		dash.Transparency = spec.transparency or 0.25
		dash.TopSurface = Enum.SurfaceType.Smooth
		dash.BottomSurface = Enum.SurfaceType.Smooth
		dash.Parent = folder
	end

	folder.Parent = parent
	return folder
end

--- Repaint the ground. A world swap changes what is underfoot as well as what is on it.
function ContentLoader.setFloor(pack: any, spec: any)
	local floor = pack.folder:FindFirstChild("Floor")
	if floor and floor:IsA("BasePart") and typeof(spec) == "table" then
		floor.Color = spec.color or floor.Color
		floor.Material = spec.material or floor.Material
	end
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

	-- The ground, in as few pieces as it takes. A pack that digs underground has to be
	-- able to cut a hole in its own floor, or the way down is sealed by the world itself
	-- and nothing below it can be reached — so `world.floorHoles` lists rectangles in
	-- world XZ and the slab is split around them.
	local function subtract(rects: { any }, hole: { number }): { any }
		local out = {}
		for _, r in rects do
			if hole[1] >= r[3] or hole[3] <= r[1] or hole[2] >= r[4] or hole[4] <= r[2] then
				table.insert(out, r)
				continue
			end
			if hole[1] > r[1] then
				table.insert(out, { r[1], r[2], hole[1], r[4] })
			end
			if hole[3] < r[3] then
				table.insert(out, { hole[3], r[2], r[3], r[4] })
			end
			local x0, x1 = math.max(r[1], hole[1]), math.min(r[3], hole[3])
			if hole[2] > r[2] then
				table.insert(out, { x0, r[2], x1, hole[2] })
			end
			if hole[4] < r[4] then
				table.insert(out, { x0, hole[4], x1, r[4] })
			end
		end
		return out
	end

	local fsize, fat = world.floor.size, world.floor.position
	local rects = { { fat.X - fsize.X / 2, fat.Z - fsize.Z / 2, fat.X + fsize.X / 2, fat.Z + fsize.Z / 2 } }
	for _, hole in world.floorHoles or {} do
		rects = subtract(rects, hole)
	end
	local floor: BasePart
	for index, r in rects do
		local piece = block({
			name = if index == 1 then "Floor" else `Floor_{index}`,
			shape = world.floor.shape,
			rotation = world.floor.rotation,
			size = Vector3.new(r[3] - r[1], fsize.Y, r[4] - r[2]),
			position = Vector3.new((r[1] + r[3]) / 2, fat.Y, (r[2] + r[4]) / 2),
			color = world.floor.color,
			material = world.floor.material,
		}, folder)
		floor = floor or piece
	end

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

	-- A prop may name a `group`: it is built into a subfolder of that name, so a
	-- whole visual pass can be found, toggled or thrown away as one thing in Studio.
	local groups: { [string]: Folder } = {}
	local function groupFolder(name: string): Folder
		local existing = groups[name]
		if existing then
			return existing
		end
		local made = Instance.new("Folder")
		made.Name = name
		made.Parent = folder
		groups[name] = made
		return made
	end
	for _, prop in world.props or {} do
		block(prop, if prop.group then groupFolder(prop.group) else folder)
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

-- world — The Quiet Shore, as data.
--
-- Built at run time by ContentLoader. A 350x350 starting disk of grey sand (owner
-- lock: bigger than 99 Nights' cramped first circle), black glass water under and
-- beyond it, driftwood, pale dead trees, one ruined rowboat, two seated wanderers in
-- the fog. The Wick, the Tempter, the fog ring and every Ashwood are built by the loop
-- from config, because they move or respawn.
--
-- Distances are the design: spawn is 30 studs from the Wick, facing it, with three
-- Ashwood on that line. Ring A (0-50) is the whole one-minute teach.

local theme = require(game:GetService("ReplicatedStorage").Pack.theme)

local SAND = theme.colors.sand
local TREE = theme.colors.tree
local DRIFT = theme.colors.driftwood
local ROCK = theme.colors.rock

local function tree(name: string, x: number, z: number, height: number)
	return {
		name = name,
		shape = Enum.PartType.Cylinder,
		size = Vector3.new(height, 1.1, 1.1),
		position = Vector3.new(x, height / 2, z),
		rotation = Vector3.new(0, 0, 90),
		color = TREE,
		material = Enum.Material.Wood,
		canCollide = true,
	}
end

local function branch(name: string, x: number, z: number, y: number, length: number, yaw: number)
	return {
		name = name,
		shape = Enum.PartType.Cylinder,
		size = Vector3.new(length, 0.5, 0.5),
		position = Vector3.new(x, y, z),
		rotation = Vector3.new(0, yaw, 28),
		color = TREE,
		material = Enum.Material.Wood,
		canCollide = false,
	}
end

local function drift(name: string, x: number, z: number, length: number, yaw: number)
	return {
		name = name,
		size = Vector3.new(length, 1, 1.2),
		position = Vector3.new(x, 0.5, z),
		rotation = Vector3.new(0, yaw, 0),
		color = DRIFT,
		material = Enum.Material.Wood,
		canCollide = true,
	}
end

local function rock(name: string, x: number, z: number, size: number)
	return {
		name = name,
		shape = Enum.PartType.Ball,
		size = Vector3.new(size, size * 0.6, size * 0.8),
		position = Vector3.new(x, size * 0.2, z),
		color = ROCK,
		material = Enum.Material.Slate,
		canCollide = true,
	}
end

-- A seated figure in the fog: torso + head, no face, no colour. Set dressing only.
local function wanderer(name: string, x: number, z: number, yaw: number)
	return {
		{
			name = `{name}Body`,
			size = Vector3.new(1.6, 2.2, 1.2),
			position = Vector3.new(x, 1.1, z),
			rotation = Vector3.new(0, yaw, 0),
			color = Color3.fromRGB(60, 62, 68),
			material = Enum.Material.SmoothPlastic,
			canCollide = false,
			castShadow = false,
		},
		{
			name = `{name}Head`,
			shape = Enum.PartType.Ball,
			size = Vector3.new(1.1, 1.1, 1.1),
			position = Vector3.new(x, 2.7, z),
			color = Color3.fromRGB(60, 62, 68),
			material = Enum.Material.SmoothPlastic,
			canCollide = false,
			castShadow = false,
		},
	}
end

local props = {
	-- Black glass water, under everything and out past the shore edge.
	{
		name = "Water",
		size = Vector3.new(1200, 1, 1200),
		position = Vector3.new(0, -1.6, 0),
		color = theme.colors.water,
		material = Enum.Material.Glass,
		canCollide = true,
	},

	-- Ring A: two driftwood piles the brief asks for, off the spawn line.
	drift("DriftA1", -14, 12, 7, 20),
	drift("DriftA2", 16, -10, 6, -35),
	rock("RockA1", -9, -20, 3),

	-- Ring B: the extra sand. A ruined rowboat, pale tree clusters, grey flats.
	drift("BoatHull", 88, -62, 11, 15),
	drift("BoatRib1", 86, -60, 4, 105),
	drift("BoatRib2", 91, -64, 4, 105),
	tree("TreeB1", -70, 40, 18),
	branch("TreeB1a", -70, 40, 13, 6, 30),
	tree("TreeB2", -78, 52, 14),
	tree("TreeB3", -62, 58, 21),
	branch("TreeB3a", -62, 58, 15, 7, -60),
	tree("TreeB4", 40, 120, 17),
	tree("TreeB5", 52, 128, 12),
	branch("TreeB5a", 52, 128, 9, 5, 80),
	tree("TreeB6", -120, -90, 19),
	tree("TreeB7", -128, -80, 15),
	drift("DriftB1", 30, 70, 8, 60),
	drift("DriftB2", -40, -110, 9, -20),
	rock("RockB1", 110, 30, 5),
	rock("RockB2", -100, 100, 4),
	rock("RockB3", 20, -140, 6),

	-- Ring C/D: sparse, the same silhouettes, so the peel reads as "more shore".
	tree("TreeC1", 200, 80, 20),
	tree("TreeC2", -190, -140, 16),
	tree("TreeC3", -60, 230, 18),
	branch("TreeC3a", -60, 230, 12, 6, 10),
	drift("DriftC1", 150, -190, 10, 45),
	rock("RockC1", 240, -60, 7),
	rock("RockD1", -290, 60, 6),
	tree("TreeD1", 120, -300, 15),
}

for _, part in wanderer("Wanderer1", 96, 118, 200) do
	table.insert(props, part)
end
for _, part in wanderer("Wanderer2", -140, 20, 80) do
	table.insert(props, part)
end

-- The crafting bench (Justin's art drop, 2026-09-12): Ring A, ~12 studs from the Wick,
-- off the spawn line so it never hides the Ashwood path, its two plates turned toward
-- spawn so they read on the first walk in. Parts come from bench.luau in the bench's
-- own frame; one CFrame places all of them. Set dressing in Pass 1 — crafting is parked.
local benchParts = require(script.Parent.bench)
local benchAt = Vector3.new(11, 0, 4)
local spawnAt = Vector3.new(0, 0, 30)
local benchOrigin = CFrame.lookAt(benchAt, benchAt - (spawnAt - benchAt)) -- +Z faces spawn
for _, spec in benchParts do
	table.insert(props, {
		name = `Bench_{spec.name}`,
		shape = spec.shape,
		size = spec.size,
		position = benchAt,
		cframe = benchOrigin * spec.cframe,
		color = spec.color,
		material = spec.material,
		face = spec.face,
		canCollide = spec.name == "Tabletop" or string.sub(spec.name, 1, 4) == "Leg_" or spec.name == "Shelf",
		castShadow = spec.material ~= Enum.Material.Neon,
	})
end

return {
	-- The starting disk: a cylinder on its side is a vertical-axis disc. Size.X is
	-- the thickness, Y/Z the diameter.
	floor = {
		shape = Enum.PartType.Cylinder,
		size = Vector3.new(2, 350, 350),
		position = Vector3.new(0, -1, 0),
		rotation = Vector3.new(0, 0, 90),
		color = SAND,
		material = Enum.Material.Sand,
	},

	props = props,

	-- The feed spot: a faint gold disc on the sand around the Wick post. Walking into
	-- it feeds whatever you carry. The loop binds the kind; the loader only draws it.
	zones = {
		{
			id = "wick",
			kind = "beacon",
			shape = Enum.PartType.Cylinder,
			size = Vector3.new(0.3, 14, 14),
			position = Vector3.new(0, 0.15, 0),
			rotation = Vector3.new(0, 0, 90),
			color = theme.colors.flame,
			material = Enum.Material.Neon,
			transparency = 0.7,
			canCollide = false,
		},
	},

	spawn = {
		position = Vector3.new(0, 0.5, 30),
		lookAt = Vector3.new(0, 0.5, 0), -- face the Wick on arrival
		transparency = 0.85,
		color = SAND,
	},

	-- The lighting rig from games/hell-week/lighting.md. Applied by ContentLoader at
	-- boot. LightingStyle / Technology are plugin-only and set once in Studio.
	lighting = {
		ClockTime = 20.4,
		Brightness = 1.8,
		Ambient = Color3.fromRGB(20, 22, 28),
		OutdoorAmbient = Color3.fromRGB(40, 48, 62),
		ColorShift_Top = Color3.fromRGB(180, 160, 140),
		GlobalShadows = true,
		EnvironmentDiffuseScale = 0.4,
		EnvironmentSpecularScale = 0.2,
		atmosphere = {
			Density = 0.42,
			Offset = 0.15,
			Haze = 2.5,
			Color = Color3.fromRGB(90, 100, 120),
			Decay = Color3.fromRGB(60, 66, 80),
			Glare = 0,
		},
		colorCorrection = {
			Contrast = 0.12,
			Saturation = -0.08,
			TintColor = Color3.fromRGB(220, 230, 240),
		},
		bloom = {
			Intensity = 0.35,
			Size = 24,
			Threshold = 1.6, -- only the wick flame and the gift cross this
		},
	},
}

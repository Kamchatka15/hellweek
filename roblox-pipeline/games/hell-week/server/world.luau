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
local benchAt = Vector3.new(70, 0, -140) -- just inside the Day-1 fog wall (175), Justin 2026-09-12; still right-of-centre from spawn
local spawnAt = Vector3.new(0, 0, 48)
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
		fire = spec.fire,
		canCollide = spec.name == "Tabletop" or string.sub(spec.name, 1, 4) == "Leg_" or spec.name == "Shelf",
		castShadow = spec.material ~= Enum.Material.Neon,
	})
end

-- The pentagram stone floor (Justin, 2026-09-12): five gold lines and a gold ring inlaid
-- on the slab under the obelisk. Gold Neon like the glyphs, so it reads at night and
-- doubles as the "feed here" mark. (Reopens settled answer §1.1's "no pentagram logo" —
-- owner's call, recorded in brief.md.)
local PENT_R = 24 -- the star's outer radius: its inner pentagon (~9.2) clears the 5.2-stud base,
local SLAB_R = 30 -- so the obelisk stands INSIDE the pentagram (Justin, 2026-09-12)
local PENT_Y = 0.56
local GOLD = Color3.fromRGB(255, 196, 64)
local starPoints = {}
for k = 0, 4 do
	local a = math.rad(90 + 72 * k)
	starPoints[k + 1] = Vector3.new(math.cos(a) * PENT_R, PENT_Y, math.sin(a) * PENT_R)
end
for k = 1, 5 do
	local a = starPoints[k]
	local b = starPoints[(k + 1) % 5 + 1] -- every second point: the star, not the pentagon
	local mid = (a + b) / 2
	table.insert(props, {
		name = `Pentagram_Line{k}`,
		size = Vector3.new(1.3, 0.14, (a - b).Magnitude),
		position = mid,
		cframe = CFrame.lookAt(mid, b),
		color = GOLD,
		material = Enum.Material.Neon,
		canCollide = false,
		castShadow = false,
	})
end
local RING_SEGMENTS = 56
local RING_R = 26.5
for i = 1, RING_SEGMENTS do
	local a = (i / RING_SEGMENTS) * math.pi * 2
	local pos = Vector3.new(math.cos(a) * RING_R, PENT_Y, math.sin(a) * RING_R)
	table.insert(props, {
		name = `Pentagram_Ring{i}`,
		size = Vector3.new(2 * math.pi * RING_R / RING_SEGMENTS + 0.3, 0.14, 1.1),
		position = pos,
		cframe = CFrame.lookAt(pos, Vector3.new(0, PENT_Y, 0)), -- -Z toward the centre; the long X axis is the tangent
		color = GOLD,
		material = Enum.Material.Neon,
		canCollide = false,
		castShadow = false,
	})
end

-- The obelisk is the only light on a dark shore, so it has to actually GLOW rather than
-- stand as a silhouette (Justin, 2026-09-12: "it needs to glow because you are at the
-- centre and obviously everything around you will be darker"). A light INSIDE the stone
-- lights nothing, so warm anchors ring the shaft just outside it and wash its four
-- faces, and five more sit at the star tips and pour onto the sand. Invisible parts:
-- the light is the prop.
local GLOW = Color3.fromRGB(255, 172, 86) -- the sand pool: warm
local WASH = Color3.fromRGB(255, 214, 176) -- the stone wash: pale, or the charcoal reads as sand
for k = 1, 4 do
	local a = (k / 4) * math.pi * 2 + math.pi / 4
	table.insert(props, {
		name = `ObeliskGlow{k}`,
		size = Vector3.new(0.4, 0.4, 0.4),
		position = Vector3.new(math.cos(a) * 9, 9, math.sin(a) * 9),
		transparency = 1,
		canCollide = false,
		castShadow = false,
		light = { color = WASH, brightness = 1.5, range = 24 },
	})
end
for k = 1, 5 do
	local a = math.rad(90 + 72 * k)
	table.insert(props, {
		name = `StarGlow{k}`,
		size = Vector3.new(0.4, 0.4, 0.4),
		position = Vector3.new(math.cos(a) * (PENT_R - 2), 2.2, math.sin(a) * (PENT_R - 2)),
		transparency = 1,
		canCollide = false,
		castShadow = false,
		light = { color = GLOW, brightness = 1.5, range = 26 },
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

	-- The feed spot: a faint gold ring on the sand around the obelisk base. Walking into
	-- it feeds whatever you carry. The loop binds the kind; the loader only draws it.
	zones = {
		{
			id = "obelisk",
			kind = "beacon",
			shape = Enum.PartType.Cylinder,
			size = Vector3.new(0.5, 2 * SLAB_R, 2 * SLAB_R), -- the pentagram stone floor; standing on it feeds
			position = Vector3.new(0, 0.25, 0),
			rotation = Vector3.new(0, 0, 90),
			color = Color3.fromRGB(40, 40, 44),
			material = Enum.Material.Slate,
			transparency = 0,
			canCollide = true,
		},
	},

	spawn = {
		position = Vector3.new(0, 0.5, 48), -- 18 studs of sand before the stone edge (r=30)
		lookAt = Vector3.new(0, 6, 0), -- face the obelisk on arrival
		transparency = 0.85,
		color = SAND,
	},

	-- The lighting rig from games/hell-week/lighting.md. Applied by ContentLoader at
	-- boot. LightingStyle / Technology are plugin-only and set once in Studio.
	lighting = {
		-- Dim, never black. The sun is weak and the ambient is low so distance falls off
		-- honestly, and the obelisk's own lights are what a player reads by. Raising
		-- ambient to "fix" darkness flattens exactly the contrast this scene is made of.
		ClockTime = 21.2,
		Brightness = 1.1,
		Ambient = Color3.fromRGB(26, 27, 34),
		OutdoorAmbient = Color3.fromRGB(34, 38, 50),
		ColorShift_Top = Color3.fromRGB(150, 140, 130),
		GlobalShadows = true,
		EnvironmentDiffuseScale = 0.25,
		EnvironmentSpecularScale = 0.15,
		atmosphere = {
			Density = 0.36,
			Offset = 0.15,
			Haze = 2,
			Color = Color3.fromRGB(90, 100, 120),
			Decay = Color3.fromRGB(52, 58, 72),
			Glare = 0,
		},
		colorCorrection = {
			Contrast = 0.12,
			Saturation = -0.08,
			TintColor = Color3.fromRGB(220, 230, 240),
		},
		bloom = {
			Intensity = 0.7,
			Size = 28,
			Threshold = 1.1, -- the gold glyphs, the pentagram and the cap fire bloom; nothing else
		},
	},
}

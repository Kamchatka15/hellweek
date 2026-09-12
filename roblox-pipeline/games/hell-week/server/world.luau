-- world — The Ashen Waste, as data.
--
-- Built at run time by ContentLoader. A 700-stud disk of bleached dead sand with the
-- obelisk at its centre on a pentagram stone. The scenery is generated
-- (`server/desert.luau`, from `tools/gen_desert.py`); everything assembled here is the
-- part that has to line up by hand: the stone, the five point triangles, the offering
-- bowl, the light, and the rig.
--
-- Harvestable nodes — cactus, boulders, deadfall — are NOT here. The loop places them
-- from `config.resources` so they can respawn at dawn.
--
-- Distances are the design: spawn is 62 studs out, facing the obelisk, with deadfall
-- on that line. The stone's edge is at 30, so the walk in is about two seconds of sand
-- and then you are standing on the star.

local theme = require(game:GetService("ReplicatedStorage").Pack.theme)

local props = {}

-- The generated desert: dunes, mesas, dead trees, scrub, ruins, bone scatter, one dry
-- wash. 1,100-odd parts, none of them inside the 46-stud belt around the obelisk.
for _, spec in require(script.Parent.desert) do
	table.insert(props, spec)
end

-- The pentagram stone floor. Five gold lines and a gold ring inlaid on the slab under
-- the obelisk; the slab is also the feed zone. (Reopens settled answer §1.1's "no
-- pentagram logo" — owner's call, recorded in brief.md.)
local PENT_R = 24 -- the star's outer radius: its inner pentagon (~9.2) clears the base,
local SLAB_R = 30 -- so the obelisk stands INSIDE the pentagram
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

-- The five point triangles — one per world (`server/biomes.luau`). Dark while a world
-- is locked, red once it is open, green once it is mastered. Each is two right-angled
-- wedges laid flat back to back, so the pair reads from above as the filled triangle
-- between the star's tip and the two inner vertices beside it. The client recolours
-- them from its own progress, so in co-op every player reads their own stone.
local TIP_THICK = 0.16
local INNER_R = PENT_R * 0.38197 -- a five-pointed star's inner pentagon
for k = 1, 5 do
	local a = math.rad(90 + 72 * (k - 1))
	local apex = Vector3.new(math.cos(a) * PENT_R, PENT_Y, math.sin(a) * PENT_R)
	local b1 = Vector3.new(math.cos(a - math.rad(36)) * INNER_R, PENT_Y, math.sin(a - math.rad(36)) * INNER_R)
	local b2 = Vector3.new(math.cos(a + math.rad(36)) * INNER_R, PENT_Y, math.sin(a + math.rad(36)) * INNER_R)
	local mid = (b1 + b2) / 2
	local forward = apex - mid
	local height = forward.Magnitude
	local forwardUnit = forward.Unit
	for half, corner in { A = b1, B = b2 } do
		local side = corner - mid
		local halfBase = side.Magnitude
		local sideUnit = side.Unit
		local vz = forwardUnit
		local vx = sideUnit:Cross(vz)
		table.insert(props, {
			name = `BiomePoint{k}{half}`,
			shape = Enum.PartType.Wedge,
			size = Vector3.new(TIP_THICK, halfBase, height),
			position = mid,
			cframe = CFrame.fromMatrix(mid + sideUnit * (halfBase / 2) + forwardUnit * (height / 2), vx, sideUnit, vz),
			color = Color3.fromRGB(22, 20, 26), -- locked: the client lights it
			material = Enum.Material.Neon,
			canCollide = false,
			castShadow = false,
		})
	end
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

-- The offering bowl: a stone basin with a gold rim on the sand just outside the
-- pentagram, in plain sight from spawn but OFF the straight walk to the fire. On the
-- line it was a toll booth — it took the sack of anyone heading for the obelisk. A few
-- steps to the side turns the same object into a decision.
local BOWL_AT = Vector3.new(24, 0, 28)
table.insert(props, {
	name = "OfferingBasin",
	shape = Enum.PartType.Cylinder,
	size = Vector3.new(1.6, 8.4, 8.4),
	position = BOWL_AT + Vector3.new(0, 0.8, 0),
	rotation = Vector3.new(0, 0, 90),
	color = Color3.fromRGB(46, 46, 52),
	material = Enum.Material.Slate,
	canCollide = true,
})
table.insert(props, {
	name = "OfferingRim",
	shape = Enum.PartType.Cylinder,
	size = Vector3.new(0.3, 9.2, 9.2),
	position = BOWL_AT + Vector3.new(0, 1.65, 0),
	rotation = Vector3.new(0, 0, 90),
	color = GOLD,
	material = Enum.Material.Neon,
	canCollide = false,
	castShadow = false,
})
table.insert(props, {
	name = "OfferingHollow",
	shape = Enum.PartType.Cylinder,
	size = Vector3.new(0.3, 6.4, 6.4),
	position = BOWL_AT + Vector3.new(0, 1.7, 0),
	rotation = Vector3.new(0, 0, 90),
	color = Color3.fromRGB(18, 16, 20),
	material = Enum.Material.SmoothPlastic,
	canCollide = false,
	castShadow = false,
})

-- The obelisk is the only light on a dark waste, so it has to actually GLOW rather
-- than stand as a silhouette. A light INSIDE the stone lights nothing, so warm anchors
-- ring the shaft and wash its four faces, and five more sit at the star tips and pour
-- onto the sand. Invisible parts: the light is the prop.
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
	-- The disk: a cylinder on its side is a vertical-axis disc. Size.X is the
	-- thickness, Y/Z the diameter. 700 studs across — a 22-second walk from the
	-- obelisk to the edge, and you cannot see the edge from the middle.
	floor = {
		shape = Enum.PartType.Cylinder,
		size = Vector3.new(4, 700, 700),
		position = Vector3.new(0, -2, 0),
		rotation = Vector3.new(0, 0, 90),
		color = theme.colors.sand,
		material = Enum.Material.Sand,
	},

	props = props,

	zones = {
		{
			id = "offering",
			kind = "offering",
			shape = Enum.PartType.Cylinder,
			size = Vector3.new(0.3, 9.6, 9.6),
			position = BOWL_AT + Vector3.new(0, 1.8, 0),
			rotation = Vector3.new(0, 0, 90),
			color = GOLD,
			material = Enum.Material.Neon,
			transparency = 0.86,
			canCollide = false,
			label = "OFFER",
			sublabel = "OR WALK PAST AND BURN IT",
		},
		{
			id = "obelisk",
			kind = "beacon",
			shape = Enum.PartType.Cylinder,
			size = Vector3.new(0.5, 2 * SLAB_R, 2 * SLAB_R), -- the pentagram stone; standing on it feeds
			position = Vector3.new(0, 0.25, 0),
			rotation = Vector3.new(0, 0, 90),
			color = Color3.fromRGB(40, 40, 44),
			material = Enum.Material.Slate,
			transparency = 0,
			canCollide = true,
		},
	},

	spawn = {
		position = Vector3.new(0, 0.5, 62), -- 32 studs of sand before the stone edge
		lookAt = Vector3.new(0, 6, 0), -- face the obelisk on arrival
		transparency = 0.85,
		color = theme.colors.sand,
	},

	-- The rig from games/hell-week/lighting.md. Applied by ContentLoader at boot.
	-- Dim, never black: the sun is weak and the ambient is low so distance falls off
	-- honestly, and the obelisk's own lights are what a player reads by. Raising
	-- ambient to "fix" darkness flattens exactly the contrast this scene is made of.
	-- LightingStyle / Technology are plugin-only and set once in Studio.
	lighting = {
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
			Color = Color3.fromRGB(104, 96, 92),
			Decay = Color3.fromRGB(58, 54, 58),
			Glare = 0,
		},
		colorCorrection = {
			Contrast = 0.12,
			Saturation = -0.08,
			TintColor = Color3.fromRGB(228, 226, 226),
		},
		bloom = {
			Intensity = 0.7,
			Size = 28,
			Threshold = 1.1, -- the gold glyphs, the pentagram and the cap fire bloom; nothing else
		},
	},
}

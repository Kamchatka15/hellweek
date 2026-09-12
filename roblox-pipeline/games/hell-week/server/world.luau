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

-- The five point triangles. FOUR are worlds (`server/biomes.luau`) — dark while a
-- world is locked, red once open, green once mastered — and the FIFTH holds the
-- offering table (Justin, 2026-09-12). Point 1 faces spawn and is the world you are
-- standing in; the offering sits on point 5, right of centre, so it is in plain sight
-- but not on the straight walk to the fire.
--
-- Each triangle fills the star's OUTWARD point: apex at the star's tip, base across
-- the two inner-pentagon vertices beside it. Built as a fan of tapering strips rather
-- than a pair of wedges — a WedgePart's right-angle corner is a convention that is easy
-- to get backwards, and the first build had every triangle pointing inward at the
-- obelisk, which is the opposite of what a point means.
local TIP_SLICES = 14
local TIP_Y = 0.62
local INNER_R = PENT_R * 0.38197 -- a five-pointed star's inner pentagon
local BASE_MID_R = INNER_R * math.cos(math.rad(36)) -- where the base crosses the bearing
local TIP_H = PENT_R - BASE_MID_R
local TIP_HALF_BASE = INNER_R * math.sin(math.rad(36))

-- Which point carries the offering table instead of a world.
local OFFERING_POINT = 5
local OFFERING_R = BASE_MID_R + TIP_H * 0.42 -- far enough out to clear the feed zone
local OFFERING_ZONE_R = 3.2

local function pointBearing(k: number): number
	return math.rad(90 + 72 * (k - 1))
end

for k = 1, 5 do
	local a = pointBearing(k)
	local radial = Vector3.new(math.cos(a), 0, math.sin(a))
	local up = Vector3.yAxis
	local tangent = radial:Cross(up)
	local offering = k == OFFERING_POINT
	for i = 1, TIP_SLICES do
		local t0, t1 = (i - 1) / TIP_SLICES, i / TIP_SLICES
		local mid = (t0 + t1) / 2
		local width = 2 * TIP_HALF_BASE * (1 - mid)
		local centre = radial * (BASE_MID_R + TIP_H * mid) + Vector3.new(0, TIP_Y, 0)
		table.insert(props, {
			name = if offering then `OfferingTable{i}` else `BiomePoint{k}_{i}`,
			size = Vector3.new(TIP_H / TIP_SLICES + 0.04, if offering then 0.5 else 0.16, width + 0.04),
			position = centre,
			cframe = CFrame.fromMatrix(centre, radial, up, tangent),
			color = if offering then Color3.fromRGB(52, 50, 56) else Color3.fromRGB(22, 20, 26),
			material = if offering then Enum.Material.Slate else Enum.Material.Neon,
			canCollide = false,
			castShadow = false,
		})
	end
	if offering then
		-- A gold lip around the table so it reads as a surface to put things on rather
		-- than another lit point.
		for _, edge in { -1, 1 } do
			for i = 1, TIP_SLICES do
				local t0, t1 = (i - 1) / TIP_SLICES, i / TIP_SLICES
				local mid = (t0 + t1) / 2
				local width = TIP_HALF_BASE * (1 - mid)
				local centre = radial * (BASE_MID_R + TIP_H * mid)
					+ tangent * (edge * width)
					+ Vector3.new(0, TIP_Y + 0.3, 0)
				table.insert(props, {
					name = `OfferingRim{k}{edge}{i}`,
					size = Vector3.new(TIP_H / TIP_SLICES + 0.1, 0.3, 0.5),
					position = centre,
					cframe = CFrame.fromMatrix(centre, radial, up, tangent),
					color = GOLD,
					material = Enum.Material.Neon,
					canCollide = false,
					castShadow = false,
				})
			end
		end
	end
end

local OFFERING_AT = Vector3.new(
	math.cos(pointBearing(OFFERING_POINT)) * OFFERING_R,
	0,
	math.sin(pointBearing(OFFERING_POINT)) * OFFERING_R
)

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

-- The obelisk is the only light on a dark waste, so it has to actually GLOW rather
-- than stand as a silhouette. A light INSIDE the stone lights nothing, so warm anchors
-- ring the shaft and wash its four faces, and five more sit at the star tips and pour
-- onto the sand. Invisible parts: the light is the prop.
local GLOW = Color3.fromRGB(255, 172, 86) -- the sand pool: warm
local WASH = Color3.fromRGB(232, 236, 246) -- the stone wash: near-neutral. Warm light on
-- grey stone turns it terracotta; only the flame and the sand pool are allowed to be warm.
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
			size = Vector3.new(0.3, 2 * OFFERING_ZONE_R, 2 * OFFERING_ZONE_R),
			position = OFFERING_AT + Vector3.new(0, 1.1, 0),
			rotation = Vector3.new(0, 0, 90),
			color = GOLD,
			material = Enum.Material.Neon,
			transparency = 0.84,
			canCollide = false,
			label = "OFFER",
			sublabel = "OR FEED IT TO THE FIRE",
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
	-- The WHOLE world is lit (Justin, 2026-09-12), not a pool with a void around it: a
	-- player anywhere on the 700-stud disk can see the sand, the dunes and the mesas on
	-- the horizon. Contrast is kept by the obelisk being the only warm light and the only
	-- thing that gets BRIGHTER, not by taking light away from everything else. Night
	-- lowers the sky; it never blinds the player.
	-- LightingStyle / Technology are plugin-only and set once in Studio.
	lighting = {
		ClockTime = 21.2,
		Brightness = 3,
		Ambient = Color3.fromRGB(86, 82, 88),
		OutdoorAmbient = Color3.fromRGB(132, 126, 130),
		ColorShift_Top = Color3.fromRGB(150, 140, 130),
		GlobalShadows = true,
		EnvironmentDiffuseScale = 0.25,
		EnvironmentSpecularScale = 0.15,
		atmosphere = {
			Density = 0.2,
			Offset = 0.15,
			Haze = 1.5,
			Color = Color3.fromRGB(122, 114, 110),
			Decay = Color3.fromRGB(66, 62, 66),
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

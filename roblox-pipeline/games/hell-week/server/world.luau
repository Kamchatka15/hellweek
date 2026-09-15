-- world — the place Hell Week happens, as data.
--
-- TWO LAYERS, and the split is the whole point:
--
--   FIXTURES  the obelisk's stone, the pentagram, the four world points, the offering
--             table, the camp's light. These never change. They are what the player
--             stands at while everything else becomes somewhere else.
--   BIOMES    one entry per world: its scenery, its ground, its day rig and its night
--             rig. Mastering a world swaps the entry, and 700 studs of desert becomes
--             700 studs of dead forest around a player who has not moved.
--
-- That is the "biome changes 360 degrees" the owner asked about (2026-09-12): not a
-- teleport to another map — the same ground rewritten around the same monument.
--
-- Scenery is generated (`tools/gen_biome.py` -> `server/scenery/<id>/`). Harvest nodes
-- and teepee chests are NOT here; the loop places those so they can restock.

local theme = require(game:GetService("ReplicatedStorage").Pack.theme)

local GOLD = Color3.fromRGB(255, 196, 64)

local PENT_R = 24 -- the star's outer radius: its inner pentagon (~9.2) clears the base
local SLAB_R = 30 -- so the obelisk stands INSIDE the pentagram
local PENT_Y = 0.56

local fixtures = {}
local vision = require(script.Parent.vision)

-- Vision palette pass over generated scenery, by part-name prefix. The chunks on disk
-- are already regenerated on the six colours; this makes an older chunk still in a
-- place read the same, and it is idempotent on a new one. Graphics only.
local function onPalette(data: any): any
	if not vision.on then
		return data
	end
	-- A chunk module returns { scenery = {...}, teepees = {...} }. The parts are the
	-- list under `scenery`; walking the wrapper recolours nothing, which is exactly
	-- what happened the first time.
	local specs = data.scenery or data
	local ASH = Color3.fromRGB(145, 125, 95)
	local STONE = Color3.fromRGB(45, 42, 40)
	local BONE = Color3.fromRGB(210, 200, 180)
	local MAP = {
		{ "Mound", ASH },
		{ "Wash", ASH },
		{ "Mesa", STONE },
		{ "Rubble", STONE },
		{ "Ruin", STONE },
		{ "Scrub", STONE },
		{ "Tree", STONE },
		{ "Bone", BONE },
	}
	for _, spec in specs do
		local name = spec.name or ""
		if string.sub(name, 1, 3) == "Tee" then
			-- teepees: poles charcoal, hide panels ash
			spec.color = if string.find(name, "_h") then ASH else STONE
		else
			for _, pair in MAP do
				if string.sub(name, 1, #pair[1]) == pair[1] then
					spec.color = pair[2]
					break
				end
			end
		end
	end
	return data
end

local function pointBearing(k: number): number
	return math.rad(90 + 72 * (k - 1))
end

local starPoints = {}
for k = 0, 4 do
	local a = math.rad(90 + 72 * k)
	starPoints[k + 1] = Vector3.new(math.cos(a) * PENT_R, PENT_Y, math.sin(a) * PENT_R)
end
for k = 1, 5 do
	local a = starPoints[k]
	local b = starPoints[(k + 1) % 5 + 1] -- every second point: the star, not the pentagon
	local mid = (a + b) / 2
	table.insert(fixtures, {
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
	table.insert(fixtures, {
		name = `Pentagram_Ring{i}`,
		size = Vector3.new(2 * math.pi * RING_R / RING_SEGMENTS + 0.3, 0.14, 1.1),
		position = pos,
		cframe = CFrame.lookAt(pos, Vector3.new(0, PENT_Y, 0)),
		color = GOLD,
		material = Enum.Material.Neon,
		canCollide = false,
		castShadow = false,
	})
end

-- ---------------------------------------------------------------- the five points
-- FOUR are worlds (`server/biomes.luau`) — dark while locked, red once open, green
-- once mastered — and the FIFTH carries the offering table. Point 1 faces spawn and is
-- the world you are standing in.
--
-- Each triangle fills the star's OUTWARD point, built as a fan of tapering strips. A
-- WedgePart's right-angle corner is a convention easy to get backwards, and the first
-- build had every triangle pointing inward at the obelisk.
local TIP_SLICES = 14
local INNER_R = PENT_R * 0.38197
local BASE_MID_R = INNER_R * math.cos(math.rad(36))
local TIP_H = PENT_R - BASE_MID_R
local TIP_HALF_BASE = INNER_R * math.sin(math.rad(36))

local OFFERING_POINT = 5
local TABLE_TOP_Y = 3.4 -- waist-high: a table seen from spawn, not a mark on the floor
local TABLE_R = 40 -- outside the 30-stud slab and the 26.5 ring: clear floor all round
local OFFERING_ZONE_R = 8

for k = 1, 4 do
	local a = pointBearing(k)
	local radial = Vector3.new(math.cos(a), 0, math.sin(a))
	local up = Vector3.yAxis
	local tangent = radial:Cross(up)
	for i = 1, TIP_SLICES do
		local t0, t1 = (i - 1) / TIP_SLICES, i / TIP_SLICES
		local mid = (t0 + t1) / 2
		local width = 2 * TIP_HALF_BASE * (1 - mid)
		local centre = radial * (BASE_MID_R + TIP_H * mid) + Vector3.new(0, PENT_Y + 0.06, 0)
		table.insert(fixtures, {
			name = `BiomePoint{k}_{i}`,
			size = Vector3.new(TIP_H / TIP_SLICES + 0.04, 0.16, width + 0.04),
			position = centre,
			cframe = CFrame.fromMatrix(centre, radial, up, tangent),
			color = Color3.fromRGB(22, 20, 26), -- locked: the client lights it
			material = Enum.Material.Neon,
			canCollide = false,
			castShadow = false,
		})
	end
end

-- ---------------------------------------------------------------- the offering
-- The TABLE stands OUTSIDE the pentagram (owner call, 2026-09-12: it did not work
-- where it was — a table sitting on the star had the player fighting its own legs to
-- reach it). It is out on the open ground at 40 studs along the fifth point's bearing,
-- facing the obelisk, with clear floor all round it.
--
-- The fifth POINT stays where it is and becomes the table's status light:
--   grey   nothing has been offered
--   blue   something is in it, but no recipe fits what is there
--   green  a sacrifice is ready — dawn will make something
-- The client paints it from the server's own answer; see SurviveLoop.offeringState.
local TABLE_AT
do
	local a = pointBearing(OFFERING_POINT)
	local radial = Vector3.new(math.cos(a), 0, math.sin(a))
	local up = Vector3.yAxis
	local tangent = radial:Cross(up)

	-- the status light: the same tapering fan as a world point, on the fifth point
	for i = 1, TIP_SLICES do
		local t0, t1 = (i - 1) / TIP_SLICES, i / TIP_SLICES
		local mid = (t0 + t1) / 2
		local width = 2 * TIP_HALF_BASE * (1 - mid)
		local centre = radial * (BASE_MID_R + TIP_H * mid) + Vector3.new(0, PENT_Y + 0.06, 0)
		table.insert(fixtures, {
			name = `OfferingPoint{i}`,
			size = Vector3.new(TIP_H / TIP_SLICES + 0.04, 0.16, width + 0.04),
			position = centre,
			cframe = CFrame.fromMatrix(centre, radial, up, tangent),
			color = Color3.fromRGB(74, 74, 82), -- grey: nothing offered
			material = Enum.Material.Neon,
			canCollide = false,
			castShadow = false,
		})
	end

	TABLE_AT = radial * TABLE_R
	local facing = CFrame.fromMatrix(Vector3.zero, -radial:Cross(up), up, -radial)
	local function at(offset: Vector3): CFrame
		return CFrame.new(TABLE_AT + Vector3.new(0, offset.Y, 0)) * facing * CFrame.new(offset.X, 0, offset.Z)
	end

	-- top slab
	table.insert(fixtures, {
		name = "OfferingTop",
		size = Vector3.new(10, 0.7, 5.6),
		position = TABLE_AT,
		cframe = at(Vector3.new(0, TABLE_TOP_Y, 0)),
		color = Color3.fromRGB(58, 56, 64),
		material = Enum.Material.Slate,
		canCollide = true,
	})
	-- gold lip round all four edges
	for li, edge in
		{
			{ Vector3.new(0, TABLE_TOP_Y + 0.44, 2.9), Vector3.new(10.4, 0.26, 0.5) },
			{ Vector3.new(0, TABLE_TOP_Y + 0.44, -2.9), Vector3.new(10.4, 0.26, 0.5) },
			{ Vector3.new(5.1, TABLE_TOP_Y + 0.44, 0), Vector3.new(0.5, 0.26, 6.2) },
			{ Vector3.new(-5.1, TABLE_TOP_Y + 0.44, 0), Vector3.new(0.5, 0.26, 6.2) },
		}
	do
		table.insert(fixtures, {
			name = `OfferingLip{li}`,
			size = edge[2],
			position = TABLE_AT,
			cframe = at(edge[1]),
			color = GOLD,
			material = Enum.Material.Neon,
			canCollide = false,
			castShadow = false,
		})
	end
	-- legs
	for li, foot in
		{ Vector3.new(4.2, 0, 2.1), Vector3.new(-4.2, 0, 2.1), Vector3.new(4.2, 0, -2.1), Vector3.new(-4.2, 0, -2.1) }
	do
		table.insert(fixtures, {
			name = `OfferingLeg{li}`,
			size = Vector3.new(0.9, TABLE_TOP_Y, 0.9),
			position = TABLE_AT,
			cframe = at(Vector3.new(foot.X, TABLE_TOP_Y / 2, foot.Z)),
			color = Color3.fromRGB(44, 42, 50),
			material = Enum.Material.Slate,
			canCollide = true,
		})
	end
	-- the hollow things go into
	table.insert(fixtures, {
		name = "OfferingHollow",
		shape = Enum.PartType.Cylinder,
		size = Vector3.new(0.35, 4.4, 4.4),
		position = TABLE_AT,
		cframe = at(Vector3.new(0, TABLE_TOP_Y + 0.36, 0)) * CFrame.Angles(0, 0, math.pi / 2),
		color = Color3.fromRGB(16, 15, 19),
		material = Enum.Material.SmoothPlastic,
		canCollide = false,
		castShadow = false,
	})
	-- two standing stones behind it, so the table reads as a place from a distance
	for li, side in { -1, 1 } do
		table.insert(fixtures, {
			name = `OfferingStone{li}`,
			size = Vector3.new(1.5, 7.5, 1.5),
			position = TABLE_AT,
			cframe = at(Vector3.new(side * 6.4, 3.75, -1.4)) * CFrame.Angles(0, 0, math.rad(side * 4)),
			color = Color3.fromRGB(48, 46, 54),
			material = Enum.Material.Slate,
			canCollide = true,
		})
	end
end

local OFFERING_AT = Vector3.new(TABLE_AT.X, 0, TABLE_AT.Z)

-- ---------------------------------------------------------------- the camp's light
-- A light INSIDE the stone lights nothing, so warm anchors ring the shaft and wash its
-- four faces, and five more sit at the star tips and pour onto the ground. Invisible
-- parts: the light is the prop. The loop turns these down by day.
local GLOW = Color3.fromRGB(255, 172, 86)
local WASH = Color3.fromRGB(232, 236, 246) -- near-neutral: warm light on grey stone reads terracotta
for k = 1, 4 do
	local a = (k / 4) * math.pi * 2 + math.pi / 4
	table.insert(fixtures, {
		name = `ObeliskGlow{k}`,
		size = Vector3.new(0.4, 0.4, 0.4),
		position = Vector3.new(math.cos(a) * 9, 9, math.sin(a) * 9),
		transparency = 1,
		canCollide = false,
		castShadow = false,
		light = { color = WASH, brightness = 1.15, range = 24 },
	})
end
for k = 1, 5 do
	local a = math.rad(90 + 72 * k)
	table.insert(fixtures, {
		name = `StarGlow{k}`,
		size = Vector3.new(0.4, 0.4, 0.4),
		position = Vector3.new(math.cos(a) * (PENT_R - 2), 2.2, math.sin(a) * (PENT_R - 2)),
		transparency = 1,
		canCollide = false,
		castShadow = false,
		light = { color = GLOW, brightness = 1.5, range = 26 },
	})
end

-- ---------------------------------------------------------------- the four worlds
local function floorOf(color: Color3, material: Enum.Material)
	-- A cylinder on its side is a vertical-axis disc. 700 studs across.
	return {
		shape = Enum.PartType.Cylinder,
		size = Vector3.new(4, 700, 700),
		position = Vector3.new(0, -2, 0),
		rotation = Vector3.new(0, 0, 90),
		color = color,
		material = material,
	}
end

local biomes = {
	["ashen-waste"] = {
		data = onPalette(require(script.Parent.scenery["ashen-waste"])),
		floor = floorOf(theme.colors.sand, Enum.Material.Sand),
		fog = { 200, 290, 350 },
		-- DAY. The waste is bright and exposed — brighter than the camp at its centre.
		-- Heavy sand haze bleaches the sky white-hot instead of the postcard blue Roblox
		-- gives for free; saturation alone will not take that away. Low sun for long
		-- hard shadows. Bright AND wrong, not bright and pleasant.
		day = {
			-- VISION day profile. Grey-beige overcast, low contrast, the horizon dying
			-- in haze rather than a postcard-blue sky. Numbers are the brief's.
			ClockTime = 15.2,
			Brightness = 1.15,
			Ambient = Color3.fromRGB(88, 78, 68),
			OutdoorAmbient = Color3.fromRGB(108, 98, 84),
			ColorShift_Top = Color3.fromRGB(168, 152, 128),
			ColorShift_Bottom = Color3.fromRGB(145, 125, 95),
			GlobalShadows = true,
			EnvironmentDiffuseScale = 0.5,
			EnvironmentSpecularScale = 0.2,
			FogEnd = 1400,
			atmosphere = {
				Density = 0.38,
				Offset = 0.18,
				Haze = 2.4,
				Glare = 0.08,
				Color = Color3.fromRGB(168, 152, 128),
				Decay = Color3.fromRGB(118, 92, 68),
			},
			colorCorrection = {
				Saturation = -0.28,
				Contrast = 0.14,
				Brightness = -0.04,
				TintColor = Color3.fromRGB(255, 236, 214),
			},
			bloom = { Intensity = 0.25, Size = 10, Threshold = 1.15 },
		},
		night = {
			ClockTime = 22.1,
			Brightness = 0.9,
			Ambient = Color3.fromRGB(30, 31, 40),
			OutdoorAmbient = Color3.fromRGB(52, 54, 70),
			ColorShift_Top = Color3.fromRGB(96, 104, 138),
			ColorShift_Bottom = Color3.fromRGB(26, 28, 38),
			EnvironmentDiffuseScale = 0.2,
			EnvironmentSpecularScale = 0.12,
			FogEnd = 700,
			atmosphere = {
				Density = 0.42,
				Offset = 0.15,
				Haze = 2.6,
				Color = Color3.fromRGB(70, 76, 96),
				Decay = Color3.fromRGB(34, 38, 50),
				Glare = 0,
			},
			colorCorrection = {
				Contrast = 0.16,
				Saturation = -0.05,
				Brightness = -0.02,
				TintColor = Color3.fromRGB(206, 216, 240),
			},
			bloom = { Intensity = 0.8, Size = 30, Threshold = 1 },
		},
	},

	["still-wood"] = {
		data = require(script.Parent.scenery["still-wood"]),
		floor = floorOf(Color3.fromRGB(76, 80, 68), Enum.Material.Ground),
		fog = { 170, 260, 330 }, -- tighter: the trees already take the sightlines
		day = {
			ClockTime = 9.6,
			Brightness = 1.9,
			Ambient = Color3.fromRGB(74, 80, 74),
			OutdoorAmbient = Color3.fromRGB(112, 120, 112),
			ColorShift_Top = Color3.fromRGB(206, 214, 198),
			ColorShift_Bottom = Color3.fromRGB(70, 78, 70),
			GlobalShadows = true,
			EnvironmentDiffuseScale = 0.4,
			EnvironmentSpecularScale = 0.18,
			FogEnd = 900,
			atmosphere = {
				Density = 0.48,
				Offset = 0.12,
				Haze = 3.4,
				Color = Color3.fromRGB(176, 184, 172),
				Decay = Color3.fromRGB(118, 126, 116),
				Glare = 0.2,
			},
			colorCorrection = {
				Contrast = 0.1,
				Saturation = -0.3,
				Brightness = 0,
				TintColor = Color3.fromRGB(238, 246, 236),
			},
			bloom = { Intensity = 0.4, Size = 24, Threshold = 1.5 },
		},
		night = {
			ClockTime = 23.2,
			Brightness = 0.5,
			Ambient = Color3.fromRGB(20, 24, 24),
			OutdoorAmbient = Color3.fromRGB(34, 40, 44),
			ColorShift_Top = Color3.fromRGB(70, 84, 88),
			ColorShift_Bottom = Color3.fromRGB(18, 22, 24),
			EnvironmentDiffuseScale = 0.14,
			EnvironmentSpecularScale = 0.1,
			FogEnd = 480,
			atmosphere = {
				Density = 0.62,
				Offset = 0.15,
				Haze = 3.6,
				Color = Color3.fromRGB(48, 58, 60),
				Decay = Color3.fromRGB(22, 28, 30),
				Glare = 0,
			},
			colorCorrection = {
				Contrast = 0.2,
				Saturation = -0.08,
				Brightness = -0.03,
				TintColor = Color3.fromRGB(198, 216, 216),
			},
			bloom = { Intensity = 0.9, Size = 32, Threshold = 0.95 },
		},
	},

	["drowned-quarter"] = {
		data = require(script.Parent.scenery["drowned-quarter"]),
		floor = floorOf(Color3.fromRGB(58, 62, 66), Enum.Material.Slate),
		fog = { 190, 280, 340 },
		day = {
			ClockTime = 6.4,
			Brightness = 1.6,
			Ambient = Color3.fromRGB(70, 78, 86),
			OutdoorAmbient = Color3.fromRGB(112, 124, 136),
			ColorShift_Top = Color3.fromRGB(198, 214, 226),
			ColorShift_Bottom = Color3.fromRGB(64, 74, 84),
			GlobalShadows = true,
			EnvironmentDiffuseScale = 0.45,
			EnvironmentSpecularScale = 0.5,
			FogEnd = 1000,
			atmosphere = {
				Density = 0.44,
				Offset = 0.12,
				Haze = 3.8,
				Color = Color3.fromRGB(168, 184, 198),
				Decay = Color3.fromRGB(104, 120, 134),
				Glare = 0.3,
			},
			colorCorrection = {
				Contrast = 0.08,
				Saturation = -0.28,
				Brightness = 0,
				TintColor = Color3.fromRGB(236, 246, 255),
			},
			bloom = { Intensity = 0.45, Size = 26, Threshold = 1.4 },
		},
		night = {
			ClockTime = 22.6,
			Brightness = 0.6,
			Ambient = Color3.fromRGB(20, 26, 32),
			OutdoorAmbient = Color3.fromRGB(36, 46, 58),
			ColorShift_Top = Color3.fromRGB(72, 92, 116),
			ColorShift_Bottom = Color3.fromRGB(16, 22, 30),
			EnvironmentDiffuseScale = 0.16,
			EnvironmentSpecularScale = 0.4,
			FogEnd = 560,
			atmosphere = {
				Density = 0.58,
				Offset = 0.15,
				Haze = 3.2,
				Color = Color3.fromRGB(52, 66, 82),
				Decay = Color3.fromRGB(24, 32, 42),
				Glare = 0,
			},
			colorCorrection = {
				Contrast = 0.18,
				Saturation = -0.06,
				Brightness = -0.02,
				TintColor = Color3.fromRGB(202, 220, 244),
			},
			bloom = { Intensity = 0.9, Size = 30, Threshold = 0.95 },
		},
	},

	["the-kiln"] = {
		data = require(script.Parent.scenery["the-kiln"]),
		floor = floorOf(Color3.fromRGB(74, 48, 42), Enum.Material.Basalt),
		fog = { 210, 300, 350 },
		-- The one world where the ground itself glows: ember light on every surface is
		-- what makes the safe circle almost impossible to read.
		day = {
			ClockTime = 17.9,
			Brightness = 2.2,
			Ambient = Color3.fromRGB(96, 62, 52),
			OutdoorAmbient = Color3.fromRGB(140, 88, 68),
			ColorShift_Top = Color3.fromRGB(255, 168, 110),
			ColorShift_Bottom = Color3.fromRGB(96, 48, 36),
			GlobalShadows = true,
			EnvironmentDiffuseScale = 0.5,
			EnvironmentSpecularScale = 0.25,
			FogEnd = 1000,
			atmosphere = {
				Density = 0.4,
				Offset = 0.12,
				Haze = 4,
				Color = Color3.fromRGB(210, 130, 90),
				Decay = Color3.fromRGB(140, 74, 52),
				Glare = 0.8,
			},
			colorCorrection = {
				Contrast = 0.14,
				Saturation = -0.12,
				Brightness = 0,
				TintColor = Color3.fromRGB(255, 232, 218),
			},
			bloom = { Intensity = 0.7, Size = 28, Threshold = 1.2 },
		},
		night = {
			ClockTime = 23.6,
			Brightness = 0.55,
			Ambient = Color3.fromRGB(44, 24, 20),
			OutdoorAmbient = Color3.fromRGB(66, 34, 26),
			ColorShift_Top = Color3.fromRGB(128, 56, 36),
			ColorShift_Bottom = Color3.fromRGB(30, 14, 12),
			EnvironmentDiffuseScale = 0.18,
			EnvironmentSpecularScale = 0.14,
			FogEnd = 600,
			atmosphere = {
				Density = 0.56,
				Offset = 0.15,
				Haze = 3,
				Color = Color3.fromRGB(96, 44, 30),
				Decay = Color3.fromRGB(44, 20, 16),
				Glare = 0.2,
			},
			colorCorrection = {
				Contrast = 0.2,
				Saturation = 0,
				Brightness = -0.02,
				TintColor = Color3.fromRGB(255, 226, 210),
			},
			bloom = { Intensity = 1.1, Size = 34, Threshold = 0.9 },
		},
	},
}

local START = "ashen-waste"

return {
	floor = biomes[START].floor,
	props = (function()
		if not vision.on then
			return fixtures
		end

		-- HIDE, do not delete. Every neon or bright fixture of the old camp stays as
		-- an instance, invisible, lightless, in a folder of its own, so it can be
		-- compared against or restored with one flag.
		local HIDE = { "Pentagram_", "StarGlow", "ObeliskGlow", "BiomePoint", "OfferingPoint" }
		for _, spec in fixtures do
			for _, prefix in HIDE do
				if string.sub(spec.name or "", 1, #prefix) == prefix then
					spec.transparency = 1
					spec.canCollide = false
					spec.light = nil
					spec.fire = nil
					spec.group = "VisionRework_Hidden"
					break
				end
			end
		end

		local STONE = Color3.fromRGB(45, 42, 40)
		local BONE = Color3.fromRGB(210, 200, 180)
		local GOLD_METAL = Color3.fromRGB(212, 168, 62)
		-- The offering table stays (functional) but joins the palette: lips are gold
		-- metal rather than neon, and every stone part is charcoal.
		for _, spec in fixtures do
			local name = spec.name or ""
			if string.sub(name, 1, 11) == "OfferingLip" then
				spec.color = GOLD_METAL
				spec.material = Enum.Material.Metal
				spec.castShadow = true
			elseif string.sub(name, 1, 8) == "Offering" and string.sub(name, 1, 13) ~= "OfferingPoint" then
				if name ~= "OfferingHollow" then
					spec.color = STONE
				end
			end
		end
		local out = table.clone(fixtures)
		local function add(spec)
			spec.group = "VisionRework"
			table.insert(out, spec)
		end

		-- Dead trees: four clusters of three, no grid, sizes 0.7 to 1.8. Charcoal, as
		-- burnt wood is in an ash desert. A fixed seed so the camp is the same camp
		-- every time you open the place.
		local rng = Random.new(7)
		local clusters = { 62, 148, 214, 301 } -- bearings, degrees
		for c, bearing in clusters do
			local dist = rng:NextNumber(58, 108)
			local cx = math.cos(math.rad(bearing)) * dist
			local cz = math.sin(math.rad(bearing)) * dist
			for t = 1, 3 do
				local scale = rng:NextNumber(0.7, 1.8)
				local ox = rng:NextNumber(-9, 9)
				local oz = rng:NextNumber(-9, 9)
				local lean = rng:NextNumber(-7, 7)
				local yaw = rng:NextNumber(0, 360)
				local h = 11 * scale
				local x, z = cx + ox, cz + oz
				add({
					name = `DeadTree{c}_{t}_trunk`,
					shape = Enum.PartType.Cylinder,
					size = Vector3.new(h, 1.1 * scale, 1.1 * scale),
					position = Vector3.new(x, h / 2, z),
					rotation = Vector3.new(lean, yaw, 90),
					color = STONE,
					material = Enum.Material.Wood,
				})
				for b = 1, 2 do
					local bh = h * rng:NextNumber(0.35, 0.55)
					local pitch = rng:NextNumber(28, 52) * (if b == 1 then 1 else -1)
					local by = h * rng:NextNumber(0.55, 0.85)
					add({
						name = `DeadTree{c}_{t}_b{b}`,
						shape = Enum.PartType.Cylinder,
						size = Vector3.new(bh, 0.55 * scale, 0.55 * scale),
						position = Vector3.new(x, by, z),
						rotation = Vector3.new(lean + pitch, yaw + rng:NextNumber(-40, 40), 90 - pitch * 0.6),
						color = STONE,
						material = Enum.Material.Wood,
						canCollide = false,
					})
				end
			end
		end

		-- One distant stepped pyramid. Large, and meant to be half-lost in the haze:
		-- a landmark to walk toward, not a place.
		do
			-- Bearing 250: over the obelisk's left shoulder as seen from spawn, so it is
			-- IN the frame-1 camera rather than behind it.
			local bearing, dist = 250, 330
			local px = math.cos(math.rad(bearing)) * dist
			local pz = math.sin(math.rad(bearing)) * dist
			local base, tiers, height = 64, 5, 42
			local step = height / tiers
			local y = 0
			for i = 1, tiers do
				local w = base * (1 - (i - 1) / tiers * 0.82)
				add({
					name = `Pyramid_{i}`,
					size = Vector3.new(w, step, w),
					position = Vector3.new(px, y + step / 2, pz),
					rotation = Vector3.new(0, 24, 0),
					color = Color3.fromRGB(90, 82, 72),
					material = Enum.Material.Slate,
				})
				y += step
			end
		end

		-- Three loot-looking things on the sand near the disc. Dressing only.
		add({
			name = "Dress_BoneSticks",
			shape = Enum.PartType.Cylinder,
			size = Vector3.new(3.4, 0.5, 0.5),
			position = Vector3.new(29, 0.25, 9),
			rotation = Vector3.new(0, 32, 0),
			color = BONE,
			material = Enum.Material.SmoothPlastic,
			canCollide = false,
		})
		add({
			name = "Dress_BoneSticks2",
			shape = Enum.PartType.Cylinder,
			size = Vector3.new(2.6, 0.45, 0.45),
			position = Vector3.new(30.6, 0.22, 10.4),
			rotation = Vector3.new(0, 74, 0),
			color = BONE,
			material = Enum.Material.SmoothPlastic,
			canCollide = false,
		})
		add({
			name = "Dress_CharcoalRock",
			shape = Enum.PartType.Ball,
			size = Vector3.new(2.2, 1.6, 1.9),
			position = Vector3.new(-31, 0.7, -14),
			color = Color3.fromRGB(28, 26, 24),
			material = Enum.Material.Slate,
			canCollide = false,
		})
		add({
			name = "Dress_GoldChunk",
			size = Vector3.new(1.3, 0.9, 1.1),
			position = Vector3.new(-12, 0.45, 33),
			rotation = Vector3.new(12, 41, 8),
			color = Color3.fromRGB(196, 150, 48),
			material = Enum.Material.Metal,
			canCollide = false,
		})
		return out
	end)(),
	biomes = biomes,

	zones = {
		{
			id = "offering",
			kind = "offering",
			shape = Enum.PartType.Cylinder,
			size = Vector3.new(0.3, 2 * OFFERING_ZONE_R, 2 * OFFERING_ZONE_R),
			position = OFFERING_AT + Vector3.new(0, 0.7, 0),
			rotation = Vector3.new(0, 0, 90),
			color = GOLD,
			material = Enum.Material.Neon,
			transparency = if vision.on then 1 else 0.88,
			canCollide = false,
			-- No standing sign. It was two lines of shouting over the table for the
			-- whole run. Point at the table and press I: there is room there to say
			-- what it does AND what is currently in it.
			label = nil,
			sublabel = nil,
		},
		{
			id = "obelisk",
			kind = "beacon",
			shape = Enum.PartType.Cylinder,
			size = Vector3.new(0.5, 2 * SLAB_R, 2 * SLAB_R),
			position = Vector3.new(0, 0.25, 0),
			rotation = Vector3.new(0, 0, 90),
			color = Color3.fromRGB(40, 40, 44),
			material = Enum.Material.Slate,
			-- The vision's disc is the visual; this zone is only the feed trigger now.
			transparency = if vision.on then 1 else 0,
			canCollide = true,
		},
	},

	spawn = {
		position = Vector3.new(0, 0.5, 62), -- 32 studs of ground before the stone edge
		lookAt = Vector3.new(0, 6, 0),
		transparency = 0.85,
		color = theme.colors.sand,
	},

	-- The boot rig is the starting world's day. Every swap replaces it.
	-- LightingStyle / Technology are plugin-only and set once in Studio.
	lighting = biomes[START].day,
}

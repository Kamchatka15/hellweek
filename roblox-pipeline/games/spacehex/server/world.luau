-- world — the grey-box layout, as data.
--
-- Built at run time by ContentLoader rather than placed in Studio, so the repo alone is
-- a playable game and the layout diffs like code. Distances are the design:
--   spawn -> pad is 20 studs (about two seconds), so the first thing a stranger sees is
--   the pad and the rocket standing on it. Pad -> hangar is 64 studs: the rocket rolls
--   out along that line, which is what makes "roll out" a verb you can watch.
--
-- The hexagon is the identity. A six-clamp ring around a round pad reads as a hex from
-- every angle and from directly above, and costs six primitives.

local theme = require(game:GetService("ReplicatedStorage").Pack.theme)

local PAD = Vector3.new(0, 0, -30)
local CLAMP_R = 17

-- Six clamps at 60 degrees. This is the logo.
local function clamps()
	local out = {}
	for i = 0, 5 do
		local a = math.rad(i * 60)
		out[i + 1] = {
			name = `Clamp{i + 1}`,
			size = Vector3.new(3, 26, 3),
			position = PAD + Vector3.new(math.cos(a) * CLAMP_R, 13, math.sin(a) * CLAMP_R),
			color = theme.wall,
			material = Enum.Material.Metal,
		}
	end
	return out
end

local props = clamps()

-- The gantry. Tall, off to one side, so the pad has a silhouette from the spawn point
-- before anything has launched — the scene has to say "rocket" at a glance.
table.insert(props, {
	name = "GantryTower",
	size = Vector3.new(5, 62, 5),
	position = PAD + Vector3.new(26, 31, 0),
	color = theme.wall,
	material = Enum.Material.Metal,
})
table.insert(props, {
	name = "GantryArm",
	size = Vector3.new(22, 2.5, 3),
	position = PAD + Vector3.new(15, 40, 0),
	color = theme.wall,
	material = Enum.Material.Metal,
})

-- Hangar shell behind the assembly zone, so "the hangar" points at a building.
table.insert(props, {
	name = "HangarShell",
	size = Vector3.new(34, 18, 22),
	position = Vector3.new(0, 9, 46),
	color = theme.wall,
	material = Enum.Material.Metal,
	transparency = 0.15,
})

-- Four perimeter masts. They are also the only thing marking the apron's edge.
for i, p in ipairs({
	Vector3.new(-52, 11, -52),
	Vector3.new(52, 11, -52),
	Vector3.new(-52, 11, 52),
	Vector3.new(52, 11, 52),
}) do
	table.insert(props, {
		name = `Mast{i}`,
		size = Vector3.new(2, 22, 2),
		position = p,
		color = theme.wall,
		material = Enum.Material.Metal,
	})
end

return {
	floor = {
		size = Vector3.new(190, 2, 190),
		position = Vector3.new(0, -1, 0),
		color = theme.floor,
		material = Enum.Material.Concrete,
	},

	-- Walls mark the apron's edge so a dropped stage never slides out of the world.
	walls = {
		height = 16,
		thickness = 2,
		color = theme.wall,
		material = Enum.Material.SmoothPlastic,
		transparency = 0.4,
	},

	props = props,

	-- The three places the loop lives. Their kinds are the build family's contract
	-- (BuildLoop.validate): walking onto one opens that screen.
	zones = {
		{
			id = "pad",
			kind = "pad",
			shape = Enum.PartType.Cylinder,
			rotation = Vector3.new(0, 0, 90), -- lay the cylinder flat
			size = Vector3.new(1, 24, 24),
			position = PAD + Vector3.new(0, 0.5, 0),
			color = theme.pad,
			material = Enum.Material.DiamondPlate,
			label = "LAUNCH PAD",
			sublabel = "ROLL OUT, THEN LAUNCH",
		},
		{
			id = "hangar",
			kind = "assembly",
			size = Vector3.new(20, 1, 20),
			position = Vector3.new(0, 0.5, 34),
			color = theme.hangar,
			material = Enum.Material.Metal,
			label = "HANGAR",
			sublabel = "STACK YOUR ROCKET",
		},
		{
			id = "parts",
			kind = "warehouse",
			size = Vector3.new(14, 1, 14),
			position = Vector3.new(-36, 0.5, 2),
			color = theme.warehouse,
			material = Enum.Material.Metal,
			label = "WAREHOUSE",
			sublabel = "BUY PARTS",
		},
	},

	-- THE LIGHTING RIG. Applied from data at boot (ContentLoader.applyLighting); default
	-- lighting is a fail (docs/OPERATING_MANUAL.md §5). The visual bet: a hard black sky,
	-- one hard white sun, no fog, and the only warm colour on screen is the fire under
	-- the rocket and the altitude ribbon. Every comp is a busy blue Earth plate.
	--
	-- One property cannot be set from a script: Lighting.Technology = Future is a
	-- plugin-only click for Justin (games/hell-week/lighting.md found this).
	lighting = {
		ClockTime = 13.4,
		Brightness = 2.6,
		ExposureCompensation = -0.15,
		Ambient = Color3.fromRGB(6, 7, 10),
		OutdoorAmbient = Color3.fromRGB(18, 20, 26),
		ColorShift_Top = Color3.fromRGB(255, 252, 246),
		ColorShift_Bottom = Color3.fromRGB(0, 0, 0),
		ShadowSoftness = 0.08,
		GlobalShadows = true,
		EnvironmentDiffuseScale = 0.15,
		EnvironmentSpecularScale = 0.5,
		FogStart = 100000,
		FogEnd = 200000,
		-- No skybox faces: the renderer draws nothing behind the world, which is the
		-- black we want, with the sun disc still drawn and a field of stars.
		sky = {
			SkyboxBk = "",
			SkyboxDn = "",
			SkyboxFt = "",
			SkyboxLf = "",
			SkyboxRt = "",
			SkyboxUp = "",
			CelestialBodiesShown = true,
			StarCount = 3000,
			SunAngularSize = 14,
			MoonAngularSize = 0,
		},
		-- Air with no colour in it: density for the sun's glare to bite, no haze, and
		-- black scattering so the sky stays black to the horizon.
		atmosphere = {
			Density = 0.22,
			Offset = 0,
			Haze = 0,
			Glare = 0.25,
			Color = Color3.fromRGB(0, 0, 0),
			Decay = Color3.fromRGB(0, 0, 0),
		},
		colorCorrection = {
			Contrast = 0.15,
			Saturation = -0.08,
			Brightness = 0,
			TintColor = Color3.fromRGB(236, 240, 255),
		},
		-- Bloom only where something is actually bright: the exhaust and the neon
		-- pieces. The steel and the concrete never glow.
		bloom = { Intensity = 0.35, Size = 24, Threshold = 1.25 },
	},

	spawn = {
		position = Vector3.new(0, 0.5, -10),
		lookAt = PAD, -- face the pad on arrival; the first thing you see is the rocket
	},
}

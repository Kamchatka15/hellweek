-- config — every tuning number for Hell Week, world 1: The Ashen Waste.
--
-- Server-only: nothing here replicates. These are Pass 1 candidates, simulated in
-- games/hell-week/economy.md before being frozen. Days 4-7 are escalation defaults
-- and are PARKED tuning: the clock reaches them, the numbers are not the ones we mean.
--
-- The first-minute arithmetic they are chosen to produce:
--   spawn is 62 studs out; deadfall sits on the line in
--   -> pick one up (~4s), walk it to the stone (~3s), the radius pops 25 -> 33
--   -> the Tempter appears on the light-line, still. Night 1 it never moves.
--   -> Day 1 burns 3 over 45s, and Ring A alone holds more than that

return {
	loop = "survive",

	-- The five worlds, one per pentagram point (`biomes.luau`). This pack builds the
	-- first; the rest are the roadmap the stone draws.
	worlds = require(script.Parent.biomes),
	worldId = "ashen-waste",

	-- The floor top. Everything that sits on the sand is placed from this.
	groundY = 0,

	-- Six slots, because a desert has three raw resources and the recipes need room
	-- to hold two kinds at once.
	sack = { cap = 6 },

	-- ---------------------------------------------------------------- items
	-- `fuel` is what one burns for. Zero means it is not fuel — cactus and stone are
	-- crafting stock, and the obelisk is the only thing that turns them into anything.
	items = {
		ashwood = {
			label = "Ashwood",
			fuel = 1,
			size = Vector3.new(1.1, 1.1, 3.4),
			color = Color3.fromRGB(196, 176, 142),
			material = Enum.Material.Wood,
		},
		cactus = {
			label = "Cactus",
			fuel = 0,
			size = Vector3.new(1.5, 2.6, 1.5),
			color = Color3.fromRGB(92, 122, 82),
			material = Enum.Material.Grass,
		},
		stone = {
			label = "Stone",
			fuel = 0,
			shape = Enum.PartType.Ball,
			size = Vector3.new(1.9, 1.5, 1.7),
			color = Color3.fromRGB(108, 96, 84),
			material = Enum.Material.Slate,
		},
		water = {
			label = "Water",
			fuel = 0,
			size = Vector3.new(1.3, 1.9, 1.3),
			color = Color3.fromRGB(92, 178, 198),
			material = Enum.Material.Neon,
			glow = { color = Color3.fromRGB(110, 200, 220), brightness = 1, range = 8 },
		},
		emberwood = {
			label = "Emberwood",
			fuel = 3,
			size = Vector3.new(1.3, 1.3, 3.6),
			color = Color3.fromRGB(196, 118, 52),
			material = Enum.Material.Wood,
			glow = { color = Color3.fromRGB(255, 150, 60), brightness = 1.1, range = 9 },
		},
		heartwood = {
			label = "Heartwood",
			fuel = 8,
			size = Vector3.new(1.6, 1.6, 4),
			color = Color3.fromRGB(255, 196, 64),
			material = Enum.Material.Neon,
			glow = { color = Color3.fromRGB(255, 200, 90), brightness = 1.8, range = 14 },
		},
		wardstone = {
			label = "Wardstone",
			fuel = 0,
			onFeed = "liftWeight", -- fed to the fire, it takes one Weight off you
			shape = Enum.PartType.Ball,
			size = Vector3.new(2, 1.7, 1.9),
			color = Color3.fromRGB(150, 200, 210),
			material = Enum.Material.Neon,
			glow = { color = Color3.fromRGB(140, 200, 220), brightness = 1.4, range = 11 },
		},
	},

	-- ---------------------------------------------------------------- the workbench
	-- The obelisk IS the bench. Offer a sack into the bowl and these run on it at
	-- dawn, in this order — two cactus become water BEFORE water tempers wood, so a
	-- sack of cactus and ashwood cascades on its own. Leftovers that match nothing
	-- come back one tier up anyway (`offering.multiplier`), so an offering is never a
	-- waste, only less clever than it could have been.
	recipes = {
		{
			id = "press_water",
			label = "Cactus, pressed",
			inputs = { cactus = 2 },
			outputs = { water = 1 },
		},
		{
			id = "temper_wood",
			label = "Wood, water-tempered",
			inputs = { water = 1, ashwood = 2 },
			outputs = { emberwood = 1 },
		},
		{
			id = "quicken_heart",
			label = "Heartwood",
			inputs = { water = 1, emberwood = 1 },
			outputs = { heartwood = 1 },
		},
		{
			id = "cut_ward",
			label = "Wardstone",
			inputs = { water = 1, stone = 2 },
			outputs = { wardstone = 1 },
		},
	},

	-- What the bowl does with anything the recipes did not want.
	offering = {
		multiplier = 1.6,
		scatter = 13, -- studs from the obelisk that worked goods are laid out
		ladder = { "ashwood", "emberwood", "heartwood" }, -- the value ladder for leftovers
	},

	-- ---------------------------------------------------------------- the obelisk
	beacon = {
		position = Vector3.new(0, 0, 0),
		parts = require(script.Parent.obelisk),
		flameName = "CapFlame",
		facing = CFrame.Angles(0, 0, 0),
		feedRadius = 30, -- the pentagram stone's edge: step onto the star and you feed
		lightOffset = Vector3.new(0, 3, 0),
		startingFuel = 0,
		fuelCap = 15,
		radiusBase = 25,
		radiusPerFuel = 8,
		radiusCap = 90,
		levelThresholds = { 8, 20 },
		lightBrightness = 3.2,
		flameSize = Vector3.new(1.7, 1.7, 1.7),
	},

	-- One row per day. `stalker` is what it does at night: watch (stand still on the
	-- line) or hunt (walk toward anyone outside the light).
	days = {
		{ day = 100, night = 45, burn = 3, stalker = "watch" },
		{ day = 100, night = 50, burn = 4, stalker = "hunt" },
		{ day = 95, night = 55, burn = 6, stalker = "hunt" },
		-- PARKED tuning below: escalation placeholders so the week has a shape
		{ day = 90, night = 60, burn = 8, stalker = "hunt" },
		{ day = 85, night = 65, burn = 10, stalker = "hunt" },
		{ day = 80, night = 70, burn = 12, stalker = "hunt" },
		{ day = 75, night = 75, burn = 14, stalker = "hunt" },
	},

	-- ---------------------------------------------------------------- harvesting
	-- A node is a thing standing in the world that gives one item and is gone until
	-- dawn. `parts` is its look, built relative to the node's base.
	pickupRadius = 6,
	maxNodes = 150,

	resources = {
		{
			kind = "ashwood",
			node = "Deadfall",
			rings = {
				{ inner = 34, outer = 62, level = 0, count = 7, path = 3 },
				{ inner = 62, outer = 200, level = 0, count = 22 },
				{ inner = 200, outer = 290, level = 1, count = 14 },
				{ inner = 290, outer = 345, level = 2, count = 8 },
			},
			parts = {
				{
					shape = Enum.PartType.Cylinder,
					size = Vector3.new(4.6, 0.95, 0.95),
					offset = Vector3.new(0, 0.5, 0),
					rotation = Vector3.new(0, 20, 90),
					color = Color3.fromRGB(126, 110, 90),
					material = Enum.Material.Wood,
				},
				{
					shape = Enum.PartType.Cylinder,
					size = Vector3.new(3.4, 0.8, 0.8),
					offset = Vector3.new(0.4, 0.5, 0.7),
					rotation = Vector3.new(0, -35, 90),
					color = Color3.fromRGB(112, 98, 80),
					material = Enum.Material.Wood,
				},
				{
					shape = Enum.PartType.Cylinder,
					size = Vector3.new(2.6, 0.6, 0.6),
					offset = Vector3.new(-0.5, 1.1, -0.4),
					rotation = Vector3.new(8, 68, 90),
					color = Color3.fromRGB(134, 118, 96),
					material = Enum.Material.Wood,
				},
			},
		},
		{
			kind = "cactus",
			node = "Cactus",
			rings = {
				{ inner = 40, outer = 200, level = 0, count = 20 },
				{ inner = 200, outer = 290, level = 1, count = 12 },
				{ inner = 290, outer = 345, level = 2, count = 7 },
			},
			parts = {
				{
					shape = Enum.PartType.Cylinder,
					size = Vector3.new(11, 2.6, 2.6),
					offset = Vector3.new(0, 5.5, 0),
					rotation = Vector3.new(0, 0, 90),
					color = Color3.fromRGB(88, 118, 80),
					material = Enum.Material.Grass,
				},
				{
					shape = Enum.PartType.Ball,
					size = Vector3.new(2.6, 2.2, 2.6),
					offset = Vector3.new(0, 10.8, 0),
					color = Color3.fromRGB(96, 126, 86),
					material = Enum.Material.Grass,
				},
				{
					shape = Enum.PartType.Cylinder,
					size = Vector3.new(3.6, 1.5, 1.5),
					offset = Vector3.new(1.8, 6.4, 0),
					color = Color3.fromRGB(84, 114, 76),
					material = Enum.Material.Grass,
				},
				{
					shape = Enum.PartType.Cylinder,
					size = Vector3.new(4.2, 1.5, 1.5),
					offset = Vector3.new(3.4, 8.3, 0),
					rotation = Vector3.new(0, 0, 90),
					color = Color3.fromRGB(84, 114, 76),
					material = Enum.Material.Grass,
				},
				{
					shape = Enum.PartType.Cylinder,
					size = Vector3.new(3, 1.4, 1.4),
					offset = Vector3.new(-1.6, 5.4, 0),
					color = Color3.fromRGB(90, 120, 82),
					material = Enum.Material.Grass,
				},
				{
					shape = Enum.PartType.Cylinder,
					size = Vector3.new(3.4, 1.4, 1.4),
					offset = Vector3.new(-3, 6.9, 0),
					rotation = Vector3.new(0, 0, 90),
					color = Color3.fromRGB(90, 120, 82),
					material = Enum.Material.Grass,
				},
			},
		},
		{
			kind = "stone",
			node = "Boulder",
			rings = {
				{ inner = 36, outer = 200, level = 0, count = 16 },
				{ inner = 200, outer = 290, level = 1, count = 10 },
				{ inner = 290, outer = 345, level = 2, count = 6 },
			},
			parts = {
				{
					shape = Enum.PartType.Ball,
					size = Vector3.new(5.2, 3.6, 4.6),
					offset = Vector3.new(0, 1.3, 0),
					rotation = Vector3.new(-12, 30, 8),
					color = Color3.fromRGB(96, 84, 74),
					material = Enum.Material.Slate,
				},
				{
					shape = Enum.PartType.Ball,
					size = Vector3.new(3, 2.2, 2.8),
					offset = Vector3.new(2.2, 0.8, 1.1),
					rotation = Vector3.new(10, -20, 0),
					color = Color3.fromRGB(108, 96, 84),
					material = Enum.Material.Slate,
				},
				{
					shape = Enum.PartType.Ball,
					size = Vector3.new(2.2, 1.7, 2),
					offset = Vector3.new(-1.9, 0.6, -1.3),
					color = Color3.fromRGB(88, 78, 68),
					material = Enum.Material.Slate,
				},
			},
		},
	},

	stalker = {
		height = 9,
		standOff = 2,
		speed = 9,
		touchDistance = 3.5,
		sway = 4,
		touchCooldown = 4,
		fuelPenalty = 0.2,
		weight = 1,
	},

	lure = {
		firstDay = 3,
		value = 5,
		weight = 1,
		burnMultiplier = 1.25,
		standOff = 3,
		size = Vector3.new(2.6, 1.6, 3.8),
		lightBrightness = 1.6,
		lightRange = 14,
	},

	fog = {
		radiusByLevel = { 200, 290, 350 },
		pushBackAt = 360,
		wallHeight = 60,
		segments = 40,
		transparency = 0.35,
	},

	night = {
		brightness = 0.35,
		atmosphereDensity = 0.52,
		transition = 4,
		graceSeconds = 2,
	},

	onboarding = {
		firstToastAt = 3,
		nudgeAfter = 28,
	},

	score = { perDay = 1000, perFuel = 10, perLure = 200 },

	runEndPause = 8,
}

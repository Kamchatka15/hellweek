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

	-- The camp and the things that live in the waste. `camp.luau` explains why every
	-- piece is justified by RANGE rather than by being nice to have.
	pieces = require(script.Parent.camp).pieces,
	-- The camp creatures plus the boss. Concatenated here rather than in camp.luau so
	-- the boss can be pulled out of a run without touching anything else.
	creatures = (function()
		local list = {}
		for _, c in require(script.Parent.camp).creatures do
			table.insert(list, c)
		end
		for _, c in require(script.Parent.boss) do
			table.insert(list, c)
		end
		return list
	end)(),

	-- The siege. The Herald walks in on this night and every night after, heads for
	-- the obelisk, and drinks the light until it is driven off.
	siege = {
		firstNight = 3,
		drainPerHit = 1, -- fuel taken each time it reaches the obelisk and feeds
		spawnRing = { inner = 210, outer = 260 },
		creature = "dry_herald",
	},

	-- How much is alive out there, and where it starts. Never inside the first ring:
	-- a scorpion at the obelisk on the first morning is a different, worse game.
	creatureBase = 4,
	creaturePerDay = 2,
	creatureCap = 14,
	creatureRing = { inner = 78, outer = 250 },

	-- Seconds of warning before night. Nothing bad here arrives unannounced.
	nightWarning = 12,

	-- WHAT YOU WAKE UP HOLDING.
	--
	-- The leader hands a child a starter axe in the first second, and that one object
	-- teaches the whole game: swing it at a tree, carry what falls, feed the fire. A
	-- player who must first EARN a tool cannot begin, and a ten-year-old will not wait.
	--
	-- Two, not one, because the desert has two things worth taking and a child should
	-- discover that by having the answer to both already in hand.
	startingTools = { "Pickaxe", "Dagger" },

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
			note = "Dead wood from the waste. Burns. One fuel.",
			fuel = 1,
			size = Vector3.new(1.1, 1.1, 3.4),
			color = Color3.fromRGB(196, 176, 142),
			material = Enum.Material.Wood,
		},
		cactus = {
			label = "Cactus",
			note = "Wet inside. Will not burn. Two of them press into water.",
			fuel = 0,
			size = Vector3.new(1.5, 2.6, 1.5),
			color = Color3.fromRGB(92, 122, 82),
			material = Enum.Material.Grass,
		},
		stone = {
			label = "Stone",
			note = "Building material. Will not burn.",
			fuel = 0,
			shape = Enum.PartType.Ball,
			size = Vector3.new(1.9, 1.5, 1.7),
			color = Color3.fromRGB(108, 96, 84),
			material = Enum.Material.Slate,
		},
		water = {
			label = "Water",
			note = "Pressed from cactus. Tempers wood and wets stone.",
			fuel = 0,
			size = Vector3.new(1.3, 1.9, 1.3),
			color = Color3.fromRGB(92, 178, 198),
			material = Enum.Material.Neon,
			glow = { color = Color3.fromRGB(110, 200, 220), brightness = 1, range = 8 },
		},
		emberwood = {
			label = "Emberwood",
			note = "Wood the obelisk has tempered. Burns three times as long.",
			fuel = 3,
			size = Vector3.new(1.3, 1.3, 3.6),
			color = Color3.fromRGB(196, 118, 52),
			material = Enum.Material.Wood,
			glow = { color = Color3.fromRGB(255, 150, 60), brightness = 1.1, range = 9 },
		},
		heartwood = {
			label = "Heartwood",
			note = "The deepest burn there is. Slow to make, worth the wait.",
			fuel = 8,
			size = Vector3.new(1.6, 1.6, 4),
			color = Color3.fromRGB(255, 196, 64),
			material = Enum.Material.Neon,
			glow = { color = Color3.fromRGB(255, 200, 90), brightness = 1.8, range = 14 },
		},
		chitin = {
			label = "Chitin",
			note = "Scorpion shell. Hard, light, good for building.",
			fuel = 0,
			size = Vector3.new(1.6, 0.5, 1.9),
			color = Color3.fromRGB(56, 44, 52),
			material = Enum.Material.Slate,
		},
		venom = {
			label = "Venom",
			note = "Drawn from a sting. The obelisk wants it.",
			fuel = 0,
			size = Vector3.new(1, 1.5, 1),
			color = Color3.fromRGB(176, 220, 96),
			material = Enum.Material.Neon,
			glow = { color = Color3.fromRGB(176, 220, 96), brightness = 1.1, range = 8 },
		},
		wardstone = {
			label = "Wardstone",
			note = "Wet stone the obelisk has marked. The dark will not cross it.",
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
	-- sack of cactus and ashwood cascades on its own. The Wardstone is listed ABOVE
	-- Heartwood on purpose: with a greedy resolver whichever comes first eats the
	-- water, and the item that answers the Gift is worth more to the game than the deep
	-- fuel tier. Leftovers come back as themselves plus a bonus on the ladder, so an
	-- offering is never a waste — only less clever than it could have been.
	recipes = {
		-- THE HELD THINGS COME FIRST. With a greedy resolver whatever is listed first
		-- eats the inputs, and with these at the bottom a generous offering made
		-- emberwood out of every stick and never a tool — the stingy offering got the
		-- knife and the rich one did not, which is backwards. `limit = 1` because a
		-- second knife is not a sharper knife, and the loop drops a tool recipe once
		-- everyone holds it so it stops quietly eating a stone every dawn.
		-- The held things. `limit = 1` because a second knife is not a sharper knife,
		-- and without it a rich offering would hand back a pile of identical tools.
		{
			id = "cut_knife",
			label = "Bone Knife (all resources)",
			inputs = { stone = 1, ashwood = 1 },
			tool = "Knife",
			limit = 1,
		},
		{
			id = "light_brand",
			label = "Brand",
			inputs = { emberwood = 1, ashwood = 1 },
			tool = "Brand",
			limit = 1,
		},
		{
			id = "cut_sigil",
			label = "Sigil",
			inputs = { heartwood = 1, wardstone = 1 },
			tool = "Sigil",
			limit = 1,
		},
		{
			id = "cut_pick",
			label = "Pickaxe",
			inputs = { stone = 2, ashwood = 1 },
			tool = "Pickaxe",
			limit = 1,
		},
		-- The weapon ladder. Club is cheap and weak; Spear costs the deep materials
		-- and is worth it. You are meant to meet the Herald holding the club first
		-- and understand that you brought the wrong thing.
		{
			id = "cut_club",
			label = "Club",
			inputs = { ashwood = 2, stone = 1 },
			tool = "Club",
			limit = 1,
		},
		{
			id = "cut_spear",
			label = "Spear",
			inputs = { heartwood = 1, chitin = 1 },
			tool = "Spear",
			limit = 1,
		},

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
			id = "cut_ward",
			label = "Wardstone",
			inputs = { water = 1, stone = 2 },
			outputs = { wardstone = 1 },
		},
		{
			id = "quicken_heart",
			label = "Heartwood",
			inputs = { water = 1, emberwood = 1 },
			outputs = { heartwood = 1 },
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
		parts = require(script.Parent.obelisk), -- ~19 studs as generated; no extra scaling
		flameName = "CapFlame",
		facing = CFrame.Angles(0, 0, 0),
		-- The obelisk itself, not the whole stone: the five points each mean something
		-- now, so standing on one must not also be feeding the fire. 10 rather than 8
		-- because the stepped base is 13.4 wide, and a player stopped against it stands
		-- at about 8.7 from the centre — a tighter zone is one they cannot reach.
		feedRadius = 10,
		lightOffset = Vector3.new(0, 3, 0),
		-- LIT, dimly, from the first second.
		--
		-- It used to start dead, which meant a child who wandered for three minutes
		-- lost the run to their first night having never seen what a night was. Two
		-- fuel is a small circle, so the ring is drawn and the lesson is visible
		-- immediately: this is safe, out there is not, feeding makes it bigger.
		startingFuel = 2,
		fuelCap = 15,
		radiusBase = 25,
		radiusPerFuel = 8,
		radiusCap = 90,
		levelThresholds = { 8, 20 },
		lightBrightness = 1.25,
		flameSize = Vector3.new(1.7, 1.7, 1.7),
	},

	-- One row per day. `stalker` is what it does at night: watch (stand still on the
	-- line) or hunt (walk toward anyone outside the light).
	-- DAY 1 IS A TUTORIAL DAY, and it is long.
	--
	-- The single biggest onboarding device in the genre, taken from watching a
	-- ten-year-old play the leader: its first day ran longer on its own than days 2
	-- through 5 combined. A stranger gets to be bad at the game for as long as they
	-- need, with no clock pressure, and the real cadence only starts once they have
	-- fed the obelisk and built something. It costs one number.
	--
	-- Day 1 is also when the camp gets built, which is the whole reason day 2 is
	-- different from day 1 rather than the same lap against a bigger number.
	-- THE TEN-MINUTE ARC.
	--
	-- Three days and three nights land at about eight and three quarter minutes, which
	-- is the session we are aiming at: long enough to learn the loop and make a plan
	-- together, short enough to finish in one sitting before anyone drifts off.
	--
	-- Day 1 is still the long tutorial day, just not half the session. 180 seconds is
	-- nearly twice a normal day, with no pressure, which is room enough to be bad at
	-- the game for a while.
	days = {
		{ day = 180, night = 40, burn = 2, stalker = "watch", mercy = true },
		{ day = 110, night = 45, burn = 4, stalker = "hunt" },
		{ day = 100, night = 50, burn = 6, stalker = "hunt" },
		-- PARKED tuning below: escalation placeholders so the week has a shape
		{ day = 90, night = 60, burn = 8, stalker = "hunt" },
		{ day = 85, night = 65, burn = 10, stalker = "hunt" },
		{ day = 80, night = 70, burn = 12, stalker = "hunt" },
		{ day = 75, night = 75, burn = 14, stalker = "hunt" },
	},

	-- ---------------------------------------------------------------- held things
	-- Crafted at the obelisk like everything else, and NONE of them kill. In a
	-- survive-the-night game the threat being unkillable is the game; a weapon that
	-- ends it ends the loop with it. So defence here is holding something off.
	--
	--   Knife    a tool: cactus gives two instead of one
	--   Brand    a burning torch: you carry a pool of light, and it holds the Tempter
	--            a short way off — enough to walk home, not enough to camp outside
	--   Sigil    the artifact of faith. Not a cross: the obelisk's own glyph language
	--            cut into bone and gold. The widest ward in the game, and the only
	--            thing that makes the dark somewhere you can choose to be.
	tools = {
		{
			id = "Knife",
			label = "Bone Knife — everything gives two",
			kind = "any",
			bonus = 1,
			parts = {
				{
					size = Vector3.new(0.36, 0.34, 1.5),
					color = Color3.fromRGB(96, 80, 62),
					material = Enum.Material.Wood,
				},
				{
					size = Vector3.new(0.16, 0.5, 2.2),
					offset = Vector3.new(0, 0.08, -1.7),
					color = Color3.fromRGB(224, 216, 198),
					material = Enum.Material.SmoothPlastic,
				},
			},
		},
		{
			id = "Brand",
			label = "Brand — light you can carry",
			effect = "ward",
			radius = 9,
			parts = {
				{
					size = Vector3.new(0.4, 0.4, 3),
					color = Color3.fromRGB(74, 58, 44),
					material = Enum.Material.Wood,
				},
				{
					shape = Enum.PartType.Ball,
					size = Vector3.new(1.1, 1.3, 1.1),
					offset = Vector3.new(0, 0.1, -1.7),
					color = Color3.fromRGB(255, 168, 52),
					material = Enum.Material.Neon,
					light = { color = Color3.fromRGB(255, 150, 60), brightness = 2.4, range = 26 },
				},
			},
		},
		{
			id = "Dagger",
			label = "Dagger — cuts cactus, and cuts back",
			-- No `effect`: it is not a ward and not a lamp. It strikes because it has
			-- `power`, and it harvests because it names a `kind`. One tool, two jobs,
			-- the way the leader's starter axe both chops and kills.
			power = 2,
			kind = "cactus",
			bonus = 1,
			parts = {
				{
					size = Vector3.new(0.36, 0.34, 1.3),
					color = Color3.fromRGB(88, 74, 58),
					material = Enum.Material.Wood,
				},
				{
					size = Vector3.new(0.18, 0.46, 2),
					offset = Vector3.new(0, 0.06, -1.5),
					color = Color3.fromRGB(214, 208, 192),
					material = Enum.Material.SmoothPlastic,
				},
			},
		},
		{
			id = "Pickaxe",
			label = "Pickaxe — stone gives two",
			kind = "stone",
			bonus = 1,
			parts = {
				{
					size = Vector3.new(0.34, 0.34, 3.2),
					color = Color3.fromRGB(104, 90, 74),
					material = Enum.Material.Wood,
				},
				{
					size = Vector3.new(2.3, 0.4, 0.42),
					offset = Vector3.new(0, 0.1, -1.4),
					color = Color3.fromRGB(150, 142, 128),
					material = Enum.Material.Slate,
				},
			},
		},
		{
			id = "Club",
			label = "Club — heavier than the dagger",
			power = 3,
			parts = {
				{
					size = Vector3.new(0.38, 0.38, 2.6),
					color = Color3.fromRGB(96, 82, 66),
					material = Enum.Material.Wood,
				},
				{
					shape = Enum.PartType.Ball,
					size = Vector3.new(1.1, 1.1, 1.3),
					offset = Vector3.new(0, 0, -1.5),
					color = Color3.fromRGB(78, 70, 62),
					material = Enum.Material.Slate,
				},
			},
		},
		{
			id = "Spear",
			label = "Spear — five hits become one",
			power = 5,
			parts = {
				{
					size = Vector3.new(0.3, 0.3, 5),
					color = Color3.fromRGB(118, 100, 78),
					material = Enum.Material.Wood,
				},
				{
					size = Vector3.new(0.34, 0.12, 1.9),
					offset = Vector3.new(0, 0, -2.9),
					color = Color3.fromRGB(56, 44, 52),
					material = Enum.Material.Slate,
				},
				{
					size = Vector3.new(0.5, 0.5, 0.22),
					offset = Vector3.new(0, 0, -1.9),
					color = Color3.fromRGB(212, 168, 74),
					material = Enum.Material.Metal,
				},
			},
		},
		{
			id = "Sigil",
			label = "Sigil — it will not come near",
			effect = "ward",
			radius = 19,
			parts = {
				{
					shape = Enum.PartType.Cylinder,
					size = Vector3.new(0.28, 2.3, 2.3),
					color = Color3.fromRGB(228, 220, 202),
					material = Enum.Material.SmoothPlastic,
				},
				{
					shape = Enum.PartType.Cylinder,
					size = Vector3.new(0.34, 1.6, 1.6),
					offset = Vector3.new(0.06, 0, 0),
					color = Color3.fromRGB(255, 196, 64),
					material = Enum.Material.Neon,
					light = { color = Color3.fromRGB(255, 210, 120), brightness = 1.4, range = 16 },
				},
				{
					size = Vector3.new(0.4, 0.26, 1.5),
					offset = Vector3.new(0.1, 0, 0),
					color = Color3.fromRGB(255, 196, 64),
					material = Enum.Material.Neon,
				},
				{
					size = Vector3.new(0.4, 1.5, 0.26),
					offset = Vector3.new(0.1, 0, 0),
					color = Color3.fromRGB(255, 196, 64),
					material = Enum.Material.Neon,
				},
			},
		},
	},

	-- ---------------------------------------------------------------- the chest
	-- One in the mouth of every teepee. A chest is the reason to walk out to a
	-- silhouette instead of past it: several things at once, and the only place the
	-- crafted tiers turn up without being made.
	chest = {
		standOff = 5.5, -- studs out from the teepee centre, on the side facing the obelisk
		loot = {
			{ kind = "ashwood", count = 2, chance = 1 },
			{ kind = "cactus", count = 1, chance = 0.8 },
			{ kind = "stone", count = 1, chance = 0.7 },
			{ kind = "water", count = 1, chance = 0.35 },
			{ kind = "emberwood", count = 1, chance = 0.18 },
			{ kind = "heartwood", count = 1, chance = 0.05 },
		},
		parts = {
			{
				size = Vector3.new(3.4, 1.9, 2.3),
				offset = Vector3.new(0, 0.95, 0),
				color = Color3.fromRGB(92, 68, 46),
				material = Enum.Material.Wood,
			},
			{
				shape = Enum.PartType.Cylinder,
				size = Vector3.new(3.4, 2.3, 2.3),
				offset = Vector3.new(0, 1.9, 0),
				rotation = Vector3.new(0, 0, 0),
				color = Color3.fromRGB(78, 58, 40),
				material = Enum.Material.Wood,
			},
			{
				size = Vector3.new(3.6, 0.34, 0.34),
				offset = Vector3.new(0, 1.9, -1.05),
				color = Color3.fromRGB(168, 132, 60),
				material = Enum.Material.Metal,
			},
			{
				size = Vector3.new(0.5, 0.7, 0.5),
				offset = Vector3.new(0, 1.35, -1.2),
				color = Color3.fromRGB(212, 172, 76),
				material = Enum.Material.Metal,
			},
		},
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

	-- NIGHT is its own complete rig, not the day rig dimmed. The sky goes out, the haze
	-- thickens and cools, and the camp's warm lights come back to full — so the same
	-- monument that read cold and exposed at noon is the only warm thing on the waste
	-- after dark.
	night = {
		transition = 5,
		graceSeconds = 2,
		campGlowByDay = 0.12, -- how much of the camp's warm light survives daylight
		rig = {
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
			bloom = {
				Intensity = 0.8,
				Size = 30,
				Threshold = 1, -- after dark the gold and the fire are allowed to burn
			},
		},
	},

	onboarding = {
		firstToastAt = 3,
		nudgeAfter = 28,
	},

	score = { perDay = 1000, perFuel = 10, perLure = 200 },

	runEndPause = 8,
}

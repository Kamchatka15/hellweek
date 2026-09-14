--!strict
-- camp.luau — what the player builds, and what is alive out there.
--
-- Written from one sentence a ten-year-old said after playing the genre leader:
-- "he enjoys building his camp up on day one, so he can later explore."
--
-- So every piece below is justified by RANGE. Each one removes a specific reason you
-- currently have to turn around and walk back to the obelisk. If a piece cannot be
-- described that way it is furniture, and furniture is a Pass 2 problem.
--
-- The division of labour with the obelisk is strict, because two places that do the
-- same job means neither one feels like home:
--
--   THE OBELISK  crafts by offering, counts the days, ends the run
--   THE CAMP     extends how far you can go and how long you can stay
--
-- Nothing here crafts. Nothing at the obelisk extends range.

local COLORS = {
	stone = Color3.fromRGB(104, 96, 86),
	stoneDark = Color3.fromRGB(72, 66, 60),
	wood = Color3.fromRGB(104, 90, 74),
	bone = Color3.fromRGB(214, 204, 182),
	gold = Color3.fromRGB(212, 168, 74),
	ember = Color3.fromRGB(255, 168, 52),
	salt = Color3.fromRGB(228, 220, 196),
	hide = Color3.fromRGB(150, 122, 96),
	chitin = Color3.fromRGB(56, 44, 52),
	venom = Color3.fromRGB(176, 220, 96),
}

--- A ring of dashes lying flat on the ground, as ordinary part specs.
---
--- This is the readability device the whole watch turned up: the genre leader PAINTS
--- its safe radius on the terrain instead of implying it with light. A drawn line is
--- legible at noon from outside, and legible on dark ground at midnight. Light
--- falloff is neither.
local function ringParts(radius: number, dashes: number, color: Color3, y: number): { any }
	local out = {}
	local arc = 2 * math.pi * radius / dashes
	for index = 1, dashes do
		local theta = (index - 1) / dashes * math.pi * 2
		table.insert(out, {
			name = `Salt{index}`,
			size = Vector3.new(arc * 0.55, 0.08, 0.9),
			position = Vector3.new(math.cos(theta) * radius, y, math.sin(theta) * radius),
			rotation = Vector3.new(0, -math.deg(theta), 0),
			color = color,
			material = Enum.Material.Neon,
			transparency = 0.3,
			canCollide = false,
			castShadow = false,
		})
	end
	return out
end

--- The five pieces. `blurb` says what the piece BUYS you, never what it is, because a
--- player deciding whether to spend three stone does not care what it is called.
local pieces = {
	{
		id = "cache",
		label = "Cache",
		blurb = "Leave things out here instead of carrying them home",
		cost = { stone = 3, ashwood = 2 },
		effect = "store",
		capacity = 12,
		away = 26, -- do not let the camp pile onto the obelisk
		parts = {
			{
				name = "CacheBody",
				size = Vector3.new(3.4, 2.2, 2.6),
				position = Vector3.new(0, 1.1, 0),
				color = COLORS.stone,
				material = Enum.Material.Slate,
			},
			{
				name = "CacheLid",
				size = Vector3.new(3.8, 0.45, 3),
				position = Vector3.new(0, 2.4, 0),
				color = COLORS.stoneDark,
				material = Enum.Material.Slate,
			},
			{
				name = "CacheMark",
				shape = Enum.PartType.Cylinder,
				size = Vector3.new(0.12, 1.1, 1.1),
				position = Vector3.new(0, 2.66, 0),
				rotation = Vector3.new(0, 0, 90),
				color = COLORS.gold,
				material = Enum.Material.Neon,
				canCollide = false,
			},
		},
	},

	{
		id = "brazier",
		label = "Brazier",
		blurb = "A second place the dark will not come into",
		cost = { stone = 2, ashwood = 3, emberwood = 1 },
		effect = "light",
		radius = 24,
		away = 30,
		limit = 4,
		parts = {
			{
				name = "BrazierLeg",
				shape = Enum.PartType.Cylinder,
				size = Vector3.new(2.6, 0.4, 0.4),
				position = Vector3.new(0, 1.3, 0),
				rotation = Vector3.new(0, 0, 90),
				color = COLORS.wood,
				material = Enum.Material.Wood,
			},
			{
				name = "BrazierBowl",
				shape = Enum.PartType.Cylinder,
				size = Vector3.new(0.9, 2.4, 2.4),
				position = Vector3.new(0, 2.8, 0),
				rotation = Vector3.new(0, 0, 90),
				color = COLORS.stoneDark,
				material = Enum.Material.Slate,
			},
			{
				name = "BrazierFire",
				shape = Enum.PartType.Ball,
				size = Vector3.new(1.2, 1.2, 1.2),
				position = Vector3.new(0, 3.5, 0),
				color = COLORS.ember,
				material = Enum.Material.Neon,
				transparency = 0.25,
				canCollide = false,
				castShadow = false,
				fire = { size = 1.5, height = 3.4, range = 26, brightness = 2, rate = 20 },
			},
		},
	},

	{
		id = "ward_stake",
		label = "Ward Stake",
		blurb = "It will not cross this, even at night",
		cost = { wardstone = 1, ashwood = 2 },
		effect = "ward",
		radius = 17,
		away = 26,
		limit = 6,
		parts = {
			{
				name = "StakeShaft",
				size = Vector3.new(0.44, 5.2, 0.44),
				position = Vector3.new(0, 2.6, 0),
				color = COLORS.wood,
				material = Enum.Material.Wood,
			},
			{
				name = "StakeHead",
				size = Vector3.new(1.5, 1.7, 0.32),
				position = Vector3.new(0, 5.4, 0),
				color = COLORS.bone,
				material = Enum.Material.SmoothPlastic,
			},
			{
				name = "StakeGlyph",
				size = Vector3.new(0.62, 0.9, 0.44),
				position = Vector3.new(0, 5.4, 0),
				color = COLORS.gold,
				material = Enum.Material.Neon,
				canCollide = false,
				castShadow = false,
				light = { color = COLORS.gold, brightness = 1.3, range = 14 },
			},
		},
	},

	{
		id = "drying_rack",
		label = "Drying Rack",
		blurb = "Turns cactus into water while you are somewhere else",
		cost = { ashwood = 4, chitin = 2 },
		effect = "convert",
		input = "cactus",
		output = "water",
		every = 9,
		capacity = 10,
		away = 26,
		limit = 3,
		parts = {
			{
				name = "RackPostL",
				size = Vector3.new(0.36, 4, 0.36),
				position = Vector3.new(-1.9, 2, 0),
				color = COLORS.bone,
				material = Enum.Material.SmoothPlastic,
			},
			{
				name = "RackPostR",
				size = Vector3.new(0.36, 4, 0.36),
				position = Vector3.new(1.9, 2, 0),
				color = COLORS.bone,
				material = Enum.Material.SmoothPlastic,
			},
			{
				name = "RackBar",
				shape = Enum.PartType.Cylinder,
				size = Vector3.new(4.4, 0.3, 0.3),
				position = Vector3.new(0, 4, 0),
				rotation = Vector3.new(0, 0, 90),
				color = COLORS.bone,
				material = Enum.Material.SmoothPlastic,
			},
			{
				name = "RackHide",
				size = Vector3.new(3.2, 2.3, 0.14),
				position = Vector3.new(0, 2.8, 0),
				color = COLORS.hide,
				material = Enum.Material.Fabric,
				canCollide = false,
			},
		},
	},

	{
		id = "salt_line",
		label = "Salt Line",
		blurb = "Draws where safe ends, so you can see it at night",
		cost = { stone = 4 },
		effect = "mark",
		radius = 18,
		away = 26,
		limit = 3,
		parts = ringParts(18, 30, COLORS.salt, 0.08),
	},
}

--- The scorpion.
---
--- Prey with teeth: it roams, it bites, it dies to a held tool, and it drops the
--- material the drying rack needs. It is NOT the night threat. The stalker remains
--- unkillable, because a night you can put down is not a night.
---
--- The eyes are the whole design. Our night is navy rather than black, which means
--- two glowing points low to the ground at forty studs is a complete sentence:
--- something is there, it is small, and it has noticed you. You read the eyes long
--- before you read the body, and reading before seeing is what makes a thing feel
--- alive rather than placed.
local creatures = {
	{
		id = "scorpion",
		label = "Scorpion",
		health = 3, -- swings, not hit points. A kid counts swings
		speed = 6,
		nightSpeed = 9.5,
		noticeRadius = 24,
		nightNoticeRadius = 42,
		biteRadius = 4.2,
		biteCooldown = 2.4,
		wander = 22,
		drops = { chitin = 2, venom = 1 },
		eyes = {
			attach = "Head",
			offsets = { Vector3.new(-0.42, 0.1, -0.55), Vector3.new(0.42, 0.1, -0.55) },
			color = Color3.fromRGB(255, 222, 64),
			size = 0.5,
			brightness = 3.2,
			range = 15,
		},
		parts = {
			{
				name = "Body",
				shape = Enum.PartType.Ball,
				size = Vector3.new(2.6, 1.3, 3.4),
				position = Vector3.new(0, 0.9, 0),
				color = COLORS.chitin,
				material = Enum.Material.Slate,
			},
			{
				name = "Head",
				shape = Enum.PartType.Ball,
				size = Vector3.new(1.7, 1, 1.5),
				position = Vector3.new(0, 0.95, -1.7),
				color = COLORS.chitin,
				material = Enum.Material.Slate,
			},
			{
				name = "ClawL",
				size = Vector3.new(0.5, 0.45, 1.9),
				position = Vector3.new(-1.25, 0.6, -2.1),
				rotation = Vector3.new(0, 22, 0),
				color = COLORS.chitin,
				material = Enum.Material.Slate,
			},
			{
				name = "ClawR",
				size = Vector3.new(0.5, 0.45, 1.9),
				position = Vector3.new(1.25, 0.6, -2.1),
				rotation = Vector3.new(0, -22, 0),
				color = COLORS.chitin,
				material = Enum.Material.Slate,
			},
			{
				name = "Tail1",
				size = Vector3.new(0.5, 0.5, 1.2),
				position = Vector3.new(0, 1.7, 1.7),
				rotation = Vector3.new(-38, 0, 0),
				color = COLORS.chitin,
				material = Enum.Material.Slate,
			},
			{
				name = "Tail2",
				size = Vector3.new(0.45, 0.45, 1.1),
				position = Vector3.new(0, 2.6, 2.3),
				rotation = Vector3.new(-74, 0, 0),
				color = COLORS.chitin,
				material = Enum.Material.Slate,
			},
			{
				name = "Sting",
				shape = Enum.PartType.Ball,
				size = Vector3.new(0.55, 0.8, 0.55),
				position = Vector3.new(0, 3.1, 1.9),
				color = COLORS.venom,
				material = Enum.Material.Neon,
				castShadow = false,
				light = { color = COLORS.venom, brightness = 1.1, range = 7 },
			},
		},
	},

	{
		-- THE MAGMA GOLEM — behaviour test rig for the HW art drop.
		--
		-- This is a parts BLOCKOUT standing in for magma_golem.glb, matched to the
		-- mesh's real footprint (6.1 wide x 9.8 tall x 4.5 deep) so the behaviour
		-- being tuned here is the behaviour the mesh will have. Swapping the mesh in
		-- changes how it looks and nothing about how it moves.
		--
		-- Tuned to the brief: as fast as a player, comes for you when you get close,
		-- and its eyes burn red after dark.
		id = "golem",
		label = "Magma Golem",

		-- Drop the imported mesh into ServerStorage/CreatureBodies named exactly this
		-- and it becomes the body, with no code change. Until then the blockout below
		-- stands in, matched to the mesh's real 6.1 x 9.8 x 4.5 footprint.
		template = "MagmaGolem",
		templateYOffset = 0,

		-- Roblox's default player WalkSpeed is 16, and this game never changes it. So
		-- 16 means exactly matched: it will never gain on you down a straight line,
		-- and every corner you turn, it takes back. That is a far better chase than
		-- something faster, which is just a death sentence with extra steps.
		speed = 16,
		nightSpeed = 16,

		-- Get near it and it comes. Generous at night because that is when you are
		-- meant to see the eyes coming from a long way off.
		noticeRadius = 46,
		nightNoticeRadius = 80,

		biteRadius = 6.5,
		biteCooldown = 2.6,
		wander = 26,
		health = 10,
		drops = { stone = 3, emberwood = 2 },

		eyes = {
			-- Sunk deep in the brow so they read as sockets, not headlights.
			offsets = { Vector3.new(-1.05, 8.5, -1.5), Vector3.new(1.05, 8.5, -1.5) },
			-- Day: a dull ember you can barely see against the sand.
			color = Color3.fromRGB(196, 88, 30),
			brightness = 0.9,
			range = 10,
			size = 0.78,
			-- Night: red, and burning hard enough to find from across the waste.
			-- The NEON PART is what carries at distance: it is emissive, so it reads
			-- from far away without lighting anything. The PointLight is only there
			-- to put a little colour on the rock around the head. Seen live at
			-- brightness 4.2 / range 34 it washed whole mesas orange and killed the
			-- night, which is the opposite of the point.
			nightColor = Color3.fromRGB(255, 42, 28),
			nightBrightness = 1.5,
			nightRange = 13,
		},

		-- Two of them, 180 degrees apart at the edge of the biome. Fixed spots, so
		-- they are landmarks you learn rather than weather that happens to you.
		fixed = {
			Vector3.new(215, 0, 0),
			Vector3.new(-215, 0, 0),
		},

		parts = {
			-- legs
			{
				name = "FootL",
				size = Vector3.new(1.9, 1.2, 2.6),
				position = Vector3.new(-1.5, 0.6, 0.2),
				color = COLORS.stoneDark,
				material = Enum.Material.Basalt,
			},
			{
				name = "FootR",
				size = Vector3.new(1.9, 1.2, 2.6),
				position = Vector3.new(1.5, 0.6, 0.2),
				color = COLORS.stoneDark,
				material = Enum.Material.Basalt,
			},
			{
				name = "LegL",
				size = Vector3.new(1.7, 2.4, 1.8),
				position = Vector3.new(-1.5, 2.3, 0),
				color = COLORS.stone,
				material = Enum.Material.Basalt,
			},
			{
				name = "LegR",
				size = Vector3.new(1.7, 2.4, 1.8),
				position = Vector3.new(1.5, 2.3, 0),
				color = COLORS.stone,
				material = Enum.Material.Basalt,
			},
			-- torso, wide and heavy
			{
				name = "Torso",
				size = Vector3.new(5.2, 4.2, 3.6),
				position = Vector3.new(0, 5.6, 0),
				color = COLORS.stone,
				material = Enum.Material.Basalt,
			},
			{
				name = "Shoulders",
				size = Vector3.new(6.1, 1.7, 3.8),
				position = Vector3.new(0, 7.5, 0),
				color = COLORS.stoneDark,
				material = Enum.Material.Basalt,
			},
			-- the belly: the mesh's signature. Molten, and it lights the ground it stands on
			{
				name = "Belly",
				shape = Enum.PartType.Ball,
				size = Vector3.new(3.6, 3.2, 2.6),
				position = Vector3.new(0, 5.2, -1.4),
				color = Color3.fromRGB(255, 126, 30),
				material = Enum.Material.Neon,
				transparency = 0.12,
				castShadow = false,
				-- Same lesson as the eyes: the neon sphere is the glow, this light is
				-- only a pool at its feet.
				light = { color = Color3.fromRGB(255, 120, 36), brightness = 1.15, range = 14 },
			},
			-- long arms, knuckles near the ground
			{
				name = "ArmL",
				size = Vector3.new(1.7, 4.6, 1.9),
				position = Vector3.new(-3.5, 5.2, 0),
				color = COLORS.stone,
				material = Enum.Material.Basalt,
			},
			{
				name = "ArmR",
				size = Vector3.new(1.7, 4.6, 1.9),
				position = Vector3.new(3.5, 5.2, 0),
				color = COLORS.stone,
				material = Enum.Material.Basalt,
			},
			{
				name = "FistL",
				size = Vector3.new(2.2, 2, 2.3),
				position = Vector3.new(-3.5, 2.2, 0),
				color = COLORS.stoneDark,
				material = Enum.Material.Basalt,
			},
			{
				name = "FistR",
				size = Vector3.new(2.2, 2, 2.3),
				position = Vector3.new(3.5, 2.2, 0),
				color = COLORS.stoneDark,
				material = Enum.Material.Basalt,
			},
			-- head, sunk between the shoulders
			{
				name = "Head",
				size = Vector3.new(2.9, 2.3, 2.7),
				position = Vector3.new(0, 8.7, -0.3),
				color = COLORS.stone,
				material = Enum.Material.Basalt,
			},
			{
				name = "Brow",
				size = Vector3.new(3.1, 0.7, 0.9),
				position = Vector3.new(0, 9.3, -1.3),
				color = COLORS.stoneDark,
				material = Enum.Material.Basalt,
			},
			-- the mouth: a crack of molten light under the brow
			{
				name = "Mouth",
				size = Vector3.new(1.9, 0.45, 0.5),
				position = Vector3.new(0, 7.9, -1.45),
				color = Color3.fromRGB(255, 108, 24),
				material = Enum.Material.Neon,
				castShadow = false,
				light = { color = Color3.fromRGB(255, 100, 30), brightness = 0.7, range = 8 },
			},
			-- cracks down the back, so it reads as magma from behind too
			{
				name = "VentL",
				size = Vector3.new(0.5, 2.6, 0.4),
				position = Vector3.new(-1.4, 5.8, 1.8),
				color = Color3.fromRGB(255, 96, 24),
				material = Enum.Material.Neon,
				castShadow = false,
			},
			{
				name = "VentR",
				size = Vector3.new(0.5, 2.6, 0.4),
				position = Vector3.new(1.4, 5.8, 1.8),
				color = Color3.fromRGB(255, 96, 24),
				material = Enum.Material.Neon,
				castShadow = false,
			},
		},
	},
}

return {
	pieces = pieces,
	creatures = creatures,
	ringParts = ringParts,
	colors = COLORS,
}

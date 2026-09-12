-- config — every tuning number for Hell Week. Server-only: nothing here replicates.
--
-- These are Pass 1 CANDIDATE numbers from the brief (§5 rings, §6 days), simulated in
-- games/hell-week/economy.md before being frozen. Days 4–7 are escalation defaults and
-- are PARKED tuning: the clock can reach them, the numbers are not the ones we mean yet.
--
-- The first-minute arithmetic they are chosen to produce:
--   spawn is 30 studs from the Wick; three Ashwood sit on that line
--   -> pick one up (~3s), walk it in (~2s), the radius pops 25 -> 33 and the fog steps back
--   -> the Tempter appears on the light-line, still. Night 1 it never moves.
--   -> Day 1 burns 3 over 40s; 8+ Ashwood are inside 175 studs, so a slacker still sees Day 2

return {
	loop = "survive",

	-- The floor top. Everything that sits on the sand is placed from this.
	groundY = 0,

	sack = { cap = 3 },

	beacon = {
		position = Vector3.new(0, 0, 0),
		startingFuel = 0,
		fuelCap = 15,
		radiusBase = 25, -- brief: 25 + 8 x fuel, cap 90
		radiusPerFuel = 8,
		radiusCap = 90,
		-- total fuel ever fed at which the shore peels: Ring C after ~8, Ring D after 20
		levelThresholds = { 8, 20 },
		lightBrightness = 2,
		postHeight = 7,
		flameSize = Vector3.new(1.3, 1.7, 1.3),
	},

	-- One row per day. `stalker` is what it does at night: watch (stand still on the
	-- line) or hunt (walk toward anyone outside the light).
	days = {
		{ day = 90, night = 40, burn = 3, stalker = "watch" },
		{ day = 90, night = 45, burn = 4, stalker = "hunt" },
		{ day = 85, night = 50, burn = 6, stalker = "hunt" },
		-- PARKED tuning below: escalation placeholders so the week has a shape
		{ day = 80, night = 55, burn = 7, stalker = "hunt" },
		{ day = 75, night = 60, burn = 8, stalker = "hunt" },
		{ day = 70, night = 65, burn = 9, stalker = "hunt" },
		{ day = 65, night = 70, burn = 10, stalker = "hunt" },
	},

	fuel = {
		value = 1,
		size = Vector3.new(1.1, 1.1, 3.4),
		pickupRadius = 4.5,
		maxOnFloor = 60,
		-- Rings from the brief §5. `level` is the Wick level that opens the ring;
		-- `path` puts that many pieces on the straight line spawn -> Wick (Ring A only).
		rings = {
			{ id = "A", inner = 9, outer = 50, level = 0, count = 5, path = 3 },
			{ id = "B", inner = 50, outer = 175, level = 0, count = 6 },
			{ id = "C", inner = 175, outer = 280, level = 1, count = 6 },
			{ id = "D", inner = 280, outer = 345, level = 2, count = 4 },
		},
	},

	stalker = {
		height = 9, -- wrong proportions beat a stock devil
		standOff = 2, -- studs outside the light-line when watching
		speed = 9, -- studs/second when hunting; walk speed is 16, so it can be outrun
		touchDistance = 3.5,
		sway = 4,
		touchCooldown = 4,
		fuelPenalty = 0.2, -- brief: touch = lose 20% of current fuel
		weight = 1,
	},

	lure = {
		firstDay = 3,
		value = 5, -- looks like five Ashwood
		weight = 1,
		burnMultiplier = 1.25, -- next night burns x1.25 per Weight, stacking
		standOff = 3, -- sits just outside the light-line
		size = Vector3.new(2.6, 1.6, 3.8),
		lightBrightness = 1.6,
		lightRange = 14,
	},

	fog = {
		radiusByLevel = { 175, 280, 350 },
		pushBackAt = 360,
		wallHeight = 44,
		segments = 24,
		transparency = 0.35,
	},

	night = {
		brightness = 0.55,
		atmosphereDensity = 0.6,
		transition = 4,
	},

	onboarding = {
		firstToastAt = 3, -- seconds after the fade-in
		nudgeAfter = 25, -- no feed by then: pulse the meter and highlight the nearest Ashwood
	},

	score = { perDay = 1000, perFuel = 10, perLure = 200 },

	runEndPause = 8,
}

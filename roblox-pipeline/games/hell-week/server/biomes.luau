-- biomes — the four worlds of Hell Week, one per point of the pentagram.
--
-- The pentagram has five points. FOUR carry a world and the fifth holds the offering
-- table (Justin, 2026-09-12). A world's triangle is dark while it is locked, red once
-- opened, green once mastered; mastering means clearing its seven challenges.
--
-- Four rather than five cost The Long Salt, which was the weakest of the set once the
-- desert took slot one: both are open arid ground, and "no cover at all" reads as less
-- of a world than a wood, a flood or a furnace. It is in the brief if it comes back.
--
-- World 1 is the desert by owner call (2026-09-12). The Quiet Shore it replaced was
-- the same teach with grey sand and no second resource; the waste keeps the teach and
-- adds the thing the workbench runs on.
--
-- WHY THESE FOUR. Every one has to (a) read differently at 200px, (b) be a different
-- KIND of fear rather than the same night with new paint, and (c) run on the engine
-- that already exists — a beacon you feed, a clock, a thing that walks the light-line.
-- The order is the difficulty curve: cover is taken away, then the ground, then the
-- horizon, then the fire itself turns on you.
--
-- Point 1 faces spawn and is the world you are standing in; points 2-4 run clockwise
-- from it, and point 5 is the offering table.
--
-- PASS 1 REALITY: only The Quiet Shore is built, and only its seven challenges are
-- wired to real signals in SurviveLoop. The other four are the roadmap, listed so the
-- pentagram has something true to draw and so the shape of the game is on disk rather
-- than in a chat window. Building any of them is a separate wave.

return {
	{
		id = "ashen-waste",
		name = "The Ashen Waste",
		note = "A 700-stud disk of bleached dead sand: dunes, rock mesas, dead trees, "
			.. "cactus, half-buried ruins, one dry wash. The teach, and the world where "
			.. "water enters the game — cactus is the only source of it, and water is "
			.. "what the obelisk needs to make anything worth having.",
		challenges = {
			{ id = "first_light", label = "Feed the obelisk", hint = "Carry deadfall onto the stone." },
			{ id = "first_night", label = "Hold the first night", hint = "Do not let the fire go out." },
			{ id = "press_water", label = "Press water from cactus", hint = "Two cactus in the bowl." },
			{ id = "harvest", label = "Take back what the obelisk made", hint = "Offer a sack and return at dawn." },
			{ id = "open_waste", label = "Push the fog back", hint = "Feed it eight." },
			{ id = "refuse", label = "Reach day three taking no Gift", hint = "The easy pile costs tomorrow." },
			{ id = "the_week", label = "Last all seven days" },
		},
	},
	{
		id = "still-wood",
		name = "The Still Wood",
		note = "Dead standing trees, ash falling like snow. Takes away SIGHTLINES: the "
			.. "light-line is broken by trunks, so the thing on it is only ever half visible.",
		challenges = {
			{ id = "kindle", label = "Wake the second obelisk" },
			{ id = "deadfall", label = "Burn only deadfall for a night" },
			{ id = "count_trunks", label = "Find the clearing" },
			{ id = "ash_night", label = "Hold a night in the ashfall" },
			{ id = "no_torch", label = "Cross the wood without leaving the light" },
			{ id = "two_stand", label = "Keep two fires lit at once" },
			{ id = "the_week", label = "Last all seven days" },
		},
	},
	{
		id = "drowned-quarter",
		name = "The Drowned Quarter",
		note = "Flooded ruins, black water to the waist. Takes away the GROUND: fuel floats "
			.. "and drifts, and the light does not cross water the way it crosses sand.",
		challenges = {
			{ id = "kindle", label = "Wake the third obelisk" },
			{ id = "float", label = "Land a floating bundle" },
			{ id = "high_ground", label = "Hold a night on the roofs" },
			{ id = "wade", label = "Cross the deep channel" },
			{ id = "dry_fuel", label = "Keep a full sack dry" },
			{ id = "still_water", label = "Let the water settle" },
			{ id = "the_week", label = "Last all seven days" },
		},
	},
	{
		id = "the-kiln",
		name = "The Kiln",
		note = "The only warm world: red-black, ember light on every surface. Takes away "
			.. "THE FIRE ITSELF — fuel is everywhere and burns four times as fast, and the "
			.. "ambient glow makes the safe circle almost impossible to read.",
		challenges = {
			{ id = "kindle", label = "Wake the last obelisk" },
			{ id = "read_the_line", label = "Find the edge of the light" },
			{ id = "starve", label = "Hold a night on half fuel" },
			{ id = "quench", label = "Put something out" },
			{ id = "ember_walk", label = "Cross the ember field" },
			{ id = "last_stand", label = "Hold the final night" },
			{ id = "the_week", label = "Last all seven days" },
		},
	},
}

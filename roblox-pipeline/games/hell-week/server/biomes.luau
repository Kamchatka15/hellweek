-- biomes — the five worlds of Hell Week, one per point of the pentagram.
--
-- Justin, 2026-09-12: "the pentagram on the floor of the obelisk has five points,
-- naturally there are going to be 5 biomes. Pick the strongest ones." Each point's
-- triangle is dark while its world is locked, red once opened, green once mastered;
-- mastering a world means clearing its seven challenges.
--
-- WHY THESE FIVE. Every one has to (a) read differently at 200px, (b) be a different
-- KIND of fear rather than the same night with new paint, and (c) run on the engine
-- that already exists — a beacon you feed, a clock, a thing that walks the light-line.
-- The order is the difficulty curve: cover is taken away, then the ground, then the
-- horizon, then the fire itself turns on you.
--
-- Point 1 faces spawn, and the rest run clockwise from it.
--
-- PASS 1 REALITY: only The Quiet Shore is built, and only its seven challenges are
-- wired to real signals in SurviveLoop. The other four are the roadmap, listed so the
-- pentagram has something true to draw and so the shape of the game is on disk rather
-- than in a chat window. Building any of them is a separate wave.

return {
	{
		id = "quiet-shore",
		name = "The Quiet Shore",
		note = "Grey sand, black glass water, a fog ring. The teach.",
		challenges = {
			{ id = "first_light", label = "Feed the obelisk", hint = "Carry Ashwood into the stone." },
			{ id = "first_night", label = "Hold the first night", hint = "Do not let the fire go out." },
			{ id = "open_shore", label = "Push the fog back", hint = "Feed it eight." },
			{ id = "third_day", label = "Reach the third day" },
			{ id = "refuse", label = "Reach day three taking no Gift", hint = "The easy pile costs tomorrow." },
			{ id = "untouched", label = "Reach day three untouched", hint = "Stay inside the light at night." },
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
		id = "long-salt",
		name = "The Long Salt",
		note = "White cracked flats under a black sky — the palette inverted, and the one "
			.. "world that reads as bright. Takes away DISTANCE: you see it coming for a "
			.. "full minute across open ground and there is nowhere to be.",
		challenges = {
			{ id = "kindle", label = "Wake the fourth obelisk" },
			{ id = "first_mile", label = "Reach the far pan" },
			{ id = "no_cover", label = "Hold a night with nothing to hide behind" },
			{ id = "salt_burn", label = "Burn salt-soaked wood" },
			{ id = "outrun", label = "Outwalk it in the open" },
			{ id = "white_night", label = "Survive a night you can see all of" },
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

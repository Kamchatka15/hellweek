-- config — every tuning number for SPACEHEX that is not physics. Server-only: prices are
-- decided here and travel to the client for display only (skills/roblox-security.md).
--
-- Loop family `build`: buy parts -> assemble -> roll out -> launch -> earn on performance
-- -> buy something better. Design of record: ../brief.md, ../PARTS.md, ../economy.md.
-- The physics (flight.luau) and the catalogue (parts.luau) are simulated end to end by
-- tools/spacehex_career.luau, which docks on launch 19; do not retune either without
-- re-running it and reporting the new docking launch.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

return {
	loop = "build",

	-- The real spine. These ARE the game and they are simulated end to end.
	flight = require(script.Parent.flight),
	parts = require(script.Parent.parts),
	assembly = require(script.Parent.assembly),
	tiers = require(script.Parent.tiers),
	-- The silhouette. Shared, because the client draws the same rocket in the assembly
	-- preview and the warehouse icons that the server stands on the pad. No numbers in it.
	rocket = require(ReplicatedStorage.Pack.rocket),

	startingCash = 1000000,
	startingParts = { "eng_hopper", "tank_micro", "nose_blunt", "gnc_none" },

	-- What is on the hangar floor at the first join: the starters, stacked, with exactly
	-- one thing wrong (no fins). The first red line a player reads is the first part
	-- they buy, and that is the whole loop taught in under a minute.
	starterAssembly = {
		stages = { { engine = "eng_hopper", tank = "tank_micro", engineCount = 1 } },
		nose = "nose_blunt",
		gnc = "gnc_none",
		rcs = false,
		dock = false,
	},

	limits = { maxStages = 4, maxEngines = 4 },

	launch = {
		prelaunch = 3, -- seconds of countdown
		holdDown = 4, -- seconds the engine fires against the clamps when TWR <= 1
		recovery = 6, -- seconds the result stays up before the pad clears
		rolloutSeconds = 3, -- hangar -> pad
		-- Playback compression. Real time while the engines burn (the clip moment), then
		-- each later phase is squeezed into at most this many wall seconds.
		maxAscentWall = 24,
		maxCoastWall = 12,
		maxDescentWall = 8,
		telemetryHz = 8, -- altitude updates to the HUD per second during a flight
		debrisSeconds = 14, -- how long a dropped stage lies where it fell
	},

	-- THE MONEY. Every number is the career sim's number (tools/spacehex_career.luau,
	-- ../economy.md). Move these to move the docking launch; never move the physics.
	payout = {
		altitude = { rate = 700000, exp = 0.38 }, -- rate * km ^ exp
		performance = { rate = 300000, exp = 1.85 }, -- rate * (effective dV / 1000) ^ exp
		repeatFactor = 0.62, -- a flight that beats neither record pays this fraction
		refurbish = { rate = 0.04, recovered = 0.01 }, -- of the stack's part value, per launch
		milestones = {
			{ id = "alt_5k", kind = "apogee", at = 5000, label = "5 KM", pay = 180000 },
			{ id = "alt_20k", kind = "apogee", at = 20000, label = "20 KM", pay = 420000 },
			{ id = "alt_50k", kind = "apogee", at = 50000, label = "50 KM", pay = 900000 },
			{ id = "karman", kind = "apogee", at = 100000, label = "KÁRMÁN LINE — 100 KM", pay = 2200000 },
			{ id = "alt_250k", kind = "apogee", at = 250000, label = "250 KM", pay = 4500000 },
			{ id = "dv_2k", kind = "dv", at = 2000, label = "2,000 M/S", pay = 300000 },
			{ id = "dv_3500", kind = "dv", at = 3500, label = "3,500 M/S", pay = 900000 },
			{ id = "dv_5k", kind = "dv", at = 5000, label = "5,000 M/S", pay = 2400000 },
			{ id = "dv_6500", kind = "dv", at = 6500, label = "6,500 M/S", pay = 5000000 },
			{ id = "dv_8k", kind = "dv", at = 8000, label = "8,000 M/S", pay = 9000000 },
			{ id = "orbit", kind = "orbit", label = "ORBIT", pay = 26000000 },
			{ id = "docked", kind = "docked", label = "DOCKED WITH THE STATION", pay = 60000000 },
		},
	},
}

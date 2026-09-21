-- tiers — the mission ladder, in the exact shape ChallengeService already consumes:
--   World = { id, name, gate, challenges = { { id, label, hint, test } } }
-- locked -> open -> mastered, persisted per player, and mastering one opens the next.
--
-- This IS the tutorial. Doctrine requires every game to teach itself well enough that a
-- ten-year-old who has never seen it wants to keep playing; a mission board that names
-- the next thing to do does that without a tutorial wall, and the comps prove it (The
-- Space Simulator's NPC missions are its onboarding).
--
-- EVERY rung is decidable from one launch result, so nothing on the board is a dead
-- button. The loop reads `test` and nothing else:
--   launch            any launch, held or flown
--   apogee   at=m     apogee >= at
--   twr      at=n     lift-off thrust-to-weight >= at
--   dv       at=m/s   effective dV >= at
--   stages   at=n     the stack had at least n stages
--   mass     at=kg    lift-off mass >= at
--   payload           a payload rode along
--   rcs               an RCS pack rode along
--   part     id=x     that part id was on the stack, anywhere
--   vacuum            an upper stage flew a vacuum engine
--   orbit             effective dV reached the orbital gate
--   docked            orbit + RCS + docking port
--   deliver           docked with a payload aboard
--
-- `gate` is the tier's headline altitude for the board; opening is by mastery, not by it.
-- Tiers 5 and 6 are the road beyond the station: real stacks, real numbers, and the
-- Moon base itself comes after them (parked, brief.md).

return {
	{
		id = "atmosphere",
		name = "Upper Atmosphere",
		gate = 10_000,
		challenges = {
			{
				id = "first_launch",
				label = "Launch once",
				hint = "Roll it out, then press LAUNCH.",
				test = { kind = "launch" },
			},
			{
				id = "reach_5k",
				label = "Reach 5 km",
				hint = "A bigger tank or a better nose.",
				test = { kind = "apogee", at = 5000 },
			},
			{
				id = "reach_10k",
				label = "Reach 10 km",
				hint = "Fins, a cone and a decoupler all count.",
				test = { kind = "apogee", at = 10000 },
			},
		},
	},
	{
		id = "karman",
		name = "Kármán Line",
		gate = 100_000,
		challenges = {
			{
				id = "two_stages",
				label = "Fly a two-stage rocket",
				hint = "A decoupler between them, or they are one stage.",
				test = { kind = "stages", at = 2 },
			},
			{
				id = "twr_15",
				label = "Lift off above 1.5 : 1",
				hint = "Thrust up, or weight down.",
				test = { kind = "twr", at = 1.5 },
			},
			{
				id = "reach_100k",
				label = "Reach 100 km",
				hint = "This is where space officially starts.",
				test = { kind = "apogee", at = 100000 },
			},
		},
	},
	{
		id = "leo",
		name = "Low Earth Orbit",
		gate = 400_000,
		challenges = {
			{
				id = "dv_5000",
				label = "Build 5,000 m/s of Δv",
				hint = "Guidance multiplies the whole stack.",
				test = { kind = "dv", at = 5000 },
			},
			{
				id = "payload_first",
				label = "Fly a payload",
				hint = "It costs you altitude. A satellite needs a fairing.",
				test = { kind = "payload" },
			},
			{
				id = "orbit",
				label = "Reach orbit",
				hint = "7,700 m/s after losses. Up is the easy half.",
				test = { kind = "orbit" },
			},
		},
	},
	{
		id = "rendezvous",
		name = "Station Rendezvous",
		gate = 400_000,
		challenges = {
			{
				id = "rcs_flown",
				label = "Fly an RCS pack",
				hint = "You cannot line up on a port without thrusters.",
				test = { kind = "rcs" },
			},
			{
				id = "dock",
				label = "Dock with the station",
				hint = "Orbit, RCS and a docking port on one stack.",
				test = { kind = "docked" },
			},
			{
				id = "deliver",
				label = "Deliver a payload to the station",
				hint = "Dock with something in the bay.",
				test = { kind = "deliver" },
			},
		},
	},
	{
		id = "tli",
		name = "Trans-Lunar Injection",
		gate = 0,
		challenges = {
			{
				id = "three_stages",
				label = "Fly a three-stage rocket",
				hint = "Each stage drops the weight of the last.",
				test = { kind = "stages", at = 3 },
			},
			{
				id = "vacuum_stage",
				label = "Fly a vacuum engine up top",
				hint = "Poor at sea level, superb once the air is gone.",
				test = { kind = "vacuum" },
			},
			{
				id = "dv_10000",
				label = "Build 10,000 m/s of Δv",
				hint = "Escape is expensive. Four stages, two of them vacuum.",
				test = { kind = "dv", at = 10000 },
			},
		},
	},
	{
		id = "moon",
		name = "Moon Landing",
		gate = 0,
		challenges = {
			{
				id = "legs_flown",
				label = "Fly landing legs",
				hint = "They need grid fins on the same stage.",
				test = { kind = "part", id = "legs" },
			},
			{
				id = "four_stages",
				label = "Fly a four-stage rocket",
				hint = "The most the hangar can stack.",
				test = { kind = "stages", at = 4 },
			},
			{
				id = "heavy_lift",
				label = "Lift 100 tonnes off the pad",
				hint = "That needs the Flame Trench under it.",
				test = { kind = "mass", at = 100000 },
			},
		},
	},
}

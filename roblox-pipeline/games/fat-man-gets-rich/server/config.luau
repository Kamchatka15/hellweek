-- config — every tuning number for Fat Man Gets Rich. Server-only: prices never
-- replicate, the catalog does (skills/roblox-economy.md, skills/roblox-security.md).
--
-- These are FIRST-PASS numbers for a playtest, not a G2-approved economy. The whole
-- point of the slice is to find out which of them are wrong.
--
-- The first-session arithmetic they are chosen to produce:
--   level 1 burst  = 60 coins x 1 value = 60, against a 40 bag
--   -> the first payout overfills the bag, which teaches the bank with no tutorial
--   -> two banks (~30s) = 80 coins, and the first upgrade costs 50
--   -> first earn -> spend -> visible progress inside the first minute

return {
	-- Which of this pack's upgrades fills each engine slot. LoopService reads these
	-- instead of hardcoding our vocabulary.
	roles = {
		carryCap = "bag",
		collectRadius = "magnet",
		burstCount = "payout",
		pickupValue = "shine",
	},

	flood = {
		cooldown = 4, -- seconds between payouts while standing on the pad
		lifetime = 45, -- how long a dropped coin survives; generous on purpose
		speed = 26, -- outward launch speed
		lift = 42, -- upward launch speed
		originHeight = 9, -- studs above the pad the burst erupts from
		size = Vector3.new(0.25, 1.4, 1.4), -- a coin, not a cube
		material = Enum.Material.Neon,
		maxActive = 420, -- server-wide ceiling on live pickups
	},

	collect = {
		baseRadius = 6, -- studs, before the magnet upgrade
	},

	offline = {
		capSeconds = 8 * 3600, -- a school night is covered; nothing is ever lost
		burstsPerHour = 4, -- offline pays ~4 payouts an hour vs. ~15/min while playing
	},

	upgrades = {
		{
			id = "bag",
			label = "Bigger Bag",
			blurb = "Carry more before you have to bank.",
			maxLevel = 10,
			baseCost = 50,
			costGrowth = 1.85,
			base = 40,
			perLevel = 35,
		},
		{
			id = "payout",
			label = "Bigger Payout",
			blurb = "More coins in every flood.",
			maxLevel = 8,
			baseCost = 75,
			costGrowth = 1.9,
			base = 60,
			perLevel = 22,
		},
		{
			id = "magnet",
			label = "Coin Magnet",
			blurb = "Sweep coins up from further away.",
			maxLevel = 6,
			baseCost = 60,
			costGrowth = 1.8,
			base = 0,
			perLevel = 2.5,
		},
		{
			id = "shine",
			label = "Shinier Coins",
			blurb = "Every coin is worth more.",
			maxLevel = 6,
			baseCost = 120,
			costGrowth = 2.1,
			base = 1,
			perLevel = 1,
		},
	},
}

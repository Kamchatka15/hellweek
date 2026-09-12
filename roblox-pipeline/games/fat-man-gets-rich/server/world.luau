-- world — the grey-box layout, as data.
--
-- Built at run time by ContentLoader rather than placed in Studio, so the repo alone is
-- a playable game and the layout diffs like code. Distances are the design:
--   spawn -> payout pad is 20 studs (about two seconds) so the hook lands well inside
--   the 60s the brief demands. Payout -> bank is 52 studs, far enough that banking is a
--   decision and near enough that a snack session never feels like commuting.

local theme = require(game:GetService("ReplicatedStorage").Pack.theme)

return {
	floor = {
		size = Vector3.new(150, 2, 150),
		position = Vector3.new(0, -1, 0),
		color = theme.floor,
		material = Enum.Material.SmoothPlastic,
	},

	-- Walls exist so a coin never slides out of the world. Watching a coin you earned
	-- disappear over an edge reads as the game taking something back.
	walls = {
		height = 14,
		thickness = 2,
		color = theme.wall,
		material = Enum.Material.SmoothPlastic,
		transparency = 0.35,
	},

	props = {
		{ name = "Pillar1", size = Vector3.new(6, 18, 6), position = Vector3.new(-46, 8, -46), color = theme.wall },
		{ name = "Pillar2", size = Vector3.new(6, 18, 6), position = Vector3.new(46, 8, -46), color = theme.wall },
		{ name = "Pillar3", size = Vector3.new(6, 18, 6), position = Vector3.new(-46, 8, 46), color = theme.wall },
		{ name = "Pillar4", size = Vector3.new(6, 18, 6), position = Vector3.new(46, 8, 46), color = theme.wall },
	},

	zones = {
		{
			id = "payout",
			kind = "payout",
			size = Vector3.new(16, 1, 16),
			position = Vector3.new(0, 0.5, -26),
			color = theme.payout,
			label = "PAYOUT",
			sublabel = "STAND HERE",
		},
		{
			id = "bank",
			kind = "bank",
			size = Vector3.new(18, 1, 18),
			position = Vector3.new(0, 0.5, 26),
			color = theme.bank,
			label = "BANK",
			sublabel = "DROP YOUR COINS",
		},
		{
			id = "shop",
			kind = "shop",
			size = Vector3.new(12, 1, 12),
			position = Vector3.new(-30, 0.5, 4),
			color = theme.shop,
			label = "UPGRADES",
			sublabel = "SPEND YOUR COINS",
		},
	},

	spawn = {
		position = Vector3.new(0, 0.5, -6),
		lookAt = Vector3.new(0, 0.5, -26), -- face the payout pad on arrival
	},
}

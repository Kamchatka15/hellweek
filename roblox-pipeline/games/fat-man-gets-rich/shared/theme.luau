-- theme — names, colors and copy for Fat Man Gets Rich. Replicated, because the HUD
-- needs it. No numbers live here: tuning is server-side in config.luau so the client
-- never holds a price (skills/roblox-security.md).
--
-- TITLE HISTORY, kept because it is the reason this file looks the way it does:
-- the title was "Peter Gets Rich" and Justin's reference for "Peter" was Peter Griffin.
-- That is Fox/Disney property, and CLAUDE.md's non-negotiables, skills/art-pipeline.md
-- and the Steal-a-Brainrot precedent in PIPELINE.md §1 all forbid third-party IP. The
-- build refused the likeness and kept the comedic register; Justin then renamed the
-- title to "Fat Man Gets Rich" on 2026-09-11, which removes the last hook to it.
--
-- What that leaves, and what art direction at Gate 4 must hold to: a round, ordinary,
-- badly-dressed everyman who ends up absurdly rich, drawn from scratch. The joke is the
-- scale of the money, never cruelty aimed at the character — a mascot the player is
-- laughing WITH survives moderation, parents, and its own store page. Specifically
-- still refused: the green-shirt/white-collar/brown-pants costume, the
-- glasses-and-chin silhouette, the voice, Quahog, and any Family Guy lookalike
-- commission.

return {
	title = "Fat Man Gets Rich",
	currencyName = "Coins",
	bankVerb = "bank",

	-- Grey-box palette. The flood has to read at 200px in two seconds (brief), so the
	-- pickup color is the highest-contrast thing in the scene and everything else is
	-- deliberately drab.
	pickupColor = Color3.fromRGB(255, 206, 61),
	accent = Color3.fromRGB(255, 206, 61),
	floor = Color3.fromRGB(58, 60, 66),
	wall = Color3.fromRGB(78, 81, 88),
	payout = Color3.fromRGB(255, 176, 46),
	bank = Color3.fromRGB(76, 204, 122),
	shop = Color3.fromRGB(86, 150, 255),

	uiBackground = Color3.fromRGB(22, 23, 28),
	uiPanel = Color3.fromRGB(32, 34, 41),
	uiText = Color3.fromRGB(245, 245, 248),
	uiMuted = Color3.fromRGB(168, 172, 182),
	uiGood = Color3.fromRGB(76, 204, 122),
	uiWarn = Color3.fromRGB(255, 176, 46),

	-- Copy. Written for a nine-year-old reading at a glance, per the MCP QA question in
	-- skills/studio-mcp.md: "would a 9-year-old know what to tap?"
	copy = {
		offlineTitle = "WHILE YOU WERE GONE",
		offlineBody = "Your coins kept piling up.",
		shopTitle = "UPGRADES",
		shopEmpty = "Bank some coins first!",
		carryLabel = "BAG",
	},
}

-- sku — DRAFT price ladder. NOT WIRED TO ANYTHING.
--
-- ================================ READ THIS ==================================
-- Nothing in this file is loaded by the running game. No MarketplaceService call
-- exists anywhere in this repo, and no ReceiptService has been written.
--
-- Creating ANY paid product is Gate 5 / G5: an explicit human click, never automated,
-- and silence is not approval (CLAUDE.md non-negotiables, PIPELINE.md §0). So this is
-- a document that happens to be Luau — the ladder we would propose at G2, written down
-- now while the reasoning is fresh, so the slice is not shaped around a guess later.
--
-- When Justin approves a product, the first engine module built is ReceiptService:
-- idempotent ProcessReceipt over a durable receipt ledger, ledger write BEFORE
-- PurchaseGranted, repeat ReceiptIds granted without re-granting
-- (skills/roblox-security.md). Not before, because an untested receipt path written
-- against products that do not exist is the "feature-complete before players"
-- anti-pattern, not diligence.
-- =============================================================================
--
-- Doctrine constraints every row below already satisfies:
--   * doctrine §4.4 / roblox-economy: ONE obvious first purchase, 25-99 R$, overdelivering
--   * every SKU answers "what does this let me DO or SHOW?"
--   * NO randomized purchase of any kind. No crates, no keys, no spins, no odds to
--     disclose, no PolicyService fallback to get wrong. Direct-buy and earnable only.
--   * nothing here is pay-to-stop-suffering; every row accelerates or displays a loop
--     the player already likes

return {
	proposedFirstPurchase = {
		id = "starter_bag",
		kind = "gamepass",
		price = 49, -- R$, inside the 25-99 trust band
		label = "Starter Bag",
		does = "Doubles bag capacity forever, from the moment you buy it.",
		why = "Accelerates the one thing a new player is already annoyed by (banking trips).",
		earnable = "The same capacity is reachable free via the Bigger Bag upgrade ladder.",
	},

	proposedLadder = {
		{
			id = "payout_boost_2x_1h",
			kind = "developerproduct",
			price = 99,
			label = "Double Payout - 1 hour",
			does = "Every flood drops twice the coins for an hour.",
			lane = "acceleration",
		},
		{
			id = "golden_pad",
			kind = "gamepass",
			price = 199,
			label = "Golden Payout Pad",
			does = "Your pad is visibly gold and taller. Everyone on the server sees it.",
			lane = "status", -- status only sells if other players can see it
		},
		{
			id = "offline_12h",
			kind = "gamepass",
			price = 299,
			label = "Overnight Vault",
			does = "Offline earnings cap rises from 8h to 12h.",
			lane = "acceleration",
			note = "Raises a CAP. Never adds decay, never adds a timer, never punishes missing a day.",
		},
	},

	refusedOnPurpose = {
		"Coin crates / mystery boxes of any kind - paid randomness, odds disclosure, regional restrictions. Skip the category.",
		"Timed 'your coins expire' pressure - dark pattern, and doctrine §8 forbids it.",
		"Currency bundles priced to obscure the exchange rate - FTC x Epic, $520M.",
		"Anything that makes NOT paying worse, rather than paying better.",
	},
}

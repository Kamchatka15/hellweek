-- sku — DRAFT soft-shop ladder for Hell Week. NOT WIRED TO ANYTHING.
--
-- ================================ READ THIS ==================================
-- Nothing in this file is loaded by the running game. No MarketplaceService call
-- exists anywhere in this repo, and no ReceiptService has been written.
--
-- Creating ANY paid product is Gate 5 / G5: an explicit human click, never automated,
-- and silence is not approval. The brief (§6) asks for three "shop stubs" coded but
-- never forced before a Day-2 survive; this is the stub. The engine module that
-- wires it (ReceiptService: idempotent ProcessReceipt over a durable receipt ledger)
-- is built the day Justin approves a product, not before.
-- =============================================================================
--
-- Settled answer §1.5: soft shop, not a door. F2P finishes Day 7 if they play well.
-- Oil is slack, never a key. No day is ever locked behind Robux. No randomness.

return {
	-- Offered only after the player has survived to Day 2 once (never in the teach).
	offerAfter = { dayReached = 2 },

	proposedFirstPurchase = {
		id = "wick_oil",
		kind = "developerproduct",
		price = 49, -- R$, inside the 25-99 trust band
		label = "Wick Oil",
		does = "+4 fuel to the Wick, this run.",
		why = "Slack on Day 3 when the burn first bites. It buys time, never a day.",
		earnable = "Four Ashwood do the same thing. Ring C has them.",
	},

	proposedLadder = {
		{
			id = "deep_pockets",
			kind = "gamepass",
			price = 99,
			label = "Deep Pockets",
			does = "Sack holds 5 instead of 3. Persists.",
			lane = "acceleration",
		},
		{
			id = "second_wind",
			kind = "developerproduct",
			price = 79,
			label = "Second Wind",
			does = "One wake at the Wick with no fuel penalty, this run.",
			lane = "acceleration",
			note = "Removes ONE setback. Never removes the Tempter, never skips a night.",
		},
	},

	refusedOnPurpose = {
		"Anything that unlocks or skips a day - the week is the game.",
		"Crates, spins, mystery piles - paid randomness. The Gift is free and its cost is known.",
		"'Salvation', 'blessing', 'holy' anything in a product name - settled answer 1.",
		"A lobby class shop - parked to Pass 2 by the cut list.",
	},
}

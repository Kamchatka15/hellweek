-- theme — names, colours and copy for Hell Week. Replicated, because the HUD needs it.
-- No tuning numbers live here: those are server-side in config.luau.
--
-- Register (designers only, never printed): a dead place that used to be lived in.
-- Bleached, quiet, wrong. Not fire, not torture, not scripture. The player-facing zone
-- name is The Ashen Waste. Settled answers in games/hell-week/brief.md §1 — do not
-- reopen them here.

return {
	title = "Hell Week",
	loop = "survive",
	zoneName = "The Ashen Waste",

	-- The engine's vocabulary slots, filled with this title's words.
	names = {
		beacon = "Obelisk",
		fuel = "Ashwood",
		water = "Water",
		stalker = "Tempter",
		lure = "Gift",
		sack = "Sack",
		offering = "Offering",
		chest = "Chest",
	},

	weightVisibleFromDay = 3,

	-- The opening act (Justin, 2026-09-12): a title card over the black at every join,
	-- skippable with a tap. Narration is the largest register; the voice is the bold,
	-- blood-drenched one; the meaning sits quiet beneath it. NOTE: this reopens two of
	-- the brief's own rules on purpose — "no paragraph in the first minute" (§4) and
	-- the no-angels/no-heaven register (§1.1). Owner's call, recorded in brief.md.
	opening = {
		-- The ENGLISH is the voice now (Justin, 2026-09-12): big, blood red, the line
		-- the player actually reads. The old tongue sits small and dim beneath it as
		-- aura — nothing in it is needed, and skipping it costs the player nothing.
		--
		-- NOTE ON THE COPY: Justin wrote "You must of fell asleep in class". Corrected
		-- to "must've fallen" — in shipped narration the original reads as a typo
		-- rather than a voice, and this is the first sentence a stranger ever sees.
		-- Revert in one line if the rougher voice was the intent.
		narration = {
			"You must've fallen asleep in class...",
			"Then you hear a voice.",
		},
		voice = {
			"Whither is fled the glory of the angels,",
			"which we should have in heaven?",
			"This is a home of darkness,",
			"terribly bound with fettering bonds of fire.",
		},
		echo = {
			"Ten shemen aût akhu nu pet",
			"nety wenes nen em pet",
			"Per pen en keku pu",
			"qastuef em nuḥu en khet nesret",
		},
		skipHint = "TAP TO SKIP",
		narrationColor = Color3.fromRGB(186, 182, 176),
		voiceColor = Color3.fromRGB(176, 6, 6),
		voiceStroke = Color3.fromRGB(34, 0, 0),
		dripColor = Color3.fromRGB(126, 4, 4),
		echoColor = Color3.fromRGB(104, 74, 74),
	},

	-- Five style lines (games/hell-week/theme.md): grey sand / black water + fire gold.
	-- The Gift's bloom is the only competing warm, and it is deliberately WRONG — a
	-- pink-orange that does not belong to the wick.
	colors = {
		-- VISION PALETTE. Six colours and nothing else while `vision.on` is true:
		-- charcoal stone, ash sand, bone, wick gold, fire orange, night void.
		safeRing = Color3.fromRGB(212, 168, 62), -- the gold ring IS the safe zone
		sand = Color3.fromRGB(145, 125, 95), -- ash sand
		water = Color3.fromRGB(92, 178, 198),
		post = Color3.fromRGB(45, 42, 40),
		lip = Color3.fromRGB(45, 42, 40),
		flame = Color3.fromRGB(255, 138, 48), -- fire orange
		flameLight = Color3.fromRGB(255, 138, 48),
		fuel = Color3.fromRGB(212, 168, 62),
		stalker = Color3.fromRGB(18, 16, 26), -- night void
		lure = Color3.fromRGB(255, 138, 48),
		lureLight = Color3.fromRGB(255, 138, 48),
		fog = Color3.fromRGB(145, 125, 95), -- ash, so any slab that shows reads as haze
		tree = Color3.fromRGB(45, 42, 40),
		driftwood = Color3.fromRGB(45, 42, 40),
		rock = Color3.fromRGB(45, 42, 40),
		night = Color3.fromRGB(18, 16, 26),
		bone = Color3.fromRGB(210, 200, 180),
		gold = Color3.fromRGB(212, 168, 62),
	},
	-- The ground ring is gold METAL by day, not neon: inlay, not a glow.
	safeRingMaterial = Enum.Material.Metal,
	safeRingTransparency = 0,
	-- At night the same ring goes slightly Neon, so the safe radius is readable
	-- when the ground it is painted on is not.
	safeRingNightMaterial = Enum.Material.Neon,
	safeRingNightTransparency = 0.35,

	accent = Color3.fromRGB(255, 190, 70),
	uiBackground = Color3.fromRGB(14, 15, 20),
	uiPanel = Color3.fromRGB(24, 26, 34),
	uiText = Color3.fromRGB(236, 236, 240),
	uiMuted = Color3.fromRGB(150, 154, 166),
	uiGood = Color3.fromRGB(214, 196, 120),
	uiWarn = Color3.fromRGB(255, 140, 96),

	-- Copy. Every line is one sentence a nine-year-old can read at a glance, and there
	-- are exactly two onboarding lines (brief §4). No scripture, no sermons, no names
	-- of anywhere in the parked list.
	copy = {
		-- Telegraphed, never sprung. Lowercase and plain on purpose: the leader's
		-- danger lines are written the way a friend would say them, not the way a
		-- system would log them.
		nightComing = "night is coming",
		beaconGuttered = "the light is out — but it holds, this once",

		-- INSPECT. Point at a thing and press I. One line saying what it is, one
		-- saying what it does; the live state is filled in by the server. These
		-- replaced the permanent floating labels, which ate the screen to say less.
		inspectHint = "[I]",
		inspectObelisk = "The Obelisk",
		inspectObeliskDoes = "Feed it what burns. Offer it what does not, and come back at dawn for what it made.",
		inspectOffering = "The Offering Table",
		inspectOfferingDoes = "Leave a sack here. The obelisk works on it overnight.",
		inspectChest = "Chest",
		inspectChestDoes = "Opens once. Whatever is inside goes straight into your sack.",
		inspectNothing = "Nothing here to look at.",
		inspectTooFar = "Too far away to make out.",
		heraldComes = "something is walking toward the light",
		heraldDrinks = "it is drinking the light",
		heraldDriven = "it draws back into the dark",
		creatureHit = "it turns on you",
		creatureKilled = "it stops moving",
		nothingFits = "it has no use for that",

		toastClock = "THE FIRE IS THE ONLY CLOCK",
		toastWaits = "IT WAITS FOR THE LIGHT TO THIN",
		pickUp = "PICK UP",
		sackFull = "SACK FULL — TAKE IT TO THE OBELISK",
		beaconFull = "THE FIRE IS FULL",
		nothingBurns = "NONE OF THAT BURNS — OFFER IT INSTEAD",
		weightLifted = "THE STONE TAKES THE WEIGHT",
		notThatWay = "NOT THAT WAY",
		downed = "THE DARK TOOK YOU",
		lightOut = "THE LIGHT WENT OUT",
		weekDone = "YOU LASTED THE WEEK",
		fogPeels = "THE WASTE OPENS",
		offered = "THE OBELISK TAKES IT",
		offeringEmpty = "NOTHING TO OFFER",
		returned = "IT GAVE BACK MORE THAN IT TOOK",
		nothingHere = "NOTHING HERE",
		pickupLabel = "PICK UP",
		actionFeed = "FEED",
		actionOffer = "OFFER",
		actionOpen = "OPEN",
		infoLabel = "INFO",
		recipeTitle = "THE OBELISK CAN MAKE",
		howToPlay = "Feed the fire. Do not go into the dark. Do not take the pile that looks too good.",
		toolMade = "THE OBELISK MADE YOU SOMETHING",
		chestLabel = "OPEN",
		chestOpened = "SOMETHING WAS LEFT HERE",
		worldChanged = "THE GROUND IS NOT WHERE IT WAS",
		challengeTitle = "TRIALS",
		challengeDone = "TRIAL PASSED",
		dayLabel = "Day",
		scoreLabel = "Score",
	},
}

-- theme — names, colours and copy for Hell Week. Replicated, because the HUD needs it.
-- No tuning numbers live here: those are server-side in config.luau.
--
-- Register (designers only, never printed): a quiet grave, low tide in a place that
-- used to be a beach. Not fire, not torture, not scripture. The player-facing zone
-- name is The Quiet Shore. Settled answers in games/hell-week/brief.md §1 — do not
-- reopen them here.

return {
	title = "Hell Week",
	loop = "survive",
	zoneName = "The Quiet Shore",

	-- The engine's vocabulary slots, filled with this title's words.
	names = {
		beacon = "Obelisk",
		fuel = "Ashwood",
		stalker = "Tempter",
		lure = "Gift",
		sack = "Sack",
		offering = "Offering",
	},

	weightVisibleFromDay = 3,

	-- The opening act (Justin, 2026-09-12): a title card over the black at every join,
	-- skippable with a tap. Narration is the largest register; the voice is the bold,
	-- blood-drenched one; the meaning sits quiet beneath it. NOTE: this reopens two of
	-- the brief's own rules on purpose — "no paragraph in the first minute" (§4) and
	-- the no-angels/no-heaven register (§1.1). Owner's call, recorded in brief.md.
	opening = {
		narration = {
			"You awake as if from a dream.",
			"You are not in your bed.",
			"Then you hear a dark, ancient voice speak...",
		},
		voice = {
			"Ten shemen aût akhu nu pet",
			"nety wenes nen em pet",
			"Per pen en keku pu",
			"qastuef em nuḥu en khet nesret",
		},
		meaningLead = "Somehow you know it means:",
		meaning = "Whither is fled the glory of the angels, which we should have in heaven? "
			.. "This is a home of darkness, terribly bound with fettering bonds of fire.",
		skipHint = "TAP TO SKIP",
		narrationColor = Color3.fromRGB(214, 210, 200),
		voiceColor = Color3.fromRGB(168, 8, 8),
		voiceStroke = Color3.fromRGB(38, 0, 0),
		dripColor = Color3.fromRGB(118, 4, 4),
		meaningColor = Color3.fromRGB(196, 186, 170),
	},

	-- Five style lines (games/hell-week/theme.md): grey sand / black water + fire gold.
	-- The Gift's bloom is the only competing warm, and it is deliberately WRONG — a
	-- pink-orange that does not belong to the wick.
	colors = {
		sand = Color3.fromRGB(112, 114, 112),
		water = Color3.fromRGB(8, 9, 12),
		post = Color3.fromRGB(70, 62, 56),
		lip = Color3.fromRGB(46, 46, 50),
		flame = Color3.fromRGB(255, 190, 70),
		flameLight = Color3.fromRGB(255, 176, 96),
		fuel = Color3.fromRGB(226, 224, 212),
		stalker = Color3.fromRGB(9, 9, 13),
		lure = Color3.fromRGB(255, 120, 96),
		lureLight = Color3.fromRGB(255, 96, 120),
		fog = Color3.fromRGB(90, 100, 120),
		tree = Color3.fromRGB(150, 150, 146),
		driftwood = Color3.fromRGB(130, 124, 116),
		rock = Color3.fromRGB(84, 86, 90),
		night = Color3.fromRGB(110, 120, 160),
	},

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
		toastClock = "THE FIRE IS THE ONLY CLOCK",
		toastWaits = "IT WAITS FOR THE LIGHT TO THIN",
		pickUp = "PICK UP",
		sackFull = "SACK FULL — CARRY IT TO THE OBELISK",
		beaconFull = "THE FIRE IS FULL",
		notThatWay = "NOT THAT WAY",
		downed = "THE DARK TOOK YOU",
		lightOut = "THE LIGHT WENT OUT",
		weekDone = "YOU LASTED THE WEEK",
		fogPeels = "THE SHORE OPENS",
		offered = "THE OBELISK TAKES IT",
		offeringEmpty = "NOTHING TO OFFER",
		returned = "IT GAVE BACK MORE THAN IT TOOK",
		challengeTitle = "TRIALS",
		challengeDone = "TRIAL PASSED",
		dayLabel = "Day",
		scoreLabel = "Score",
	},
}

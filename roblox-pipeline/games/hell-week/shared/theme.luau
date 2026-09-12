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
		sand = Color3.fromRGB(168, 150, 122), -- bleached dead sand, never golden-hour warm
		water = Color3.fromRGB(92, 178, 198),
		post = Color3.fromRGB(70, 62, 56),
		lip = Color3.fromRGB(46, 46, 50),
		flame = Color3.fromRGB(255, 190, 70),
		flameLight = Color3.fromRGB(255, 176, 96),
		fuel = Color3.fromRGB(226, 224, 212),
		stalker = Color3.fromRGB(9, 9, 13),
		lure = Color3.fromRGB(255, 120, 96),
		lureLight = Color3.fromRGB(255, 96, 120),
		fog = Color3.fromRGB(104, 96, 92),
		tree = Color3.fromRGB(104, 90, 74),
		driftwood = Color3.fromRGB(126, 110, 90),
		rock = Color3.fromRGB(78, 68, 60),
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
		challengeTitle = "TRIALS",
		challengeDone = "TRIAL PASSED",
		dayLabel = "Day",
		scoreLabel = "Score",
	},
}

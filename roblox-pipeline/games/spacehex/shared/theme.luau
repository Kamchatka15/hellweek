-- theme — names, colours and copy for SPACEHEX. Replicated, because the HUD needs it.
-- No numbers live here: tuning is server-side in config.luau so the client never holds
-- a price (skills/roblox-security.md).
--
-- THE VISUAL BET, stated so Gate 4 can be held to it:
-- hard black sky, one hard white sun, no fog, and ONE warm colour on the whole screen —
-- the altitude ribbon and the fire under the rocket. Every comp's thumbnail is a busy
-- blue Earth plate; at 200px ours is a small rocket, a lot of black, and a number. The
-- hexagon is the identity at every scale: the pad, the tier badges, the Moon modules.

return {
	title = "SPACEHEX",
	loop = "build",
	currencyName = "Cash",
	currencySymbol = "$",

	accent = Color3.fromRGB(255, 138, 48), -- the one warm colour: the ribbon and the fire
	floor = Color3.fromRGB(38, 40, 46),
	wall = Color3.fromRGB(60, 64, 72),
	pad = Color3.fromRGB(112, 116, 126), -- the hex disc: cold steel, not a warm target
	hangar = Color3.fromRGB(64, 70, 84),
	warehouse = Color3.fromRGB(64, 70, 84),

	-- The rocket's own palette. Cold, so the fire under it is the only warm thing.
	rocket = {
		body = Color3.fromRGB(222, 224, 230),
		bell = Color3.fromRGB(58, 60, 68),
		dark = Color3.fromRGB(38, 40, 46),
		fin = Color3.fromRGB(120, 124, 134),
		payload = Color3.fromRGB(110, 130, 160),
		flame = Color3.fromRGB(255, 138, 48),
		flameTip = Color3.fromRGB(255, 224, 160),
	},

	uiBackground = Color3.fromRGB(12, 13, 17),
	uiPanel = Color3.fromRGB(24, 26, 33),
	uiText = Color3.fromRGB(240, 242, 248),
	uiMuted = Color3.fromRGB(150, 156, 170),
	uiGood = Color3.fromRGB(80, 208, 168),
	uiWarn = Color3.fromRGB(255, 138, 48),
	uiBad = Color3.fromRGB(235, 80, 70), -- a problem on the pad card; red means it does not go up

	-- Copy. Written for a nine-year-old reading at a glance, per the MCP QA question in
	-- skills/studio-mcp.md: "would a 9-year-old know what to tap?" Nothing player-facing
	-- is hardcoded in the client; every string it shows is one of these.
	copy = {
		howToPlay = "Buy parts. Stack them. The card says if it flies. Launch. Get paid for how high and how fast.",
		cashLabel = "CASH",

		-- navigation
		navWarehouse = "WAREHOUSE",
		navAssembly = "ASSEMBLY",
		navPad = "PAD CARD",
		navMissions = "MISSIONS",
		close = "CLOSE",

		-- warehouse
		warehouseTitle = "WAREHOUSE",
		groupEngines = "ENGINES",
		groupTanks = "TANKS",
		groupAero = "AERO",
		groupAvionics = "GUIDANCE",
		groupStructure = "STRUCTURE",
		groupMission = "MISSION",
		groupPad = "PAD",
		buy = "BUY",
		owned = "OWNED",
		yourPad = "YOUR PAD",
		upgradePad = "UPGRADE",
		padLater = "AFTER THE NEXT PAD",
		statThrust = "THRUST",
		statIsp = "ISP",
		statMass = "MASS",
		statProp = "FUEL",
		statCd = "DRAG",
		statControl = "CONTROL",
		statTurn = "TURN",
		statRefund = "REFUND",
		statLimit = "MASS LIMIT",
		tagVacuum = "VACUUM BELL",
		tagNeedsFairing = "NEEDS A FAIRING",
		tagNeedsRcs = "NEEDS RCS",
		tagNeedsGrid = "NEEDS GRID FINS",
		tagReusable = "REUSABLE",

		-- assembly
		assemblyTitle = "ASSEMBLY",
		stage = "STAGE",
		addStage = "+ ADD A STAGE",
		removeStage = "REMOVE",
		engine = "ENGINE",
		engineCount = "ENGINES",
		tank = "TANK",
		decoupler = "DECOUPLER",
		fins = "FINS",
		recovery = "RECOVERY",
		nose = "NOSE",
		guidance = "GUIDANCE",
		payload = "PAYLOAD",
		rcs = "RCS PACK",
		dock = "DOCKING PORT",
		none = "NONE",
		on = "ON",
		off = "OFF",
		clear = "CLEAR THE STACK",
		ready = "READY TO ROLL OUT",
		problemsTitle = "BEFORE IT CAN FLY",
		noCard = "Give every stage an engine and a tank and the numbers appear here.",

		-- pad card
		padTitle = "PAD CARD",
		thrust = "THRUST",
		weight = "WEIGHT",
		liftoff = "LIFT-OFF",
		deltaV = "Δv",
		orbitNeeds = "ORBIT NEEDS",
		mass = "MASS",
		padLimit = "PAD LIMIT",
		apogee = "EST. APOGEE",
		refurbish = "REFURBISH",
		rollout = "ROLL OUT",
		launch = "LAUNCH",
		onPad = "ON THE PAD",
		padBusy = "PAD IN USE",
		fixFirst = "FIX THE RED LINES FIRST",
		willOrbit = "IT WILL REACH ORBIT",

		-- flight
		countdown = "T-",
		altitude = "ALTITUDE",
		speed = "SPEED",
		phasePrelaunch = "COUNTDOWN",
		phaseAscent = "ASCENT",
		phaseCoast = "COAST",
		phaseDescent = "DESCENT",
		phaseRecovery = "RECOVERY",
		held = "HOLD-DOWN",
		staged = "STAGE SEPARATION",
		apogeeReached = "APOGEE",
		orbitReached = "ORBIT",
		dockedReached = "DOCKED WITH THE STATION",
		touchdown = "DOWN",
		flying = "is flying",

		-- missions
		missionsTitle = "MISSIONS",
		tierLocked = "LOCKED",
		tierOpen = "OPEN",
		tierDone = "DONE",

		-- server toasts (the server reads these too; the pack owns every sentence)
		bought = "BOUGHT",
		fitted = "fitted to the stack",
		needMore = "NOT ENOUGH CASH — you need %s more",
		alreadyOwned = "You already own that.",
		notForSale = "That is not for sale.",
		padOwned = "You own the biggest pad there is.",
		padBought = "PAD UPGRADED",
		fixProblems = "It cannot roll out yet — read the red lines.",
		padInUse = "The pad is in use. Wait for the flight to end.",
		rolledOut = "ROLLED OUT — the card is live",
		rolledBack = "Rolled back to the hangar.",
		notYours = "That is not your rocket.",
		rollOutFirst = "Roll it out first.",
		heldToast = "IT WILL NOT LIFT — thrust is less than weight.",
		paid = "PAID",
		newRecord = "NEW RECORD",
		repeatFlight = "no record — %d%% pay",
		milestone = "MILESTONE",
		missionDone = "MISSION COMPLETE",
		tierOpened = "NEW TIER OPEN",
		stageAway = "stage away",
		badAssembly = "That stack was rejected: %s",
	},
}

-- SurviveLoop — the survive-the-night loop family, generically.
--
-- gather fuel -> carry it (capped) -> feed the beacon -> the light holds the night
--         ^                                                     |
--    tomorrow burns faster if you slacked or took the lure  <---+
--
-- The engine must not know that this title calls its beacon a wick or its stalker a
-- tempter. Every name, colour and number comes from the pack: `config` for tuning,
-- `theme` for vocabulary. Swap the pack, keep the loop.
--
-- Trust surface: ZERO client->server remotes. Picking up is a server proximity sweep,
-- feeding is a server-detected zone entry, the clock and the fuel are server numbers.
-- The client renders what it is told.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Core = script.Parent
local AnalyticsService = require(Core.AnalyticsService)
local BeaconService = require(Core.BeaconService)
local ChallengeService = require(Core.ChallengeService)
local ClockService = require(Core.ClockService)
local ContentLoader = require(Core.ContentLoader)
local DataService = require(Core.DataService)
local PickupService = require(Core.PickupService)
local RecipeService = require(Core.RecipeService)
local RemoteGuard = require(Core.RemoteGuard)
local SackService = require(Core.SackService)
local StalkerService = require(Core.StalkerService)
local StateSync = require(Core.StateSync)
local ZoneService = require(Core.ZoneService)

local Shared = game:GetService("ReplicatedStorage").Shared
local Net = require(Shared.Net)

local SurviveLoop = {}

local TOAST_COOLDOWN = 4
local FEED_POLL = 0.25
local BOUNDARY_POLL = 0.5
local OPENING_PUSHES = { 0, 0.5, 1.5, 3 }

local pack: any = nil
local config: any = nil
local theme: any = nil

local run = {
	active = false,
	day = 0,
	phase = "day",
	weight = 0,
	lures = 0,
	fuelIn = 0,
	fuelOut = 0,
	stalkerSeen = false,
	downs = 0,
	bowl = {} :: { [string]: number },
	startedAt = 0,
}

local insideBeacon: { [Player]: boolean } = {}
local nextToastAt: { [Player]: { [string]: number } } = {}
local joinedAt: { [Player]: number } = {}
local nudged: { [Player]: boolean } = {}
local seenStalkerToast: { [Player]: boolean } = {}
local pickedUpEver: { [Player]: boolean } = {}
local nudgeHighlight: Highlight? = nil

-- Dawn hands the bowl back, and the clock reaches that point before the verb block is
-- read, so it is declared here and filled in below.
local returnOfferings: () -> ()

local fogRing: { BasePart } = {}
local stalkerModel: Model? = nil

-- ---------------------------------------------------------------- helpers

local function toast(player: Player, key: string, text: string, tone: string?, cooldown: number?)
	local now = os.clock()
	local perPlayer = nextToastAt[player]
	if not perPlayer then
		perPlayer = {}
		nextToastAt[player] = perPlayer
	end
	if (perPlayer[key] or 0) > now then
		return
	end
	perPlayer[key] = now + (cooldown or TOAST_COOLDOWN)
	RemoteGuard.fire(player, Net.S2C_Toast, text, tone or "info")
end

local function toastAll(key: string, text: string, tone: string?)
	for _, player in Players:GetPlayers() do
		toast(player, key, text, tone, 0.5)
	end
end

local function fxAll(kind: string, payload: any?)
	RemoteGuard.fireAll(Net.S2C_Fx, kind, payload)
end

local function fx(player: Player, kind: string, payload: any?)
	RemoteGuard.fire(player, Net.S2C_Fx, kind, payload)
end

--- Award a challenge to everyone present and say so once. Challenges are per-player
--- and idempotent, so a returning player is never re-awarded and a new one is not
--- handed the room's history.
local function award(challengeId: string)
	if not config.worldId then
		return
	end
	for _, player in Players:GetPlayers() do
		if ChallengeService.complete(player, config.worldId, challengeId) then
			local done, total = ChallengeService.doneCount(player, config.worldId)
			toast(player, "chal_" .. challengeId, `{theme.copy.challengeDone}  {done}/{total}`, "good", 0)
			AnalyticsService.track(player, `challenge_{challengeId}`, done)
		end
	end
	StateSync.requestAll()
end

local function dayTuning(day: number): any
	local days = config.days
	return days[math.clamp(day, 1, #days)]
end

local function rootOf(player: Player): BasePart?
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	return root :: BasePart?
end

local function flatDistance(a: Vector3, b: Vector3): number
	return Vector3.new(a.X - b.X, 0, a.Z - b.Z).Magnitude
end

local function smallLabel(part: BasePart, text: string)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "Label"
	billboard.Size = UDim2.fromOffset(160, 36)
	billboard.StudsOffset = Vector3.new(0, 2.6, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 70
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Text = text
	label.TextColor3 = theme.uiText
	label.TextStrokeTransparency = 0.3
	label.Parent = billboard
	billboard.Parent = part
end

-- ---------------------------------------------------------------- world pieces

local function buildBeacon(): (BasePart, PointLight)
	local c = config.beacon
	local base = c.position
	local folder = pack.folder

	-- A pack may hand the beacon over as parts (an obelisk, a shrine, a generator)
	-- with one part named as the flame core. The gameplay light — whose range IS the
	-- safe radius — sits on an invisible anchor near the ground, because a light on a
	-- 28-stud cap with a 25-stud range never touches the sand.
	if c.parts then
		local origin = CFrame.new(base) * (c.facing or CFrame.new())
		local flame: BasePart? = nil
		for _, spec in c.parts do
			local part = ContentLoader.block({
				name = `Beacon_{spec.name}`,
				shape = spec.shape,
				size = spec.size,
				position = base,
				cframe = origin * spec.cframe,
				color = spec.color,
				material = spec.material,
				canCollide = spec.canCollide,
				castShadow = spec.material ~= Enum.Material.Neon,
				fire = spec.fire,
			}, folder)
			if spec.name == c.flameName then
				flame = part
			end
		end
		ContentLoader.expect(flame, `config.beacon.flameName '{c.flameName}' is not one of config.beacon.parts`)
		local anchor = ContentLoader.block({
			name = "BeaconLightAnchor",
			size = Vector3.new(1, 1, 1),
			position = base + (c.lightOffset or Vector3.new(0, 3, 0)),
			transparency = 1,
			canCollide = false,
			castShadow = false,
		}, folder)
		local light = Instance.new("PointLight")
		light.Name = "BeaconLight"
		light.Color = theme.colors.flameLight
		light.Brightness = c.lightBrightness
		light.Range = c.radiusBase
		light.Shadows = false
		light.Parent = anchor
		ContentLoader.label(flame :: BasePart, string.upper(theme.names.beacon), nil, theme)
		return flame :: BasePart, light
	end

	ContentLoader.block({
		name = "BeaconPost",
		size = Vector3.new(1.4, c.postHeight, 1.4),
		position = base + Vector3.new(0, c.postHeight / 2, 0),
		color = theme.colors.post,
		material = Enum.Material.Wood,
	}, folder)
	-- No wax anywhere on the shore (owner lock 2026-09-12): the beacon is a post with a
	-- stone lip and a fire jet, not a candle. The Neon core is what the loop scales
	-- with fuel; the jet on top of it is the pack's `beaconFire` look.
	ContentLoader.block({
		name = "BeaconLip",
		shape = Enum.PartType.Cylinder,
		size = Vector3.new(0.5, 2.2, 2.2),
		position = base + Vector3.new(0, c.postHeight + 0.25, 0),
		rotation = Vector3.new(0, 0, 90),
		color = theme.colors.lip or Color3.fromRGB(46, 46, 50),
		material = Enum.Material.Slate,
	}, folder)
	local flame = ContentLoader.block({
		name = "BeaconFlame",
		shape = Enum.PartType.Ball,
		size = c.flameSize,
		position = base + Vector3.new(0, c.postHeight + 1.1, 0),
		color = theme.colors.flame,
		material = Enum.Material.Neon,
		canCollide = false,
		castShadow = false,
		fire = c.fire,
	}, folder)
	local light = Instance.new("PointLight")
	light.Name = "BeaconLight"
	light.Color = theme.colors.flameLight
	light.Brightness = c.lightBrightness
	light.Range = c.radiusBase
	light.Shadows = false
	light.Parent = flame
	ContentLoader.label(flame, string.upper(theme.names.beacon), nil, theme)
	return flame, light
end

local function buildStalker(): Model
	local c = config.stalker
	local model = Instance.new("Model")
	model.Name = "Stalker"

	local root = Instance.new("Part")
	root.Name = "Root"
	root.Size = Vector3.new(0.2, 0.2, 0.2)
	root.Transparency = 1
	root.Anchored = true
	root.CanCollide = false
	root.CanQuery = false
	root.CanTouch = false
	root.Parent = model
	model.PrimaryPart = root

	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(1.8, c.height, 1.4)
	body.Position = Vector3.new(0, c.height / 2, 0)
	body.Color = theme.colors.stalker
	body.Material = Enum.Material.SmoothPlastic
	body.Anchored = true
	body.CanCollide = false
	body.CanQuery = false
	body.CanTouch = false
	body.CastShadow = false
	body.Parent = model

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Shape = Enum.PartType.Ball
	head.Size = Vector3.new(1.3, 1.3, 1.3)
	head.Position = Vector3.new(0, c.height + 0.5, 0)
	head.Color = theme.colors.stalker
	head.Material = Enum.Material.SmoothPlastic
	head.Anchored = true
	head.CanCollide = false
	head.CanQuery = false
	head.CanTouch = false
	head.CastShadow = false
	head.Parent = model

	model.Parent = pack.folder
	model:PivotTo(CFrame.new(0, -500, 0))
	return model
end

local function buildFogRing()
	local c = config.fog
	local model = Instance.new("Model")
	model.Name = "FogRing"
	for index = 1, c.segments do
		local slab = Instance.new("Part")
		slab.Name = `Fog{index}`
		slab.Anchored = true
		slab.CanCollide = false
		slab.CanQuery = false
		slab.CanTouch = false
		slab.CastShadow = false
		slab.Color = theme.colors.fog
		slab.Material = Enum.Material.SmoothPlastic
		slab.Transparency = c.transparency
		slab.Parent = model
		table.insert(fogRing, slab)
	end
	model.Parent = pack.folder
end

local function setFogRadius(radius: number)
	local c = config.fog
	local origin = config.beacon.position
	local width = (2 * math.pi * radius) / c.segments + 2
	for index, slab in fogRing do
		local theta = (index / c.segments) * math.pi * 2
		local position = Vector3.new(
			origin.X + math.cos(theta) * radius,
			config.groundY + c.wallHeight / 2,
			origin.Z + math.sin(theta) * radius
		)
		slab.Size = Vector3.new(width, c.wallHeight, 1)
		slab.CFrame = CFrame.lookAt(position, Vector3.new(origin.X, position.Y, origin.Z))
	end
end

local function fogRadiusForLevel(level: number): number
	local list = config.fog.radiusByLevel
	return list[math.clamp(level + 1, 1, #list)]
end

-- ---------------------------------------------------------------- the ground

--- One item lying on the sand: a thing the player walks over and picks up. Products
--- the obelisk hands back and raw items both come through here.
local function placeItem(kind: string, position: Vector3)
	local def = config.items[kind]
	if not def then
		return nil
	end
	return PickupService.place(position, {
		name = def.label,
		value = 1,
		shape = def.shape,
		size = def.size,
		color = def.color,
		material = def.material,
		meta = { kind = kind, returned = true },
		decorate = if def.glow
			then function(part)
				local light = Instance.new("PointLight")
				light.Color = def.glow.color
				light.Brightness = def.glow.brightness
				light.Range = def.glow.range
				light.Shadows = false
				light.Parent = part
			end
			else nil,
	})
end

--- A harvestable node: cactus, boulder, deadfall. The pickup itself is an invisible
--- marker at the base with the node's look parented to it, so walking to the base
--- collects the whole thing and one Destroy takes the visuals with it.
local function placeNode(resource: any, position: Vector3, labelText: string?)
	local yaw = math.random() * 360
	return PickupService.place(position, {
		name = resource.node,
		value = 1,
		size = Vector3.new(1.6, 1.6, 1.6),
		color = Color3.new(1, 1, 1),
		meta = { kind = resource.kind, node = true },
		rotation = Vector3.new(0, yaw, 0),
		decorate = function(part)
			part.Transparency = 1
			for index, spec in resource.parts do
				local piece = Instance.new("Part")
				piece.Name = `{resource.node}_{index}`
				piece.Anchored = true
				piece.CanCollide = false
				piece.CanTouch = false
				piece.CanQuery = false
				piece.Shape = spec.shape or Enum.PartType.Block
				piece.Size = spec.size
				piece.Color = spec.color
				piece.Material = spec.material or Enum.Material.SmoothPlastic
				local rot = spec.rotation or Vector3.zero
				piece.CFrame = part.CFrame
					* CFrame.new(spec.offset)
					* CFrame.Angles(math.rad(rot.X), math.rad(rot.Y), math.rad(rot.Z))
				piece.Parent = part
			end
			if labelText then
				smallLabel(part, labelText)
			end
		end,
	})
end

local function randomInRing(inner: number, outer: number): Vector3
	local origin = config.beacon.position
	local theta = math.random() * math.pi * 2
	-- sqrt keeps the density even across the band instead of bunching at the inner edge
	local r = math.sqrt(math.random() * (outer ^ 2 - inner ^ 2) + inner ^ 2)
	return Vector3.new(origin.X + math.cos(theta) * r, config.groundY, origin.Z + math.sin(theta) * r)
end

local function spawnRing(resource: any, ring: any)
	if PickupService.activeCount() >= config.maxNodes then
		return
	end
	-- Pieces in the path: on the straight line from spawn to the stone's edge, so the
	-- first minute needs no full turn to find them.
	if ring.path and ring.path > 0 then
		local from = pack.world.spawn.position
		local centre = config.beacon.position
		local toward = Vector3.new(from.X - centre.X, 0, from.Z - centre.Z)
		local to = centre
			+ (if toward.Magnitude > 0.1 then toward.Unit else Vector3.zAxis) * (config.beacon.feedRadius or 0)
		for index = 1, ring.path do
			local t = index / (ring.path + 1)
			local along = from:Lerp(to, t)
			local jitter = Vector3.new((math.random() - 0.5) * 10, 0, 0)
			placeNode(
				resource,
				Vector3.new(along.X, config.groundY, along.Z) + jitter,
				if index == 1 then theme.copy.pickUp else nil
			)
		end
	end
	for _ = 1, ring.count do
		placeNode(resource, randomInRing(ring.inner, ring.outer))
	end
end

--- Lay out every resource whose ring the obelisk has opened. `onlyLevel` restocks just
--- the band that a fog peel has revealed.
local function spawnOpenRings(onlyLevel: number?)
	local level = BeaconService.level()
	for _, resource in config.resources do
		for _, ring in resource.rings do
			if ring.level > level then
				continue
			end
			if onlyLevel ~= nil and ring.level ~= onlyLevel then
				continue
			end
			spawnRing(resource, ring)
		end
	end
end

local function spawnLure()
	local c = config.lure
	local origin = config.beacon.position
	local theta = math.random() * math.pi * 2
	local r = BeaconService.radius() + c.standOff
	local position =
		Vector3.new(origin.X + math.cos(theta) * r, config.groundY + c.size.Y / 2, origin.Z + math.sin(theta) * r)
	PickupService.place(position, {
		name = theme.names.lure,
		value = c.value,
		size = c.size,
		color = theme.colors.lure,
		material = Enum.Material.Neon,
		meta = { kind = "lure" },
		decorate = function(part)
			-- The wrong bloom: the only warm light that is not the obelisk.
			local light = Instance.new("PointLight")
			light.Color = theme.colors.lureLight
			light.Brightness = c.lightBrightness
			light.Range = c.lightRange
			light.Shadows = false
			light.Parent = part
		end,
	})
	local first = Players:GetPlayers()[1]
	if first then
		AnalyticsService.track(first, "lure_spawned", run.day)
	end
end

-- ---------------------------------------------------------------- lighting moods

--- Day and night are two complete rigs, not one rig with the lamp turned down.
---
--- The desert DAY is the bright one — brighter than the camp (Justin, 2026-09-12): the
--- waste is exposed and bleached, and the obelisk's ground is dark slate in its own
--- shadow. The camp's warm lights are dimmed almost out by daylight, so by day the
--- obelisk is a cold monument on a bright plain, and at night it is the only warm thing
--- left. Same object, opposite job, and the player learns the difference by watching it.
local function setMood(night: boolean)
	local c = config.night
	local seconds = c.transition
	ContentLoader.tweenLighting(if night then c.rig else pack.world.lighting, seconds)

	local scale = if night then 1 else (c.campGlowByDay or 0.15)
	local info = TweenInfo.new(seconds, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	for _, part in pack.folder:GetChildren() do
		local name = part.Name
		if string.sub(name, 1, 12) == "ObeliskGlow" or string.sub(name, 1, 8) == "StarGlow" then
			local light = part:FindFirstChildOfClass("PointLight")
			if light then
				local full = light:GetAttribute("FullBrightness")
				if full == nil then
					full = light.Brightness
					light:SetAttribute("FullBrightness", full)
				end
				TweenService:Create(light, info, { Brightness = (full :: number) * scale }):Play()
			end
		end
	end
end

-- ---------------------------------------------------------------- the stalker

local function revealStalker()
	if run.stalkerSeen then
		return
	end
	run.stalkerSeen = true
	-- Put it where the player who just fed will actually see it: on the light-line
	-- beyond the beacon, along the spawn -> beacon bearing.
	local from = pack.world.spawn.position
	local to = config.beacon.position
	local theta = math.atan2(to.Z - from.Z, to.X - from.X)
	StalkerService.setMode("watch")
	StalkerService.standAt(theta)
	for _, player in Players:GetPlayers() do
		if not seenStalkerToast[player] then
			seenStalkerToast[player] = true
			toast(player, "waits", theme.copy.toastWaits, "info", 0)
		end
	end
end

local function onTouch(player: Player)
	local c = config.stalker
	local root = rootOf(player)
	if not root then
		return
	end
	local origin = config.beacon.position
	-- Wake at the beacon, on the spawn side, a step outside the post.
	local from = pack.world.spawn.position
	local toward = Vector3.new(from.X - origin.X, 0, from.Z - origin.Z)
	local dir = if toward.Magnitude > 0.1 then toward.Unit else Vector3.new(0, 0, 1)
	local wake = origin + dir * ((config.beacon.feedRadius or 4) + 2) + Vector3.new(0, 3.5, 0)
	local character = player.Character
	if character then
		character:PivotTo(CFrame.lookAt(wake, Vector3.new(origin.X, wake.Y, origin.Z)))
	end
	local lost = BeaconService.drain(BeaconService.fuel() * c.fuelPenalty)
	run.fuelOut += lost
	run.weight += c.weight
	run.downs += 1
	fx(player, "downed")
	toast(player, "downed", theme.copy.downed, "warn", 0)
	AnalyticsService.track(player, "downed_by_stalker", run.day)
	StateSync.requestAll()
end

-- ---------------------------------------------------------------- the run

local function schedule(): ClockService.Schedule
	local cycles = {}
	for _, tuning in config.days do
		table.insert(cycles, {
			{ name = "day", length = tuning.day },
			{ name = "night", length = tuning.night },
		})
	end
	return { cycles = cycles }
end

local function recordBestDay()
	for _, player in Players:GetPlayers() do
		local profile = DataService.get(player)
		if profile and (profile.bestDay or 0) < run.day then
			profile.bestDay = run.day
		end
	end
end

local function scoreNow(won: boolean): (number, number)
	local s = config.score
	local daysCleared = if won then #config.days else math.max(0, run.day - 1)
	local score = daysCleared * s.perDay + math.floor(BeaconService.fuel()) * s.perFuel - run.lures * s.perLure
	return math.max(0, score), daysCleared
end

local startRun -- forward

local function endRun(won: boolean, reason: string)
	if not run.active then
		return
	end
	run.active = false
	ClockService.stop()
	BeaconService.setBurn(0, 0)
	StalkerService.setMode("hidden")
	local score, daysCleared = scoreNow(won)
	recordBestDay()
	for _, player in Players:GetPlayers() do
		AnalyticsService.step(player, "run_end")
		AnalyticsService.track(player, "run_days_cleared", daysCleared)
		AnalyticsService.track(player, "run_score", score)
		AnalyticsService.track(player, "run_fuel_in", run.fuelIn)
		AnalyticsService.track(player, "run_fuel_out", math.floor(run.fuelOut))
		AnalyticsService.track(player, "run_lures_taken", run.lures)
		AnalyticsService.track(player, `run_end_{reason}`, run.day)
		DataService.save(player, false)
	end
	fxAll("runEnd", { won = won, days = daysCleared, score = score, reason = reason })
	toastAll("runend", if won then theme.copy.weekDone else theme.copy.lightOut, if won then "good" else "warn")
	StateSync.requestAll()
	task.delay(config.runEndPause, function()
		if not run.active then
			startRun()
		end
	end)
end

local function onPhase(name: string, cycle: number, length: number)
	run.day = cycle
	run.phase = name
	local tuning = dayTuning(cycle)

	if name == "day" then
		BeaconService.setBurn(0, 0)
		setMood(false)
		spawnOpenRings(nil)
		if cycle >= config.lure.firstDay then
			spawnLure()
		end
		if run.stalkerSeen then
			StalkerService.setMode("watch")
		end
		if cycle >= 2 then
			returnOfferings()
		end
		recordBestDay()
		-- Reaching a day means the night before it was held.
		if cycle >= 2 then
			award("first_night")
		end
		if cycle >= 3 then
			award("third_day")
			if run.lures == 0 then
				award("refuse")
			end
			if run.downs == 0 then
				award("untouched")
			end
		end
		for _, player in Players:GetPlayers() do
			AnalyticsService.track(player, "day_reached", cycle)
			if cycle > 1 then
				AnalyticsService.step(player, "first_night")
			end
			if cycle >= 3 then
				AnalyticsService.step(player, "day_3")
			end
		end
	else
		-- Night falls on a dead beacon: that IS the light going out. Found by Hunter's
		-- first playtest (2026-09-12): an idle player at zero fuel "survived" every
		-- night because the burn only fires `emptied` on a transition to zero.
		if BeaconService.fuel() <= 0 then
			fxAll("phase", { name = name, day = cycle, length = length })
			endRun(false, "light_out")
			return
		end
		local burn = tuning.burn * (config.lure.burnMultiplier ^ run.weight)
		BeaconService.setBurn(burn, length)
		setMood(true)
		-- The stalker is out every night, even if nobody has fed yet.
		revealStalker()
		StalkerService.setMode(if tuning.stalker == "hunt" then "hunt" else "watch")
		for _, player in Players:GetPlayers() do
			if not seenStalkerToast[player] then
				seenStalkerToast[player] = true
				toast(player, "waits", theme.copy.toastWaits, "info", 0)
			end
		end
	end
	fxAll("phase", { name = name, day = cycle, length = length })
	StateSync.requestAll()
end

startRun = function()
	PickupService.clear()
	run.bowl = {}
	BeaconService.reset(config.beacon.startingFuel)
	run.active = true
	run.day = 0
	run.phase = "day"
	run.weight = 0
	run.lures = 0
	run.fuelIn = 0
	run.fuelOut = 0
	run.stalkerSeen = false
	run.downs = 0
	run.startedAt = os.clock()
	StalkerService.setMode("hidden")
	setFogRadius(fogRadiusForLevel(0))
	SackService.clearAll()
	ClockService.start(schedule())
end

-- ---------------------------------------------------------------- the verb

--- Feed the fire. Only fuel burns: cactus and stone are crafting stock and stay in the
--- sack, because silently eating them would punish a player for walking the wrong way.
--- An item with an `onFeed` effect is spent here too — that is what a Wardstone is for.
local function feed(player: Player)
	local burnable = SackService.drain(player, function(kind)
		local def = config.items[kind]
		return def ~= nil and ((def.fuel or 0) > 0 or def.onFeed ~= nil)
	end)

	local amount, effects = 0, {}
	for kind, count in burnable do
		local def = config.items[kind]
		amount += (def.fuel or 0) * count
		if def.onFeed then
			effects[def.onFeed] = (effects[def.onFeed] or 0) + count
		end
	end

	for effect, count in effects do
		if effect == "liftWeight" then
			local lifted = math.min(run.weight, count)
			run.weight -= lifted
			if lifted > 0 then
				toast(player, "weight", theme.copy.weightLifted, "good", 0)
				AnalyticsService.track(player, "weight_lifted", lifted)
			end
		end
	end

	if amount <= 0 then
		if next(effects) == nil and SackService.count(player) > 0 then
			toast(player, "noburn", theme.copy.nothingBurns, "info")
		end
		if next(effects) ~= nil then
			StateSync.requestAll()
		end
		return
	end

	local accepted = BeaconService.feed(amount)
	if accepted < amount then
		toast(player, "full", theme.copy.beaconFull, "info")
	end
	if accepted <= 0 then
		return
	end
	run.fuelIn += accepted
	local profile = DataService.get(player)
	if profile then
		profile.tutorialComplete = true
	end
	AnalyticsService.step(player, "first_feed")
	AnalyticsService.track(player, "fuel_fed", accepted)
	award("first_light")
	fxAll("feed", { amount = accepted, fuel = BeaconService.fuel() })
	if not run.stalkerSeen then
		revealStalker()
	end
	StateSync.requestAll()
end

--- Walk into the bowl carrying a sack and the obelisk takes ALL of it — fuel, cactus,
--- stone, whatever. Nothing burns, the light does not grow, and at dawn it hands back
--- what its recipes could make. The whole mechanic is one decision made by where the
--- player stops walking.
local function offer(player: Player)
	local bag = SackService.drain(player, nil)
	local count = 0
	for kind, n in bag do
		run.bowl[kind] = (run.bowl[kind] or 0) + n
		count += n
	end
	if count <= 0 then
		toast(player, "offerempty", theme.copy.offeringEmpty, "info")
		return
	end
	AnalyticsService.step(player, "first_offering")
	AnalyticsService.track(player, "offered", count)
	toast(player, "offered", theme.copy.offered, "good", 0)
	fx(player, "offer", { count = count })
	StateSync.requestAll()
end

--- Dawn: run the bowl through the recipes and lay out what came of it. Whatever no
--- recipe wanted still comes back a tier up, so an offering is never a waste — only
--- less clever than it could have been.
function returnOfferings()
	if next(run.bowl) == nil then
		return
	end
	local result = RecipeService.resolve(run.bowl)
	run.bowl = {}

	-- Leftovers come back AS THEMSELVES plus a bonus on the ladder. Converting them
	-- outright would be odd alchemy — a player who offered stone hoping for a Wardstone
	-- and had no water should get the stone back, not wood. The bonus is what keeps the
	-- promise that the bowl always returns more than it took.
	local ladder = config.offering.ladder
	local leftoverValue = 0
	for kind, count in result.leftovers do
		local def = config.items[kind]
		leftoverValue += math.max(1, def and def.fuel or 1) * count
	end
	local bonus: { [string]: number } = {}
	local budget = leftoverValue * config.offering.multiplier
	for index = #ladder, 1, -1 do
		local kind = ladder[index]
		local def = config.items[kind]
		local value = def and def.fuel or 1
		if value > 0 then
			local n = math.floor(budget / value)
			if n > 0 then
				bonus[kind] = (bonus[kind] or 0) + n
				budget -= n * value
			end
		end
	end

	local out: { { kind: string, count: number } } = {}
	local total = 0
	for _, bag in { result.products, result.leftovers, bonus } do
		for kind, count in bag do
			table.insert(out, { kind = kind, count = count })
			total += count
		end
	end
	if total == 0 then
		return
	end

	local origin = config.beacon.position
	local laid = 0
	for _, entry in out do
		for _ = 1, entry.count do
			laid += 1
			local theta = (laid / total) * math.pi * 2 + math.random() * 0.3
			local r = config.offering.scatter
			placeItem(
				entry.kind,
				Vector3.new(origin.X + math.cos(theta) * r, config.groundY + 1.4, origin.Z + math.sin(theta) * r)
			)
		end
	end

	for _, applied in result.applied do
		award(applied.recipe.id)
		for _, player in Players:GetPlayers() do
			AnalyticsService.track(player, `recipe_{applied.recipe.id}`, applied.count)
		end
	end
	fxAll("returned", { count = total })
	toastAll("returned", theme.copy.returned, "good")
end

local function onCollect(player: Player, value: number, meta: any?): number
	if meta and meta.kind == "lure" then
		local accepted = BeaconService.feed(value)
		run.fuelIn += accepted
		run.weight += config.lure.weight
		run.lures += 1
		AnalyticsService.track(player, "lure_taken", run.day)
		fxAll("lure", { fuel = BeaconService.fuel(), weight = run.weight })
		StateSync.requestAll()
		return value -- the pile is gone either way
	end
	local kind = meta and meta.kind
	if not kind or not config.items[kind] then
		return 0
	end
	if not SackService.add(player, kind) then
		return 0
	end
	if meta.returned then
		award("harvest")
	end
	pickedUpEver[player] = true
	AnalyticsService.step(player, "first_pickup")
	if nudgeHighlight then
		nudgeHighlight:Destroy()
		nudgeHighlight = nil
	end
	-- Already standing on the stone: it burns straight away.
	if insideBeacon[player] then
		feed(player)
	end
	return 1
end

local function onBlocked(player: Player)
	toast(player, "sack", theme.copy.sackFull, "warn")
end

-- ---------------------------------------------------------------- onboarding

local function nudge(player: Player)
	if nudged[player] or pickedUpEver[player] then
		return
	end
	local root = rootOf(player)
	if not root then
		return
	end
	nudged[player] = true
	local part = PickupService.nearest(root.Position, function(meta)
		return meta and meta.kind == "fuel"
	end)
	if part then
		if nudgeHighlight then
			nudgeHighlight:Destroy()
		end
		local highlight = Instance.new("Highlight")
		highlight.FillColor = theme.colors.flame
		highlight.FillTransparency = 0.6
		highlight.OutlineColor = theme.colors.flame
		highlight.OutlineTransparency = 0
		highlight.Parent = part
		nudgeHighlight = highlight
	end
	fx(player, "pulse")
end

local function onProfileLoaded(player: Player, profile: any)
	AnalyticsService.markJoin(player)
	joinedAt[player] = os.clock()
	SackService.ensureDefaults(profile)
	SackService.clear(player) -- the sack is per run, never carried between sessions
	profile.bestDay = profile.bestDay or 0
	profile.tutorialComplete = profile.tutorialComplete == true
	ChallengeService.ensureDefaults(profile)

	if not run.active then
		startRun()
	end

	fx(player, "fadeIn")
	if not profile.tutorialComplete then
		task.delay(config.onboarding.firstToastAt, function()
			if player.Parent then
				toast(player, "clock", theme.copy.toastClock, "info", 0)
			end
		end)
	end
	for _, delay in OPENING_PUSHES do
		task.delay(delay, function()
			if player.Parent then
				StateSync.push(player)
			end
		end)
	end
end

-- ---------------------------------------------------------------- packet

local function packet(player: Player, profile: any): any
	local clock = ClockService.state()
	return {
		active = run.active,
		day = run.day,
		phase = run.phase,
		remaining = clock.remaining,
		length = clock.length,
		fuel = BeaconService.fuel(),
		fuelCap = BeaconService.fuelCap(),
		radius = BeaconService.radius(),
		beacon = BeaconService.position(),
		carry = SackService.count(player),
		sack = (function()
			local _, order = SackService.contents(player)
			local out = {}
			for _, entry in order do
				local def = config.items[entry.kind]
				table.insert(
					out,
					{ kind = entry.kind, label = if def then def.label else entry.kind, count = entry.count }
				)
			end
			return out
		end)(),
		carryCap = SackService.cap(player),
		weight = run.weight,
		level = BeaconService.level(),
		bestDay = profile.bestDay or 0,
		stalker = run.stalkerSeen,
		bowl = (function()
			local n = 0
			for _, count in run.bowl do
				n += count
			end
			return n
		end)(),
		challenges = if config.worldId then ChallengeService.packetFor(player, config.worldId) else nil,
	}
end

-- ---------------------------------------------------------------- contract

function SurviveLoop.validate(cfg: any, world: any, thm: any)
	local expect = ContentLoader.expect
	expect(typeof(cfg.groundY) == "number", "config.groundY is required")
	expect(typeof(cfg.sack) == "table" and typeof(cfg.sack.cap) == "number", "config.sack.cap is required")
	expect(typeof(cfg.beacon) == "table", "config.beacon is required")
	expect(typeof(cfg.beacon.position) == "Vector3", "config.beacon.position must be a Vector3")
	expect(typeof(cfg.beacon.levelThresholds) == "table", "config.beacon.levelThresholds is required")
	expect(typeof(cfg.days) == "table" and #cfg.days > 0, "config.days must be a non-empty array")
	for index, tuning in cfg.days do
		expect(
			typeof(tuning.day) == "number" and typeof(tuning.night) == "number",
			`days[{index}] needs day and night lengths`
		)
		expect(typeof(tuning.burn) == "number", `days[{index}] needs a burn`)
	end
	expect(typeof(cfg.items) == "table", "config.items is required")
	expect(typeof(cfg.recipes) == "table", "config.recipes is required")
	expect(typeof(cfg.resources) == "table" and #cfg.resources > 0, "config.resources must be a non-empty array")
	for _, resource in cfg.resources do
		expect(typeof(resource.kind) == "string", "every resource needs a kind")
		expect(cfg.items[resource.kind] ~= nil, `resource '{resource.kind}' is not in config.items`)
		expect(typeof(resource.rings) == "table" and #resource.rings > 0, `resource '{resource.kind}' needs rings`)
		expect(typeof(resource.parts) == "table" and #resource.parts > 0, `resource '{resource.kind}' needs parts`)
	end
	expect(typeof(cfg.pickupRadius) == "number", "config.pickupRadius is required")
	expect(typeof(cfg.maxNodes) == "number", "config.maxNodes is required")
	expect(typeof(cfg.stalker) == "table", "config.stalker is required")
	expect(typeof(cfg.lure) == "table", "config.lure is required")
	expect(
		typeof(cfg.fog) == "table" and typeof(cfg.fog.radiusByLevel) == "table",
		"config.fog.radiusByLevel is required"
	)
	expect(typeof(cfg.score) == "table", "config.score is required")
	expect(typeof(cfg.night) == "table", "config.night is required")
	expect(
		typeof(cfg.night.rig) == "table",
		"config.night.rig is required (night is its own rig, not the day rig dimmed)"
	)
	expect(typeof(cfg.onboarding) == "table", "config.onboarding is required")
	expect(typeof(cfg.runEndPause) == "number", "config.runEndPause is required")
	expect(typeof(cfg.offering) == "table", "config.offering is required")
	expect(typeof(cfg.offering.ladder) == "table", "config.offering.ladder is required")
	local hasBowl = false
	for _, zone in world.zones do
		hasBowl = hasBowl or zone.kind == "offering"
	end
	expect(hasBowl, "world.zones needs a zone of kind 'offering' (the bowl)")
	if cfg.worlds then
		expect(typeof(cfg.worldId) == "string", "config.worldId must name which of config.worlds is this pack")
		local found = false
		for _, world in cfg.worlds do
			expect(
				typeof(world.id) == "string" and typeof(world.challenges) == "table",
				"every world needs an id and challenges"
			)
			found = found or world.id == cfg.worldId
		end
		expect(found, `config.worldId '{cfg.worldId}' is not one of config.worlds`)
	end

	local kinds = {}
	for _, zone in world.zones do
		kinds[zone.kind] = true
	end
	expect(kinds.beacon, "world.zones needs a zone of kind 'beacon' (the feed spot)")

	expect(typeof(thm.names) == "table", "theme.names is required")
	for _, key in { "beacon", "fuel", "stalker", "lure", "sack" } do
		expect(typeof(thm.names[key]) == "string", `theme.names.{key} is required`)
	end
	expect(typeof(thm.colors) == "table", "theme.colors is required")
	expect(typeof(thm.copy) == "table", "theme.copy is required")
	for _, key in
		{
			"toastClock",
			"toastWaits",
			"sackFull",
			"notThatWay",
			"downed",
			"lightOut",
			"weekDone",
			"pickUp",
			"beaconFull",
		}
	do
		expect(typeof(thm.copy[key]) == "string", `theme.copy.{key} is required`)
	end
end

function SurviveLoop.start(loaded: any)
	pack = loaded
	config = pack.config
	theme = pack.theme
	SurviveLoop.validate(config, pack.world, theme)

	AnalyticsService.configure({ "first_pickup", "first_feed", "first_offering", "first_night", "run_end" })
	if config.worlds then
		ChallengeService.configure(config.worlds)
	end
	RecipeService.configure(config.recipes)

	local flame, light = buildBeacon()
	stalkerModel = buildStalker()
	buildFogRing()

	BeaconService.configure({
		position = config.beacon.position,
		fuelCap = config.beacon.fuelCap,
		radiusBase = config.beacon.radiusBase,
		radiusPerFuel = config.beacon.radiusPerFuel,
		radiusCap = config.beacon.radiusCap,
		levelThresholds = config.beacon.levelThresholds,
		light = light,
		lightBrightness = config.beacon.lightBrightness,
		flame = flame,
		flameSize = config.beacon.flameSize,
	})

	StalkerService.configure({
		model = stalkerModel :: Model,
		origin = BeaconService.position,
		safeRadius = BeaconService.radius,
		standOff = config.stalker.standOff,
		speed = config.stalker.speed,
		touchDistance = config.stalker.touchDistance,
		sway = config.stalker.sway,
		touchCooldown = config.stalker.touchCooldown,
		onTouch = onTouch,
	})

	SackService.setCapProvider(function()
		return config.sack.cap
	end)
	SackService.changed:connect(StateSync.request)

	PickupService.setup({
		parent = pack.folder,
		maxActive = config.maxNodes + 40,
		radiusFor = function()
			return config.pickupRadius
		end,
		onCollect = onCollect,
		onBlocked = onBlocked,
	})

	StateSync.setBuilder(packet)

	for _, zone in pack.world.zones do
		local part = pack.zoneParts[zone.id]
		if part and zone.kind == "offering" then
			ZoneService.create(part, { onEnter = offer })
		elseif part and zone.kind == "beacon" then
			ZoneService.create(part, {
				onEnter = function(player)
					insideBeacon[player] = true
					feed(player)
				end,
				onLeave = function(player)
					insideBeacon[player] = nil
				end,
			})
		end
	end
	ZoneService.start()

	ClockService.phaseStarted:connect(onPhase)
	ClockService.completed:connect(function()
		award("the_week")
		endRun(true, "week")
	end)
	ClockService.tick:connect(function()
		StateSync.requestAll()
	end)
	BeaconService.emptied:connect(function()
		if not run.active or run.phase ~= "night" then
			return
		end
		-- Feeding EXACTLY the night's burn drained to zero on the last tick and killed
		-- the run at 130.0s (Hunter, twice, 2026-09-12). A wick that gutters as dawn
		-- breaks has held the night; only a dark stretch loses it.
		if ClockService.state().remaining <= (config.night.graceSeconds or 2) then
			return
		end
		endRun(false, "light_out")
	end)
	BeaconService.levelChanged:connect(function(level, old)
		setFogRadius(fogRadiusForLevel(level))
		if level > old then
			if level >= 1 then
				award("open_shore")
			end
			spawnOpenRings(level)
			if theme.copy.fogPeels then
				toastAll("peel", theme.copy.fogPeels, "good")
			end
		end
	end)

	DataService.profileLoaded:connect(onProfileLoaded)
	Players.PlayerRemoving:Connect(function(player)
		AnalyticsService.summarize(player)
		insideBeacon[player] = nil
		nextToastAt[player] = nil
		joinedAt[player] = nil
		nudged[player] = nil
		seenStalkerToast[player] = nil
		pickedUpEver[player] = nil
	end)

	-- Burn, feed-while-standing, boundary and the idle nudge, on one cheap ticker.
	local feedAccumulator = 0
	local boundaryAccumulator = 0
	RunService.Heartbeat:Connect(function(delta)
		if not run.active then
			return
		end
		local before = BeaconService.fuel()
		BeaconService.step(delta)
		run.fuelOut += math.max(0, before - BeaconService.fuel())

		feedAccumulator += delta
		if feedAccumulator >= FEED_POLL then
			feedAccumulator = 0
			for player in insideBeacon do
				if player.Parent and SackService.count(player) > 0 then
					feed(player)
				end
			end
		end

		boundaryAccumulator += delta
		if boundaryAccumulator >= BOUNDARY_POLL then
			boundaryAccumulator = 0
			local origin = config.beacon.position
			local limit = config.fog.pushBackAt
			for _, player in Players:GetPlayers() do
				local root = rootOf(player)
				if root then
					local distance = flatDistance(root.Position, origin)
					if distance > limit then
						local dir = Vector3.new(root.Position.X - origin.X, 0, root.Position.Z - origin.Z).Unit
						local back = origin + dir * (limit - 12) + Vector3.new(0, 3.5, 0)
						local character = player.Character
						if character then
							character:PivotTo(CFrame.lookAt(back, Vector3.new(origin.X, back.Y, origin.Z)))
						end
						toast(player, "edge", theme.copy.notThatWay, "warn", 3)
					end
				end
				local since = os.clock() - (joinedAt[player] or os.clock())
				if since >= config.onboarding.nudgeAfter and not nudged[player] then
					nudge(player)
				end
			end
		end
	end)
end

return SurviveLoop

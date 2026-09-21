-- BuildLoop — the build-and-launch loop family, generically.
--
-- buy a part -> stack it -> roll it out -> the card says whether it flies -> launch
--        ^                                                                     |
--        +------------------ paid on how high and how fast --------------------+
--
-- The engine must not know what this title calls its parts, its pad or its money. The
-- catalogue, the physics, the rules, the silhouette and every number come from the pack:
--   config.parts      the catalogue, in groups; every stat is read by the physics
--   config.flight     .resolve(asm, lib) -> vehicle, .simulate(vehicle) -> result + trace
--   config.assembly   .check(asm, lib, padLimit) -> ok, problems; .card(vehicle, result, padLimit)
--   config.rocket     .stack(asm, byId) -> part specs (shared, so the client draws the same thing)
--   config.tiers      ChallengeService worlds whose challenges each carry a `test`
--   config.payout     the money: rates, exponents, milestones, refurbish
--
-- Trust surface: ONE remote (C2S_Act), carrying a verb and at most one table. The server
-- owns cash, ownership, the stack, the pad, the flight and every number on the card.
-- Nothing the client sends is a price, an altitude or a result; the flight is a trace
-- the physics produced, played back on the server and replicated like any other part.

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Core = script.Parent
local AnalyticsService = require(Core.AnalyticsService)
local ChallengeService = require(Core.ChallengeService)
local ClockService = require(Core.ClockService)
local ContentLoader = require(Core.ContentLoader)
local DataService = require(Core.DataService)
local EconomyService = require(Core.EconomyService)
local RemoteGuard = require(Core.RemoteGuard)
local StateSync = require(Core.StateSync)
local ZoneService = require(Core.ZoneService)

local Shared = game:GetService("ReplicatedStorage").Shared
local Format = require(Shared.Format)
local Net = require(Shared.Net)

local BuildLoop = {}

local TOAST_COOLDOWN = 2
local OPENING_PUSHES = { 0, 0.5, 1.5, 3 }
local ACT_LIMIT, ACT_WINDOW = 12, 4
local MAX_VERB = 40
local BUY_PREFIX = "warehouse:buy:"
local GROUP_ORDER = { "engines", "tanks", "aero", "avionics", "structure", "mission", "pad" }

-- Which assembly slot holds which class of part. The pack's catalogue names classes;
-- this is the only place the loop says what an assembly is shaped like.
local STAGE_SLOTS = { engine = "engine", tank = "tank", decoupler = "decoupler", fins = "fin", recovery = "recovery" }
local TOP_SLOTS = { nose = "nose", gnc = "gnc", payload = "payload" }

local pack: any = nil
local config: any = nil
local theme: any = nil
local copy: any = nil
local Flight: any = nil
local Assembly: any = nil
local Rocket: any = nil

local byId: { [string]: any } = {}
local firstOfClass: { [string]: any } = {}
local nextToastAt: { [Player]: { [string]: number } } = {}
-- The card and the problem list for a player's current stack, keyed by a signature of
-- that stack, so the physics runs once per change rather than once per packet.
local cardCache: { [Player]: any } = {}

-- THE ONE PAD. One rocket stands on it at a time; everybody watches the same flight.
local pad = {
	state = "empty", -- empty | rollout | rolled | flying
	owner = nil :: Player?,
	asm = nil :: any,
	vehicle = nil :: any,
	result = nil :: any,
	model = nil :: Model?,
	stages = {} :: { [number]: Model },
	padCFrame = CFrame.new(),
	hangarCFrame = CFrame.new(),
	-- playback
	timeline = nil :: any,
	burnouts = {} :: { number },
	scale = 1,
	apogee = 0,
	altitude = 0,
	maxAltitude = 0,
	stageIndex = 1,
	cursor = 1,
	held = false,
	telemetryClock = 0,
}

-- ---------------------------------------------------------------- helpers

local function money(amount: number): string
	return `{theme.currencySymbol or "$"}{Format.short(amount)}`
end

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

local function fx(player: Player, kind: string, payload: any?)
	RemoteGuard.fire(player, Net.S2C_Fx, kind, payload)
end

local function fxAll(kind: string, payload: any?)
	RemoteGuard.fireAll(Net.S2C_Fx, kind, payload)
end

local function indexParts(parts: any)
	byId = {}
	firstOfClass = {}
	for _, groupName in GROUP_ORDER do
		for _, part in parts[groupName] or {} do
			byId[part.id] = part
			if part.class and not firstOfClass[part.class] then
				firstOfClass[part.class] = part
			end
		end
	end
end

local function padTierFor(profile: any): (number, any)
	local tiers = config.parts.pad
	local tier = tiers[math.clamp(profile.padTier or 1, 1, #tiers)]
	return tier.massLimit, tier
end

--- A clean copy of an assembly table, in the shape the physics reads. Never alias a
--- table that came from the config or from a client.
local function copyAssembly(asm: any): any
	local out = { stages = {}, rcs = asm.rcs == true, dock = asm.dock == true }
	for i, s in ipairs(asm.stages or {}) do
		local stage = { engineCount = s.engineCount or 1 }
		for key in STAGE_SLOTS do
			stage[key] = s[key]
		end
		out.stages[i] = stage
	end
	for key in TOP_SLOTS do
		out[key] = asm[key]
	end
	return out
end

local function usesPart(asm: any, id: string): boolean
	for _, s in ipairs(asm.stages or {}) do
		for key in STAGE_SLOTS do
			if s[key] == id then
				return true
			end
		end
	end
	for key in TOP_SLOTS do
		if asm[key] == id then
			return true
		end
	end
	local rcs, dock = firstOfClass.rcs, firstOfClass.dock
	if asm.rcs and rcs and rcs.id == id then
		return true
	end
	if asm.dock and dock and dock.id == id then
		return true
	end
	return false
end

-- ---------------------------------------------------------------- the profile

local function ensureDefaults(profile: any)
	profile.parts = profile.parts or {}
	profile.assembly = profile.assembly or { stages = {} }
	profile.assembly.stages = profile.assembly.stages or {}
	profile.padTier = math.clamp(profile.padTier or 1, 1, #config.parts.pad)
	profile.bestApogee = profile.bestApogee or 0
	profile.bestDV = profile.bestDV or 0
	profile.launches = profile.launches or 0
	profile.milestones = profile.milestones or {}
	profile.cash = profile.cash or 0
	-- A fresh hangar: the starting money, the starter parts, and the starters already
	-- stacked with whatever the pack left wrong on purpose. Only ever granted to a
	-- profile that has never launched and owns nothing, so it cannot be farmed.
	if profile.launches == 0 and next(profile.parts) == nil then
		profile.cash = config.startingCash
		for _, id in config.startingParts do
			profile.parts[id] = true
		end
		profile.assembly = copyAssembly(config.starterAssembly or { stages = {} })
	end
end

-- ---------------------------------------------------------------- the stack

local function ownedPartOf(profile: any, id: any, class: string): (any?, string?)
	if typeof(id) ~= "string" or #id > MAX_VERB then
		return nil, "a part id was not a name"
	end
	local part = byId[id]
	if not part or part.class ~= class then
		return nil, `{id} is not a {class}`
	end
	if not profile.parts[id] then
		return nil, `you do not own {part.label}`
	end
	return part, nil
end

--- Rebuild a client-sent assembly as a clean table, refusing anything unknown, unowned
--- or out of range. The reason is a plain sentence for a toast.
local function sanitizeAssembly(profile: any, raw: any): (any?, string?)
	if typeof(raw) ~= "table" or typeof(raw.stages) ~= "table" then
		return nil, "that was not a stack"
	end
	local limits = config.limits
	local clean = { stages = {} }
	for i = 1, limits.maxStages + 1 do
		local s = raw.stages[i]
		if s == nil then
			break
		end
		if i > limits.maxStages then
			return nil, `{limits.maxStages} stages is the limit`
		end
		if typeof(s) ~= "table" then
			return nil, `stage {i} was not a stage`
		end
		local stage = {}
		for key, class in STAGE_SLOTS do
			if s[key] ~= nil then
				local part, why = ownedPartOf(profile, s[key], class)
				if not part then
					return nil, why
				end
				stage[key] = s[key]
			end
		end
		local count = s.engineCount
		if count == nil then
			count = 1
		end
		if typeof(count) ~= "number" or count ~= math.floor(count) or count < 1 or count > limits.maxEngines then
			return nil, `engine count must be 1 to {limits.maxEngines}`
		end
		stage.engineCount = count
		clean.stages[i] = stage
	end
	for key, class in TOP_SLOTS do
		if raw[key] ~= nil then
			local part, why = ownedPartOf(profile, raw[key], class)
			if not part then
				return nil, why
			end
			clean[key] = raw[key]
		end
	end
	clean.rcs = raw.rcs == true
	clean.dock = raw.dock == true
	for _, class in { "rcs", "dock" } do
		if clean[class] then
			local part = firstOfClass[class]
			if not (part and profile.parts[part.id]) then
				return nil, `you do not own {if part then part.label else class}`
			end
		end
	end
	return clean, nil
end

--- Every stage has a real engine and a real tank, so the physics can read the stack.
local function resolvable(asm: any): boolean
	if not asm.stages or #asm.stages == 0 then
		return false
	end
	for _, s in ipairs(asm.stages) do
		local eng = s.engine and byId[s.engine]
		local tank = s.tank and byId[s.tank]
		if not (eng and eng.class == "engine" and tank and tank.class == "tank") then
			return false
		end
	end
	return true
end

--- What it costs to press LAUNCH on this stack: a fraction of the engines, tanks and nose,
--- smaller on a stage carrying recovery gear. The pack sets both fractions.
local function refurbishFor(asm: any): number
	local rates = config.payout.refurbish
	local total = 0
	for _, s in ipairs(asm.stages or {}) do
		local eng = s.engine and byId[s.engine]
		local tank = s.tank and byId[s.tank]
		local base = ((eng and eng.cost) or 0) * (s.engineCount or 1) + ((tank and tank.cost) or 0)
		total += base * (if s.recovery then rates.recovered else rates.rate)
	end
	local nose = asm.nose and byId[asm.nose]
	total += ((nose and nose.cost) or 0) * rates.rate
	return math.floor(total)
end

local function signatureOf(asm: any, padTier: number): string
	local bits = { tostring(padTier) }
	for _, s in ipairs(asm.stages or {}) do
		table.insert(
			bits,
			`{s.engine or "-"}x{s.engineCount or 1}/{s.tank or "-"}/{s.decoupler or "-"}/{s.fins or "-"}/{s.recovery or "-"}`
		)
	end
	table.insert(
		bits,
		`{asm.nose or "-"}/{asm.gnc or "-"}/{asm.payload or "-"}/{asm.rcs and 1 or 0}/{asm.dock and 1 or 0}`
	)
	return table.concat(bits, "|")
end

--- The rules and the physics, run on a player's current stack and cached by signature.
--- `card` is nil until every stage has an engine and a tank; the problems always exist.
local function evaluate(player: Player, profile: any): any
	local asm = profile.assembly
	local limit = padTierFor(profile)
	local key = signatureOf(asm, profile.padTier)
	local cached = cardCache[player]
	if cached and cached.key == key then
		return cached
	end
	local ok, problems = Assembly.check(asm, config.parts, limit)
	local bundle = {
		key = key,
		ok = ok,
		problems = problems,
		refurb = refurbishFor(asm),
		card = nil,
		vehicle = nil,
		result = nil,
	}
	if resolvable(asm) then
		-- The physics is the pack's code. If it throws on some stack, the card goes dark
		-- and says so; the packet, the HUD and every other player carry on.
		local okPhysics, err = pcall(function()
			local vehicle = Flight.resolve(asm, config.parts)
			local result = Flight.simulate(vehicle)
			local card = Assembly.card(vehicle, result, limit)
			card.apogee = result.apogee
			card.orbit = result.orbit == true
			card.docked = result.docked == true
			card.held = result.held == true
			card.stages = #vehicle.stages
			bundle.card = card
			bundle.vehicle = vehicle
			bundle.result = result
		end)
		if not okPhysics then
			warn(`[BuildLoop] physics failed on a stack: {err}`)
			bundle.ok = false
			table.insert(bundle.problems, { text = "The numbers for this stack could not be worked out." })
		end
	end
	cardCache[player] = bundle
	return bundle
end

local function invalidate(player: Player)
	cardCache[player] = nil
end

-- ---------------------------------------------------------------- the pad

local function cutoff()
	for _, holder in pad.stages do
		for _, part in holder:GetDescendants() do
			if part:IsA("ParticleEmitter") or part:IsA("PointLight") then
				part.Enabled = false
			end
		end
	end
end

local function ignite(stageIndex: number)
	local holder = pad.stages[stageIndex]
	if not holder then
		return
	end
	for _, part in holder:GetDescendants() do
		if part:IsA("ParticleEmitter") or part:IsA("PointLight") then
			part.Enabled = true
		end
	end
end

--- The fire under a bell: a jet out of its mouth, pointing down, and a warm light. Off
--- until ignition. The colours are the pack's; the fire is the one warm thing allowed.
local function exhaust(mouth: BasePart, radius: number)
	local palette = theme.rocket or {}
	local flame = palette.flame or Color3.fromRGB(255, 138, 48)
	local tip = palette.flameTip or Color3.fromRGB(255, 224, 160)
	local dark = palette.dark or Color3.fromRGB(38, 40, 46)

	local jet = Instance.new("ParticleEmitter")
	jet.Name = "Exhaust"
	jet.Texture = "rbxasset://textures/particles/fire_main.dds"
	jet.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, tip),
		ColorSequenceKeypoint.new(0.3, flame),
		ColorSequenceKeypoint.new(1, dark),
	})
	jet.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, radius * 1.4),
		NumberSequenceKeypoint.new(0.5, radius * 2.4),
		NumberSequenceKeypoint.new(1, radius * 0.6),
	})
	jet.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.05),
		NumberSequenceKeypoint.new(0.6, 0.3),
		NumberSequenceKeypoint.new(1, 1),
	})
	jet.Lifetime = NumberRange.new(0.35, 0.6)
	jet.Speed = NumberRange.new(radius * 18, radius * 26)
	jet.Rate = 60
	jet.SpreadAngle = Vector2.new(6, 6)
	jet.LightEmission = 1
	jet.LightInfluence = 0
	-- The mouth is a cylinder stood on end (its length axis turned to world up), so
	-- its local -X face is the one that looks at the ground.
	jet.EmissionDirection = Enum.NormalId.Left
	jet.Enabled = false
	jet.Parent = mouth

	local light = Instance.new("PointLight")
	light.Name = "ExhaustLight"
	light.Color = flame
	light.Brightness = 2.5
	light.Range = math.clamp(radius * 14, 12, 60)
	light.Shadows = false
	light.Enabled = false
	light.Parent = mouth
end

local function clearPad()
	cutoff()
	if pad.model then
		pad.model:Destroy()
	end
	pad.model = nil
	pad.stages = {}
	pad.state = "empty"
	pad.owner = nil
	pad.asm = nil
	pad.vehicle = nil
	pad.result = nil
	pad.timeline = nil
	pad.held = false
	pad.altitude = 0
	pad.maxAltitude = 0
	fxAll("padClear")
	StateSync.requestAll()
end

--- Stand the stack up at the hangar, built from the pack's silhouette. Parts are grouped
--- by stage so a whole stage can be let go at separation.
local function buildRocket(asm: any): Model
	local specs, height = Rocket.stack(asm, byId)
	local model = Instance.new("Model")
	model.Name = "Rocket"

	local root = Instance.new("Part")
	root.Name = "Root"
	root.Size = Vector3.new(1, 1, 1)
	root.Transparency = 1
	root.Anchored = true
	root.CanCollide = false
	root.CanQuery = false
	root.CanTouch = false
	root.CFrame = pad.hangarCFrame
	root.Parent = model
	model.PrimaryPart = root

	local holders: { [number]: Model } = {}
	for _, spec in specs do
		local key = spec.stage or 0
		local holder = holders[key]
		if not holder then
			holder = Instance.new("Model")
			holder.Name = if key == 0 then "Top" else `Stage{key}`
			holder.Parent = model
			holders[key] = holder
		end
		local placed = table.clone(spec)
		placed.cframe = pad.hangarCFrame * spec.cframe
		local part = ContentLoader.block(placed, holder)
		part.CanTouch = false
		part:SetAttribute("Role", spec.role or "")
		if spec.role == "bellMouth" then
			exhaust(part, spec.size.Y / 2)
		end
	end

	model:SetAttribute("Height", height)
	model.Parent = pack.folder
	pad.model = model
	pad.stages = holders
	return model
end

--- Let go of a spent stage: it leaves the stack, falls under ordinary physics, and is
--- cleared away after a while. This is the clip moment and it costs almost nothing.
local function separate(stageIndex: number)
	local holder = pad.stages[stageIndex]
	if holder then
		holder.Parent = pack.folder
		for _, part in holder:GetDescendants() do
			if part:IsA("BasePart") then
				part.Anchored = false
				part.CanCollide = true
				part.AssemblyLinearVelocity = Vector3.new(math.random(-6, 6), -4, math.random(-6, 6))
				part.AssemblyAngularVelocity = Vector3.new(math.random(-2, 2), 0, math.random(-2, 2))
			elseif part:IsA("ParticleEmitter") or part:IsA("PointLight") then
				part.Enabled = false
			end
		end
		Debris:AddItem(holder, config.launch.debrisSeconds or 12)
	end
	pad.stages[stageIndex] = nil
	pad.stageIndex = stageIndex + 1
	ignite(pad.stageIndex)
	fxAll("staged", { stage = stageIndex })
end

-- ---------------------------------------------------------------- the flight

--- Altitude at a moment of simulated time, read off the trace. Monotonic cursor: the
--- playback only ever moves forward.
local function traceAltitude(simT: number): number
	local trace = pad.result.trace
	if #trace == 0 then
		return 0
	end
	while pad.cursor < #trace and trace[pad.cursor + 1].t <= simT do
		pad.cursor += 1
	end
	local a = trace[pad.cursor]
	local b = trace[pad.cursor + 1]
	if not b then
		return a.h
	end
	local span = b.t - a.t
	local u = if span > 0 then math.clamp((simT - a.t) / span, 0, 1) else 0
	return a.h + (b.h - a.h) * u
end

local function segment(name: string): any?
	for _, seg in pad.timeline or {} do
		if seg.name == name then
			return seg
		end
	end
	return nil
end

--- Every heartbeat while something is flying: sim time from wall time, altitude from the
--- trace, the stack moved to match, stages let go as they burn out, and a little
--- telemetry to the HUD.
local function tickFlight(delta: number)
	if pad.state ~= "flying" or not pad.model then
		return
	end
	local clock = ClockService.state()
	local phase = clock.phase
	if not phase or phase == "prelaunch" or phase == "recovery" then
		return
	end
	local elapsed = math.max(0, clock.length - clock.remaining)
	local h = 0
	if not pad.held then
		local seg = segment(phase)
		if seg then
			local u = math.clamp(elapsed / seg.wall, 0, 1)
			if phase == "descent" then
				-- Falling. The trace may have stopped short of the ground; the number
				-- comes down from apogee on its own curve so the flight always ends.
				h = pad.apogee * (1 - u * u)
			else
				local simT = seg.simStart + u * (seg.simEnd - seg.simStart)
				h = traceAltitude(simT) * pad.scale
				local stages = #pad.vehicle.stages
				while pad.stageIndex < stages and simT >= (pad.burnouts[pad.stageIndex] or math.huge) do
					separate(pad.stageIndex)
				end
			end
		end
	end
	pad.altitude = h
	pad.maxAltitude = math.max(pad.maxAltitude, h)

	-- Draw it. At scale below the ceiling; a slow drift above it so it never freezes.
	local ceiling = Flight.VISUAL_CEILING or 2000
	local studs = math.min(h, ceiling) * (Flight.STUDS_PER_M or 3.5)
	if h > ceiling then
		studs += math.log(1 + (h - ceiling) / 1000) * 40
	end
	local lean = math.rad(math.clamp(h / 300, 0, 10))
	local shake = if pad.held
		then CFrame.new((math.random() - 0.5) * 0.18, 0, (math.random() - 0.5) * 0.18)
		else CFrame.new()
	pad.model:PivotTo(pad.padCFrame * shake * CFrame.new(0, studs, 0) * CFrame.Angles(0, 0, lean))

	pad.telemetryClock += delta
	if pad.telemetryClock >= 1 / (config.launch.telemetryHz or 8) then
		pad.telemetryClock = 0
		fxAll("telemetry", {
			h = h,
			max = pad.maxAltitude,
			apogee = pad.apogee,
			phase = phase,
			stage = pad.stageIndex,
			stages = #pad.vehicle.stages,
			held = pad.held,
		})
	end
end

--- Build the playback timeline from the result and start the clock. Real time while the
--- engines burn; every later phase squeezed into the pack's wall caps.
local function beginFlight(vehicle: any, result: any)
	local launchCfg = config.launch
	pad.state = "flying"
	pad.vehicle = vehicle
	pad.result = result
	pad.held = result.held == true
	pad.altitude = 0
	pad.maxAltitude = 0
	pad.stageIndex = 1
	pad.cursor = 1
	pad.telemetryClock = 0
	pad.apogee = result.apogee or 0

	local phases = { { name = "prelaunch", length = launchCfg.prelaunch } }
	if pad.held then
		pad.timeline = {}
		pad.burnouts = {}
		pad.scale = 1
		table.insert(phases, { name = "ascent", length = launchCfg.holdDown })
	else
		local burnouts = {}
		local t = 0
		for _, st in vehicle.stages do
			t += st.prop / st.burnRate
			table.insert(burnouts, t)
		end
		local trace = result.trace
		local rawMax, apogeeT, endT = 0, 0, 0
		for _, sample in trace do
			if sample.h > rawMax then
				rawMax = sample.h
				apogeeT = sample.t
			end
			endT = sample.t
		end
		-- The physics scales the integrated apogee for guidance after the fact; the
		-- number the player watches has to agree with the number they are paid on.
		pad.scale = if rawMax > 0 then (result.apogee / rawMax) else 1
		local lastBurn = math.min(burnouts[#burnouts] or apogeeT, apogeeT)
		local ascentSim = math.max(lastBurn, 0.25)
		local coastSim = math.max(0, apogeeT - ascentSim)
		local timeline = {
			{
				name = "ascent",
				simStart = 0,
				simEnd = ascentSim,
				wall = math.clamp(ascentSim, 0.5, launchCfg.maxAscentWall),
			},
		}
		if coastSim > 0.05 then
			table.insert(timeline, {
				name = "coast",
				simStart = ascentSim,
				simEnd = apogeeT,
				wall = math.clamp(coastSim, 0.5, launchCfg.maxCoastWall),
			})
		end
		if not result.orbit then
			table.insert(timeline, {
				name = "descent",
				simStart = apogeeT,
				simEnd = endT,
				wall = math.clamp(apogeeT * 0.35, 2, launchCfg.maxDescentWall),
			})
		end
		pad.timeline = timeline
		pad.burnouts = burnouts
		for _, seg in timeline do
			table.insert(phases, { name = seg.name, length = seg.wall })
		end
	end
	table.insert(phases, { name = "recovery", length = launchCfg.recovery })

	fxAll("countdown", { owner = pad.owner and pad.owner.Name, seconds = launchCfg.prelaunch })
	ClockService.start({ cycles = { phases } })
	StateSync.requestAll()
end

-- ---------------------------------------------------------------- the money

local function milestoneMet(milestone: any, result: any): boolean
	local kind = milestone.kind
	if kind == "apogee" then
		return (result.apogee or 0) >= (milestone.at or math.huge)
	elseif kind == "dv" then
		return (result.effectiveDV or 0) >= (milestone.at or math.huge)
	elseif kind == "orbit" then
		return result.orbit == true
	elseif kind == "docked" then
		return result.docked == true
	end
	return false
end

local function challengeMet(test: any, asm: any, vehicle: any, result: any): boolean
	local kind = test and test.kind
	if kind == "launch" then
		return true
	elseif kind == "apogee" then
		return (result.apogee or 0) >= (test.at or math.huge)
	elseif kind == "twr" then
		return (result.twr or 0) >= (test.at or math.huge)
	elseif kind == "dv" then
		return (result.effectiveDV or 0) >= (test.at or math.huge)
	elseif kind == "stages" then
		return #vehicle.stages >= (test.at or math.huge)
	elseif kind == "mass" then
		return (vehicle.totalMass or 0) >= (test.at or math.huge)
	elseif kind == "payload" then
		return vehicle.payload ~= nil
	elseif kind == "rcs" then
		return vehicle.hasRcs == true
	elseif kind == "part" then
		return usesPart(asm, test.id)
	elseif kind == "vacuum" then
		for index, st in vehicle.stages do
			if index > 1 and st.engine and st.engine.vacuum then
				return true
			end
		end
		return false
	elseif kind == "orbit" then
		return result.orbit == true
	elseif kind == "docked" then
		return result.docked == true
	elseif kind == "deliver" then
		return result.docked == true and vehicle.payload ~= nil
	end
	return false
end

--- Walk the ladder in order: a single great flight can master one tier and, because
--- mastering opens the next synchronously, be credited on the next in the same pass.
local function evaluateChallenges(player: Player, asm: any, vehicle: any, result: any)
	for _, world in ChallengeService.worlds() do
		if ChallengeService.stateOf(player, world.id) ~= "open" then
			continue
		end
		for _, challenge in world.challenges do
			if ChallengeService.isDone(player, world.id, challenge.id) then
				continue
			end
			if challengeMet(challenge.test, asm, vehicle, result) then
				if ChallengeService.complete(player, world.id, challenge.id) then
					toast(player, `chal_{challenge.id}`, `{copy.missionDone}: {challenge.label}`, "good", 0)
					AnalyticsService.track(player, `mission_{challenge.id}`, 1)
				end
			end
		end
	end
end

--- The flight is over: pay for how high and how fast, once-only bonuses for barriers
--- broken, the records, the funnel, the ladder. Runs for the owner if they are still here.
local function settle()
	local player = pad.owner
	local result, vehicle, asm = pad.result, pad.vehicle, pad.asm
	local profile = player and DataService.get(player)
	if not (player and profile and player.Parent and result and vehicle) then
		return
	end
	local rates = config.payout
	local apogee = result.apogee or 0
	local dv = result.effectiveDV or 0
	local record = apogee > profile.bestApogee or dv > profile.bestDV
	local altPay = rates.altitude.rate * (apogee / 1000) ^ rates.altitude.exp
	local dvPay = if dv > 0 then rates.performance.rate * (dv / 1000) ^ rates.performance.exp else 0
	local base = math.max(altPay, dvPay) * (if record then 1 else rates.repeatFactor)

	local bonuses = {}
	local bonus = 0
	for _, milestone in rates.milestones do
		if not profile.milestones[milestone.id] and milestoneMet(milestone, result) then
			profile.milestones[milestone.id] = true
			bonus += milestone.pay
			table.insert(bonuses, { id = milestone.id, label = milestone.label, pay = milestone.pay })
		end
	end
	local total = math.floor(base + bonus)
	if total > 0 then
		EconomyService.grantCoins(player, total, "launch")
	end
	if apogee > profile.bestApogee then
		profile.bestApogee = apogee
	end
	if dv > profile.bestDV then
		profile.bestDV = dv
	end

	fx(player, "payout", {
		total = total,
		base = math.floor(base),
		record = record,
		bonuses = bonuses,
		apogee = apogee,
		dv = dv,
		twr = result.twr,
		orbit = result.orbit == true,
		docked = result.docked == true,
		held = result.held == true,
		repeatPercent = math.floor(rates.repeatFactor * 100 + 0.5),
	})
	if result.held then
		toast(player, "held", copy.heldToast, "warn", 0)
	elseif total > 0 then
		local tail = if record
			then copy.newRecord
			else string.format(copy.repeatFlight, math.floor(rates.repeatFactor * 100 + 0.5))
		toast(player, "paid", `{copy.paid} {money(total)} — {tail}`, "good", 0)
	end
	for index, entry in bonuses do
		task.delay(0.8 * index, function()
			if player.Parent then
				toast(player, `mile_{entry.id}`, `{copy.milestone}: {entry.label}  +{money(entry.pay)}`, "good", 0)
			end
		end)
	end

	if record then
		AnalyticsService.step(player, "first_record")
	end
	for _, entry in bonuses do
		AnalyticsService.step(player, entry.id)
	end
	if result.orbit then
		AnalyticsService.step(player, "orbit")
	end
	if result.docked then
		AnalyticsService.step(player, "docked")
	end
	AnalyticsService.track(player, "launch_apogee_m", math.floor(apogee))
	AnalyticsService.track(player, "launch_effective_dv", math.floor(dv))
	AnalyticsService.track(player, "launch_pay", total)

	evaluateChallenges(player, asm, vehicle, result)
	StateSync.request(player)
	-- A launch is worth a save. Off this thread: the clock is what called us.
	task.spawn(DataService.save, player, false)
end

local function onPhase(name: string)
	if pad.state ~= "flying" then
		return
	end
	if name == "ascent" then
		ignite(1)
		fxAll("ignition", { held = pad.held })
	elseif name == "coast" then
		cutoff()
		fxAll("coast", { apogee = pad.apogee })
	elseif name == "descent" then
		fxAll("apogee", { apogee = pad.apogee })
	elseif name == "recovery" then
		cutoff()
		if pad.held then
			fxAll("held")
		elseif pad.result and pad.result.orbit then
			fxAll("orbit", { docked = pad.result.docked == true })
		else
			fxAll("touchdown")
		end
		settle()
	end
	StateSync.requestAll()
end

-- ---------------------------------------------------------------- the verbs

--- A part just bought drops into an empty required slot on its own, so "buy fins"
--- fixes "no fins" without a second trip. Never replaces a part already there.
local function autoFit(profile: any, part: any): boolean
	local asm = profile.assembly
	local class = part.class
	if class == "fin" then
		local first = asm.stages[1]
		if first and first.fins == nil then
			first.fins = part.id
			return true
		end
	elseif class == "nose" then
		if asm.nose == nil then
			asm.nose = part.id
			return true
		end
	elseif class == "gnc" then
		if asm.gnc == nil then
			asm.gnc = part.id
			return true
		end
	elseif class == "decoupler" then
		for i = 1, #asm.stages - 1 do
			if asm.stages[i].decoupler == nil then
				asm.stages[i].decoupler = part.id
				return true
			end
		end
	end
	return false
end

--- The stack changed under a rocket standing on the pad: it goes back to the hangar.
local function rollbackIfOwner(player: Player)
	if pad.owner == player and (pad.state == "rolled" or pad.state == "rollout") then
		clearPad()
		toast(player, "rollback", copy.rolledBack, "info", 0)
	end
end

local function buy(player: Player, profile: any, id: string)
	local part = byId[id]
	if not part or not part.class then
		toast(player, "buy", copy.notForSale, "warn")
		return
	end
	if profile.parts[id] then
		toast(player, "buy", copy.alreadyOwned, "info")
		return
	end
	local cost = part.cost or 0
	if profile.cash < cost or not EconomyService.trySpend(player, cost, `part:{id}`) then
		toast(player, "buy", string.format(copy.needMore, money(cost - profile.cash)), "warn", 0.5)
		return
	end
	profile.parts[id] = true
	local fitted = autoFit(profile, part)
	invalidate(player)
	if fitted then
		rollbackIfOwner(player)
	end
	toast(player, `bought_{id}`, `{copy.bought}: {part.label}{if fitted then ` — {copy.fitted}` else ""}`, "good", 0)
	AnalyticsService.step(player, "first_buy")
	AnalyticsService.track(player, `buy_{id}`, cost)
	StateSync.request(player)
end

local function upgradePad(player: Player, profile: any)
	local tiers = config.parts.pad
	local nextTier = tiers[profile.padTier + 1]
	if not nextTier then
		toast(player, "pad", copy.padOwned, "info")
		return
	end
	local cost = nextTier.cost or 0
	if profile.cash < cost or not EconomyService.trySpend(player, cost, `pad:{nextTier.id}`) then
		toast(player, "pad", string.format(copy.needMore, money(cost - profile.cash)), "warn", 0.5)
		return
	end
	profile.padTier += 1
	invalidate(player)
	toast(player, "pad", `{copy.padBought}: {nextTier.label}`, "good", 0)
	AnalyticsService.track(player, "pad_tier", profile.padTier)
	StateSync.request(player)
end

local function setAssembly(player: Player, profile: any, raw: any)
	local clean, why = sanitizeAssembly(profile, raw)
	if not clean then
		toast(player, "asm", string.format(copy.badAssembly, why or "?"), "warn", 0.5)
		return
	end
	profile.assembly = clean
	invalidate(player)
	rollbackIfOwner(player)
	AnalyticsService.step(player, "first_assembly")
	StateSync.request(player)
end

local function clearAssembly(player: Player, profile: any)
	profile.assembly = { stages = {}, rcs = false, dock = false }
	invalidate(player)
	rollbackIfOwner(player)
	StateSync.request(player)
end

local function rollout(player: Player, profile: any)
	if pad.state ~= "empty" then
		if pad.owner == player then
			toast(player, "rollout", copy.rolledOut, "info")
		else
			toast(player, "rollout", copy.padInUse, "warn")
		end
		return
	end
	local bundle = evaluate(player, profile)
	if not bundle.ok or not bundle.vehicle then
		toast(player, "rollout", copy.fixProblems, "warn")
		return
	end
	pad.state = "rollout"
	pad.owner = player
	pad.asm = copyAssembly(profile.assembly)
	pad.vehicle = bundle.vehicle
	pad.result = bundle.result
	local model = buildRocket(pad.asm)
	fxAll("rollout", { owner = player.Name })
	StateSync.requestAll()

	task.spawn(function()
		local from, to = pad.hangarCFrame, pad.padCFrame
		local seconds = math.max(0.1, config.launch.rolloutSeconds or 3)
		local startedAt = os.clock()
		while pad.model == model and pad.state == "rollout" do
			local u = math.clamp((os.clock() - startedAt) / seconds, 0, 1)
			local eased = u * u * (3 - 2 * u)
			model:PivotTo(from:Lerp(to, eased))
			if u >= 1 then
				break
			end
			task.wait()
		end
		if pad.model == model and pad.state == "rollout" then
			pad.state = "rolled"
			toast(player, "rolled", copy.rolledOut, "good", 0)
			StateSync.requestAll()
		end
	end)
end

local function launch(player: Player, profile: any)
	if pad.owner ~= player then
		toast(player, "launch", if pad.state == "empty" then copy.rollOutFirst else copy.notYours, "warn")
		return
	end
	if pad.state ~= "rolled" then
		toast(player, "launch", copy.rollOutFirst, "info")
		return
	end
	-- Never trust that the client checked, or that the stack is the one that rolled out.
	local limit = padTierFor(profile)
	local ok = Assembly.check(pad.asm, config.parts, limit)
	if not ok then
		toast(player, "launch", copy.fixProblems, "warn")
		clearPad()
		return
	end
	local vehicle = Flight.resolve(pad.asm, config.parts)
	local result = Flight.simulate(vehicle)

	-- The refurbish is the price of pressing the button. It never takes cash below zero,
	-- because a player who cannot pay it still has to be able to fly their way out.
	local refurb = math.min(profile.cash, refurbishFor(pad.asm))
	if refurb > 0 then
		EconomyService.trySpend(player, refurb, "refurbish")
	end
	profile.launches += 1
	AnalyticsService.step(player, "first_launch")
	AnalyticsService.track(player, "launch", profile.launches)
	beginFlight(vehicle, result)
end

-- ---------------------------------------------------------------- packet

--- The first tier still being worked, or the last one if the ladder is done.
local function activeWorldId(player: Player): string
	local worlds = ChallengeService.worlds()
	local last = if worlds[1] then worlds[1].id else ""
	for _, world in worlds do
		if ChallengeService.stateOf(player, world.id) == "open" then
			return world.id
		end
		last = world.id
	end
	return last
end

--- Everything the warehouse shows: every part with its stats and its price, plus what
--- this player owns and can afford. Prices travel server -> client for display only.
local function catalogueFor(profile: any): { any }
	local groups = {}
	for _, groupName in GROUP_ORDER do
		local rows = {}
		for index, part in config.parts[groupName] or {} do
			local row = table.clone(part)
			if groupName == "pad" then
				row.tier = index
				row.owned = index <= profile.padTier
				row.current = index == profile.padTier
				row.next = index == profile.padTier + 1
			else
				row.owned = profile.parts[part.id] == true
			end
			row.affordable = (part.cost or 0) <= profile.cash
			table.insert(rows, row)
		end
		table.insert(groups, { id = groupName, rows = rows })
	end
	return groups
end

local function packet(player: Player, profile: any): any
	local bundle = evaluate(player, profile)
	local limit, tier = padTierFor(profile)
	local clock = ClockService.state()
	local flight = nil
	if pad.state == "flying" and pad.vehicle and pad.result then
		flight = {
			phase = clock.phase,
			remaining = clock.remaining,
			length = clock.length,
			altitude = pad.altitude,
			max = pad.maxAltitude,
			apogee = pad.apogee,
			held = pad.held,
			orbit = pad.result.orbit == true,
			docked = pad.result.docked == true,
			stage = pad.stageIndex,
			stages = #pad.vehicle.stages,
		}
	end
	return {
		cash = profile.cash,
		ownedParts = profile.parts,
		assembly = profile.assembly,
		padTier = profile.padTier,
		padLimit = limit,
		padLabel = tier.label,
		card = bundle.card,
		problems = bundle.problems,
		ready = bundle.ok,
		refurbish = bundle.refurb,
		catalogue = catalogueFor(profile),
		board = ChallengeService.packetFor(player, activeWorldId(player)),
		bestApogee = profile.bestApogee,
		bestDV = profile.bestDV,
		launches = profile.launches,
		limits = config.limits,
		orbitDV = Flight.ORBIT_DV,
		visualCeiling = Flight.VISUAL_CEILING,
		pad = {
			state = pad.state,
			ownerId = pad.owner and pad.owner.UserId,
			ownerName = pad.owner and pad.owner.Name,
			mine = pad.owner == player,
		},
		flight = flight,
	}
end

-- ---------------------------------------------------------------- contract

function BuildLoop.validate(cfg: any, world: any, thm: any)
	local expect = ContentLoader.expect
	expect(typeof(cfg.parts) == "table", "config.parts is required (the catalogue)")
	expect(typeof(cfg.parts.pad) == "table" and #cfg.parts.pad > 0, "config.parts.pad must list at least one pad tier")
	for _, tier in cfg.parts.pad do
		expect(typeof(tier.massLimit) == "number", "every pad tier needs a massLimit")
	end
	expect(
		typeof(cfg.flight) == "table"
			and typeof(cfg.flight.resolve) == "function"
			and typeof(cfg.flight.simulate) == "function",
		"config.flight needs resolve and simulate"
	)
	expect(typeof(cfg.flight.ORBIT_DV) == "number", "config.flight.ORBIT_DV is required")
	expect(
		typeof(cfg.assembly) == "table"
			and typeof(cfg.assembly.check) == "function"
			and typeof(cfg.assembly.card) == "function",
		"config.assembly needs check and card"
	)
	expect(typeof(cfg.rocket) == "table" and typeof(cfg.rocket.stack) == "function", "config.rocket needs stack")
	expect(typeof(cfg.tiers) == "table" and #cfg.tiers > 0, "config.tiers must be a non-empty array of worlds")
	for _, tier in cfg.tiers do
		expect(
			typeof(tier.id) == "string" and typeof(tier.challenges) == "table",
			"every tier needs an id and challenges"
		)
		for _, challenge in tier.challenges do
			expect(
				typeof(challenge.id) == "string" and typeof(challenge.label) == "string",
				`tier {tier.id}: every challenge needs an id and a label`
			)
			expect(
				typeof(challenge.test) == "table" and typeof(challenge.test.kind) == "string",
				`tier {tier.id}: challenge {challenge.id} needs a test with a kind`
			)
		end
	end
	expect(typeof(cfg.startingCash) == "number" and cfg.startingCash >= 0, "config.startingCash is required")
	expect(typeof(cfg.startingParts) == "table", "config.startingParts is required")
	local known = {}
	for _, groupName in GROUP_ORDER do
		for _, part in cfg.parts[groupName] or {} do
			expect(typeof(part.id) == "string", `config.parts.{groupName}: every part needs a string id`)
			known[part.id] = true
		end
	end
	for _, id in cfg.startingParts do
		expect(known[id], `config.startingParts names '{id}', which is not in the catalogue`)
	end
	if cfg.starterAssembly then
		for _, s in cfg.starterAssembly.stages or {} do
			for key in STAGE_SLOTS do
				expect(s[key] == nil or known[s[key]], `config.starterAssembly names '{s[key]}', not in the catalogue`)
			end
		end
		for key in TOP_SLOTS do
			local id = cfg.starterAssembly[key]
			expect(id == nil or known[id], `config.starterAssembly names '{id}', not in the catalogue`)
		end
	end
	expect(
		typeof(cfg.limits) == "table" and (cfg.limits.maxStages or 0) >= 1 and (cfg.limits.maxEngines or 0) >= 1,
		"config.limits needs maxStages and maxEngines"
	)
	expect(typeof(cfg.launch) == "table", "config.launch is required")
	for _, key in { "prelaunch", "holdDown", "recovery", "maxAscentWall", "maxCoastWall", "maxDescentWall" } do
		expect(typeof(cfg.launch[key]) == "number", `config.launch.{key} must be a number`)
	end
	expect(typeof(cfg.payout) == "table", "config.payout is required")
	for _, key in { "altitude", "performance" } do
		local entry = cfg.payout[key]
		expect(
			typeof(entry) == "table" and typeof(entry.rate) == "number" and typeof(entry.exp) == "number",
			`config.payout.{key} needs rate and exp`
		)
	end
	expect(typeof(cfg.payout.repeatFactor) == "number", "config.payout.repeatFactor is required")
	expect(
		typeof(cfg.payout.refurbish) == "table"
			and typeof(cfg.payout.refurbish.rate) == "number"
			and typeof(cfg.payout.refurbish.recovered) == "number",
		"config.payout.refurbish needs rate and recovered"
	)
	expect(typeof(cfg.payout.milestones) == "table", "config.payout.milestones is required")
	for _, milestone in cfg.payout.milestones do
		expect(
			typeof(milestone.id) == "string"
				and typeof(milestone.kind) == "string"
				and typeof(milestone.pay) == "number",
			"every milestone needs id, kind and pay"
		)
	end

	local kinds = {}
	for _, zone in world.zones do
		kinds[zone.kind] = true
	end
	for _, kind in { "warehouse", "assembly", "pad" } do
		expect(kinds[kind], `world.zones needs a zone of kind '{kind}'`)
	end

	expect(typeof(thm.copy) == "table", "theme.copy is required")
	for _, key in
		{
			"bought",
			"fitted",
			"needMore",
			"alreadyOwned",
			"notForSale",
			"padOwned",
			"padBought",
			"fixProblems",
			"padInUse",
			"rolledOut",
			"rolledBack",
			"notYours",
			"rollOutFirst",
			"heldToast",
			"paid",
			"newRecord",
			"repeatFlight",
			"milestone",
			"missionDone",
			"tierOpened",
			"badAssembly",
		}
	do
		expect(typeof(thm.copy[key]) == "string", `theme.copy.{key} is required`)
	end
end

local function onProfileLoaded(player: Player, profile: any)
	ensureDefaults(profile)
	ChallengeService.ensureDefaults(profile)
	AnalyticsService.markJoin(player)
	invalidate(player)
	fx(player, "fadeIn")
	for _, delay in OPENING_PUSHES do
		task.delay(delay, function()
			if player.Parent then
				StateSync.push(player)
			end
		end)
	end
end

local function zoneTop(part: BasePart): CFrame
	local thickness = math.min(part.Size.X, part.Size.Y, part.Size.Z)
	return CFrame.new(part.Position.X, part.Position.Y + thickness / 2, part.Position.Z)
end

function BuildLoop.start(loaded: any)
	pack = loaded
	config = pack.config
	theme = pack.theme
	copy = theme.copy
	Flight = config.flight
	Assembly = config.assembly
	Rocket = config.rocket
	BuildLoop.validate(config, pack.world, theme)
	indexParts(config.parts)

	-- Money is a single banked balance in this family; there is no carry to cap.
	EconomyService.setBalanceField("cash")
	AnalyticsService.configure({
		"first_buy",
		"first_assembly",
		"first_launch",
		"first_record",
		"karman",
		"orbit",
		"docked",
	})
	ChallengeService.configure(config.tiers)
	ChallengeService.opened:connect(function(player, worldId)
		for _, world in ChallengeService.worlds() do
			if world.id == worldId then
				toast(player, `tier_{worldId}`, `{copy.tierOpened}: {world.name}`, "good", 0)
				break
			end
		end
		StateSync.request(player)
	end)
	StateSync.setBuilder(packet)

	-- THE ONLY CLIENT MESSAGE. A verb, and for one verb a table the server rebuilds from
	-- scratch. Nothing in it is a price, a balance or a result.
	RemoteGuard.bind(Net.C2S_Act, {
		limit = ACT_LIMIT,
		window = ACT_WINDOW,
		validate = function(verb, payload)
			if typeof(verb) ~= "string" or #verb > MAX_VERB then
				return false
			end
			if verb == "assembly:set" then
				return typeof(payload) == "table"
			end
			if verb == "assembly:clear" or verb == "pad:rollout" or verb == "pad:launch" or verb == "pad:upgrade" then
				return true
			end
			return string.sub(verb, 1, #BUY_PREFIX) == BUY_PREFIX
		end,
	}, function(player, verb, payload)
		local profile = DataService.get(player)
		if not profile then
			return
		end
		if verb == "assembly:set" then
			setAssembly(player, profile, payload)
		elseif verb == "assembly:clear" then
			clearAssembly(player, profile)
		elseif verb == "pad:rollout" then
			rollout(player, profile)
		elseif verb == "pad:launch" then
			launch(player, profile)
		elseif verb == "pad:upgrade" then
			upgradePad(player, profile)
		else
			buy(player, profile, string.sub(verb, #BUY_PREFIX + 1))
		end
	end)

	-- Walking onto a place opens its screen. The pad and the hangar are also where the
	-- rocket stands and where it starts its roll.
	for _, zone in pack.world.zones do
		local part = pack.zoneParts[zone.id]
		if not part then
			continue
		end
		if zone.kind == "pad" then
			pad.padCFrame = zoneTop(part)
		elseif zone.kind == "assembly" then
			pad.hangarCFrame = zoneTop(part)
		end
		if zone.kind == "warehouse" or zone.kind == "assembly" or zone.kind == "pad" then
			ZoneService.create(part, {
				onEnter = function(player)
					fx(player, "screen", { name = zone.kind })
				end,
			})
		end
	end
	ZoneService.start()

	ClockService.phaseStarted:connect(onPhase)
	ClockService.completed:connect(function()
		if pad.state == "flying" then
			clearPad()
		end
	end)
	ClockService.tick:connect(function()
		if pad.state == "flying" then
			StateSync.requestAll()
		end
	end)

	DataService.profileLoaded:connect(onProfileLoaded)
	Players.PlayerRemoving:Connect(function(player)
		AnalyticsService.summarize(player)
		nextToastAt[player] = nil
		cardCache[player] = nil
		if pad.owner == player and pad.state ~= "flying" then
			clearPad()
		end
	end)

	RunService.Heartbeat:Connect(function(delta)
		local ok, err = pcall(tickFlight, delta)
		if not ok then
			warn(`[BuildLoop] flight tick error: {err}`)
		end
	end)
end

return BuildLoop

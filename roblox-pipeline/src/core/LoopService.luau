-- LoopService — binds zone kinds to loop verbs. This is the whole game, generically.
--
-- The engine must not know that this title calls its currency "coins" or that its
-- magnet upgrade is called "magnet". So the pack declares ROLES: which of its upgrades
-- fills the engine's slot for carry capacity, collect radius, burst size and pickup
-- value. Swap the pack, keep the loop.
--
-- Earn and spend are zone entries, not remotes (see the threat model in
-- specs/2026-09-12-fat-man-gets-rich-slice.md §5). The only client message in the whole
-- game is "buy this upgrade id", and it is validated here.

local Players = game:GetService("Players")

local Core = script.Parent
local AnalyticsService = require(Core.AnalyticsService)
local ContentLoader = require(Core.ContentLoader)
local DataService = require(Core.DataService)
local EconomyService = require(Core.EconomyService)
local PickupService = require(Core.PickupService)
local ProgressionService = require(Core.ProgressionService)
local RemoteGuard = require(Core.RemoteGuard)
local RewardService = require(Core.RewardService)
local StateSync = require(Core.StateSync)
local ZoneService = require(Core.ZoneService)

local Shared = game:GetService("ReplicatedStorage").Shared
local Format = require(Shared.Format)
local Net = require(Shared.Net)

local LoopService = {}

local BLOCKED_TOAST_COOLDOWN = 4
-- The client has no way to ask for state (adding one would widen the trust surface for
-- no gain), so the server re-sends the opening packet a few times to beat a slow client.
local OPENING_PUSHES = { 0, 0.5, 1.5, 3 }

local pack: any = nil
local roles: any = nil
local nextFloodAt: { [Player]: number } = {}
local onPad: { [Player]: boolean } = {}
local nextBlockedToastAt: { [Player]: number } = {}

local function toast(player: Player, text: string, tone: string?)
	RemoteGuard.fire(player, Net.S2C_Toast, text, tone or "info")
end

local function floodSpecFor(player: Player)
	local flood = pack.config.flood
	return {
		count = math.max(1, math.floor(ProgressionService.effect(player, roles.burstCount))),
		value = ProgressionService.effect(player, roles.pickupValue),
		lifetime = flood.lifetime,
		speed = flood.speed,
		lift = flood.lift,
		size = flood.size,
		color = pack.theme.pickupColor,
		material = flood.material,
	}
end

local function onBlocked(player: Player)
	local now = os.clock()
	if (nextBlockedToastAt[player] or 0) > now then
		return
	end
	nextBlockedToastAt[player] = now + BLOCKED_TOAST_COOLDOWN
	toast(player, `Bag full — take it to the {string.upper(pack.theme.bankVerb)}!`, "warn")
end

local function tryFlood(player: Player, padPart: BasePart)
	local now = os.clock()
	if (nextFloodAt[player] or 0) > now then
		return
	end

	local profile = DataService.get(player)
	if not profile then
		return
	end

	-- Playtest 1 finding: standing on the pad with a full bag kept firing and left 320
	-- uncollectable pickups on the floor — a perf drain and a readability mess. Refuse
	-- the payout instead and say why. The cooldown is deliberately NOT consumed, so the
	-- first payout after banking is instant.
	if profile.carry >= EconomyService.capFor(player) then
		onBlocked(player)
		return
	end

	nextFloodAt[player] = now + pack.config.flood.cooldown
	profile.stats.floods += 1

	local spec = floodSpecFor(player)
	local origin = padPart.CFrame * CFrame.new(0, pack.config.flood.originHeight, 0)
	PickupService.burst(origin, spec)
	RemoteGuard.fire(player, Net.S2C_Flood, padPart.Position, spec.count)
	AnalyticsService.step(player, "first_flood")
end

local function onCollect(player: Player, value: number): number
	local accepted = EconomyService.addCarry(player, value)
	if accepted > 0 then
		AnalyticsService.step(player, "first_collect")
	end
	return accepted
end

local function onBank(player: Player)
	local amount = EconomyService.bank(player)
	if amount <= 0 then
		return
	end
	toast(player, `+{Format.short(amount)} {pack.theme.currencyName}`, "good")
	AnalyticsService.step(player, "first_bank")
end

local function onBuy(player: Player, upgradeId: any)
	local ok, err = ProgressionService.buy(player, upgradeId)
	if ok then
		toast(player, `Upgraded ${upgradeId}`, "good")
		AnalyticsService.step(player, "first_upgrade")
		AnalyticsService.track(player, `upgrade_{upgradeId}`, ProgressionService.level(player, upgradeId))
	elseif err == "funds" then
		toast(player, `Not enough {pack.theme.currencyName}`, "warn")
	elseif err == "maxed" then
		toast(player, "Already maxed", "info")
	end
	-- An "unknown" id gets no reply at all. Nothing legitimate produces one.
end

local function onProfileLoaded(player: Player, profile: any)
	ProgressionService.ensureDefaults(profile)
	AnalyticsService.markJoin(player)

	local offline = RewardService.grantOffline(player, profile)
	if offline then
		RemoteGuard.fire(player, Net.S2C_Offline, {
			amount = offline.amount,
			away = Format.duration(offline.elapsed),
			capped = offline.capped,
			capText = Format.duration(RewardService.capSeconds()),
		})
	end

	for _, delay in OPENING_PUSHES do
		task.delay(delay, function()
			if player.Parent then
				StateSync.push(player)
			end
		end)
	end
end

local function bindZones()
	for _, zone in pack.world.zones do
		local part = pack.zoneParts[zone.id]
		if not part then
			continue
		end
		if zone.kind == "payout" then
			ZoneService.create(part, {
				onEnter = function(player)
					onPad[player] = true
					tryFlood(player, part)
				end,
				onLeave = function(player)
					onPad[player] = nil
				end,
			})
			-- Standing on the pad keeps paying out on the cooldown. A snack session
			-- should never make you step off and back on to see the hook again.
			task.spawn(function()
				while true do
					task.wait(0.25)
					for player in onPad do
						if player.Parent then
							tryFlood(player, part)
						else
							onPad[player] = nil
						end
					end
				end
			end)
		elseif zone.kind == "bank" then
			ZoneService.create(part, { onEnter = onBank })
		elseif zone.kind == "shop" then
			ZoneService.create(part, {
				onEnter = function(player)
					RemoteGuard.fire(player, Net.S2C_Shop, true)
				end,
				onLeave = function(player)
					RemoteGuard.fire(player, Net.S2C_Shop, false)
				end,
			})
		end
	end
end

--- The sweep-and-bank contract. ContentLoader checks only what every loop shares;
--- the numbers this loop needs are checked here, loudly, before anything runs.
function LoopService.validate(config: any, world: any, theme: any)
	local expect = ContentLoader.expect
	expect(typeof(config.flood) == "table", "config.flood is required")
	expect(typeof(config.flood.cooldown) == "number", "config.flood.cooldown must be a number")
	expect(typeof(config.collect) == "table", "config.collect is required")
	expect(typeof(config.upgrades) == "table" and #config.upgrades > 0, "config.upgrades must be a non-empty array")
	for _, def in config.upgrades do
		expect(typeof(def.id) == "string", "every upgrade needs a string id")
		expect(typeof(def.maxLevel) == "number" and def.maxLevel >= 1, `upgrade {def.id} needs maxLevel >= 1`)
		expect(typeof(def.baseCost) == "number" and def.baseCost > 0, `upgrade {def.id} needs a positive baseCost`)
	end
	-- Roles are how the engine stays ignorant of this game's vocabulary: the pack says
	-- which of its upgrades fills each engine slot.
	expect(typeof(config.roles) == "table", "config.roles is required")
	local byId = {}
	for _, def in config.upgrades do
		byId[def.id] = true
	end
	for _, role in { "carryCap", "collectRadius", "burstCount", "pickupValue" } do
		local target = config.roles[role]
		expect(typeof(target) == "string", `config.roles.{role} must name an upgrade id`)
		expect(byId[target], `config.roles.{role} points at '{target}', which is not in config.upgrades`)
	end
	expect(typeof(config.offline) == "table", "config.offline is required (the return hook)")
	expect(config.offline.capSeconds and config.offline.capSeconds > 0, "config.offline.capSeconds must be positive")

	-- The loop does not close without both halves of earn -> spend.
	local kinds = {}
	for _, zone in world.zones do
		kinds[zone.kind] = true
	end
	expect(kinds.payout, "world.zones needs at least one zone of kind 'payout'")
	expect(kinds.bank, "world.zones needs at least one zone of kind 'bank'")
	expect(typeof(theme.currencyName) == "string", "theme.currencyName is required")
end

function LoopService.start(loaded: any)
	pack = loaded
	LoopService.validate(pack.config, pack.world, pack.theme)
	roles = pack.config.roles

	ProgressionService.load(pack.config.upgrades)

	EconomyService.setCapProvider(function(player)
		return ProgressionService.effect(player, roles.carryCap)
	end)

	PickupService.setup({
		parent = pack.folder,
		maxActive = pack.config.flood.maxActive,
		radiusFor = function(player)
			return pack.config.collect.baseRadius + ProgressionService.effect(player, roles.collectRadius)
		end,
		onCollect = onCollect,
		onBlocked = onBlocked,
	})

	RewardService.configure({
		capSeconds = pack.config.offline.capSeconds,
		ratePerSecond = function(player)
			-- "One burst is worth this much; offline pays you this many bursts an hour."
			-- Expressed against the player's own upgrades, so progression carries over
			-- to time away without a second set of numbers to keep in sync.
			local perBurst = ProgressionService.effect(player, roles.burstCount)
				* ProgressionService.effect(player, roles.pickupValue)
			return perBurst * pack.config.offline.burstsPerHour / 3600
		end,
	})

	RemoteGuard.bind(Net.C2S_Buy, {
		limit = 6,
		window = 10,
		validate = function(upgradeId)
			return typeof(upgradeId) == "string" and #upgradeId <= 40
		end,
	}, onBuy)

	DataService.profileLoaded:connect(onProfileLoaded)
	Players.PlayerRemoving:Connect(function(player)
		AnalyticsService.summarize(player)
		nextFloodAt[player] = nil
		onPad[player] = nil
		nextBlockedToastAt[player] = nil
	end)

	bindZones()
	ZoneService.start()
end

return LoopService

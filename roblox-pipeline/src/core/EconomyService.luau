-- EconomyService — balances live here and nowhere else.
--
-- Two balances, because the loop needs a sell beat: `carry` is what you are holding
-- (capped), `coins` is what you have banked (spendable). Nothing in this module reads
-- a number that came from a client.

local Shared = game:GetService("ReplicatedStorage").Shared
local Signal = require(Shared.Signal)

local Core = script.Parent
local DataService = require(Core.DataService)

local EconomyService = {}

EconomyService.changed = Signal.new() -- (player)
EconomyService.banked = Signal.new() -- (player, amount)

local LEDGER_MAX = 200 -- in-memory ring; a durable ledger lands with ReceiptService
local ledger: { { userId: number, delta: number, reason: string, t: number } } = {}

-- Injected by LoopService so the engine does not need to know what a "carry cap" is
-- in this particular game.
local capProvider: ((Player) -> number)? = nil

function EconomyService.setCapProvider(fn: (Player) -> number)
	capProvider = fn
end

function EconomyService.capFor(player: Player): number
	return if capProvider then capProvider(player) else math.huge
end

local function record(player: Player, delta: number, reason: string)
	table.insert(ledger, { userId = player.UserId, delta = delta, reason = reason, t = os.time() })
	if #ledger > LEDGER_MAX then
		table.remove(ledger, 1)
	end
end

function EconomyService.coins(player: Player): number
	local profile = DataService.get(player)
	return if profile then profile.coins else 0
end

function EconomyService.carry(player: Player): number
	local profile = DataService.get(player)
	return if profile then profile.carry else 0
end

--- Try to take `value` into the carry. Returns how much was actually accepted, which
--- is how the caller knows the bag is full without asking a second question.
function EconomyService.addCarry(player: Player, value: number): number
	local profile = DataService.get(player)
	if not profile or value <= 0 then
		return 0
	end
	local cap = EconomyService.capFor(player)
	local room = math.max(0, cap - profile.carry)
	local accepted = math.min(room, value)
	if accepted <= 0 then
		return 0
	end
	profile.carry += accepted
	profile.stats.collected += accepted
	EconomyService.changed:fire(player)
	return accepted
end

--- Convert the whole carry into coins. Returns the amount banked (0 if empty).
function EconomyService.bank(player: Player): number
	local profile = DataService.get(player)
	if not profile then
		return 0
	end
	local amount = math.floor(profile.carry)
	if amount <= 0 then
		return 0
	end
	profile.carry = 0
	profile.coins += amount
	profile.stats.banks += 1
	record(player, amount, "bank")
	EconomyService.changed:fire(player)
	EconomyService.banked:fire(player, amount)
	return amount
end

--- Server-side grant (offline earnings, rewards). Never reachable from a remote.
function EconomyService.grantCoins(player: Player, amount: number, reason: string)
	local profile = DataService.get(player)
	if not profile or amount <= 0 then
		return
	end
	profile.coins += math.floor(amount)
	record(player, amount, reason)
	EconomyService.changed:fire(player)
end

function EconomyService.trySpend(player: Player, amount: number, reason: string): boolean
	local profile = DataService.get(player)
	if not profile or amount < 0 then
		return false
	end
	if profile.coins < amount then
		return false
	end
	profile.coins -= amount
	record(player, -amount, reason)
	EconomyService.changed:fire(player)
	return true
end

function EconomyService.recentLedger(): { any }
	return table.clone(ledger)
end

return EconomyService

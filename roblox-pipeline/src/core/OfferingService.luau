-- OfferingService — a bank that gives back more than it took, on a schedule.
--
-- Put value in; later, take out more of it, packaged into the best goods the total
-- affords. A forge, a shrine, a composter, a smelter: the shape is the same and none
-- of it knows what the goods are called. The pack supplies the tier ladder (an id, a
-- label, a value each) and the multiplier.
--
-- The point of the delay is that it makes the deposit a DECISION. Value handed over is
-- value not spent tonight, so an offering is a bet on there being a tomorrow.

local Shared = game:GetService("ReplicatedStorage").Shared
local Signal = require(Shared.Signal)

local OfferingService = {}

OfferingService.deposited = Signal.new() -- (amount, banked)
OfferingService.returned = Signal.new() -- ({ {tier, count} }, totalValue)

export type Tier = { id: string, label: string, value: number }
export type Config = { tiers: { Tier }, multiplier: number }

local tiers: { Tier } = {}
local multiplier = 1.5
local banked = 0

--- Tiers may arrive in any order; they are sorted richest-first because that is the
--- order the packer needs and sorting once is cheaper than sorting per harvest.
function OfferingService.configure(config: Config)
	tiers = table.clone(config.tiers)
	table.sort(tiers, function(a, b)
		return a.value > b.value
	end)
	multiplier = config.multiplier or 1.5
	banked = 0
end

function OfferingService.reset()
	banked = 0
end

--- Hand value over. Returns what is now banked.
function OfferingService.deposit(amount: number): number
	if amount <= 0 then
		return banked
	end
	banked += amount
	OfferingService.deposited:fire(amount, banked)
	return banked
end

function OfferingService.banked(): number
	return banked
end

function OfferingService.pending(): boolean
	return banked > 0
end

--- The lowest tier's value is the smallest thing the bank can hand back, so anything
--- under it stays banked rather than evaporating.
local function smallest(): number
	if #tiers == 0 then
		return 1
	end
	return tiers[#tiers].value
end

export type Return = { tier: Tier, count: number }

--- Work the bank and hand back goods worth `multiplier` times what went in, packaged
--- into the richest tiers that fit. Whatever is too small to package stays banked for
--- next time. Empties the bank of everything it managed to spend.
function OfferingService.harvest(): ({ Return }, number)
	if banked <= 0 or #tiers == 0 then
		return {}, 0
	end
	local budget = banked * multiplier
	local out: { Return } = {}
	local spent = 0
	for _, tier in tiers do
		if tier.value <= 0 then
			continue
		end
		local count = math.floor(budget / tier.value)
		if count > 0 then
			table.insert(out, { tier = tier, count = count })
			budget -= count * tier.value
			spent += count * tier.value
		end
	end
	-- Convert what was actually handed out back into deposit terms, and keep the rest.
	banked = math.max(0, banked - spent / multiplier)
	if banked < smallest() / multiplier then
		banked = 0
	end
	if #out > 0 then
		OfferingService.returned:fire(out, spent)
	end
	return out, spent
end

return OfferingService

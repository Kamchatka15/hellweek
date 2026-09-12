-- ProgressionService — upgrade levels and what they are worth.
--
-- Owns no numbers of its own. Every cost and every effect comes from the content
-- pack's `config.upgrades`, so a new game re-tunes progression without touching the
-- engine (GAME_FACTORY §1).

local Shared = game:GetService("ReplicatedStorage").Shared
local Signal = require(Shared.Signal)

local Core = script.Parent
local DataService = require(Core.DataService)
local EconomyService = require(Core.EconomyService)

local ProgressionService = {}

ProgressionService.changed = Signal.new() -- (player, upgradeId, newLevel)

local definitions: { [string]: any } = {}
local order: { string } = {}

export type UpgradeDef = {
	id: string,
	label: string,
	blurb: string,
	maxLevel: number,
	baseCost: number,
	costGrowth: number,
	base: number, -- effect at level 1
	perLevel: number, -- effect added per level above 1
}

function ProgressionService.load(upgrades: { UpgradeDef })
	definitions = {}
	order = {}
	for _, def in upgrades do
		definitions[def.id] = def
		table.insert(order, def.id)
	end
end

function ProgressionService.level(player: Player, id: string): number
	local profile = DataService.get(player)
	if not profile then
		return 1
	end
	return profile.upgrades[id] or 1
end

local function effectAt(def: UpgradeDef, level: number): number
	return def.base + def.perLevel * (level - 1)
end

local function costAt(def: UpgradeDef, level: number): number
	-- Cost to go from `level` to `level + 1`.
	return math.floor(def.baseCost * def.costGrowth ^ (level - 1) + 0.5)
end

function ProgressionService.effect(player: Player, id: string): number
	local def = definitions[id]
	if not def then
		return 0
	end
	return effectAt(def, ProgressionService.level(player, id))
end

--- What the client is allowed to see: labels, current level, next effect, next cost.
--- Prices travel server -> client for display only; the client never sends one back.
function ProgressionService.catalogFor(player: Player): { any }
	local rows = {}
	for _, id in order do
		local def = definitions[id]
		local level = ProgressionService.level(player, id)
		local maxed = level >= def.maxLevel
		table.insert(rows, {
			id = id,
			label = def.label,
			blurb = def.blurb,
			level = level,
			maxLevel = def.maxLevel,
			current = effectAt(def, level),
			nextValue = if maxed then nil else effectAt(def, level + 1),
			cost = if maxed then nil else costAt(def, level),
		})
	end
	return rows
end

--- The only state change reachable from a client message. Validates everything.
function ProgressionService.buy(player: Player, id: string): (boolean, string?)
	local def = definitions[id]
	if not def then
		return false, "unknown"
	end
	local profile = DataService.get(player)
	if not profile then
		return false, "noprofile"
	end
	local level = ProgressionService.level(player, id)
	if level >= def.maxLevel then
		return false, "maxed"
	end
	local cost = costAt(def, level)
	if not EconomyService.trySpend(player, cost, `upgrade:{id}`) then
		return false, "funds"
	end
	profile.upgrades[id] = level + 1
	ProgressionService.changed:fire(player, id, level + 1)
	return true, nil
end

--- Fill in any upgrade the profile has never seen (new player, or a new upgrade
--- added in an update). Level 1 is "owned at base", not "unowned".
function ProgressionService.ensureDefaults(profile: any)
	for _, id in order do
		if profile.upgrades[id] == nil then
			profile.upgrades[id] = 1
		end
	end
end

return ProgressionService

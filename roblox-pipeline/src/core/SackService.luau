-- SackService — what a player is carrying, by kind.
--
-- The sweep-and-bank loop carries a NUMBER (coins). A gather loop with more than one
-- resource has to carry a LIST, because "two cactus and an ashwood" is a different
-- thing from "three units". Everything that follows — recipes, a workbench, a fuel
-- that is not the only resource — needs the list.
--
-- Server-side and on the profile. The client is told what is in the sack; it never
-- says. Nothing here knows what a cactus is.

local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage").Shared
local Signal = require(Shared.Signal)

local Core = script.Parent
local DataService = require(Core.DataService)

local SackService = {}

SackService.changed = Signal.new() -- (player)

local capProvider: ((Player) -> number)? = nil

function SackService.setCapProvider(fn: (Player) -> number)
	capProvider = fn
end

function SackService.cap(player: Player): number
	return if capProvider then capProvider(player) else 6
end

local function sackOf(player: Player): { string }?
	local profile = DataService.get(player)
	if not profile then
		return nil
	end
	profile.sack = profile.sack or {}
	return profile.sack
end

function SackService.count(player: Player): number
	local sack = sackOf(player)
	return if sack then #sack else 0
end

function SackService.isFull(player: Player): boolean
	return SackService.count(player) >= SackService.cap(player)
end

--- Put one item in. Returns false when the sack is full, which is how the caller
--- knows to refuse the pickup rather than swallow it.
function SackService.add(player: Player, kind: string): boolean
	local sack = sackOf(player)
	if not sack or #sack >= SackService.cap(player) then
		return false
	end
	table.insert(sack, kind)
	SackService.changed:fire(player)
	return true
end

--- How many of each kind, and a stable ordered list for a display that must not
--- reshuffle itself every time a packet lands.
function SackService.contents(player: Player): ({ [string]: number }, { { kind: string, count: number } })
	local sack = sackOf(player)
	local counts: { [string]: number } = {}
	local order: { { kind: string, count: number } } = {}
	if not sack then
		return counts, order
	end
	for _, kind in sack do
		if counts[kind] == nil then
			counts[kind] = 0
			table.insert(order, { kind = kind, count = 0 })
		end
		counts[kind] += 1
	end
	for _, entry in order do
		entry.count = counts[entry.kind]
	end
	return counts, order
end

function SackService.countOf(player: Player, kind: string): number
	local counts = SackService.contents(player)
	return counts[kind] or 0
end

--- Take up to `amount` of one kind out. Returns how many were actually taken.
function SackService.take(player: Player, kind: string, amount: number): number
	local sack = sackOf(player)
	if not sack or amount <= 0 then
		return 0
	end
	local taken = 0
	for index = #sack, 1, -1 do
		if taken >= amount then
			break
		end
		if sack[index] == kind then
			table.remove(sack, index)
			taken += 1
		end
	end
	if taken > 0 then
		SackService.changed:fire(player)
	end
	return taken
end

--- Take everything matching `filter` (or everything, if there is none). Returns the
--- bag that came out, as kind -> count.
function SackService.drain(player: Player, filter: ((string) -> boolean)?): { [string]: number }
	local sack = sackOf(player)
	local out: { [string]: number } = {}
	if not sack then
		return out
	end
	local kept = {}
	for _, kind in sack do
		if filter == nil or filter(kind) then
			out[kind] = (out[kind] or 0) + 1
		else
			table.insert(kept, kind)
		end
	end
	if #kept ~= #sack then
		table.clear(sack)
		for _, kind in kept do
			table.insert(sack, kind)
		end
		SackService.changed:fire(player)
	end
	return out
end

function SackService.clear(player: Player)
	local sack = sackOf(player)
	if sack and #sack > 0 then
		table.clear(sack)
		SackService.changed:fire(player)
	end
end

function SackService.clearAll()
	for _, player in Players:GetPlayers() do
		SackService.clear(player)
	end
end

function SackService.ensureDefaults(profile: any)
	profile.sack = profile.sack or {}
end

return SackService

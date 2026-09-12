-- ChallengeService — named goals per world, and which worlds a player has opened.
--
-- The shape is generic: a game declares N worlds, each with a list of challenges.
-- A world is `locked` until it is opened, `open` while its challenges are being
-- worked, and `mastered` once every one of them is done — at which point the next
-- world opens. Nothing here knows what a biome or a pentagram is.
--
-- Everything is server-side and lives on the profile, so a completion survives a
-- rejoin and cannot be claimed by a client.

local Shared = game:GetService("ReplicatedStorage").Shared
local Signal = require(Shared.Signal)

local Core = script.Parent
local DataService = require(Core.DataService)

local ChallengeService = {}

ChallengeService.completed = Signal.new() -- (player, worldId, challengeId)
ChallengeService.mastered = Signal.new() -- (player, worldId)
ChallengeService.opened = Signal.new() -- (player, worldId)

export type Challenge = { id: string, label: string, hint: string? }
export type World = { id: string, name: string, challenges: { Challenge } }

local worlds: { World } = {}
local byId: { [string]: World } = {}
local order: { [string]: number } = {}

function ChallengeService.configure(list: { World })
	worlds = list
	byId = {}
	order = {}
	for index, world in list do
		byId[world.id] = world
		order[world.id] = index
	end
end

function ChallengeService.worlds(): { World }
	return worlds
end

--- The first world is open to everyone; the rest start locked.
function ChallengeService.ensureDefaults(profile: any)
	profile.worlds = profile.worlds or {}
	for index, world in worlds do
		local record = profile.worlds[world.id]
		if not record then
			record = { state = if index == 1 then "open" else "locked", done = {} }
			profile.worlds[world.id] = record
		end
		record.done = record.done or {}
	end
end

local function recordFor(player: Player, worldId: string): any?
	local profile = DataService.get(player)
	if not profile or not profile.worlds then
		return nil
	end
	return profile.worlds[worldId]
end

function ChallengeService.stateOf(player: Player, worldId: string): string
	local record = recordFor(player, worldId)
	return if record then record.state else "locked"
end

function ChallengeService.isDone(player: Player, worldId: string, challengeId: string): boolean
	local record = recordFor(player, worldId)
	return record ~= nil and record.done[challengeId] == true
end

function ChallengeService.open(player: Player, worldId: string): boolean
	local record = recordFor(player, worldId)
	if not record or record.state ~= "locked" then
		return false
	end
	record.state = "open"
	ChallengeService.opened:fire(player, worldId)
	return true
end

--- Mark a challenge done. Idempotent: the second call is a no-op, which is what makes
--- "how far in are they" mean anything. Returns true only the first time.
function ChallengeService.complete(player: Player, worldId: string, challengeId: string): boolean
	local world = byId[worldId]
	local record = recordFor(player, worldId)
	if not world or not record or record.state == "locked" or record.done[challengeId] then
		return false
	end
	local known = false
	for _, challenge in world.challenges do
		if challenge.id == challengeId then
			known = true
			break
		end
	end
	if not known then
		return false
	end

	record.done[challengeId] = true
	ChallengeService.completed:fire(player, worldId, challengeId)

	for _, challenge in world.challenges do
		if not record.done[challenge.id] then
			return true -- still work to do
		end
	end

	record.state = "mastered"
	ChallengeService.mastered:fire(player, worldId)
	local nextWorld = worlds[(order[worldId] or 0) + 1]
	if nextWorld then
		ChallengeService.open(player, nextWorld.id)
	end
	return true
end

function ChallengeService.doneCount(player: Player, worldId: string): (number, number)
	local world = byId[worldId]
	if not world then
		return 0, 0
	end
	local record = recordFor(player, worldId)
	local done = 0
	for _, challenge in world.challenges do
		if record and record.done[challenge.id] then
			done += 1
		end
	end
	return done, #world.challenges
end

--- What the client is allowed to see: the active world's list with a done flag each,
--- plus every world's state so a progress display can be drawn.
function ChallengeService.packetFor(player: Player, activeWorldId: string): any
	local world = byId[activeWorldId]
	local list = {}
	if world then
		for _, challenge in world.challenges do
			table.insert(list, {
				id = challenge.id,
				label = challenge.label,
				hint = challenge.hint,
				done = ChallengeService.isDone(player, activeWorldId, challenge.id),
			})
		end
	end
	local states = {}
	for index, entry in worlds do
		table.insert(states, {
			id = entry.id,
			name = entry.name,
			index = index,
			state = ChallengeService.stateOf(player, entry.id),
		})
	end
	local done, total = ChallengeService.doneCount(player, activeWorldId)
	return {
		worldId = activeWorldId,
		worldName = if world then world.name else activeWorldId,
		done = done,
		total = total,
		list = list,
		worlds = states,
	}
end

return ChallengeService

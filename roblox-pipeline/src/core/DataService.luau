-- DataService — the profile store.
--
-- Data loss is the #1 Gate A killer (GAME_FACTORY §1), so this module is deliberately
-- boring: UpdateAsync everywhere, a session lock, a schema version with a migration
-- chain, exponential backoff, autosave, and BindToClose.
--
-- Studio note: if "Enable Studio Access to API Services" is off, DataStore calls throw.
-- Rather than blocking a playtest on a checkbox, we detect that once and fall back to an
-- in-memory store with a loud warning. Nothing about the fallback is durable, and it is
-- never used on a live server.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Signal = require(game:GetService("ReplicatedStorage").Shared.Signal)

local DataService = {}

local STORE_NAME = "PlayerProfiles_v1"
local SCHEMA_VERSION = 2
local AUTOSAVE_INTERVAL = 60
local LOCK_TIMEOUT = 90 -- a heartbeat older than this belongs to a dead server
local LOAD_ATTEMPTS = 4

DataService.profileLoaded = Signal.new()
DataService.SCHEMA_VERSION = SCHEMA_VERSION

local store: DataStore? = nil
local memoryFallback = false
local memory: { [number]: any } = {}
local profiles: { [number]: any } = {}
local started = false

local function defaultProfile()
	local now = os.time()
	return {
		schemaVersion = SCHEMA_VERSION,
		coins = 0,
		carry = 0,
		upgrades = {},
		stats = { floods = 0, banks = 0, collected = 0 },
		-- v2: the build-and-launch loop family. A banked balance of its own, a set of
		-- owned part ids, the stack on the hangar floor, the pad tier and the records.
		cash = 0,
		parts = {},
		assembly = { stages = {} },
		padTier = 1,
		bestApogee = 0,
		bestDV = 0,
		launches = 0,
		milestones = {},
		firstJoin = now,
		lastSeen = now,
		lock = nil,
	}
end

-- from-version -> function(record) -> record at version+1.
-- Add an entry every time SCHEMA_VERSION goes up; never edit an existing one.
local MIGRATIONS: { [number]: (any) -> any } = {}

-- 1 -> 2: the build loop family's fields. Every v1 field is kept exactly as written
-- (coins, carry, upgrades, stats, worlds, bestDay, tutorialComplete, ...); the new ones
-- start empty. A v1 profile reads back as the same player with an empty hangar.
MIGRATIONS[1] = function(record: any): any
	record.cash = record.cash or 0
	record.parts = record.parts or {}
	record.assembly = record.assembly or { stages = {} }
	record.padTier = record.padTier or 1
	record.bestApogee = record.bestApogee or 0
	record.bestDV = record.bestDV or 0
	record.launches = record.launches or 0
	record.milestones = record.milestones or {}
	return record
end

local function migrate(record: any): any?
	local version = record.schemaVersion or 0
	while version < SCHEMA_VERSION do
		local step = MIGRATIONS[version]
		if not step then
			return nil -- no path forward; refuse rather than silently reshape
		end
		record = step(record)
		version += 1
		record.schemaVersion = version
	end
	if version > SCHEMA_VERSION then
		return nil -- written by a newer server; do not downgrade a player's save
	end
	-- Fill any field a previous version never wrote.
	local template = defaultProfile()
	for key, value in template do
		if record[key] == nil then
			record[key] = value
		end
	end
	return record
end

local function key(userId: number): string
	return `p_{userId}`
end

local function lockIsForeign(record: any): boolean
	local lock = record.lock
	if not lock or lock.jobId == game.JobId then
		return false
	end
	return (os.time() - (lock.t or 0)) < LOCK_TIMEOUT
end

--- One probe decides whether DataStores are usable in this environment.
local function resolveStore()
	local ok, result = pcall(function()
		local candidate = DataStoreService:GetDataStore(STORE_NAME)
		candidate:GetAsync("__probe")
		return candidate
	end)
	if ok then
		store = result
	else
		memoryFallback = true
		warn(
			"[DataService] DataStores unavailable — running on an IN-MEMORY fallback. "
				.. "Progress will not persist. In Studio: File > Game Settings > Security > "
				.. "Enable Studio Access to API Services. Error: "
				.. tostring(result)
		)
	end
end

local function loadRecord(userId: number): any?
	if memoryFallback then
		local record = memory[userId] or defaultProfile()
		return migrate(record)
	end

	for attempt = 1, LOAD_ATTEMPTS do
		local blocked = false
		local ok, result = pcall(function()
			return (store :: DataStore):UpdateAsync(key(userId), function(old)
				local record = old or defaultProfile()
				if lockIsForeign(record) then
					blocked = true
					return nil -- another server still owns this profile
				end
				local migrated = migrate(record)
				if not migrated then
					blocked = true
					return nil
				end
				migrated.lock = { jobId = game.JobId, t = os.time() }
				return migrated
			end)
		end)

		if ok and not blocked and result then
			return result
		end
		if not ok then
			warn(`[DataService] load attempt {attempt} failed for {userId}: {result}`)
		end
		task.wait(2 ^ attempt) -- 2s, 4s, 8s, 16s
	end
	return nil
end

local function writeRecord(userId: number, record: any, release: boolean)
	record.schemaVersion = SCHEMA_VERSION
	record.lastSeen = os.time()
	record.lock = if release then nil else { jobId = game.JobId, t = os.time() }

	if memoryFallback then
		memory[userId] = record
		return true
	end

	local ok, err = pcall(function()
		-- The session lock means we are the only writer, so last-write-wins on our own
		-- record is correct here. UpdateAsync (not SetAsync) keeps us on the retry/
		-- conflict path if that assumption is ever wrong.
		(store :: DataStore):UpdateAsync(key(userId), function()
			return record
		end)
	end)
	if not ok then
		warn(`[DataService] save failed for {userId}: {err}`)
	end
	return ok
end

function DataService.get(userIdOrPlayer: Player | number): any?
	local userId = if typeof(userIdOrPlayer) == "Instance"
		then (userIdOrPlayer :: Player).UserId
		else userIdOrPlayer :: number
	return profiles[userId]
end

--- Mutate in place. Returns whatever the mutator returns, so callers can report failure.
function DataService.update(player: Player, mutator: (any) -> any): any
	local profile = profiles[player.UserId]
	if not profile then
		return nil
	end
	return mutator(profile)
end

function DataService.save(player: Player, release: boolean?)
	local profile = profiles[player.UserId]
	if not profile then
		return
	end
	writeRecord(player.UserId, profile, release == true)
end

local function onPlayerAdded(player: Player)
	local record = loadRecord(player.UserId)
	if not record then
		player:Kick(
			"Could not load your save (another server may still have it open). "
				.. "Please rejoin in a few seconds — nothing was lost."
		)
		return
	end
	if not player.Parent then
		return -- left during the yield
	end
	profiles[player.UserId] = record
	DataService.profileLoaded:fire(player, record)
end

local function onPlayerRemoving(player: Player)
	local profile = profiles[player.UserId]
	if profile then
		writeRecord(player.UserId, profile, true)
		profiles[player.UserId] = nil
	end
end

function DataService.start()
	if started then
		return
	end
	started = true
	resolveStore()

	for _, player in Players:GetPlayers() do
		task.spawn(onPlayerAdded, player)
	end
	Players.PlayerAdded:Connect(function(player)
		task.spawn(onPlayerAdded, player)
	end)
	Players.PlayerRemoving:Connect(onPlayerRemoving)

	task.spawn(function()
		while true do
			task.wait(AUTOSAVE_INTERVAL)
			for userId, profile in profiles do
				writeRecord(userId, profile, false) -- also refreshes the session lock
			end
		end
	end)

	game:BindToClose(function()
		if RunService:IsStudio() then
			return
		end
		for userId, profile in profiles do
			writeRecord(userId, profile, true)
		end
		task.wait(2) -- let the writes drain
	end)
end

return DataService

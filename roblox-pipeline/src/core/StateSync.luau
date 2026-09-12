-- StateSync — one authoritative push of "what is true" to a single client.
--
-- The client renders this and nothing else. It has no local copy of a price, a cap, or
-- a balance that it maintains itself, which is why there is no way for a desynced or
-- edited client to be right about money.

local Players = game:GetService("Players")

local Core = script.Parent
local DataService = require(Core.DataService)
local EconomyService = require(Core.EconomyService)
local ProgressionService = require(Core.ProgressionService)
local RemoteGuard = require(Core.RemoteGuard)

local Shared = game:GetService("ReplicatedStorage").Shared
local Net = require(Shared.Net)

local StateSync = {}

local PUSH_INTERVAL = 0.1 -- coalesce bursts of changes into one packet
local pending: { [Player]: boolean } = {}
local started = false

function StateSync.push(player: Player)
	local profile = DataService.get(player)
	if not profile or not player.Parent then
		return
	end
	RemoteGuard.fire(player, Net.S2C_State, {
		coins = profile.coins,
		carry = profile.carry,
		carryCap = EconomyService.capFor(player),
		catalog = ProgressionService.catalogFor(player),
	})
end

function StateSync.request(player: Player)
	pending[player] = true
end

function StateSync.start()
	if started then
		return
	end
	started = true

	EconomyService.changed:connect(StateSync.request)
	ProgressionService.changed:connect(StateSync.request)
	Players.PlayerRemoving:Connect(function(player)
		pending[player] = nil
	end)

	task.spawn(function()
		while true do
			task.wait(PUSH_INTERVAL)
			for player in pending do
				pending[player] = nil
				StateSync.push(player)
			end
		end
	end)
end

return StateSync

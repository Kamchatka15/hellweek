-- ZoneService — "is a player standing here", server-side.
--
-- Deliberately not Touched events: Touched fires from client-owned character physics,
-- misses at speed, and double-fires at rest. A polled object-space bounds check is
-- boring, cheap, and the server is the one asking.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ZoneService = {}

local POLL_INTERVAL = 0.15
local HEAD_ROOM = 8 -- studs above the pad that still count as standing on it

type Zone = {
	part: BasePart,
	onEnter: ((Player) -> ())?,
	onLeave: ((Player) -> ())?,
	inside: { [Player]: boolean },
}

local zones: { Zone } = {}
local started = false

local function contains(zone: Zone, position: Vector3): boolean
	local local_ = zone.part.CFrame:PointToObjectSpace(position)
	local half = zone.part.Size / 2
	return math.abs(local_.X) <= half.X
		and math.abs(local_.Z) <= half.Z
		and local_.Y >= -half.Y
		and local_.Y <= half.Y + HEAD_ROOM
end

local function poll()
	local players = Players:GetPlayers()
	for _, zone in zones do
		if not zone.part.Parent then
			continue
		end
		for _, player in players do
			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			local isInside = root ~= nil and contains(zone, (root :: BasePart).Position)
			local wasInside = zone.inside[player] == true
			if isInside and not wasInside then
				zone.inside[player] = true
				if zone.onEnter then
					zone.onEnter(player)
				end
			elseif not isInside and wasInside then
				zone.inside[player] = nil
				if zone.onLeave then
					zone.onLeave(player)
				end
			end
		end
	end
end

export type ZoneOptions = { onEnter: ((Player) -> ())?, onLeave: ((Player) -> ())? }

function ZoneService.create(part: BasePart, options: ZoneOptions)
	table.insert(zones, {
		part = part,
		onEnter = options.onEnter,
		onLeave = options.onLeave,
		inside = {},
	})
end

function ZoneService.start()
	if started then
		return
	end
	started = true

	Players.PlayerRemoving:Connect(function(player)
		for _, zone in zones do
			zone.inside[player] = nil
		end
	end)

	local accumulator = 0
	RunService.Heartbeat:Connect(function(delta)
		accumulator += delta
		if accumulator < POLL_INTERVAL then
			return
		end
		accumulator = 0
		local ok, err = pcall(poll)
		if not ok then
			warn(`[ZoneService] poll error: {err}`)
		end
	end)
end

return ZoneService

-- RemoteGuard — every client->server message goes through here or it does not exist.
--
-- Fail closed: an unknown remote, a bad argument, or a player over their rate limit
-- gets dropped silently. We never echo a reason back, because the only party that
-- benefits from a detailed rejection is someone probing the surface.

local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage").Shared
local Net = require(Shared.Net)

local RemoteGuard = {}

-- userId -> remoteName -> { tokens, lastRefill }
local buckets: { [number]: { [string]: { tokens: number, lastRefill: number } } } = {}

local function allow(player: Player, name: string, limit: number, window: number): boolean
	local perPlayer = buckets[player.UserId]
	if not perPlayer then
		perPlayer = {}
		buckets[player.UserId] = perPlayer
	end
	local bucket = perPlayer[name]
	local now = os.clock()
	if not bucket then
		bucket = { tokens = limit, lastRefill = now }
		perPlayer[name] = bucket
	end
	-- Continuous refill: limit tokens per window, topped up proportionally.
	local elapsed = now - bucket.lastRefill
	bucket.tokens = math.min(limit, bucket.tokens + elapsed * (limit / window))
	bucket.lastRefill = now
	if bucket.tokens < 1 then
		return false
	end
	bucket.tokens -= 1
	return true
end

export type BindOptions = {
	limit: number?, -- calls allowed per window (default 10)
	window: number?, -- seconds (default 10)
	validate: ((...any) -> boolean)?, -- return false to drop
}

--- Bind a server handler to a named remote. The handler only ever runs on input that
--- passed rate limiting and validation.
function RemoteGuard.bind(name: string, options: BindOptions, handler: (Player, ...any) -> ())
	local remote = Net.get(name)
	assert(remote, `[RemoteGuard] no remote named {name}`)

	local limit = options.limit or 10
	local window = options.window or 10
	local validate = options.validate

	remote.OnServerEvent:Connect(function(player, ...)
		if not allow(player, name, limit, window) then
			return
		end
		if validate and not validate(...) then
			return
		end
		local ok, err = pcall(handler, player, ...)
		if not ok then
			warn(`[RemoteGuard] {name} handler error: {err}`)
		end
	end)
end

function RemoteGuard.fire(player: Player, name: string, ...: any)
	local remote = Net.get(name)
	if remote then
		remote:FireClient(player, ...)
	end
end

function RemoteGuard.fireAll(name: string, ...: any)
	local remote = Net.get(name)
	if remote then
		remote:FireAllClients(...)
	end
end

function RemoteGuard.start()
	Players.PlayerRemoving:Connect(function(player)
		buckets[player.UserId] = nil
	end)
end

return RemoteGuard

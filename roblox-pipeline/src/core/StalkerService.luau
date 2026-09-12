-- StalkerService — an unkillable pursuer that respects a safe circle.
--
-- The night threat every survive-the-night game has: it stands at the edge of the
-- light, it walks toward anyone outside, it stops at the light-line like a pane of
-- glass, and touching it is a setback, not a gore death. No combat, no health, no
-- weapons; the only counter is the light.
--
-- Everything is server-side. The model is anchored and moved by the server, so its
-- position is authoritative and the touch check is a server distance test — there is
-- no client event to forge.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local StalkerService = {}

export type Mode = "hidden" | "watch" | "hunt"

export type Config = {
	model: Model, -- anchored; the service moves it with PivotTo
	origin: () -> Vector3, -- the point the safe circle is around (the beacon)
	safeRadius: () -> number, -- the current safe radius
	standOff: number, -- studs outside the line it stands when watching
	speed: number, -- studs/second while hunting
	touchDistance: number,
	sway: number?, -- degrees of idle sway
	onTouch: (Player) -> (), -- the setback; the loop decides what it costs
	touchCooldown: number?, -- seconds a player is untouchable after a touch
}

local config: Config? = nil
local mode: Mode = "hidden"
local angle = 0 -- where on the circle it is standing, radians
local untouchable: { [Player]: number } = {}
local connection: RBXScriptConnection? = nil
local swayClock = 0

local function pivot(): Vector3
	local c = config :: Config
	return c.model:GetPivot().Position
end

local function place(position: Vector3, faceToward: Vector3)
	local c = config :: Config
	local flatTarget = Vector3.new(faceToward.X, position.Y, faceToward.Z)
	local look = CFrame.lookAt(position, flatTarget)
	if c.sway and c.sway > 0 then
		look = look * CFrame.Angles(0, 0, math.rad(math.sin(swayClock * 0.9) * c.sway))
	end
	c.model:PivotTo(look)
end

local function lineAt(theta: number): Vector3
	local c = config :: Config
	local origin = c.origin()
	local r = c.safeRadius() + c.standOff
	return Vector3.new(origin.X + math.cos(theta) * r, origin.Y, origin.Z + math.sin(theta) * r)
end

local function nearestOutside(): (Player?, Vector3?)
	local c = config :: Config
	local origin = c.origin()
	local radius = c.safeRadius()
	local here = pivot()
	local best: Player? = nil
	local bestPosition: Vector3? = nil
	local bestDistance = math.huge
	for _, player in Players:GetPlayers() do
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not root or not humanoid or humanoid.Health <= 0 then
			continue
		end
		local position = (root :: BasePart).Position
		local fromOrigin = Vector3.new(position.X - origin.X, 0, position.Z - origin.Z).Magnitude
		if fromOrigin <= radius then
			continue -- inside the light: invisible to it
		end
		local distance = (position - here).Magnitude
		if distance < bestDistance then
			bestDistance = distance
			best = player
			bestPosition = position
		end
	end
	return best, bestPosition
end

local function step(delta: number)
	local c = config :: Config
	if mode == "hidden" then
		return
	end
	swayClock += delta
	local origin = c.origin()

	if mode == "watch" then
		place(lineAt(angle), origin)
		return
	end

	-- hunt
	local target, targetPosition = nearestOutside()
	local here = pivot()
	if not target or not targetPosition then
		-- Nobody outside: drift back to the line at the angle nearest to where it is.
		angle = math.atan2(here.Z - origin.Z, here.X - origin.X)
		local home = lineAt(angle)
		local toHome = home - here
		if toHome.Magnitude > 0.5 then
			local move = toHome.Unit * math.min(toHome.Magnitude, c.speed * delta)
			place(here + move, origin)
		else
			place(home, origin)
		end
		return
	end

	local toTarget = Vector3.new(targetPosition.X - here.X, 0, targetPosition.Z - here.Z)
	local move = if toTarget.Magnitude > 0.01 then toTarget.Unit * c.speed * delta else Vector3.zero
	local nextPos = here + move

	-- Pane of glass: never inside the light.
	local flat = Vector3.new(nextPos.X - origin.X, 0, nextPos.Z - origin.Z)
	local minRadius = c.safeRadius() + 0.5
	if flat.Magnitude < minRadius then
		nextPos = Vector3.new(origin.X, nextPos.Y, origin.Z) + flat.Unit * minRadius
	end
	place(nextPos, targetPosition)

	local now = os.clock()
	if (targetPosition - nextPos).Magnitude <= c.touchDistance and (untouchable[target] or 0) <= now then
		untouchable[target] = now + (c.touchCooldown or 3)
		local ok, err = pcall(c.onTouch, target)
		if not ok then
			warn(`[StalkerService] onTouch error: {err}`)
		end
	end
end

function StalkerService.configure(newConfig: Config)
	config = newConfig
	mode = "hidden"
	angle = math.random() * math.pi * 2
	if not connection then
		connection = RunService.Heartbeat:Connect(function(delta)
			local ok, err = pcall(step, delta)
			if not ok then
				warn(`[StalkerService] step error: {err}`)
			end
		end)
	end
	Players.PlayerRemoving:Connect(function(player)
		untouchable[player] = nil
	end)
end

--- hidden: parked far away and invisible. watch: stands on the line, still.
--- hunt: walks toward anyone outside the light.
function StalkerService.setMode(newMode: Mode)
	local c = config
	if not c or newMode == mode then
		return
	end
	mode = newMode
	if newMode == "hidden" then
		c.model:PivotTo(CFrame.new(0, -500, 0))
		return
	end
	-- Coming out of hiding: appear on the line, facing the light.
	if newMode == "watch" or not StalkerService.isVisible() then
		place(lineAt(angle), c.origin())
	end
end

function StalkerService.mode(): Mode
	return mode
end

function StalkerService.isVisible(): boolean
	return mode ~= "hidden"
end

--- Put it on the line at a chosen bearing (the loop picks a spot the player can see).
function StalkerService.standAt(theta: number)
	angle = theta
	if config and mode ~= "hidden" then
		place(lineAt(angle), (config :: Config).origin())
	end
end

return StalkerService

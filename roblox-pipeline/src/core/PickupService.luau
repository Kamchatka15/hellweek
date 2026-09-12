-- PickupService — the burst, and picking things up off the floor.
--
-- This is the hook's machinery. Two decisions worth knowing:
--
-- 1. Pickups are real, server-owned physics parts (`SetNetworkOwner(nil)`). The flood
--    has to be filmable and it has to be authoritative; a client-side particle effect
--    is neither.
-- 2. Collection is a server-side proximity sweep, not a Touched event and not a remote.
--    There is no "I collected a coin" message to forge — the only thing a client
--    influences is where its character is standing.
--
-- Collision groups keep the burst cheap: pickups pass through each other and through
-- players, and only collide with the world. Without that, a few hundred tumbling parts
-- turn into an n-squared contact solve.

local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local PickupService = {}

local GROUP_PICKUP = "Pickup"
local GROUP_CHARACTER = "Character"
local SWEEP_INTERVAL = 0.06
local DEFAULT_MAX_ACTIVE = 420

export type BurstSpec = {
	count: number,
	value: number, -- value of each pickup
	lifetime: number,
	speed: number, -- outward speed
	lift: number, -- upward speed
	size: Vector3,
	color: Color3,
	material: Enum.Material?,
}

type Record = { part: BasePart, value: number, expires: number, fadeAt: number }

local active: { Record } = {}
local container: Folder? = nil
local maxActive = DEFAULT_MAX_ACTIVE
local radiusFor: ((Player) -> number)? = nil
local onCollect: ((Player, number) -> number)? = nil
local onBlocked: ((Player) -> ())? = nil
local started = false

local function ensureGroups()
	local ok = pcall(function()
		PhysicsService:RegisterCollisionGroup(GROUP_PICKUP)
	end)
	local ok2 = pcall(function()
		PhysicsService:RegisterCollisionGroup(GROUP_CHARACTER)
	end)
	-- Re-registering an existing group throws; that is fine and expected on rejoin.
	local _ = ok and ok2
	pcall(function()
		PhysicsService:CollisionGroupSetCollidable(GROUP_PICKUP, GROUP_PICKUP, false)
		PhysicsService:CollisionGroupSetCollidable(GROUP_PICKUP, GROUP_CHARACTER, false)
		PhysicsService:CollisionGroupSetCollidable(GROUP_PICKUP, "Default", true)
		PhysicsService:CollisionGroupSetCollidable(GROUP_CHARACTER, "Default", true)
	end)
end

local function tagCharacter(character: Model)
	for _, descendant in character:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.CollisionGroup = GROUP_CHARACTER
		end
	end
	character.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("BasePart") then
			descendant.CollisionGroup = GROUP_CHARACTER
		end
	end)
end

local function retire(index: number)
	local record = active[index]
	if record then
		record.part:Destroy()
	end
	-- Order does not matter, so swap-remove instead of shifting the whole array.
	local last = #active
	active[index] = active[last]
	active[last] = nil
end

local function sweep()
	local now = os.clock()

	-- Snapshot player positions once per sweep rather than per pickup.
	local sweepers: { { player: Player, position: Vector3, radiusSq: number } } = {}
	for _, player in Players:GetPlayers() do
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if root and humanoid and humanoid.Health > 0 then
			local radius = if radiusFor then radiusFor(player) else 8
			table.insert(sweepers, {
				player = player,
				position = (root :: BasePart).Position,
				radiusSq = radius * radius,
			})
		end
	end

	for index = #active, 1, -1 do
		local record = active[index]
		local part = record.part
		if not part.Parent then
			retire(index)
			continue
		end
		if now >= record.expires then
			retire(index)
			continue
		end
		if now >= record.fadeAt then
			part.Transparency = math.clamp((now - record.fadeAt) / (record.expires - record.fadeAt), 0, 1)
		end

		local position = part.Position
		for _, sweeper in sweepers do
			local offset = position - sweeper.position
			if offset:Dot(offset) <= sweeper.radiusSq then -- squared compare: no sqrt per pickup
				local accepted = if onCollect then onCollect(sweeper.player, record.value) else 0
				if accepted > 0 then
					retire(index)
				elseif onBlocked then
					onBlocked(sweeper.player)
				end
				break
			end
		end
	end
end

export type SetupOptions = {
	parent: Instance,
	radiusFor: (Player) -> number,
	onCollect: (Player, number) -> number, -- returns how much was accepted
	onBlocked: ((Player) -> ())?, -- called when a pickup was in range but refused
	maxActive: number?,
}

function PickupService.setup(options: SetupOptions)
	radiusFor = options.radiusFor
	onCollect = options.onCollect
	onBlocked = options.onBlocked
	maxActive = options.maxActive or DEFAULT_MAX_ACTIVE

	local folder = Instance.new("Folder")
	folder.Name = "Pickups"
	folder.Parent = options.parent
	container = folder

	ensureGroups()
	for _, player in Players:GetPlayers() do
		if player.Character then
			tagCharacter(player.Character)
		end
		player.CharacterAdded:Connect(tagCharacter)
	end
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(tagCharacter)
	end)

	if started then
		return
	end
	started = true

	local accumulator = 0
	RunService.Heartbeat:Connect(function(delta)
		accumulator += delta
		if accumulator < SWEEP_INTERVAL then
			return
		end
		accumulator = 0
		local ok, err = pcall(sweep)
		if not ok then
			warn(`[PickupService] sweep error: {err}`)
		end
	end)
end

--- Erupt `spec.count` pickups from `origin`. This is the two-second hook; everything
--- about it is tuned in the content pack.
function PickupService.burst(origin: CFrame, spec: BurstSpec)
	local parent = container
	if not parent then
		warn("[PickupService] burst before setup")
		return
	end

	-- Global cap protects the server from a crowd all standing on pads at once.
	local overflow = (#active + spec.count) - maxActive
	while overflow > 0 and #active > 0 do
		retire(1)
		overflow -= 1
	end

	local now = os.clock()
	local material = spec.material or Enum.Material.Neon

	for _ = 1, spec.count do
		local part = Instance.new("Part")
		part.Shape = Enum.PartType.Cylinder
		part.Size = spec.size
		part.Color = spec.color
		part.Material = material
		part.CollisionGroup = GROUP_PICKUP
		part.CanTouch = false -- nothing listens for Touched; do not pay for it
		part.CanQuery = false
		part.CastShadow = false
		part.CFrame = origin
			* CFrame.new(math.random(-20, 20) / 10, math.random(0, 20) / 10, math.random(-20, 20) / 10)
			* CFrame.Angles(math.random() * 6.28, math.random() * 6.28, math.random() * 6.28)
		part.Parent = parent

		pcall(function()
			part:SetNetworkOwner(nil) -- the server owns the flood, not whoever is nearest
		end)

		local angle = math.random() * math.pi * 2
		local outward = spec.speed * (0.35 + math.random() * 0.65)
		part.AssemblyLinearVelocity =
			Vector3.new(math.cos(angle) * outward, spec.lift * (0.7 + math.random() * 0.6), math.sin(angle) * outward)
		part.AssemblyAngularVelocity = Vector3.new(math.random(-12, 12), math.random(-12, 12), math.random(-12, 12))

		table.insert(active, {
			part = part,
			value = spec.value,
			expires = now + spec.lifetime,
			fadeAt = now + spec.lifetime - 1,
		})
	end
end

function PickupService.activeCount(): number
	return #active
end

return PickupService

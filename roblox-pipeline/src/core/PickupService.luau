-- PickupService — things on the floor that a player picks up by walking to them.
--
-- Two ways a pickup gets there:
--   burst(origin, spec)  — a physics eruption (the sweep-and-bank hook). Server-owned
--                          parts, tumbling, with a lifetime.
--   place(position, spec) — a static pickup (a gather loop's resource). Anchored, no
--                          lifetime, sits until collected or cleared.
--
-- Either way collection is the same server-side proximity sweep — not a Touched event
-- and not a remote. There is no "I collected this" message to forge; the only thing a
-- client influences is where its character is standing.
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

export type PlaceSpec = {
	value: number,
	size: Vector3,
	color: Color3,
	material: Enum.Material?,
	shape: Enum.PartType?,
	name: string?,
	meta: any?, -- passed back to onCollect untouched; the loop's own tags
	rotation: Vector3?, -- degrees
	decorate: ((BasePart) -> ())?, -- lights, labels, whatever the loop wants on it
}

type Record = { part: BasePart, value: number, expires: number, fadeAt: number, meta: any? }

local active: { Record } = {}
local container: Folder? = nil
local maxActive = DEFAULT_MAX_ACTIVE
local radiusFor: ((Player) -> number)? = nil
local onCollect: ((Player, number, any?) -> number)? = nil
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
				local accepted = if onCollect then onCollect(sweeper.player, record.value, record.meta) else 0
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
	onCollect: (Player, number, any?) -> number, -- returns how much was accepted
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

--- Put one static pickup on the floor. Anchored, no lifetime; it sits there until a
--- player walks into it or the loop clears the floor. Returns the part so the loop
--- can point at it (a nudge highlight, for instance).
function PickupService.place(position: Vector3, spec: PlaceSpec): BasePart?
	local parent = container
	if not parent then
		warn("[PickupService] place before setup")
		return nil
	end
	if #active >= maxActive then
		return nil
	end

	local part = Instance.new("Part")
	part.Name = spec.name or "Pickup"
	part.Shape = spec.shape or Enum.PartType.Block
	part.Size = spec.size
	part.Color = spec.color
	part.Material = spec.material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CollisionGroup = GROUP_PICKUP
	local rotation = spec.rotation or Vector3.new(0, math.random() * 360, 0)
	part.CFrame = CFrame.new(position) * CFrame.Angles(math.rad(rotation.X), math.rad(rotation.Y), math.rad(rotation.Z))
	if spec.decorate then
		spec.decorate(part)
	end
	part.Parent = parent

	table.insert(active, {
		part = part,
		value = spec.value,
		expires = math.huge,
		fadeAt = math.huge,
		meta = spec.meta,
	})
	return part
end

--- Remove every live pickup (a run reset, a new round).
function PickupService.clear()
	for index = #active, 1, -1 do
		retire(index)
	end
end

--- The live pickup nearest to a point, or nil. Used for onboarding nudges.
function PickupService.nearest(position: Vector3, filter: ((any?) -> boolean)?): BasePart?
	local best: BasePart? = nil
	local bestDistance = math.huge
	for _, record in active do
		if filter and not filter(record.meta) then
			continue
		end
		local distance = (record.part.Position - position).Magnitude
		if distance < bestDistance then
			bestDistance = distance
			best = record.part
		end
	end
	return best
end

function PickupService.activeCount(): number
	return #active
end

return PickupService

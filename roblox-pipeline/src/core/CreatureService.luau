-- CreatureService — things that are alive, that you can kill, and that are not the threat.
--
-- The distinction this service exists to hold:
--
--   PREY WITH TEETH  roams, bites back, dies to a held tool, drops materials
--   THE THREAT       cannot be killed, only held off  (that is StalkerService)
--
-- Keeping them apart is the whole design. A survive-the-night game whose night threat
-- can be put down stops having a night; but a world with nothing alive in it has no
-- reason for a tool to exist, which is why "what are the weapons" kept feeling like an
-- unanswerable question. The answer is that the weapon is the harvesting tool, and
-- what it harvests is sometimes looking back at you.
--
-- Eyes are a first-class feature, not decoration. In a navy night rather than a black
-- one, two glowing points low to the ground at forty studs is a complete sentence:
-- something is there, it is small, and it has noticed you. That reads before the body
-- does, and reading before seeing is what makes a creature feel alive.
--
-- Server-side. Positions are server-owned and the hit test is a server distance check,
-- so there is no client event to forge.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Shared = game:GetService("ReplicatedStorage").Shared
local Signal = require(Shared.Signal)

local CreatureService = {}

CreatureService.killed = Signal.new() -- (record, player, drops)
CreatureService.bit = Signal.new() -- (record, player)

export type CreatureDef = {
	id: string,
	label: string,
	parts: { any }, -- body part specs, positions RELATIVE to the creature's origin
	eyes: { -- the readable-at-distance signature
		offsets: { Vector3 },
		color: Color3,
		size: number?,
		brightness: number?,
		range: number?,
	}?,
	health: number, -- hits from a tool, not a damage number; kids count swings
	speed: number, -- studs/second while closing
	nightSpeed: number?, -- bolder after dark
	noticeRadius: number, -- how far it notices a player
	nightNoticeRadius: number?,
	biteRadius: number,
	biteCooldown: number?,
	wander: number?, -- studs it drifts around its home point when idle
	drops: { [string]: number },
	shy: boolean?, -- true: flees when struck instead of closing (the A4 escape hatch)
}

export type Record = {
	def: CreatureDef,
	model: Model,
	home: Vector3,
	position: Vector3,
	health: number,
	target: Player?,
	nextBite: number,
	drift: Vector3,
	nextDrift: number,
}

local defs: { [string]: CreatureDef } = {}
local records: { Record } = {}
local root: Instance? = nil
local blockFn: ((any, Instance) -> BasePart)? = nil
local isNight: (() -> boolean)? = nil
local safeAt: ((Vector3) -> boolean)? = nil
local connection: RBXScriptConnection? = nil

local function flat(a: Vector3, b: Vector3): number
	return Vector3.new(a.X - b.X, 0, a.Z - b.Z).Magnitude
end

local function rootPosition(player: Player): Vector3?
	local character = player.Character
	local part = character and character:FindFirstChild("HumanoidRootPart")
	return part and (part :: BasePart).Position or nil
end

function CreatureService.configure(
	list: { CreatureDef },
	options: {
		parent: Instance,
		block: (any, Instance) -> BasePart,
		isNight: (() -> boolean)?,
		safeAt: ((Vector3) -> boolean)?, -- creatures will not enter a safe island
	}
)
	defs = {}
	for _, def in list do
		defs[def.id] = def
	end
	root = options.parent
	blockFn = options.block
	isNight = options.isNight
	safeAt = options.safeAt
	if not connection then
		connection = RunService.Heartbeat:Connect(function(delta)
			local ok, err = pcall(CreatureService.tick, delta)
			if not ok then
				warn(`[CreatureService] tick error: {err}`)
			end
		end)
	end
end

function CreatureService.definition(id: string): CreatureDef?
	return defs[id]
end

function CreatureService.all(): { Record }
	return records
end

function CreatureService.count(): number
	return #records
end

local function buildEyes(def: CreatureDef, model: Model, origin: Vector3)
	local eyes = def.eyes
	if not eyes then
		return
	end
	for index, offset in eyes.offsets do
		local eye = Instance.new("Part")
		eye.Name = `Eye{index}`
		eye.Anchored = true
		eye.CanCollide = false
		eye.CanTouch = false
		eye.CastShadow = false
		eye.Shape = Enum.PartType.Ball
		eye.Size = Vector3.one * (eyes.size or 0.45)
		eye.Position = origin + offset
		eye.Color = eyes.color
		eye.Material = Enum.Material.Neon
		-- The glow is what carries at distance. A neon ball alone reads as a dot in
		-- daylight and vanishes at night; the light is what makes it an EYE.
		local glow = Instance.new("PointLight")
		glow.Name = "EyeGlow"
		glow.Color = eyes.color
		glow.Brightness = eyes.brightness or 2.2
		glow.Range = eyes.range or 11
		glow.Shadows = false
		glow.Parent = eye
		eye.Parent = model
	end
end

function CreatureService.spawn(id: string, position: Vector3): Record?
	local def = defs[id]
	local parent = root
	local build = blockFn
	if not def or not parent or not build then
		return nil
	end

	local model = Instance.new("Model")
	model.Name = `Creature_{def.id}_{#records + 1}`
	for _, spec in def.parts do
		local copy = table.clone(spec)
		copy.position = position + (spec.position or Vector3.zero)
		copy.canCollide = false
		build(copy, model)
	end
	buildEyes(def, model, position)
	local primary = model:FindFirstChildWhichIsA("BasePart")
	if primary then
		model.PrimaryPart = primary
	end
	model.Parent = parent

	local record: Record = {
		def = def,
		model = model,
		home = position,
		position = position,
		health = def.health,
		target = nil,
		nextBite = 0,
		drift = Vector3.zero,
		nextDrift = 0,
	}
	table.insert(records, record)
	return record
end

--- Move the whole creature, eyes included, and face it where it is going.
local function place(record: Record, position: Vector3, facing: Vector3?)
	local model = record.model
	if not model or not model.PrimaryPart then
		return
	end
	local look = facing and Vector3.new(facing.X, position.Y, facing.Z) or nil
	local cf = if look and (look - position).Magnitude > 0.01
		then CFrame.lookAt(position, look)
		else CFrame.new(position)
	model:PivotTo(cf)
	record.position = position
end

--- The creature nearest this point within `range`, so the loop can answer "what am I
--- about to swing at" without the client ever naming a target.
function CreatureService.nearest(position: Vector3, range: number): Record?
	local best: Record? = nil
	local bestDistance = range
	for _, record in records do
		local distance = flat(record.position, position)
		if distance <= bestDistance then
			bestDistance = distance
			best = record
		end
	end
	return best
end

--- Hit it. `power` is swings, not damage: a kid counts swings, not hit points.
--- Returns true if this blow killed it.
function CreatureService.strike(record: Record, player: Player, power: number?): boolean
	record.health -= (power or 1)
	if record.def.shy then
		-- A shy creature turns and runs rather than closing. This is the escape hatch
		-- if killable prey ever makes the unkillable threat read as a bug.
		record.target = nil
		local from = rootPosition(player)
		local away = if from
			then Vector3.new(record.position.X - from.X, 0, record.position.Z - from.Z)
			else Vector3.zero
		local heading = if away.Magnitude > 0.01 then away.Unit else Vector3.zAxis
		record.home = record.position + heading * 40
	end
	if record.health > 0 then
		return false
	end
	local drops = record.def.drops
	CreatureService.killed:fire(record, player, drops)
	CreatureService.despawn(record)
	return true
end

function CreatureService.despawn(record: Record)
	for index, candidate in records do
		if candidate == record then
			table.remove(records, index)
			break
		end
	end
	if record.model then
		record.model:Destroy()
	end
end

function CreatureService.clear()
	for _, record in records do
		if record.model then
			record.model:Destroy()
		end
	end
	records = {}
end

local function nearestPlayerTo(record: Record, radius: number): (Player?, Vector3?)
	local best: Player? = nil
	local bestPosition: Vector3? = nil
	local bestDistance = radius
	for _, player in Players:GetPlayers() do
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then
			continue
		end
		local position = rootPosition(player)
		if not position then
			continue
		end
		-- It will not come into a lit island. The light is the rule for everything
		-- that hunts here, not a special case for the stalker.
		if safeAt and safeAt(position) then
			continue
		end
		local distance = flat(record.position, position)
		if distance <= bestDistance then
			bestDistance = distance
			best = player
			bestPosition = position
		end
	end
	return best, bestPosition
end

function CreatureService.tick(delta: number)
	local night = if isNight then isNight() else false
	local now = os.clock()

	for _, record in records do
		local def = record.def
		local notice = if night then (def.nightNoticeRadius or def.noticeRadius) else def.noticeRadius
		local speed = if night then (def.nightSpeed or def.speed) else def.speed

		local target, targetPosition = nearestPlayerTo(record, notice)
		record.target = target

		if target and targetPosition then
			local toTarget = Vector3.new(targetPosition.X - record.position.X, 0, targetPosition.Z - record.position.Z)
			local distance = toTarget.Magnitude
			if distance > def.biteRadius then
				local step = if distance > 0.01 then toTarget.Unit * speed * delta else Vector3.zero
				place(record, record.position + step, targetPosition)
			else
				place(record, record.position, targetPosition)
				if now >= record.nextBite then
					record.nextBite = now + (def.biteCooldown or 2)
					CreatureService.bit:fire(record, target)
				end
			end
			continue
		end

		-- Idle: drift around home so the world is never still. A creature standing
		-- perfectly still reads as a prop, and a prop is not worth being wary of.
		if now >= record.nextDrift then
			record.nextDrift = now + math.random(2, 5)
			local theta = math.random() * math.pi * 2
			local reach = (def.wander or 14) * (0.3 + math.random() * 0.7)
			local goal = record.home + Vector3.new(math.cos(theta) * reach, 0, math.sin(theta) * reach)
			record.drift = goal
		end
		local toDrift = Vector3.new(record.drift.X - record.position.X, 0, record.drift.Z - record.position.Z)
		if toDrift.Magnitude > 0.6 then
			local step = toDrift.Unit * (speed * 0.4) * delta
			place(record, record.position + step, record.drift)
		end
	end
end

function CreatureService.start()
	Players.PlayerRemoving:Connect(function(player)
		for _, record in records do
			if record.target == player then
				record.target = nil
			end
		end
	end)
end

return CreatureService

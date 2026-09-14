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
CreatureService.arrived = Signal.new() -- (record) — a besieger reached what it wanted
CreatureService.drivenOff = Signal.new() -- (record, player)

export type CreatureDef = {
	id: string,
	label: string,
	parts: { any }, -- body part specs, positions RELATIVE to the creature's origin
	-- Optional: the name of a Model or MeshPart sitting in the templates folder. When
	-- one is found it REPLACES `parts` as the body, and the eyes are still built on
	-- top so the night signature works either way.
	--
	-- This is how an imported mesh lands with no code change. `MeshPart.MeshId` is not
	-- settable at runtime, so the durable path is always: import once, keep the
	-- instance in the tree, clone it. `parts` stays as the blockout that behaviour was
	-- tuned against, and as the fallback if the template is ever missing.
	template: string?,
	templateScale: number?,
	templateYOffset: number?,
	-- Degrees to spin an imported body about its own vertical axis.
	--
	-- Roblox's front is -Z, and CFrame.lookAt points -Z at the target. A body authored
	-- facing +Z therefore walks backwards: the root is oriented correctly, the geometry
	-- inside it is not. 180 turns such a body round. Nothing else needs to change.
	templateYaw: number?,
	eyes: { -- the readable-at-distance signature
		offsets: { Vector3 },
		color: Color3,
		size: number?,
		brightness: number?,
		range: number?,
		-- Night is a different creature. When these are set the eyes change colour
		-- and burn harder after dark, so the thing you walked past in daylight is
		-- the thing you can see coming from the far side of the map at night.
		nightColor: Color3?,
		nightBrightness: number?,
		nightRange: number?,
		-- Which part the eyes belong to. Offsets are read in THAT part's local space,
		-- so the same numbers work for an imported mesh and for the blockout. Without
		-- this the eyes stay anchored where the creature spawned and the body walks
		-- out from under them.
		attach: string?,
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

	-- A RIG. Parts joined by Motor6D instead of welded solid, so limbs can rotate
	-- relative to each other. Without this nothing can ever animate, and a creature
	-- that slides across the ground reads as a prop no matter how well it is modelled.
	-- Only the root is anchored; everything else hangs off joints.
	rig: {
		root: string, -- part name that the service moves
		joints: { { part: string, to: string } },
	}?,

	-- A GAIT. Procedural animation, driven from code, needing no uploaded Animation
	-- asset and therefore no human upload click. Each limb is a sine wave on one axis
	-- with its own phase, which is all a walk cycle actually is.
	gait: {
		period: number, -- seconds per full stride
		limbs: { { part: string, axis: string?, amplitude: number, phase: number } },
		bob: number?, -- studs the body rises and falls
		sway: number?, -- degrees of roll
		idle: number?, -- fraction of amplitude used while standing still
	}?,

	-- A creature that wants something OTHER than the player. The loop supplies the
	-- point; the creature walks to it and never deviates. This is what makes a siege
	-- different from a chase: it is not coming for you, it is coming for your fire,
	-- and ignoring it is the one thing you cannot do.
	goalRadius: number?, -- how close counts as arrived
	boss: boolean?, -- struck to zero it RETREATS rather than dying
	retreatFor: number?, -- seconds it stays away after being driven off
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
	eyeParts: { BasePart },
	litForNight: boolean,
	rootPart: BasePart?,
	joints: { [string]: Motor6D },
	baseC0: { [string]: CFrame },
	gaitClock: number,
	-- How far the root part sits above the body's lowest point. place() moves the root
	-- and everything else hangs off it, so without this an 18-stud creature spawned at
	-- ground level stands with its feet nine studs under the sand.
	rootLift: number,
	bob: number,
	retreatUntil: number,
	driving: boolean, -- true while walking a goal rather than hunting a player
}

local defs: { [string]: CreatureDef } = {}
local records: { Record } = {}
local root: Instance? = nil
local blockFn: ((any, Instance) -> BasePart)? = nil
local isNight: (() -> boolean)? = nil
local templates: Instance? = nil
local safeAt: ((Vector3) -> boolean)? = nil
local goalFor: ((any) -> Vector3?)? = nil
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
	goalFor = options.goalFor
	templates = options.templates
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

--- Find a part by a loose name. Generated and imported bodies name their pieces in
--- whatever style the exporter felt like, so "left arm" has to match "LeftArm",
--- "Left Arm" and "left_arm" without the pack having to care.
local function findPart(model: Instance, name: string): BasePart?
	local wanted = string.lower(string.gsub(name, "[%s_%-]", ""))
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") then
			local got = string.lower(string.gsub(d.Name, "[%s_%-]", ""))
			if got == wanted then
				return d
			end
		end
	end
	-- second pass: substring, so "LeftArm_1" still matches
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") then
			local got = string.lower(string.gsub(d.Name, "[%s_%-]", ""))
			if string.find(got, wanted, 1, true) then
				return d
			end
		end
	end
	return nil
end

--- Join the body with Motor6D so it can move. Only the root stays anchored; every
--- other part is released and held in place by its joint, which is the whole reason
--- a rig animates and a weld does not.
local function buildRig(def: CreatureDef, model: Model): (BasePart?, { [string]: Motor6D }, { [string]: CFrame })
	local joints: { [string]: Motor6D } = {}
	local baseC0: { [string]: CFrame } = {}
	local spec = def.rig
	if not spec then
		return nil, joints, baseC0
	end
	local rootPart = findPart(model, spec.root)
	if not rootPart then
		warn(`[CreatureService] rig root '{spec.root}' not found on {def.id}; staying welded`)
		return nil, joints, baseC0
	end

	rootPart.Anchored = true
	for _, joint in spec.joints do
		local child = findPart(model, joint.part)
		local parent = findPart(model, joint.to)
		if not child or not parent then
			warn(`[CreatureService] joint {joint.part} -> {joint.to} missing on {def.id}`)
			continue
		end
		child.Anchored = false
		child.CanCollide = false
		child.Massless = true
		local motor = Instance.new("Motor6D")
		motor.Name = joint.part
		motor.Part0 = parent
		motor.Part1 = child
		-- C0/C1 are set from where the parts already sit, so the rig adopts the pose
		-- the body was authored in rather than snapping to an origin.
		motor.C0 = parent.CFrame:ToObjectSpace(child.CFrame)
		motor.C1 = CFrame.new()
		motor.Parent = parent
		joints[joint.part] = motor
		baseC0[joint.part] = motor.C0
	end
	return rootPart, joints, baseC0
end

--- Drive the rig. A walk cycle is a set of sine waves with different phases, and that
--- is all this does. No uploaded Animation asset, so no human upload click.
local function animate(record: Record, delta: number, moving: boolean)
	local gait = record.def.gait
	if not gait or not next(record.joints) then
		return
	end
	local scale = if moving then 1 else (gait.idle or 0.18)
	record.gaitClock += delta * (if moving then 1 else 0.45)
	local period = math.max(gait.period, 0.05)
	local turn = (record.gaitClock / period) % 1

	for _, limb in gait.limbs do
		local motor = record.joints[limb.part]
		local base = record.baseC0[limb.part]
		if not motor or not base then
			continue
		end
		local theta = (turn + limb.phase) % 1 * math.pi * 2
		local angle = math.rad(limb.amplitude * scale) * math.sin(theta)
		local axis = limb.axis or "X"
		local rot = if axis == "Y"
			then CFrame.Angles(0, angle, 0)
			elseif axis == "Z" then CFrame.Angles(0, 0, angle)
			else CFrame.Angles(angle, 0, 0)
		motor.C0 = base * rot
	end

	-- The body rises on the stride. Always UP, never down: a signed sine pushed the
	-- feet below the sand on every other step. abs() also happens to be how a real
	-- walk bob works — you rise on each foot, twice per stride.
	record.bob = (gait.bob or 0) * scale * math.abs(math.sin(turn * math.pi * 2))
end

local function buildEyes(def: CreatureDef, model: Model, origin: Vector3): { BasePart }
	local made: { BasePart } = {}
	local eyes = def.eyes
	if not eyes then
		return made
	end
	-- Anchor the eyes to a body part when one is named, reading the offsets in that
	-- part's local space. Falls back to world space off the spawn point.
	local host: BasePart? = if eyes.attach then findPart(model, eyes.attach) else nil
	for index, offset in eyes.offsets do
		local eye = Instance.new("Part")
		eye.Name = `Eye{index}`
		eye.Anchored = true
		eye.CanCollide = false
		eye.CanTouch = false
		eye.CastShadow = false
		eye.Shape = Enum.PartType.Ball
		eye.Size = Vector3.one * (eyes.size or 0.45)
		if host then
			eye.CFrame = host.CFrame * CFrame.new(offset)
		else
			eye.Position = origin + offset
		end
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
		-- Only a RIGGED creature needs this. A rigged body is moved by its anchored
		-- root alone, so an anchored eye would be left standing where the thing
		-- spawned while the body walks out from under it. An unrigged body is moved
		-- whole by PivotTo and its eyes are already carried along.
		if host and def.rig then
			eye.Anchored = false
			eye.Massless = true
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = host
			weld.Part1 = eye
			weld.Parent = eye
		end
		table.insert(made, eye)
	end
	return made
end

--- Repaint a creature's eyes for the current half of the day.
local function paintEyes(record: Record, night: boolean)
	local eyes = record.def.eyes
	if not eyes or record.litForNight == night then
		return
	end
	record.litForNight = night
	local colour = if night and eyes.nightColor then eyes.nightColor else eyes.color
	local bright = if night then (eyes.nightBrightness or eyes.brightness or 2.2) else (eyes.brightness or 2.2)
	local range = if night then (eyes.nightRange or eyes.range or 11) else (eyes.range or 11)
	for _, eye in record.eyeParts do
		eye.Color = colour
		local glow = eye:FindFirstChild("EyeGlow")
		if glow and glow:IsA("PointLight") then
			glow.Color = colour
			glow.Brightness = bright
			glow.Range = range
		end
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

	local body: Instance? = nil
	if def.template and templates then
		local source = templates:FindFirstChild(def.template)
		if source then
			body = source:Clone()
		end
	end

	if body then
		-- An imported body. Anchor everything, drop collision, and stand it on the spot.
		for _, d in body:GetDescendants() do
			if d:IsA("BasePart") then
				d.Anchored = true
				d.CanCollide = false
				d.CanTouch = false
			end
		end
		if body:IsA("BasePart") then
			body.Anchored = true
			body.CanCollide = false
			body.CanTouch = false
		end
		body.Parent = model
		local lift = def.templateYOffset or 0
		if body:IsA("Model") then
			if not body.PrimaryPart then
				body.PrimaryPart = body:FindFirstChildWhichIsA("BasePart")
			end
			if body.PrimaryPart then
				body:PivotTo(CFrame.new(position + Vector3.new(0, lift, 0)))
			end
		elseif body:IsA("BasePart") then
			body.Position = position + Vector3.new(0, lift + body.Size.Y / 2, 0)
		end
	else
		for _, spec in def.parts do
			local copy = table.clone(spec)
			copy.position = position + (spec.position or Vector3.zero)
			copy.canCollide = false
			build(copy, model)
		end
	end

	local eyeParts = buildEyes(def, model, position)
	local rootPart, joints, baseC0 = buildRig(def, model)

	-- Measure the root's height above the feet BEFORE anything starts moving it.
	local rootLift = 0
	if rootPart then
		local lowest = math.huge
		for _, d in model:GetDescendants() do
			if d:IsA("BasePart") and string.sub(d.Name, 1, 3) ~= "Eye" then
				lowest = math.min(lowest, d.Position.Y - d.Size.Y / 2)
			end
		end
		if lowest < math.huge then
			rootLift = rootPart.Position.Y - lowest
		end
	end
	local primary = rootPart or model:FindFirstChildWhichIsA("BasePart")
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
		eyeParts = eyeParts,
		litForNight = false,
		rootPart = rootPart,
		joints = joints,
		baseC0 = baseC0,
		gaitClock = math.random() * 4,
		rootLift = rootLift,
		bob = 0,
		retreatUntil = 0,
		driving = false,
	}
	table.insert(records, record)
	paintEyes(record, if isNight then isNight() else false)
	return record
end

--- Move the whole creature, eyes included, and face it where it is going.
local function place(record: Record, position: Vector3, facing: Vector3?)
	local model = record.model
	if not model or not model.PrimaryPart then
		return
	end
	local lifted = position + Vector3.new(0, record.rootLift + record.bob, 0)
	local look = facing and Vector3.new(facing.X, lifted.Y, facing.Z) or nil
	local cf = if look and (look - lifted).Magnitude > 0.01 then CFrame.lookAt(lifted, look) else CFrame.new(lifted)
	-- Roblox's front is -Z and lookAt points -Z at the target, so a body authored
	-- facing +Z walks backwards with its root pointed correctly. Correct it HERE,
	-- where orientation is actually decided. Spinning the body once at spawn is a
	-- no-op: this line overwrites the root every frame and the rig follows it.
	local yaw = record.def.templateYaw
	if yaw and yaw ~= 0 then
		cf = cf * CFrame.Angles(0, math.rad(yaw), 0)
	end
	if record.rootPart then
		-- Rigged: move ONLY the anchored root. Every other part is unanchored and is
		-- carried by its Motor6D, which is what lets the limbs animate at all.
		record.rootPart.CFrame = cf
	else
		model:PivotTo(cf)
	end
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
	-- Already walking away. Hitting it again should not reset the clock or fire a
	-- second driven-off line; it is leaving, and the player has won this round.
	if record.retreatUntil > os.clock() then
		return false
	end
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

	-- A boss is not killed, it is DRIVEN OFF. It walks away, waits, and comes back,
	-- which is a better threat than a corpse: the run never gets safe, it only gets
	-- quiet. It also means the fight can be lost without the run being over.
	if record.def.boss then
		record.health = record.def.health
		record.retreatUntil = os.clock() + (record.def.retreatFor or 45)
		record.target = nil
		record.driving = false
		CreatureService.drivenOff:fire(record, player)
		return true
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
		paintEyes(record, night)
		local notice = if night then (def.nightNoticeRadius or def.noticeRadius) else def.noticeRadius
		local speed = if night then (def.nightSpeed or def.speed) else def.speed

		-- Driven off. It withdraws to its home and waits, which is worse than dying,
		-- because you know it is coming back and you know roughly when.
		if record.retreatUntil > now then
			record.driving = false
			local away = Vector3.new(record.home.X - record.position.X, 0, record.home.Z - record.position.Z)
			local walking = away.Magnitude > 2
			if walking then
				place(record, record.position + away.Unit * speed * delta, record.home)
			end
			animate(record, delta, walking)
			continue
		end

		-- A siege. It is not coming for you, it is coming for your fire, and that is
		-- the whole difference: you cannot solve it by standing still or running away.
		local goalPoint = if goalFor then goalFor(record) else nil
		if goalPoint then
			record.driving = true
			record.target = nil
			local toGoal = Vector3.new(goalPoint.X - record.position.X, 0, goalPoint.Z - record.position.Z)
			local reach = def.goalRadius or 8
			if toGoal.Magnitude > reach then
				place(record, record.position + toGoal.Unit * speed * delta, goalPoint)
				animate(record, delta, true)
			else
				place(record, record.position, goalPoint)
				animate(record, delta, false)
				if now >= record.nextBite then
					record.nextBite = now + (def.biteCooldown or 2)
					CreatureService.arrived:fire(record)
				end
			end
			continue
		end
		record.driving = false

		local target, targetPosition = nearestPlayerTo(record, notice)
		record.target = target

		if target and targetPosition then
			local toTarget = Vector3.new(targetPosition.X - record.position.X, 0, targetPosition.Z - record.position.Z)
			local distance = toTarget.Magnitude
			if distance > def.biteRadius then
				local step = if distance > 0.01 then toTarget.Unit * speed * delta else Vector3.zero
				place(record, record.position + step, targetPosition)
				animate(record, delta, true)
			else
				place(record, record.position, targetPosition)
				animate(record, delta, false)
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
		local wandering = toDrift.Magnitude > 0.6
		if wandering then
			local step = toDrift.Unit * (speed * 0.4) * delta
			place(record, record.position + step, record.drift)
		end
		animate(record, delta, wandering)
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

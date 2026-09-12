-- BuildService — things the player makes and leaves standing in the world.
--
-- The camp. A ten-year-old described the genre's real structure in one sentence:
-- "he enjoys building his camp up on day one, so he can later explore." The camp is
-- not decoration and it is not a reward. It is a RANGE EXTENDER: every piece exists
-- to remove one specific reason you currently have to turn around and walk home.
--
-- So the engine knows five verbs, and each maps to a reason you had to go back:
--
--   `store`    you could only carry a few things     -> a drop point in the field
--   `light`    you could not see out there           -> a second island of light
--   `ward`     the night threat was between you and home -> it is pushed back here
--   `convert`  raw material was dead weight          -> it ripens while you are away
--   `mark`     you could not tell where safe ended   -> a line drawn on the ground
--
-- `convert` is the one that matters most and is easiest to miss: it makes time spent
-- AWAY from the camp productive, which is the only reason to come back that is not
-- fear. Fear alone makes a base feel like a bunker.
--
-- Everything is server-side. The client asks "build here"; the server decides what is
-- affordable, whether the spot is legal, and what actually appears. A forged message
-- can ask to build; it cannot say what, where, or for free.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Shared = game:GetService("ReplicatedStorage").Shared
local Signal = require(Shared.Signal)

local BuildService = {}

BuildService.placed = Signal.new() -- (record)
BuildService.removed = Signal.new() -- (record)
BuildService.converted = Signal.new() -- (record, producedKind, count)

export type Effect = "store" | "light" | "ward" | "convert" | "mark"

export type PieceDef = {
	id: string,
	label: string,
	blurb: string?, -- one line for the build menu; says what it BUYS you, not what it is
	cost: { [string]: number }, -- item kind -> count, taken from the sack
	effect: Effect?,
	radius: number?, -- ward: hold-off distance. light: glow range. mark: ring radius
	capacity: number?, -- store: how many items it holds
	input: string?, -- convert: the raw kind it eats
	output: string?, -- convert: the kind it produces
	every: number?, -- convert: seconds per unit
	batch: number?, -- convert: units produced per tick (default 1)
	parts: { any }, -- part specs, positions RELATIVE to the placement point
	drag: boolean?, -- true if this piece is drag-class rather than carried
	near: number?, -- must be placed within this distance of the anchor, if the loop sets one
	away: number?, -- ...and no closer than this, so the camp does not pile onto the anchor
	limit: number?, -- how many of this piece may stand at once
}

export type Record = {
	id: string,
	def: PieceDef,
	model: Model,
	position: Vector3,
	owner: Player?,
	held: { [string]: number }, -- store: what is inside. convert: what is ripening
	ready: { [string]: number }, -- convert: what has finished and is waiting
	clock: number, -- convert: seconds banked toward the next unit
}

local defs: { [string]: PieceDef } = {}
local records: { Record } = {}
local root: Instance? = nil
local anchor: (() -> Vector3)? = nil
local blockFn: ((any, Instance) -> BasePart)? = nil
local connection: RBXScriptConnection? = nil

local function flatDistanceBetween(a: Vector3, b: Vector3): number
	return Vector3.new(a.X - b.X, 0, a.Z - b.Z).Magnitude
end

--- The pack supplies the catalogue; the engine supplies the verbs. `block` is the
--- part builder (ContentLoader.block) so this service never learns what a part is.
function BuildService.configure(
	list: { PieceDef },
	options: {
		parent: Instance,
		block: (any, Instance) -> BasePart,
		anchor: (() -> Vector3)?,
	}
)
	defs = {}
	for _, def in list do
		defs[def.id] = def
	end
	root = options.parent
	blockFn = options.block
	anchor = options.anchor
	if not connection then
		connection = RunService.Heartbeat:Connect(function(delta)
			local ok, err = pcall(BuildService.tick, delta)
			if not ok then
				warn(`[BuildService] tick error: {err}`)
			end
		end)
	end
end

function BuildService.definition(id: string): PieceDef?
	return defs[id]
end

function BuildService.catalogue(): { PieceDef }
	local list = {}
	for _, def in defs do
		table.insert(list, def)
	end
	table.sort(list, function(a, b)
		return a.id < b.id
	end)
	return list
end

function BuildService.all(): { Record }
	return records
end

function BuildService.countOf(id: string): number
	local n = 0
	for _, record in records do
		if record.id == id then
			n += 1
		end
	end
	return n
end

--- Is this a legal spot? Returns false plus a reason the loop can put in a toast.
--- The reason is written for a player, not for a log.
function BuildService.canPlace(id: string, position: Vector3): (boolean, string?)
	local def = defs[id]
	if not def then
		return false, "You cannot build that."
	end
	if def.limit and BuildService.countOf(id) >= def.limit then
		return false, `You already have as many as you can keep.`
	end
	if anchor then
		local origin = anchor()
		local flat = Vector3.new(position.X - origin.X, 0, position.Z - origin.Z).Magnitude
		if def.near and flat > def.near then
			return false, "Too far from the obelisk to build."
		end
		if def.away and flat < def.away then
			return false, "Too close to the obelisk to build."
		end
	end
	-- Do not let pieces stack on top of each other. Two braziers in the same spot is
	-- twice the cost for one island of light, which reads as the game cheating you.
	for _, record in records do
		if flatDistanceBetween(record.position, position) < 6 then
			return false, "Something is already standing there."
		end
	end
	return true
end

--- Put the piece in the world. The caller has already taken the cost; this only
--- builds. Returns the record so the loop can hang run state off it.
function BuildService.place(id: string, position: Vector3, owner: Player?): Record?
	local def = defs[id]
	local parent = root
	local build = blockFn
	if not def or not parent or not build then
		return nil
	end

	local model = Instance.new("Model")
	model.Name = `Built_{def.id}_{#records + 1}`
	for _, spec in def.parts do
		local copy = table.clone(spec)
		copy.position = position + (spec.position or Vector3.zero)
		if spec.cframe then
			copy.cframe = spec.cframe + position
		end
		build(copy, model)
	end
	local primary = model:FindFirstChildWhichIsA("BasePart")
	if primary then
		model.PrimaryPart = primary
	end
	model.Parent = parent

	local record: Record = {
		id = def.id,
		def = def,
		model = model,
		position = position,
		owner = owner,
		held = {},
		ready = {},
		clock = 0,
	}
	table.insert(records, record)
	BuildService.placed:fire(record)
	return record
end

function BuildService.remove(record: Record)
	for index, candidate in records do
		if candidate == record then
			table.remove(records, index)
			break
		end
	end
	if record.model then
		record.model:Destroy()
	end
	BuildService.removed:fire(record)
end

--- Every run starts with bare ground. The camp is a within-run achievement, exactly
--- like the carry cap and the tools; what survives a run is decided elsewhere.
function BuildService.clear()
	for _, record in records do
		if record.model then
			record.model:Destroy()
		end
	end
	records = {}
end

--- Nearest piece with this effect, within `range`. The loop uses it for "what am I
--- standing next to" so a player never has to aim at anything.
function BuildService.nearest(position: Vector3, effect: Effect?, range: number?): Record?
	local best: Record? = nil
	local bestDistance = range or math.huge
	for _, record in records do
		if effect and record.def.effect ~= effect then
			continue
		end
		local distance = flatDistanceBetween(record.position, position)
		if distance <= bestDistance then
			bestDistance = distance
			best = record
		end
	end
	return best
end

--- How far the camp holds the threat off a point. Wards do not stack: standing in two
--- overlapping wards gives you the better one, not the sum. Stacking would let a
--- player wall the night out entirely, and a night you can switch off is not a night.
function BuildService.wardRadiusAt(position: Vector3): number
	local best = 0
	for _, record in records do
		local def = record.def
		if def.effect ~= "ward" or not def.radius then
			continue
		end
		if flatDistanceBetween(record.position, position) <= def.radius then
			best = math.max(best, def.radius)
		end
	end
	return best
end

--- Is this point inside any built island of light? Used for the same judgement the
--- beacon makes, so a brazier genuinely is a second safe place rather than a prop.
function BuildService.litAt(position: Vector3): boolean
	for _, record in records do
		local def = record.def
		if def.effect == "light" and def.radius then
			if flatDistanceBetween(record.position, position) <= def.radius then
				return true
			end
		end
	end
	return false
end

--- Put something into a store or a converter. Returns how many were accepted, so the
--- loop can put the remainder back rather than silently eating it.
function BuildService.deposit(record: Record, kind: string, count: number): number
	local def = record.def
	if def.effect == "store" then
		local used = 0
		for _, held in record.held do
			used += held
		end
		local room = math.max((def.capacity or 0) - used, 0)
		local taken = math.min(room, count)
		if taken > 0 then
			record.held[kind] = (record.held[kind] or 0) + taken
		end
		return taken
	end
	if def.effect == "convert" then
		if def.input and def.input ~= kind then
			return 0
		end
		local used = 0
		for _, held in record.held do
			used += held
		end
		local room = math.max((def.capacity or 0) - used, 0)
		local taken = math.min(room, count)
		if taken > 0 then
			record.held[kind] = (record.held[kind] or 0) + taken
		end
		return taken
	end
	return 0
end

--- Take everything out. Stores hand back what was put in; converters hand back what
--- has finished and keep what is still ripening, which is what makes checking on it
--- worth doing rather than a chore you do once.
function BuildService.withdraw(record: Record): { [string]: number }
	local out: { [string]: number } = {}
	if record.def.effect == "store" then
		for kind, count in record.held do
			out[kind] = count
		end
		record.held = {}
	elseif record.def.effect == "convert" then
		for kind, count in record.ready do
			out[kind] = count
		end
		record.ready = {}
	end
	return out
end

--- How many finished units are waiting, for the label above a converter.
function BuildService.readyCount(record: Record): number
	local n = 0
	for _, count in record.ready do
		n += count
	end
	return n
end

function BuildService.heldCount(record: Record): number
	local n = 0
	for _, count in record.held do
		n += count
	end
	return n
end

--- Advance every converter. Runs whether or not anyone is watching, which is the
--- entire point: the camp works while you are somewhere else.
function BuildService.tick(delta: number)
	for _, record in records do
		local def = record.def
		if def.effect ~= "convert" or not def.every or not def.output then
			continue
		end
		if BuildService.heldCount(record) <= 0 then
			record.clock = 0
			continue
		end
		record.clock += delta
		while record.clock >= def.every do
			record.clock -= def.every
			local input = def.input
			local available = if input then (record.held[input] or 0) else BuildService.heldCount(record)
			if available <= 0 then
				record.clock = 0
				break
			end
			if input then
				record.held[input] = available - 1
				if record.held[input] <= 0 then
					record.held[input] = nil
				end
			end
			local made = def.batch or 1
			record.ready[def.output] = (record.ready[def.output] or 0) + made
			BuildService.converted:fire(record, def.output, made)
		end
	end
end

function BuildService.start()
	Players.PlayerRemoving:Connect(function(player)
		for _, record in records do
			if record.owner == player then
				record.owner = nil
			end
		end
	end)
end

return BuildService

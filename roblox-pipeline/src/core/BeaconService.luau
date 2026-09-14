-- BeaconService — one shared, server-owned resource with a radius.
--
-- A campfire, a generator, a shrine, a wick: players feed it, it burns down, and its
-- level decides how big the safe circle is. That shape is generic to every
-- survive-the-night game, so it lives here. The pack supplies the numbers (radius
-- formula, cap, level thresholds) and the look (the part it lights, the flame).
--
-- Fuel is a server number. It is never sent from a client and there is no remote that
-- touches it: feeding is a zone entry the server detects (R1, R2).

local Shared = game:GetService("ReplicatedStorage").Shared
local Signal = require(Shared.Signal)

local BeaconService = {}

BeaconService.changed = Signal.new() -- (fuel, radius)
BeaconService.levelChanged = Signal.new() -- (newLevel, oldLevel)
BeaconService.emptied = Signal.new() -- () — fuel hit zero while burning

export type Config = {
	position: Vector3,
	fuelCap: number,
	radiusBase: number, -- radius at zero fuel
	radiusPerFuel: number,
	radiusCap: number,
	-- total fuel EVER fed at which the beacon reaches level n (level 0 needs nothing)
	levelThresholds: { number },
	light: PointLight?, -- range follows the radius; brightness follows the fuel
	lightBrightness: number?,
	flame: BasePart?, -- scaled gently with fuel so the wick reads from far away
	flameSize: Vector3?,
}

local config: Config? = nil
local fuel = 0
local fedTotal = 0
local level = 0
local burnRate = 0 -- fuel units per second, set by the loop for the current phase
local burning = false
local lastEmptied = false

local function radiusFor(amount: number): number
	local c = config :: Config
	return math.min(c.radiusCap, c.radiusBase + c.radiusPerFuel * amount)
end

local function applyLook()
	local c = config :: Config
	local radius = radiusFor(fuel)
	if c.light then
		c.light.Range = radius
		-- Brightness used to sit near 4 because the LIGHT had to communicate the safe
		-- boundary: if it was dim you could not tell where safety ended. It no longer
		-- has that job — the dashed ring painted on the ground says where the line is,
		-- in daylight and in the dark — so the light is free to be tuned for looks.
		--
		-- At the old value a range-90 PointLight at brightness 4.3 floodlit everything
		-- within 90 studs to flat white. An 18-stud boss standing at the fire read as a
		-- featureless blob. Range still tracks the radius so the safe area is genuinely
		-- lit; only the intensity came down.
		c.light.Brightness = (c.lightBrightness or 2) * math.clamp(0.8 + fuel / math.max(1, c.fuelCap), 0.8, 1.15)
	end
	if c.flame and c.flameSize then
		local scale = 0.7 + 0.6 * math.clamp(fuel / math.max(1, c.fuelCap), 0, 1)
		c.flame.Size = c.flameSize * scale
	end
end

local function checkLevel()
	local c = config :: Config
	local newLevel = 0
	for index, threshold in c.levelThresholds do
		if fedTotal >= threshold then
			newLevel = index
		end
	end
	if newLevel ~= level then
		local old = level
		level = newLevel
		BeaconService.levelChanged:fire(level, old)
	end
end

function BeaconService.configure(newConfig: Config)
	config = newConfig
	applyLook()
end

--- Start a run: fuel back to the opening amount, level back to zero.
function BeaconService.reset(startingFuel: number)
	fuel = math.clamp(startingFuel, 0, (config :: Config).fuelCap)
	fedTotal = 0
	level = 0
	burnRate = 0
	burning = false
	lastEmptied = false
	applyLook()
	BeaconService.changed:fire(fuel, radiusFor(fuel))
end

--- Add fuel. Returns how much was accepted (the cap can refuse some of it).
function BeaconService.feed(amount: number): number
	local c = config :: Config
	if amount <= 0 then
		return 0
	end
	local room = math.max(0, c.fuelCap - fuel)
	local accepted = math.min(room, amount)
	if accepted <= 0 then
		return 0
	end
	fuel += accepted
	fedTotal += accepted
	lastEmptied = false
	applyLook()
	checkLevel()
	BeaconService.changed:fire(fuel, radiusFor(fuel))
	return accepted
end

--- Take fuel away (a penalty, a theft). Never below zero. Returns the amount removed.
function BeaconService.drain(amount: number): number
	local removed = math.min(fuel, math.max(0, amount))
	if removed <= 0 then
		return 0
	end
	fuel -= removed
	applyLook()
	BeaconService.changed:fire(fuel, radiusFor(fuel))
	if fuel <= 0 and burning and not lastEmptied then
		lastEmptied = true
		BeaconService.emptied:fire()
	end
	return removed
end

--- Burn `total` units evenly across `seconds`; zero stops burning.
function BeaconService.setBurn(total: number, seconds: number)
	if total <= 0 or seconds <= 0 then
		burnRate = 0
		burning = false
		return
	end
	burnRate = total / seconds
	burning = true
end

--- Called by the loop every heartbeat while a burning phase is active.
function BeaconService.step(delta: number)
	if not burning or burnRate <= 0 or fuel <= 0 then
		return
	end
	local before = math.floor(fuel * 10)
	fuel = math.max(0, fuel - burnRate * delta)
	if math.floor(fuel * 10) ~= before then
		applyLook()
		BeaconService.changed:fire(fuel, radiusFor(fuel))
	end
	if fuel <= 0 and not lastEmptied then
		lastEmptied = true
		BeaconService.emptied:fire()
	end
end

function BeaconService.fuel(): number
	return fuel
end

function BeaconService.fedTotal(): number
	return fedTotal
end

function BeaconService.level(): number
	return level
end

function BeaconService.radius(): number
	return if config then radiusFor(fuel) else 0
end

function BeaconService.position(): Vector3
	return if config then (config :: Config).position else Vector3.zero
end

function BeaconService.fuelCap(): number
	return if config then (config :: Config).fuelCap else 0
end

--- Is this point inside the light? The one question everything else asks.
function BeaconService.contains(point: Vector3): boolean
	local c = config
	if not c then
		return true
	end
	local flat = Vector3.new(point.X - c.position.X, 0, point.Z - c.position.Z)
	return flat.Magnitude <= radiusFor(fuel)
end

return BeaconService

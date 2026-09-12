-- ClockService — a server-wide phase clock. Day/night, rounds, waves: the shape is
-- the same. A schedule is a list of cycles, each a list of named phases with a length
-- in seconds. The clock walks them in order, fires a signal at every phase start, and
-- tells you when the last cycle ends.
--
-- The clock is the only source of "what time is it" on the server. Clients are told;
-- they never ask, and nothing they send can move it.

local RunService = game:GetService("RunService")

local Shared = game:GetService("ReplicatedStorage").Shared
local Signal = require(Shared.Signal)

local ClockService = {}

export type Phase = { name: string, length: number }
export type Cycle = { Phase }
export type Schedule = { cycles: { Cycle } }

ClockService.phaseStarted = Signal.new() -- (phaseName, cycleIndex, length)
ClockService.completed = Signal.new() -- () — the last phase of the last cycle ended
ClockService.tick = Signal.new() -- (remaining) — once a second while running

local schedule: Schedule? = nil
local cycleIndex = 0
local phaseIndex = 0
local phaseStartedAt = 0
local phaseLength = 0
local running = false
local lastWholeSecond = -1
local connection: RBXScriptConnection? = nil

local function currentPhase(): Phase?
	if not schedule then
		return nil
	end
	local cycle = schedule.cycles[cycleIndex]
	return cycle and cycle[phaseIndex]
end

local function enterPhase()
	local phase = currentPhase()
	if not phase then
		return
	end
	phaseStartedAt = os.clock()
	phaseLength = phase.length
	lastWholeSecond = -1
	ClockService.phaseStarted:fire(phase.name, cycleIndex, phase.length)
end

local function advance()
	if not schedule then
		return
	end
	local cycle = schedule.cycles[cycleIndex]
	if cycle and phaseIndex < #cycle then
		phaseIndex += 1
		enterPhase()
		return
	end
	if cycleIndex < #schedule.cycles then
		cycleIndex += 1
		phaseIndex = 1
		enterPhase()
		return
	end
	running = false
	ClockService.completed:fire()
end

local function step()
	if not running then
		return
	end
	local elapsed = os.clock() - phaseStartedAt
	local remaining = math.max(0, phaseLength - elapsed)
	local whole = math.floor(remaining)
	if whole ~= lastWholeSecond then
		lastWholeSecond = whole
		ClockService.tick:fire(remaining)
	end
	if elapsed >= phaseLength then
		advance()
	end
end

--- Load a schedule and start at cycle 1, phase 1.
function ClockService.start(newSchedule: Schedule)
	assert(#newSchedule.cycles > 0, "[ClockService] schedule needs at least one cycle")
	schedule = newSchedule
	cycleIndex = 1
	phaseIndex = 1
	running = true
	if not connection then
		connection = RunService.Heartbeat:Connect(function()
			local ok, err = pcall(step)
			if not ok then
				warn(`[ClockService] step error: {err}`)
			end
		end)
	end
	enterPhase()
end

function ClockService.stop()
	running = false
end

--- Jump straight to the next phase (a phase ended early: everyone slept, the fire went out).
function ClockService.skip()
	if running then
		advance()
	end
end

export type State = {
	running: boolean,
	cycle: number,
	phase: string?,
	remaining: number,
	length: number,
}

function ClockService.state(): State
	local phase = currentPhase()
	local remaining = if running then math.max(0, phaseLength - (os.clock() - phaseStartedAt)) else 0
	return {
		running = running,
		cycle = cycleIndex,
		phase = phase and phase.name,
		remaining = remaining,
		length = phaseLength,
	}
end

function ClockService.isRunning(): boolean
	return running
end

return ClockService

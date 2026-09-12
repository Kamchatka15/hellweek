-- AnalyticsService — the funnel, because Gate B is a table of numbers.
--
-- GAME_FACTORY §1: "without instrumentation there is nothing to put in it and the gate
-- silently becomes a guess." This is the cheap version of that: a per-player timer from
-- join, and a one-time stamp on each step of the loop. The console line it prints is
-- what a Gate A playtest actually reads.
--
-- Doctrine §3 names the measurements that count: time-to-first-reward, first-sell,
-- first-upgrade. Those are exactly the steps below.

local AnalyticsService = {}

local RobloxAnalytics = nil
pcall(function()
	RobloxAnalytics = game:GetService("AnalyticsService")
end)

AnalyticsService.STEPS = { "join", "first_flood", "first_collect", "first_bank", "first_upgrade" }

type Session = { joinedAt: number, steps: { [string]: number } }

local sessions: { [number]: Session } = {}

function AnalyticsService.markJoin(player: Player)
	sessions[player.UserId] = { joinedAt = os.clock(), steps = { join = 0 } }
	print(`[funnel] {player.Name} step=join t=+0.0s`)
end

--- Stamp a funnel step the first time it happens. Repeat calls are ignored, which is
--- what makes "time to first X" mean anything.
function AnalyticsService.step(player: Player, name: string)
	local session = sessions[player.UserId]
	if not session or session.steps[name] then
		return
	end
	local elapsed = os.clock() - session.joinedAt
	session.steps[name] = elapsed
	print(`[funnel] {player.Name} step={name} t=+{string.format("%.1f", elapsed)}s`)
	if RobloxAnalytics then
		pcall(function()
			RobloxAnalytics:LogCustomEvent(player, name, elapsed)
		end)
	end
end

function AnalyticsService.track(player: Player, name: string, value: number?)
	print(`[event] {player.Name} {name}={value or 1}`)
	if RobloxAnalytics then
		pcall(function()
			RobloxAnalytics:LogCustomEvent(player, name, value or 1)
		end)
	end
end

--- Printed when a player leaves: the whole funnel on one line, for the session log.
function AnalyticsService.summarize(player: Player)
	local session = sessions[player.UserId]
	if not session then
		return
	end
	local parts = {}
	for _, name in AnalyticsService.STEPS do
		local at = session.steps[name]
		table.insert(parts, `{name}={if at then string.format("%.1f", at) else "MISS"}`)
	end
	local length = string.format("%.0f", os.clock() - session.joinedAt)
	print(`[funnel:summary] {player.Name} session={length}s {table.concat(parts, " ")}`)
	sessions[player.UserId] = nil
end

return AnalyticsService

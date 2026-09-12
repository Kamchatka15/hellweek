-- RewardService — the one reason to open the game tomorrow.
--
-- Doctrine §4.5 says pick one return hook and implement it well; the brief picked
-- offline earnings. The rules that come with that choice are not tuning knobs:
-- accrual is CAPPED, never decayed, never lost, and never on a countdown. A player
-- who goes to bed loses nothing. (Doctrine §8 and the Grow a Garden precedent in
-- PIPELINE.md §1 — "offline growth that respects bedtime".)

local Core = script.Parent
local EconomyService = require(Core.EconomyService)

local RewardService = {}

local MIN_ELAPSED = 60 -- below this, do not interrupt a rejoin with a panel

local ratePerSecond: ((Player) -> number)? = nil
local capSeconds = 8 * 3600

export type Config = { capSeconds: number, ratePerSecond: (Player) -> number }

function RewardService.configure(config: Config)
	capSeconds = config.capSeconds
	ratePerSecond = config.ratePerSecond
end

export type OfflineResult = { amount: number, elapsed: number, capped: boolean }

--- Compute and grant offline earnings. Called once, server-side, on profile load.
--- The client is told the number after the grant; it never asks for one.
function RewardService.grantOffline(player: Player, profile: any): OfflineResult?
	if not ratePerSecond then
		return nil
	end
	local elapsed = os.time() - (profile.lastSeen or os.time())
	if elapsed < MIN_ELAPSED then
		return nil
	end
	local capped = elapsed > capSeconds
	local counted = math.min(elapsed, capSeconds)
	local amount = math.floor(counted * ratePerSecond(player))
	if amount <= 0 then
		return nil
	end
	EconomyService.grantCoins(player, amount, "offline")
	return { amount = amount, elapsed = elapsed, capped = capped }
end

function RewardService.capSeconds(): number
	return capSeconds
end

return RewardService

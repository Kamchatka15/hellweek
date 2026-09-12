--!strict
-- Format — number presentation. Shared so the HUD and server toasts agree.

local Format = {}

local SUFFIXES = { "", "K", "M", "B", "T" }

--- 1234 -> "1.2K". Kept short because the HUD has to read at a glance.
function Format.short(value: number): string
	local n = math.floor(value)
	local tier = 1
	while math.abs(n) >= 1000 and tier < #SUFFIXES do
		n //= 1000
		tier += 1
	end
	if tier == 1 then
		return tostring(n)
	end
	local remainder = math.floor(value / (1000 ^ (tier - 1)) * 10) % 10
	if remainder == 0 then
		return `{n}{SUFFIXES[tier]}`
	end
	return `{n}.{remainder}{SUFFIXES[tier]}`
end

--- 7320 -> "2h 2m". Used by the offline panel.
function Format.duration(seconds: number): string
	local s = math.max(0, math.floor(seconds))
	local hours = s // 3600
	local minutes = (s % 3600) // 60
	if hours > 0 then
		return `{hours}h {minutes}m`
	end
	if minutes > 0 then
		return `{minutes}m`
	end
	return `{s}s`
end

return Format

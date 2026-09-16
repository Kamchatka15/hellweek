-- Client bootstrap. The client renders what the server says. The pack's theme names
-- its loop family, and that picks the HUD: sweep-and-bank sends exactly one message
-- back (buy an upgrade id, owned by Hud); the survive loop sends none.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage:WaitForChild("Shared").Net)
local theme = require(ReplicatedStorage:WaitForChild("Pack").theme)

if theme.loop == "survive" then
	local SurviveHud = require(script.SurviveHud)
	local gui = SurviveHud.init()
	require(script.Compass).init(gui)
	-- Air control and hit feel. Purely cosmetic and purely local: it never speaks to
	-- the server, so it can be deleted without touching a single rule.
	require(script.Moves).start()

	Net.get(Net.S2C_State).OnClientEvent:Connect(SurviveHud.setState)
	Net.get(Net.S2C_Toast).OnClientEvent:Connect(function(message, tone)
		SurviveHud.toast(message, tone or "info")
	end)
	Net.get(Net.S2C_Fx).OnClientEvent:Connect(function(kind, payload)
		task.spawn(SurviveHud.fx, kind, payload)
	end)
	return
end

local FloodFx = require(script.FloodFx)
local Hud = require(script.Hud)

local gui = Hud.init()
FloodFx.init(gui)

Net.get(Net.S2C_State).OnClientEvent:Connect(Hud.setState)

Net.get(Net.S2C_Toast).OnClientEvent:Connect(function(message, tone)
	Hud.toast(message, tone or "info")
end)

Net.get(Net.S2C_Offline).OnClientEvent:Connect(Hud.showOffline)

Net.get(Net.S2C_Shop).OnClientEvent:Connect(Hud.setShopOpen)

Net.get(Net.S2C_Flood).OnClientEvent:Connect(function(_position, count)
	FloodFx.play(count)
	FloodFx.nudge()
end)

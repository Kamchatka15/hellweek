-- Client bootstrap. The client renders what the server says and sends exactly one
-- kind of message back (buy an upgrade id), which Hud owns.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage:WaitForChild("Shared").Net)
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

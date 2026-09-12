--!strict
-- Net — the remote surface, named in one place so server and client cannot drift.
--
-- Doctrine: the client asks for exactly one thing (buy an upgrade). Everything else
-- is the server telling the client what is true. Flood and bank are server-detected
-- zone entries, not remotes, so there is nothing to spam or forge.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Net = {}

Net.FOLDER_NAME = "Net"

-- server -> client
Net.S2C_State = "S2C_State" -- authoritative coins / carry / cap / upgrades / catalog
Net.S2C_Flood = "S2C_Flood" -- a payout happened here, play the moment
Net.S2C_Toast = "S2C_Toast" -- one line of feedback
Net.S2C_Offline = "S2C_Offline" -- "while you were away"
Net.S2C_Shop = "S2C_Shop" -- open/close the upgrade panel

-- client -> server (the entire trust surface)
Net.C2S_Buy = "C2S_Buy"

local ALL = {
	Net.S2C_State,
	Net.S2C_Flood,
	Net.S2C_Toast,
	Net.S2C_Offline,
	Net.S2C_Shop,
	Net.C2S_Buy,
}

local folder: Folder? = nil

local function root(): Folder
	if folder then
		return folder
	end
	if RunService:IsServer() then
		local existing = ReplicatedStorage:FindFirstChild(Net.FOLDER_NAME)
		if not existing then
			existing = Instance.new("Folder")
			existing.Name = Net.FOLDER_NAME
			existing.Parent = ReplicatedStorage
		end
		folder = existing :: Folder
	else
		folder = ReplicatedStorage:WaitForChild(Net.FOLDER_NAME, 20) :: Folder
	end
	return folder :: Folder
end

--- Server-only: create every remote up front so the client never races a WaitForChild.
function Net.build()
	assert(RunService:IsServer(), "Net.build is server-only")
	local parent = root()
	for _, name in ALL do
		if not parent:FindFirstChild(name) then
			local remote = Instance.new("RemoteEvent")
			remote.Name = name
			remote.Parent = parent
		end
	end
end

function Net.get(name: string): RemoteEvent
	local parent = root()
	if RunService:IsServer() then
		return parent:FindFirstChild(name) :: RemoteEvent
	end
	return parent:WaitForChild(name, 20) :: RemoteEvent
end

return Net

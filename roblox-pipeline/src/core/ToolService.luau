-- ToolService — things a player holds, and what holding them changes.
--
-- A tool is a Roblox `Tool` in the backpack, built from part data so it needs no mesh
-- upload, and it is defined entirely by the pack. The engine knows three verbs:
--
--   `harvest`  holding it changes what a node yields
--   `ward`     holding it keeps the night threat at a distance
--   `light`    holding it carries a pool of light with you
--
-- None of them kill anything. That is not squeamishness: in a survive-the-night game
-- the threat being unkillable IS the game, and a weapon that ends it ends the loop
-- with it. So "defend yourself" here means holding something off, not putting it down.
--
-- Server-side. A tool is granted by the server and its effect is read by the server;
-- the client equips and animates, and nothing it says is trusted.

local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage").Shared
local Signal = require(Shared.Signal)

local ToolService = {}

ToolService.granted = Signal.new() -- (player, toolId)
ToolService.equipped = Signal.new() -- (player, toolId?)

export type ToolDef = {
	id: string,
	label: string,
	effect: string?, -- "harvest" | "ward" | "light"
	kind: string?, -- for harvest: which resource it helps with ("any" for all)
	bonus: number?, -- for harvest: extra yield
	radius: number?, -- for ward: how far it holds the threat off
	light: { color: Color3, brightness: number, range: number }?,
	grip: CFrame?,
	parts: { any },
}

local defs: { [string]: ToolDef } = {}
local held: { [Player]: string } = {}

function ToolService.configure(list: { ToolDef })
	defs = {}
	for _, def in list do
		defs[def.id] = def
	end
end

function ToolService.definition(id: string): ToolDef?
	return defs[id]
end

--- What the player is holding, or nil.
function ToolService.holding(player: Player): string?
	return held[player]
end

function ToolService.has(player: Player, id: string): boolean
	for _, container in { player:FindFirstChildOfClass("Backpack"), player.Character } do
		if container and container:FindFirstChild(id) then
			return true
		end
	end
	return false
end

--- The harvest bonus a player's held tool gives for this resource, or 0.
function ToolService.harvestBonus(player: Player, kind: string): number
	local id = held[player]
	local def = id and defs[id]
	if not def or def.effect ~= "harvest" then
		return 0
	end
	if def.kind and def.kind ~= "any" and def.kind ~= kind then
		return 0
	end
	return def.bonus or 1
end

--- How far the player's held tool holds the night threat off, or 0. The stalker asks
--- this every step; it is the only thing standing between a player and being touched.
function ToolService.wardRadius(player: Player): number
	local id = held[player]
	local def = id and defs[id]
	if not def or def.effect ~= "ward" then
		return 0
	end
	return def.radius or 0
end

local function buildModel(def: ToolDef): Tool
	local tool = Instance.new("Tool")
	tool.Name = def.id
	tool.ToolTip = def.label
	tool.RequiresHandle = true
	tool.CanBeDropped = false

	local handle: BasePart? = nil
	for index, spec in def.parts do
		local part = Instance.new("Part")
		part.Name = if index == 1 then "Handle" else `{def.id}_{index}`
		part.Anchored = false
		part.CanCollide = false
		part.Massless = true
		part.Shape = spec.shape or Enum.PartType.Block
		part.Size = spec.size
		part.Color = spec.color
		part.Material = spec.material or Enum.Material.SmoothPlastic
		if spec.light then
			local light = Instance.new("PointLight")
			light.Color = spec.light.color
			light.Brightness = spec.light.brightness
			light.Range = spec.light.range
			light.Shadows = false
			light.Parent = part
		end
		if index == 1 then
			handle = part
			part.Parent = tool
		else
			part.Parent = tool
		end
	end

	-- Everything after the handle is welded to it, so the whole thing moves as one.
	local root = handle :: BasePart
	for _, part in tool:GetChildren() do
		if part:IsA("BasePart") and part ~= root then
			local rot = (part :: any):GetAttribute("rot")
			local _ = rot
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = root
			weld.Part1 = part
			weld.Parent = root
		end
	end
	if def.grip then
		tool.Grip = def.grip
	end
	return tool
end

--- Place the offsets the pack asked for, then weld. Done after parenting so the parts
--- have a CFrame to be offset from.
local function placeParts(tool: Tool, def: ToolDef)
	local handle = tool:FindFirstChild("Handle") :: BasePart
	if not handle then
		return
	end
	for index, spec in def.parts do
		if index == 1 then
			continue
		end
		local part = tool:FindFirstChild(`{def.id}_{index}`) :: BasePart
		if part then
			local rot = spec.rotation or Vector3.zero
			part.CFrame = handle.CFrame
				* CFrame.new(spec.offset or Vector3.zero)
				* CFrame.Angles(math.rad(rot.X), math.rad(rot.Y), math.rad(rot.Z))
		end
	end
end

--- Give the player a tool. Returns false if they already have it — tools are kept, not
--- stacked, because a second copy of a ward is not twice the ward.
function ToolService.grant(player: Player, id: string): boolean
	local def = defs[id]
	if not def or ToolService.has(player, id) then
		return false
	end
	local backpack = player:FindFirstChildOfClass("Backpack")
	if not backpack then
		return false
	end
	local tool = buildModel(def)
	tool.Parent = backpack
	placeParts(tool, def)

	tool.Equipped:Connect(function()
		held[player] = id
		ToolService.equipped:fire(player, id)
	end)
	tool.Unequipped:Connect(function()
		if held[player] == id then
			held[player] = nil
			ToolService.equipped:fire(player, nil)
		end
	end)

	ToolService.granted:fire(player, id)
	return true
end

function ToolService.start()
	Players.PlayerRemoving:Connect(function(player)
		held[player] = nil
	end)
end

return ToolService

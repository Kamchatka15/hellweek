-- Hotbar — what you are holding, along the bottom of the screen.
--
-- Roblox ships a backpack hotbar and we switch it off, because it shows Tools and
-- nothing else. Half of what a player carries here is not a Tool: the sack is a list
-- of resources on the profile, and "how full am I" is the number that decides whether
-- you turn round and walk home. A bar that shows the axe but not the wood is a bar
-- that answers the less useful question.
--
-- Icons are ViewportFrames rendering the real parts, which is the whole trick: an
-- item's icon IS the item, so nothing is ever drawn, nothing is uploaded, and a
-- resource invented next month has a correct icon the moment it exists.

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local UIKit = require(script.Parent.UIKit)

local Hotbar = {}

local SLOT = 62
local GAP = 6

local theme: any = nil
local bar: Frame? = nil
local slots: { Frame } = {}
local tools: { Tool } = {}
local sackSlot: Frame? = nil
local sackCount: TextLabel? = nil
local sackIcons: Frame? = nil
local lastSack: { any } = {}

local player = Players.LocalPlayer

--- Render a set of parts into a flat panel. Clones them, anchors the clones, and
--- frames a camera on the whole assembly so it fills the slot whatever its shape.
local function iconOf(parent: Instance, source: Instance): ViewportFrame
	local view = UIKit.create("ViewportFrame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 4,
		Parent = parent,
	})

	local world = Instance.new("Model")
	local min, max: Vector3? = nil, nil
	for _, d in source:GetDescendants() do
		if d:IsA("BasePart") then
			local copy = d:Clone()
			copy:ClearAllChildren()
			copy.Anchored = true
			copy.CanCollide = false
			copy.Parent = world
			local lo = copy.Position - copy.Size / 2
			local hi = copy.Position + copy.Size / 2
			min = if min then Vector3.new(math.min(min.X, lo.X), math.min(min.Y, lo.Y), math.min(min.Z, lo.Z)) else lo
			max = if max then Vector3.new(math.max(max.X, hi.X), math.max(max.Y, hi.Y), math.max(max.Z, hi.Z)) else hi
		end
	end
	if source:IsA("BasePart") then
		local copy = source:Clone()
		copy:ClearAllChildren()
		copy.Anchored = true
		copy.CanCollide = false
		copy.Parent = world
		min = copy.Position - copy.Size / 2
		max = copy.Position + copy.Size / 2
	end
	world.Parent = view

	local centre = if min and max then (min + max) / 2 else Vector3.zero
	local span = if min and max then (max - min).Magnitude else 2
	local camera = Instance.new("Camera")
	-- Three-quarters and slightly above: the angle that reads as an object rather
	-- than a silhouette, and it works for a spear and a stone equally.
	camera.CFrame = CFrame.lookAt(centre + Vector3.new(span * 0.75, span * 0.55, span * 0.95), centre)
	camera.Parent = view
	view.CurrentCamera = camera
	view.Ambient = Color3.fromRGB(190, 190, 190)
	view.LightColor = Color3.fromRGB(255, 244, 220)
	view.LightDirection = Vector3.new(-0.4, -1, -0.6)
	return view
end

local function slotFrame(index: number, key: string?): Frame
	local frame = UIKit.create("Frame", {
		Name = `Slot{index}`,
		Size = UDim2.fromOffset(SLOT, SLOT),
		BackgroundColor3 = theme.uiPanel,
		BackgroundTransparency = 0.25,
		BorderSizePixel = 0,
		LayoutOrder = index,
		ZIndex = 3,
		Parent = bar,
	})
	UIKit.corner(8).Parent = frame
	local stroke = Instance.new("UIStroke")
	stroke.Name = "Edge"
	stroke.Color = theme.uiMuted or Color3.fromRGB(140, 140, 140)
	stroke.Transparency = 0.6
	stroke.Thickness = 1
	stroke.Parent = frame
	if key then
		local tag = UIKit.create("TextLabel", {
			Name = "Key",
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(5, 2),
			Size = UDim2.fromOffset(14, 14),
			Font = Enum.Font.GothamBold,
			Text = key,
			TextSize = 11,
			TextColor3 = theme.uiMuted or Color3.fromRGB(180, 180, 180),
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 5,
			Parent = frame,
		})
		local _ = tag
	end
	return frame
end

--- Highlight whichever tool is actually equipped.
local function paintSelection()
	local character = player.Character
	for index, tool in tools do
		local frame = slots[index]
		if frame then
			local edge = frame:FindFirstChild("Edge") :: UIStroke?
			local equipped = character ~= nil and tool.Parent == character
			if edge then
				edge.Color = if equipped
					then (theme.colors.flame or Color3.new(1, 1, 1))
					else (theme.uiMuted or Color3.fromRGB(140, 140, 140))
				edge.Transparency = if equipped then 0 else 0.6
				edge.Thickness = if equipped then 2 else 1
			end
			frame.BackgroundTransparency = if equipped then 0.05 else 0.25
		end
	end
end

local function equip(tool: Tool)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	if tool.Parent == character then
		humanoid:UnequipTools()
	else
		humanoid:EquipTool(tool)
	end
	task.defer(paintSelection)
end

--- Rebuild the tool slots from what the player is actually carrying.
function Hotbar.refresh()
	if not bar then
		return
	end
	for _, frame in slots do
		frame:Destroy()
	end
	slots = {}
	tools = {}

	local backpack = player:FindFirstChildOfClass("Backpack")
	local character = player.Character
	for _, container in { backpack, character } do
		if container then
			for _, child in container:GetChildren() do
				if child:IsA("Tool") then
					table.insert(tools, child)
				end
			end
		end
	end
	table.sort(tools, function(a, b)
		return a.Name < b.Name
	end)

	for index, tool in tools do
		local frame = slotFrame(index, tostring(index))
		local handle = tool:FindFirstChild("Handle")
		if handle then
			local icon = iconOf(frame, tool)
			icon.Size = UDim2.fromScale(0.82, 0.82)
			icon.Position = UDim2.fromScale(0.09, 0.12)
		end
		local button = UIKit.create("TextButton", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Text = "",
			ZIndex = 6,
			Parent = frame,
		})
		button.Activated:Connect(function()
			equip(tool)
		end)
		slots[index] = frame
	end

	-- The sack always sits last, so its position never moves as tools come and go.
	if sackSlot then
		sackSlot.LayoutOrder = 99
	end
	paintSelection()
end

--- What the sack is holding, as icons, with the count over them.
function Hotbar.setSack(carry: number, cap: number, entries: { any }?)
	if not sackCount or not sackIcons then
		return
	end
	sackCount.Text = `{carry}/{cap}`
	-- Red at the cap. The same element says how much you have AND go home now, which
	-- is the trick the genre leader uses and the reason it needs no second warning.
	sackCount.TextColor3 = if cap > 0 and carry >= cap
		then (theme.uiWarn or Color3.fromRGB(235, 90, 70))
		else (theme.uiText or Color3.new(1, 1, 1))

	local signature = {}
	for _, entry in entries or {} do
		table.insert(signature, `{entry.kind}:{entry.count}`)
	end
	local key = table.concat(signature, ",")
	if key == (lastSack.key or nil) then
		return -- nothing changed; do not rebuild the viewports every packet
	end
	lastSack.key = key

	for _, child in sackIcons:GetChildren() do
		if not child:IsA("UIListLayout") then
			child:Destroy()
		end
	end
	for _, entry in entries or {} do
		if entry.color and entry.size then
			local holder = UIKit.create("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(20, 20),
				Parent = sackIcons,
			})
			-- Build the item as a real part, then photograph it. This is the whole
			-- reason the hotbar needs no art: the icon is the thing.
			local piece = Instance.new("Part")
			piece.Anchored = true
			piece.CanCollide = false
			piece.Size = entry.size
			piece.Color = entry.color
			piece.Material = entry.material or Enum.Material.SmoothPlastic
			if entry.shape then
				piece.Shape = entry.shape
			end
			piece.Position = Vector3.zero
			iconOf(holder, piece)
			piece:Destroy()
			-- More than one? Say so, small, in the corner.
			if (entry.count or 1) > 1 then
				UIKit.create("TextLabel", {
					BackgroundTransparency = 1,
					AnchorPoint = Vector2.new(1, 1),
					Position = UDim2.fromScale(1, 1),
					Size = UDim2.fromOffset(12, 11),
					Font = Enum.Font.GothamBold,
					Text = tostring(entry.count),
					TextSize = 10,
					TextColor3 = theme.uiText,
					TextStrokeTransparency = 0.4,
					ZIndex = 6,
					Parent = holder,
				})
			end
		end
	end
end

function Hotbar.init(gui: ScreenGui, activeTheme: any)
	theme = activeTheme

	-- One hotbar, not two. Roblox's own shows Tools only, and this one shows the
	-- sack as well, so the native bar would be a strictly worse duplicate.
	pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	end)

	bar = UIKit.create("Frame", {
		Name = "Hotbar",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -14),
		Size = UDim2.fromOffset(SLOT * 7 + GAP * 6, SLOT),
		BackgroundTransparency = 1,
		ZIndex = 3,
		Parent = gui,
	}, {
		UIKit.create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			Padding = UDim.new(0, GAP),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	-- The sack slot. Wider than a tool slot because it holds several things.
	sackSlot = UIKit.create("Frame", {
		Name = "SackSlot",
		Size = UDim2.fromOffset(SLOT * 1.7, SLOT),
		BackgroundColor3 = theme.uiPanel,
		BackgroundTransparency = 0.25,
		BorderSizePixel = 0,
		LayoutOrder = 99,
		ZIndex = 3,
		Parent = bar,
	})
	UIKit.corner(8).Parent = sackSlot
	local sackEdge = Instance.new("UIStroke")
	sackEdge.Color = theme.uiMuted or Color3.fromRGB(140, 140, 140)
	sackEdge.Transparency = 0.6
	sackEdge.Parent = sackSlot

	sackIcons = UIKit.create("Frame", {
		Name = "Icons",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(6, 6),
		Size = UDim2.new(1, -12, 0, 20),
		ZIndex = 4,
		Parent = sackSlot,
	}, {
		UIKit.create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0, 2),
		}),
	})

	sackCount = UIKit.create("TextLabel", {
		Name = "Count",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -4),
		Size = UDim2.new(1, -8, 0, 22),
		Font = Enum.Font.GothamBlack,
		Text = "0/0",
		TextSize = 18,
		TextColor3 = theme.uiText,
		ZIndex = 5,
		Parent = sackSlot,
	})

	local label = UIKit.create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(6, 2),
		Size = UDim2.fromOffset(40, 12),
		Font = Enum.Font.GothamBold,
		Text = string.upper(theme.names.sack or "SACK"),
		TextSize = 9,
		TextColor3 = theme.uiMuted or Color3.fromRGB(180, 180, 180),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 5,
		Parent = sackSlot,
	})
	local _ = label

	-- Number keys equip, the way every game on the platform does it.
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed or input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end
		local digit = tonumber(string.match(input.KeyCode.Name, "^%a*(%d)$") or "")
		if digit and tools[digit] then
			equip(tools[digit])
		end
	end)

	local function watch(container: Instance?)
		if not container then
			return
		end
		container.ChildAdded:Connect(function()
			task.defer(Hotbar.refresh)
		end)
		container.ChildRemoved:Connect(function()
			task.defer(Hotbar.refresh)
		end)
	end
	watch(player:FindFirstChildOfClass("Backpack"))
	watch(player.Character)
	player.ChildAdded:Connect(function(child)
		if child:IsA("Backpack") then
			watch(child)
			task.defer(Hotbar.refresh)
		end
	end)
	player.CharacterAdded:Connect(function(character)
		watch(character)
		task.defer(Hotbar.refresh)
	end)

	Hotbar.refresh()
	return bar
end

return Hotbar

-- SurviveHud — the three numbers a survive-the-night player reads, and nothing else.
--
--   DAY n        (with a thin bar emptying toward night, and from day 3 a small weight mark)
--   BEACON ####  (fuel as a bar + number)
--   SACK n / cap
--
-- Renders server truth. Sends nothing back: this loop family has no client->server
-- remote at all. The darkness vignette is the one thing computed locally, from the
-- beacon position and radius the server already sent — cosmetics, not state.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Format = require(Shared.Format)
local Net = require(Shared.Net)
local theme = require(ReplicatedStorage:WaitForChild("Pack").theme)
local OpeningAct = require(script.Parent.OpeningAct)
local UIKit = require(script.Parent.UIKit)
local UserInputService = game:GetService("UserInputService")

local SurviveHud = {}

-- While the opening act owns the screen, toasts wait and the fade-in is the act's.
local openingActive = false
local heldToasts: { { message: string, tone: string } } = {}

local gui: ScreenGui
local dayValue: TextLabel
local dayFill: Frame
local weightRow: Frame
local fuelFill: Frame
local fuelText: TextLabel
local sackText: TextLabel
local sackFill: Frame
local toastHolder: Frame
local blackout: Frame
local vignette: Frame
local endPanel: Frame
local trialsButton: TextButton
local trialsPanel: Frame
local trialsList: Frame
local trialRows: { [string]: TextLabel } = {}
local pickupButton: TextButton
local actionButton: TextButton
local infoButton: TextButton
local recipeRows: Frame
local trialsOpen = false
local refreshTrials: (any) -> ()
local refreshButtons: (any) -> ()
local tipParts: { [number]: { BasePart } } = {}

local latest: any = nil
local receivedAt = 0
local weightDots: { Frame } = {}

-- INSPECT. Point at a thing, press I, read about it. This replaced the permanent
-- floating labels over every rock, chest and monument: those cost screen space every
-- second of the run to say one word, and had nowhere to put the two sentences that
-- actually help. On demand there is room to say everything, and the rest of the time
-- the screen belongs to the game.
local inspectPanel: Frame? = nil
local inspectTitle: TextLabel? = nil
local inspectBody: TextLabel? = nil
local inspectState: TextLabel? = nil
local hoverHint: TextLabel? = nil
local inspectToken = 0

local function panel(props: { [string]: any }, children: { Instance }?): Frame
	local defaults = {
		BackgroundColor3 = theme.uiPanel,
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
	}
	for key, value in props do
		defaults[key] = value
	end
	local frame = UIKit.create("Frame", defaults, children)
	UIKit.corner(10).Parent = frame
	return frame
end

local function text(props: { [string]: any }): TextLabel
	local defaults = {
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		TextColor3 = theme.uiText,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextScaled = true,
	}
	for key, value in props do
		defaults[key] = value
	end
	return UIKit.create("TextLabel", defaults)
end

local function bar(parent: Instance, y: number, color: Color3): Frame
	local track = UIKit.create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, y),
		Size = UDim2.new(1, -20, 0, 10),
		BackgroundColor3 = theme.uiBackground,
		BorderSizePixel = 0,
		Parent = parent,
	})
	UIKit.corner(5).Parent = track
	local fill = UIKit.create("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Parent = track,
	})
	UIKit.corner(5).Parent = fill
	return fill
end

-- ---------------------------------------------------------------- state

local function refreshWeight(state: any)
	local show = state.day >= (theme.weightVisibleFromDay or 3) and (state.weight or 0) > 0
	weightRow.Visible = show
	if not show then
		return
	end
	local count = math.min(state.weight, 8)
	for index = #weightDots + 1, count do
		local dot = UIKit.create("Frame", {
			Size = UDim2.fromOffset(9, 9),
			BackgroundColor3 = theme.colors.lure,
			BorderSizePixel = 0,
			LayoutOrder = index,
			Parent = weightRow,
		})
		UIKit.corner(5).Parent = dot
		table.insert(weightDots, dot)
	end
	for index, dot in weightDots do
		dot.Visible = index <= count
	end
end

-- ---------------------------------------------------------------- trials

local POINT_LOCKED = Color3.fromRGB(22, 20, 26)
local POINT_OPEN = Color3.fromRGB(206, 34, 26)
local POINT_MASTERED = Color3.fromRGB(64, 224, 96)

-- The fifth point is the offering table's light, not a world.
local OFFERING_COLOURS: { [string]: Color3 } = {
	empty = Color3.fromRGB(74, 74, 82), -- grey: nothing in it
	held = Color3.fromRGB(46, 122, 216), -- blue: something in it, nothing it can make
	ready = Color3.fromRGB(64, 224, 96), -- green: a sacrifice is ready
}
local offeringParts: { BasePart } = {}

local function paintOffering(state: string?)
	local world = workspace:FindFirstChild("World")
	if not world or not state then
		return
	end
	if #offeringParts == 0 then
		for _, part in world:GetChildren() do
			local prefix = "OfferingPoint"
			if part:IsA("BasePart") and string.sub(part.Name, 1, #prefix) == prefix then
				table.insert(offeringParts, part)
			end
		end
		if #offeringParts == 0 then
			return -- the stone has not replicated yet
		end
	end
	local colour = OFFERING_COLOURS[state] or OFFERING_COLOURS.empty
	for _, part in offeringParts do
		part.Color = colour
	end
end

-- The five pentagram points, coloured from THIS player's progress: dark while a world
-- is locked, red once it is open, green once it is mastered. Done on the client on
-- purpose — in co-op each player reads their own stone rather than the room's.
local function paintPoints(worlds: { any }?)
	if not worlds then
		return
	end
	local world = workspace:FindFirstChild("World")
	if not world then
		return
	end
	for _, entry in worlds do
		local parts = tipParts[entry.index]
		if not parts then
			parts = {}
			local prefix = `BiomePoint{entry.index}_`
			for _, part in world:GetChildren() do
				if part:IsA("BasePart") and string.sub(part.Name, 1, #prefix) == prefix then
					table.insert(parts, part)
				end
			end
			if #parts == 0 then
				continue -- the stone has not replicated yet; try again next packet
			end
			tipParts[entry.index] = parts
		end
		local color = POINT_LOCKED
		if entry.state == "open" then
			color = POINT_OPEN
		elseif entry.state == "mastered" then
			color = POINT_MASTERED
		end
		for _, part in parts do
			part.Color = color
		end
	end
end

local function trialRow(entry: any, index: number): TextLabel
	local row = text({
		Name = entry.id,
		Size = UDim2.new(1, -20, 0, 26),
		Font = Enum.Font.GothamMedium,
		RichText = true,
		TextScaled = false,
		TextSize = 15,
		LayoutOrder = index,
		Text = entry.label,
		Parent = trialsList,
	})
	return row
end

function refreshTrials(packet: any)
	if not packet then
		return
	end
	paintPoints(packet.worlds)
	trialsButton.Text = `{theme.copy.infoLabel}\n{theme.copy.challengeTitle} {packet.done}/{packet.total}`
	for index, entry in packet.list do
		local row = trialRows[entry.id]
		if not row then
			row = trialRow(entry, index)
			trialRows[entry.id] = row
		end
		-- A struck-through line is the whole point of the list: you can see what is
		-- left without reading, and what you did without a second panel.
		row.Text = if entry.done then `<s>{entry.label}</s>` else entry.label
		row.TextColor3 = if entry.done then theme.uiMuted else theme.uiText
	end
	trialsPanel.Size = UDim2.fromOffset(300, 30 + #packet.list * 28)
end

--- The recipe book. Without it the obelisk is a guessing game: a player can carry two
--- cactus forever and never learn what they are for.
local function refreshRecipes(list: { any }?)
	if not list or #recipeRows:GetChildren() > #list then
		return
	end
	for index, entry in list do
		if recipeRows:FindFirstChild(`r{index}`) then
			continue
		end
		text({
			Name = `r{index}`,
			Size = UDim2.new(1, -16, 0, 22),
			Font = Enum.Font.GothamMedium,
			TextScaled = false,
			TextSize = 14,
			LayoutOrder = index,
			Text = `{entry.from}  →  {entry.makes}`,
			TextColor3 = theme.uiMuted,
			Parent = recipeRows,
		})
	end
end

-- ---------------------------------------------------------------- the three buttons
-- PICK UP, ACTION and INFO. They are always on screen so the verbs are KNOWN, and they
-- dim when there is nothing to do — a greyed button teaches what it is for far better
-- than a button that appears only when it already works.
local ACTION_WORDS: { [string]: string } = {}

function refreshButtons(state: any)
	local near = state.near or {}

	local canPick = near.pickup ~= nil
	pickupButton.Text = if canPick then `{theme.copy.pickupLabel}\n{near.pickup}` else theme.copy.pickupLabel
	pickupButton.BackgroundColor3 = if canPick then theme.uiGood else theme.uiPanel
	pickupButton.TextColor3 = if canPick then Color3.new(1, 1, 1) else theme.uiMuted

	local word = near.action and ACTION_WORDS[near.action]
	actionButton.Text = word or theme.copy.actionFeed
	actionButton.BackgroundColor3 = if word then theme.accent else theme.uiPanel
	actionButton.TextColor3 = if word then Color3.fromRGB(30, 22, 10) else theme.uiMuted
end

function SurviveHud.setState(state: any)
	latest = state
	receivedAt = os.clock()

	dayValue.Text = `{string.upper(theme.copy.dayLabel)} {math.max(1, state.day)}`
	refreshWeight(state)

	local fuelRatio = if state.fuelCap > 0 then math.clamp(state.fuel / state.fuelCap, 0, 1) else 0
	fuelFill.Size = UDim2.fromScale(fuelRatio, 1)
	fuelFill.BackgroundColor3 = if fuelRatio < 0.2 then theme.uiWarn else theme.accent
	fuelText.Text = `{string.upper(theme.names.beacon)}  {string.format("%.0f", state.fuel)}`

	refreshTrials(state.challenges)
	paintOffering(state.offeringState)
	refreshRecipes(state.recipes)
	refreshButtons(state)

	local sackRatio = if state.carryCap > 0 then math.clamp(state.carry / state.carryCap, 0, 1) else 0
	sackFill.Size = UDim2.fromScale(sackRatio, 1)
	sackFill.BackgroundColor3 = if sackRatio >= 1 then theme.uiWarn else theme.colors.fuel
	-- What is in the sack, not just how full it is: a desert carries three kinds and
	-- "4/6" cannot tell you whether you have the two cactus a recipe wants.
	local carried = ""
	for _, entry in state.sack or {} do
		carried ..= `  {entry.label} {entry.count}`
	end
	sackText.Text = if carried == ""
		then `{string.upper(theme.names.sack)}  {state.carry}/{state.carryCap}`
		else `{state.carry}/{state.carryCap}{carried}`
end

-- The phase bar drains locally between packets so it reads as a clock, not a stutter.
local function tickClock()
	if not latest or not latest.active or latest.length <= 0 then
		dayFill.Size = UDim2.fromScale(0, 1)
		return
	end
	local remaining = math.max(0, latest.remaining - (os.clock() - receivedAt))
	local ratio = remaining / latest.length
	dayFill.Size = UDim2.fromScale(ratio, 1)
	dayFill.BackgroundColor3 = if latest.phase == "night" then theme.colors.night else theme.accent
end

-- Outside the light the screen edges close in. Purely local; the server decides the
-- radius, this only draws it.
local function tickVignette()
	if not latest or not latest.beacon then
		vignette.BackgroundTransparency = 1
		return
	end
	local character = Players.LocalPlayer.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	local position = (root :: BasePart).Position
	local beacon = latest.beacon :: Vector3
	local distance = Vector3.new(position.X - beacon.X, 0, position.Z - beacon.Z).Magnitude
	local radius = latest.radius or 25
	local over = math.clamp((distance - radius) / 30, 0, 1)
	local nightWeight = if latest.phase == "night" then 1 else 0.45
	vignette.BackgroundTransparency = 1 - over * 0.55 * nightWeight
end

-- ---------------------------------------------------------------- moments

function SurviveHud.toast(message: string, tone: string)
	if openingActive then
		table.insert(heldToasts, { message = message, tone = tone })
		return
	end
	local color = theme.uiText
	if tone == "good" then
		color = theme.uiGood
	elseif tone == "warn" then
		color = theme.uiWarn
	end

	local item = panel({
		BackgroundColor3 = theme.uiBackground,
		BackgroundTransparency = 0.15,
		Size = UDim2.fromOffset(460, 50),
		Parent = toastHolder,
	}, {
		text({
			Size = UDim2.fromScale(1, 1),
			Font = Enum.Font.GothamBold,
			Text = message,
			TextColor3 = color,
			TextXAlignment = Enum.TextXAlignment.Center,
		}),
		UIKit.padding(10),
	})

	task.delay(3.2, function()
		local fade = TweenInfo.new(0.6)
		TweenService:Create(item, fade, { BackgroundTransparency = 1 }):Play()
		for _, child in item:GetDescendants() do
			if child:IsA("TextLabel") then
				TweenService:Create(child, fade, { TextTransparency = 1 }):Play()
			end
		end
		task.wait(0.65)
		item:Destroy()
	end)
end

local function fadeFromBlack(seconds: number)
	blackout.BackgroundTransparency = 0
	TweenService:Create(blackout, TweenInfo.new(seconds, Enum.EasingStyle.Sine), { BackgroundTransparency = 1 }):Play()
end

local function showEnd(payload: any)
	local title = endPanel:FindFirstChild("Title") :: TextLabel
	local body = endPanel:FindFirstChild("Body") :: TextLabel
	title.Text = if payload.won then theme.copy.weekDone else theme.copy.lightOut
	body.Text =
		`{string.upper(theme.copy.dayLabel)} {payload.days + 1}   ·   {string.upper(theme.copy.scoreLabel)} {Format.short(
			payload.score
		)}`
	endPanel.Visible = true
	task.delay(6, function()
		endPanel.Visible = false
	end)
end

function SurviveHud.fx(kind: string, payload: any?)
	if kind == "inspect" then
		local p = inspectPanel
		if not p or typeof(payload) ~= "table" then
			return
		end
		if inspectTitle then
			inspectTitle.Text = payload.title or ""
			inspectTitle.Visible = (payload.title or "") ~= ""
		end
		if inspectBody then
			inspectBody.Text = payload.body or ""
		end
		if inspectState then
			inspectState.Text = payload.state or ""
			inspectState.Visible = (payload.state or "") ~= ""
		end
		p.Visible = true
		-- Stays up long enough to read, then gets out of the way on its own. The
		-- token guards against an earlier inspect closing a later one.
		inspectToken += 1
		local mine = inspectToken
		task.delay(9, function()
			if inspectToken == mine and inspectPanel then
				inspectPanel.Visible = false
			end
		end)
		return
	end
	if kind == "fadeIn" then
		if not openingActive then
			fadeFromBlack(1.4)
		end
	elseif kind == "downed" then
		blackout.BackgroundTransparency = 0.1
		task.delay(0.9, function()
			fadeFromBlack(1.2)
		end)
	elseif kind == "feed" then
		-- The flare: a quick warm wash the whole screen feels.
		local flash = UIKit.create("Frame", {
			BackgroundColor3 = theme.colors.flame,
			BackgroundTransparency = 0.8,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 2,
			Parent = gui,
		})
		TweenService:Create(flash, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
		task.delay(0.55, function()
			flash:Destroy()
		end)
	elseif kind == "lure" then
		local flash = UIKit.create("Frame", {
			BackgroundColor3 = theme.colors.lure,
			BackgroundTransparency = 0.75,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 2,
			Parent = gui,
		})
		TweenService:Create(flash, TweenInfo.new(0.9), { BackgroundTransparency = 1 }):Play()
		task.delay(0.95, function()
			flash:Destroy()
		end)
	elseif kind == "pulse" then
		local original = fuelText.TextColor3
		for _ = 1, 3 do
			fuelText.TextColor3 = theme.accent
			task.wait(0.25)
			fuelText.TextColor3 = original
			task.wait(0.25)
		end
	elseif kind == "runEnd" then
		showEnd(payload or { won = false, days = 0, score = 0 })
	end
end

-- ---------------------------------------------------------------- build

function SurviveHud.init(): ScreenGui
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

	gui = UIKit.create("ScreenGui", {
		Name = "SurviveHud",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = playerGui,
	})

	-- vignette (below everything) --------------------------------------------
	vignette = UIKit.create("Frame", {
		Name = "Vignette",
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 0,
		Parent = gui,
	})
	UIKit.create("UIGradient", {
		Color = ColorSequence.new(Color3.new(0, 0, 0)),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.35, 1),
			NumberSequenceKeypoint.new(0.65, 1),
			NumberSequenceKeypoint.new(1, 0),
		}),
		Parent = vignette,
	})

	-- day badge ---------------------------------------------------------------
	local dayFrame = panel({
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 14),
		Size = UDim2.fromOffset(220, 70),
		Parent = gui,
	})
	dayValue = text({
		Position = UDim2.fromOffset(0, 6),
		Size = UDim2.new(1, 0, 0, 36),
		Font = Enum.Font.GothamBlack,
		Text = `{string.upper(theme.copy.dayLabel)} 1`,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = dayFrame,
	})
	dayFill = bar(dayFrame, 50, theme.accent)
	weightRow = UIKit.create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 1, 4),
		Size = UDim2.new(1, 0, 0, 10),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = dayFrame,
	}, {
		UIKit.create("UIListLayout", {
			Padding = UDim.new(0, 4),
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	-- beacon fuel -----------------------------------------------------------
	local fuelFrame = panel({
		Position = UDim2.fromOffset(16, 16),
		Size = UDim2.fromOffset(240, 62),
		Parent = gui,
	})
	fuelText = text({
		Position = UDim2.fromOffset(12, 6),
		Size = UDim2.new(1, -24, 0, 26),
		Font = Enum.Font.GothamBold,
		Text = `{string.upper(theme.names.beacon)}  0`,
		TextColor3 = theme.accent,
		Parent = fuelFrame,
	})
	fuelFill = bar(fuelFrame, 40, theme.accent)

	-- sack ------------------------------------------------------------------
	local sackFrame = panel({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -16, 0, 16),
		Size = UDim2.fromOffset(200, 62),
		Parent = gui,
	})
	sackText = text({
		Position = UDim2.fromOffset(12, 6),
		Size = UDim2.new(1, -24, 0, 26),
		Font = Enum.Font.GothamBold,
		Text = `{string.upper(theme.names.sack)}  0 / 0`,
		Parent = sackFrame,
	})
	sackFill = bar(sackFrame, 40, theme.colors.fuel)

	-- the three buttons (bottom right, thumb reach) --------------------------
	-- PICK UP / ACTION / INFO. Always present, always labelled, dimmed when there is
	-- nothing to do. Keyboard: E, F, Tab. The server decides what each one acts on.
	ACTION_WORDS = {
		feed = theme.copy.actionFeed,
		offer = theme.copy.actionOffer,
		open = theme.copy.actionOpen,
	}

	local function bigButton(name: string, order: number, label: string): TextButton
		local button = UIKit.create("TextButton", {
			Name = name,
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -18, 1, -18 - (order - 1) * 76),
			Size = UDim2.fromOffset(178, 66),
			BackgroundColor3 = theme.uiPanel,
			BackgroundTransparency = 0.08,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			TextScaled = false,
			TextSize = 18,
			TextColor3 = theme.uiText,
			Text = label,
			AutoButtonColor = true,
			Parent = gui,
		}, { UIKit.padding(8) })
		UIKit.corner(14).Parent = button
		UIKit.stroke(Color3.fromRGB(0, 0, 0), 2).Parent = button
		return button
	end

	pickupButton = bigButton("PickUp", 3, theme.copy.pickupLabel)
	actionButton = bigButton("Action", 2, theme.copy.actionFeed)
	infoButton = bigButton("Info", 1, theme.copy.infoLabel)

	local function act(verb: string, target: Instance?)
		Net.get(Net.C2S_Act):FireServer(verb, target)
	end

	-- The inspect panel. Bottom-left, out of the way of the action buttons, hidden
	-- until asked for.
	inspectPanel = panel({
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 18, 1, -18),
		Size = UDim2.fromOffset(380, 140),
		BackgroundTransparency = 0.12,
		Visible = false,
		ZIndex = 6,
		Parent = gui,
	}, {
		UIKit.create("UIPadding", {
			PaddingTop = UDim.new(0, 12),
			PaddingBottom = UDim.new(0, 12),
			PaddingLeft = UDim.new(0, 14),
			PaddingRight = UDim.new(0, 14),
		}),
	})
	inspectTitle = text({
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, 0, 0, 26),
		Font = Enum.Font.GothamBlack,
		TextColor3 = theme.colors.flame or theme.uiText,
		ZIndex = 7,
		Parent = inspectPanel,
	})
	inspectBody = text({
		Position = UDim2.fromOffset(0, 32),
		Size = UDim2.new(1, 0, 0, 52),
		TextScaled = false,
		TextSize = 15,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		ZIndex = 7,
		Parent = inspectPanel,
	})
	inspectState = text({
		Position = UDim2.new(0, 0, 1, -26),
		Size = UDim2.new(1, 0, 0, 22),
		TextScaled = false,
		TextSize = 14,
		TextColor3 = theme.uiMuted or theme.uiText,
		ZIndex = 7,
		Parent = inspectPanel,
	})

	-- The hint. One tiny mark that appears only while something worth reading is
	-- under the cursor, and says nothing else.
	hoverHint = text({
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.62),
		Size = UDim2.fromOffset(60, 22),
		TextXAlignment = Enum.TextXAlignment.Center,
		TextScaled = false,
		TextSize = 16,
		Font = Enum.Font.GothamBold,
		TextTransparency = 0.25,
		TextStrokeTransparency = 0.6,
		Text = theme.copy.inspectHint or "[I]",
		Visible = false,
		ZIndex = 6,
		Parent = gui,
	})

	-- What is the player pointing at? Mouse target on a desktop; on a touch screen
	-- there is no hover, so fall back to whatever the camera is looking at.
	local mouse = Players.LocalPlayer:GetMouse()
	local function pointedAt(): BasePart?
		local target = mouse.Target
		if target and target:IsA("BasePart") then
			return target
		end
		local camera = workspace.CurrentCamera
		if not camera then
			return nil
		end
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { Players.LocalPlayer.Character :: any }
		local hit = workspace:Raycast(camera.CFrame.Position, camera.CFrame.LookVector * 70, params)
		return hit and hit.Instance :: BasePart or nil
	end

	-- Only mark things worth reading. The ground and the fog wall are not.
	local BORING = { Floor = true, Fog = true, Dash = true, Baseplate = true, Terrain = true }
	task.spawn(function()
		while true do
			task.wait(0.12)
			if hoverHint then
				local t = pointedAt()
				hoverHint.Visible = t ~= nil and not BORING[t.Name]
			end
		end
	end)
	pickupButton.Activated:Connect(function()
		act("pickup")
	end)
	actionButton.Activated:Connect(function()
		act("action")
	end)

	-- the INFO panel: how to play, the trials, and what the obelisk can make ----
	trialsPanel = panel({
		Name = "InfoPanel",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -206, 1, -18),
		Size = UDim2.fromOffset(420, 470),
		Visible = false,
		ZIndex = 4,
		Parent = gui,
	})
	text({
		Position = UDim2.fromOffset(18, 12),
		Size = UDim2.new(1, -36, 0, 26),
		Font = Enum.Font.GothamBlack,
		TextScaled = false,
		TextSize = 20,
		Text = theme.zoneName or theme.title,
		ZIndex = 4,
		Parent = trialsPanel,
	})
	text({
		Position = UDim2.fromOffset(18, 40),
		Size = UDim2.new(1, -36, 0, 40),
		Font = Enum.Font.GothamMedium,
		TextScaled = false,
		TextSize = 14,
		TextWrapped = true,
		Text = theme.copy.howToPlay,
		TextColor3 = theme.uiMuted,
		ZIndex = 4,
		Parent = trialsPanel,
	})
	text({
		Position = UDim2.fromOffset(18, 86),
		Size = UDim2.new(1, -36, 0, 20),
		Font = Enum.Font.GothamBold,
		TextScaled = false,
		TextSize = 15,
		Text = theme.copy.challengeTitle,
		TextColor3 = theme.accent,
		ZIndex = 4,
		Parent = trialsPanel,
	})
	trialsList = UIKit.create("Frame", {
		Position = UDim2.fromOffset(18, 108),
		Size = UDim2.new(1, -36, 0, 210),
		BackgroundTransparency = 1,
		ZIndex = 4,
		Parent = trialsPanel,
	}, { UIKit.list(2) })
	text({
		Position = UDim2.fromOffset(18, 322),
		Size = UDim2.new(1, -36, 0, 20),
		Font = Enum.Font.GothamBold,
		TextScaled = false,
		TextSize = 15,
		Text = theme.copy.recipeTitle,
		TextColor3 = theme.accent,
		ZIndex = 4,
		Parent = trialsPanel,
	})
	recipeRows = UIKit.create("Frame", {
		Position = UDim2.fromOffset(18, 344),
		Size = UDim2.new(1, -36, 0, 118),
		BackgroundTransparency = 1,
		ZIndex = 4,
		Parent = trialsPanel,
	}, { UIKit.list(1) })

	trialsButton = infoButton
	-- INFO is context-sensitive. Pointing at something? Read it. Pointing at nothing?
	-- Open the trials. One button, and it always does the thing you meant, which is
	-- the whole reason there is not a second one.
	local function toggleInfo()
		local t = pointedAt()
		if t and not BORING[t.Name] then
			act("inspect", t)
			return
		end
		trialsOpen = not trialsOpen
		trialsPanel.Visible = trialsOpen
	end
	infoButton.Activated:Connect(toggleInfo)

	-- keyboard, for anyone not on a phone
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed or input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end
		if input.KeyCode == Enum.KeyCode.E then
			act("pickup")
		elseif input.KeyCode == Enum.KeyCode.F then
			act("action")
		elseif input.KeyCode == Enum.KeyCode.Tab then
			toggleInfo()
		elseif input.KeyCode == Enum.KeyCode.I then
			act("inspect", pointedAt())
		end
	end)

	-- toasts ----------------------------------------------------------------
	toastHolder = UIKit.create("Frame", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -90),
		Size = UDim2.fromOffset(460, 200),
		BackgroundTransparency = 1,
		ZIndex = 3,
		Parent = gui,
	}, {
		UIKit.create("UIListLayout", {
			Padding = UDim.new(0, 6),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	-- run end ---------------------------------------------------------------
	endPanel = panel({
		Name = "RunEnd",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.4),
		Size = UDim2.fromOffset(460, 150),
		Visible = false,
		ZIndex = 5,
		Parent = gui,
	})
	text({
		Name = "Title",
		Position = UDim2.fromOffset(0, 22),
		Size = UDim2.new(1, 0, 0, 44),
		Font = Enum.Font.GothamBlack,
		Text = "",
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 5,
		Parent = endPanel,
	})
	text({
		Name = "Body",
		Position = UDim2.fromOffset(0, 80),
		Size = UDim2.new(1, 0, 0, 30),
		Text = "",
		TextColor3 = theme.uiMuted,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 5,
		Parent = endPanel,
	})

	-- blackout (above everything) ---------------------------------------------
	blackout = UIKit.create("Frame", {
		Name = "Blackout",
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 9,
		Parent = gui,
	})
	if theme.opening then
		openingActive = true
		-- Feet stay still while the card is up; the world is black anyway.
		local controls = nil
		pcall(function()
			local playerScripts = Players.LocalPlayer:WaitForChild("PlayerScripts", 5)
			local module = playerScripts and playerScripts:WaitForChild("PlayerModule", 5)
			controls = module and require(module):GetControls()
			if controls then
				controls:Disable()
			end
		end)
		OpeningAct.play(gui, theme.opening, function()
			openingActive = false
			fadeFromBlack(1.4)
			if controls then
				pcall(function()
					controls:Enable()
				end)
			end
			local queued = heldToasts
			heldToasts = {}
			for index, item in queued do
				task.delay(1.2 + (index - 1) * 3.4, function()
					SurviveHud.toast(item.message, item.tone)
				end)
			end
		end)
	else
		fadeFromBlack(1.4)
	end

	RunService.RenderStepped:Connect(function()
		tickClock()
		tickVignette()
	end)

	return gui
end

return SurviveHud

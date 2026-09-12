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
local theme = require(ReplicatedStorage:WaitForChild("Pack").theme)
local UIKit = require(script.Parent.UIKit)

local SurviveHud = {}

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

local latest: any = nil
local receivedAt = 0
local weightDots: { Frame } = {}

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

function SurviveHud.setState(state: any)
	latest = state
	receivedAt = os.clock()

	dayValue.Text = `{string.upper(theme.copy.dayLabel)} {math.max(1, state.day)}`
	refreshWeight(state)

	local fuelRatio = if state.fuelCap > 0 then math.clamp(state.fuel / state.fuelCap, 0, 1) else 0
	fuelFill.Size = UDim2.fromScale(fuelRatio, 1)
	fuelFill.BackgroundColor3 = if fuelRatio < 0.2 then theme.uiWarn else theme.accent
	fuelText.Text = `{string.upper(theme.names.beacon)}  {string.format("%.0f", state.fuel)}`

	local sackRatio = if state.carryCap > 0 then math.clamp(state.carry / state.carryCap, 0, 1) else 0
	sackFill.Size = UDim2.fromScale(sackRatio, 1)
	sackFill.BackgroundColor3 = if sackRatio >= 1 then theme.uiWarn else theme.colors.fuel
	sackText.Text = `{string.upper(theme.names.sack)}  {Format.short(state.carry)} / {Format.short(state.carryCap)}`
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
	if kind == "fadeIn" then
		fadeFromBlack(1.4)
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
	fadeFromBlack(1.4)

	RunService.RenderStepped:Connect(function()
		tickClock()
		tickVignette()
	end)

	return gui
end

return SurviveHud

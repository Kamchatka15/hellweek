-- Hud — everything the player reads.
--
-- Renders server truth and nothing else. There is no local balance, no local price and
-- no optimistic update: the BUY button sends an id and then waits to be told what
-- happened. That is the client half of the threat model in
-- specs/2026-09-12-fat-man-gets-rich-slice.md §5.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Format = require(Shared.Format)
local Net = require(Shared.Net)
local theme = require(ReplicatedStorage:WaitForChild("Pack").theme)
local UIKit = require(script.Parent.UIKit)

local Hud = {}

local gui: ScreenGui
local coinsValue: TextLabel
local bagFill: Frame
local bagText: TextLabel
local shopPanel: Frame
local shopList: ScrollingFrame
local shopHint: TextLabel
local toastHolder: Frame
local offlinePanel: Frame

local rows: { [string]: any } = {}
local latest: any = nil
local shopOpen = false

local function panel(props: { [string]: any }, children: { Instance }?): Frame
	local defaults = {
		BackgroundColor3 = theme.uiPanel,
		BorderSizePixel = 0,
	}
	for key, value in props do
		defaults[key] = value
	end
	local frame = UIKit.create("Frame", defaults, children)
	UIKit.corner(12).Parent = frame
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

-- ---------------------------------------------------------------- shop rows

local function buildRow(entry: any): any
	local frame = panel({
		Name = entry.id,
		BackgroundColor3 = theme.uiBackground,
		Size = UDim2.new(1, -12, 0, 88),
		LayoutOrder = #shopList:GetChildren(),
		Parent = shopList,
	})

	local label = text({
		Position = UDim2.fromOffset(14, 10),
		Size = UDim2.new(0.58, 0, 0, 24),
		Font = Enum.Font.GothamBold,
		Text = entry.label,
		Parent = frame,
	})

	local blurb = text({
		Position = UDim2.fromOffset(14, 36),
		Size = UDim2.new(0.58, 0, 0, 18),
		Text = entry.blurb,
		TextColor3 = theme.uiMuted,
		Parent = frame,
	})

	local progress = text({
		Position = UDim2.fromOffset(14, 58),
		Size = UDim2.new(0.58, 0, 0, 20),
		Font = Enum.Font.GothamBold,
		TextColor3 = theme.accent,
		Text = "",
		Parent = frame,
	})

	local button = UIKit.create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -14, 0.5, 0),
		Size = UDim2.new(0.34, 0, 0, 58),
		BackgroundColor3 = theme.uiGood,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBlack,
		TextScaled = true,
		TextColor3 = Color3.new(1, 1, 1),
		Text = "BUY",
		AutoButtonColor = true,
		Parent = frame,
	}, { UIKit.padding(8) })
	UIKit.corner(10).Parent = button

	button.Activated:Connect(function()
		Net.get(Net.C2S_Buy):FireServer(entry.id)
	end)

	local _ = label
	local _ = blurb
	return { frame = frame, progress = progress, button = button }
end

local function updateRow(row: any, entry: any, coins: number)
	local maxed = entry.cost == nil
	if maxed then
		row.progress.Text = `MAX  ({Format.short(entry.current)})`
		row.button.Text = "MAXED"
		row.button.BackgroundColor3 = theme.uiPanel
		row.button.AutoButtonColor = false
		return
	end

	row.progress.Text = `Lv {entry.level}  {Format.short(entry.current)} -> {Format.short(entry.nextValue)}`
	row.button.Text = Format.short(entry.cost)
	row.button.AutoButtonColor = true
	-- Affordability is shown, never enforced here. The server re-checks it.
	row.button.BackgroundColor3 = if coins >= entry.cost then theme.uiGood else theme.uiPanel
end

local function refreshRows()
	if not latest then
		return
	end
	shopHint.Visible = latest.coins <= 0
	for _, entry in latest.catalog do
		local row = rows[entry.id]
		if not row then
			row = buildRow(entry)
			rows[entry.id] = row
		end
		updateRow(row, entry, latest.coins)
	end
	shopList.CanvasSize = UDim2.fromOffset(0, #latest.catalog * 96 + 8)
end

-- ---------------------------------------------------------------- public

function Hud.setState(state: any)
	latest = state
	coinsValue.Text = Format.short(state.coins)

	local ratio = if state.carryCap > 0 then math.clamp(state.carry / state.carryCap, 0, 1) else 0
	bagFill.Size = UDim2.fromScale(ratio, 1)
	bagFill.BackgroundColor3 = if ratio >= 1 then theme.uiWarn else theme.accent
	bagText.Text = `{theme.copy.carryLabel}  {Format.short(state.carry)} / {Format.short(state.carryCap)}`

	if shopOpen then
		refreshRows()
	end
end

function Hud.setShopOpen(open: boolean)
	shopOpen = open
	shopPanel.Visible = open
	if open then
		refreshRows()
	end
end

function Hud.toast(message: string, tone: string)
	local color = theme.uiText
	if tone == "good" then
		color = theme.uiGood
	elseif tone == "warn" then
		color = theme.uiWarn
	end

	local item = panel({
		BackgroundColor3 = theme.uiBackground,
		BackgroundTransparency = 0.1,
		Size = UDim2.fromOffset(320, 44),
		Parent = toastHolder,
	}, {
		text({
			Size = UDim2.fromScale(1, 1),
			Font = Enum.Font.GothamBold,
			Text = message,
			TextColor3 = color,
			TextXAlignment = Enum.TextXAlignment.Center,
		}),
		UIKit.padding(8),
	})

	task.delay(2.2, function()
		local fade = TweenInfo.new(0.4)
		TweenService:Create(item, fade, { BackgroundTransparency = 1 }):Play()
		for _, child in item:GetDescendants() do
			if child:IsA("TextLabel") then
				TweenService:Create(child, fade, { TextTransparency = 1 }):Play()
			end
		end
		task.wait(0.45)
		item:Destroy()
	end)
end

function Hud.showOffline(payload: any)
	local body = offlinePanel:FindFirstChild("Body") :: TextLabel
	local amount = offlinePanel:FindFirstChild("Amount") :: TextLabel
	amount.Text = `+{Format.short(payload.amount)}`
	local note = if payload.capped then `  (capped at {payload.capText})` else ""
	body.Text = `{theme.copy.offlineBody}  Away {payload.away}.{note}`
	offlinePanel.Visible = true
end

function Hud.init(): ScreenGui
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

	gui = UIKit.create("ScreenGui", {
		Name = "PGR",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = playerGui,
	})

	-- coins ---------------------------------------------------------------
	local coinsFrame = panel({
		Position = UDim2.fromOffset(16, 16),
		Size = UDim2.fromOffset(230, 76),
		Parent = gui,
	})
	text({
		Position = UDim2.fromOffset(16, 8),
		Size = UDim2.new(1, -24, 0, 18),
		Text = string.upper(theme.currencyName),
		TextColor3 = theme.uiMuted,
		Parent = coinsFrame,
	})
	coinsValue = text({
		Position = UDim2.fromOffset(16, 26),
		Size = UDim2.new(1, -24, 0, 40),
		Font = Enum.Font.GothamBlack,
		TextColor3 = theme.accent,
		Text = "0",
		Parent = coinsFrame,
	})

	-- bag -----------------------------------------------------------------
	local bagFrame = panel({
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 16),
		Size = UDim2.fromOffset(320, 52),
		Parent = gui,
	})
	local track = UIKit.create("Frame", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -8),
		Size = UDim2.new(1, -20, 0, 12),
		BackgroundColor3 = theme.uiBackground,
		BorderSizePixel = 0,
		Parent = bagFrame,
	})
	UIKit.corner(6).Parent = track
	bagFill = UIKit.create("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = theme.accent,
		BorderSizePixel = 0,
		Parent = track,
	})
	UIKit.corner(6).Parent = bagFill
	bagText = text({
		Position = UDim2.fromOffset(10, 6),
		Size = UDim2.new(1, -20, 0, 22),
		Font = Enum.Font.GothamBold,
		Text = `{theme.copy.carryLabel}  0 / 0`,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = bagFrame,
	})

	-- shop ----------------------------------------------------------------
	local openButton = UIKit.create("TextButton", {
		Name = "OpenShop",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -16, 1, -16),
		Size = UDim2.fromOffset(190, 68),
		BackgroundColor3 = theme.shop,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBlack,
		TextScaled = true,
		TextColor3 = Color3.new(1, 1, 1),
		Text = theme.copy.shopTitle,
		Parent = gui,
	}, { UIKit.padding(12) })
	UIKit.corner(12).Parent = openButton
	openButton.Activated:Connect(function()
		Hud.setShopOpen(not shopOpen)
	end)

	shopPanel = panel({
		Name = "Shop",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(560, 460),
		Visible = false,
		ZIndex = 4,
		Parent = gui,
	})
	text({
		Position = UDim2.fromOffset(20, 14),
		Size = UDim2.new(1, -120, 0, 32),
		Font = Enum.Font.GothamBlack,
		Text = theme.copy.shopTitle,
		ZIndex = 4,
		Parent = shopPanel,
	})
	local closeButton = UIKit.create("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -16, 0, 14),
		Size = UDim2.fromOffset(44, 36),
		BackgroundColor3 = theme.uiBackground,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBlack,
		TextScaled = true,
		TextColor3 = theme.uiText,
		Text = "X",
		ZIndex = 4,
		Parent = shopPanel,
	}, { UIKit.padding(8) })
	UIKit.corner(8).Parent = closeButton
	closeButton.Activated:Connect(function()
		Hud.setShopOpen(false)
	end)

	shopList = UIKit.create("ScrollingFrame", {
		Position = UDim2.fromOffset(10, 58),
		Size = UDim2.new(1, -20, 1, -70),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 6,
		CanvasSize = UDim2.fromOffset(0, 0),
		ZIndex = 4,
		Parent = shopPanel,
	}, { UIKit.list(8) })

	shopHint = text({
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -6),
		Size = UDim2.new(1, -40, 0, 22),
		Text = theme.copy.shopEmpty,
		TextColor3 = theme.uiMuted,
		TextXAlignment = Enum.TextXAlignment.Center,
		Visible = false,
		ZIndex = 5,
		Parent = shopPanel,
	})

	-- toasts --------------------------------------------------------------
	toastHolder = UIKit.create("Frame", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -110),
		Size = UDim2.fromOffset(320, 200),
		BackgroundTransparency = 1,
		Parent = gui,
	}, {
		UIKit.create("UIListLayout", {
			Padding = UDim.new(0, 6),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	-- offline -------------------------------------------------------------
	offlinePanel = panel({
		Name = "Offline",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.45),
		Size = UDim2.fromOffset(420, 240),
		Visible = false,
		ZIndex = 6,
		Parent = gui,
	})
	text({
		Position = UDim2.fromOffset(0, 22),
		Size = UDim2.new(1, 0, 0, 26),
		Font = Enum.Font.GothamBold,
		Text = theme.copy.offlineTitle,
		TextColor3 = theme.uiMuted,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 6,
		Parent = offlinePanel,
	})
	text({
		Name = "Amount",
		Position = UDim2.fromOffset(0, 56),
		Size = UDim2.new(1, 0, 0, 76),
		Font = Enum.Font.GothamBlack,
		Text = "+0",
		TextColor3 = theme.accent,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 6,
		Parent = offlinePanel,
	})
	text({
		Name = "Body",
		Position = UDim2.fromOffset(20, 138),
		Size = UDim2.new(1, -40, 0, 24),
		Text = theme.copy.offlineBody,
		TextColor3 = theme.uiMuted,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 6,
		Parent = offlinePanel,
	})
	local okButton = UIKit.create("TextButton", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -18),
		Size = UDim2.fromOffset(200, 54),
		BackgroundColor3 = theme.uiGood,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBlack,
		TextScaled = true,
		TextColor3 = Color3.new(1, 1, 1),
		Text = "NICE",
		ZIndex = 6,
		Parent = offlinePanel,
	}, { UIKit.padding(10) })
	UIKit.corner(10).Parent = okButton
	okButton.Activated:Connect(function()
		offlinePanel.Visible = false
	end)

	return gui
end

return Hud

-- BuildHud — the three screens a build-and-launch player reads, one at a time.
--
--   WAREHOUSE   the catalogue by class: name, the two or three stats that matter, price,
--               OWNED or BUY. What you cannot afford is greyed, never hidden.
--   ASSEMBLY    the stack, bottom to top, and under it every reason it cannot fly yet,
--               as plain sentences that name the part. Red while any problem exists.
--   PAD CARD    thrust, weight, TWR, Δv, mass against the pad, the verdict, and the two
--               buttons: ROLL OUT, then LAUNCH. Two bars and a ratio: a nine-year-old
--               reads "green means it goes up"; an adult reads Tsiolkovsky.
--
-- Plus the cash, the mission board, and the altitude ribbon that takes over the screen
-- while something is flying. Renders server truth and sends verbs only (C2S_Act). This
-- file never holds a price, a balance or an altitude of its own: it draws the last
-- packet and asks. Every string it shows comes from the pack's theme.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Format = require(Shared.Format)
local Net = require(Shared.Net)
local Pack = ReplicatedStorage:WaitForChild("Pack")
local theme = require(Pack:WaitForChild("theme"))
local Rocket = require(Pack:WaitForChild("rocket"))
local UIKit = require(script.Parent.UIKit)
local Hotbar = require(script.Parent.Hotbar)

local BuildHud = {}

local copy = theme.copy
local player = Players.LocalPlayer

local SCREEN_W, SCREEN_H = 820, 540
local GROUPS = {
	{ id = "engines", key = "groupEngines" },
	{ id = "tanks", key = "groupTanks" },
	{ id = "aero", key = "groupAero" },
	{ id = "avionics", key = "groupAvionics" },
	{ id = "structure", key = "groupStructure" },
	{ id = "mission", key = "groupMission" },
	{ id = "pad", key = "groupPad" },
}
local STAGE_SLOTS = { "engine", "tank", "decoupler", "fins", "recovery" }
local SLOT_CLASS = { engine = "engine", tank = "tank", decoupler = "decoupler", fins = "fin", recovery = "recovery" }
local SLOT_LABEL = { engine = "engine", tank = "tank", decoupler = "decoupler", fins = "fins", recovery = "recovery" }
local OPTIONAL_SLOT = { decoupler = true, fins = true, recovery = true }

-- ---------------------------------------------------------------- state

local latest: any = nil
local receivedAt = 0
local draft: any = { stages = {} }
local pendingSig: string? = nil
local pendingAt = 0
local screen = "none"
local groupId = "engines"
local byId: { [string]: any } = {}
local telemetry: any = nil
local flightMine = false
local following = false
local warehouseRows: { [string]: any } = {}
local warehouseGroupBuilt: string? = nil
local assemblySig: string? = nil
local previewSig: string? = nil
local missionsOpen = false

-- widgets
local gui: ScreenGui
local root: Frame
local cashValue: TextLabel
local ribbon: Frame
local ribbonBig: TextLabel
local ribbonPhase: TextLabel
local ribbonSub: TextLabel
local navButtons: { [string]: TextButton } = {}
local screenPanel: Frame
local screenTitle: TextLabel
local screenBody: Frame
local toastHolder: Frame
local blackout: Frame
local payoutPanel: Frame
local missionsButton: TextButton
local missionsPanel: Frame
local missionsList: Frame
local tierList: Frame

-- per-screen widgets (rebuilt when the screen opens)
local warehouseList: ScrollingFrame? = nil
local groupButtons: { [string]: TextButton } = {}
local stackList: ScrollingFrame? = nil
local previewHolder: Frame? = nil
local previewView: ViewportFrame? = nil
local problemsList: Frame? = nil
local readyLabel: TextLabel? = nil
local miniCard: TextLabel? = nil
local cardWidgets: any = nil

-- ---------------------------------------------------------------- helpers

local function panel(props: { [string]: any }, children: { Instance }?): Frame
	local defaults = {
		BackgroundColor3 = theme.uiPanel,
		BackgroundTransparency = 0.06,
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
		TextScaled = false,
		TextSize = 15,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}
	for key, value in props do
		defaults[key] = value
	end
	return UIKit.create("TextLabel", defaults)
end

local function button(props: { [string]: any }, onClick: (() -> ())?): TextButton
	local defaults = {
		BackgroundColor3 = theme.uiPanel,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		TextScaled = false,
		TextSize = 15,
		TextColor3 = theme.uiText,
		AutoButtonColor = true,
	}
	for key, value in props do
		defaults[key] = value
	end
	local made = UIKit.create("TextButton", defaults)
	UIKit.corner(8).Parent = made
	if onClick then
		made.Activated:Connect(onClick)
	end
	return made
end

local function bar(parent: Instance, position: UDim2, width: UDim, color: Color3): Frame
	local track = UIKit.create("Frame", {
		Position = position,
		Size = UDim2.new(width, UDim.new(0, 12)),
		BackgroundColor3 = theme.uiBackground,
		BorderSizePixel = 0,
		Parent = parent,
	})
	UIKit.corner(6).Parent = track
	local fill = UIKit.create("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Parent = track,
	})
	UIKit.corner(6).Parent = fill
	return fill
end

local function send(verb: string, payload: any?)
	Net.get(Net.C2S_Act):FireServer(verb, payload)
end

local function money(amount: number): string
	return `{theme.currencySymbol or "$"}{Format.short(amount)}`
end

local function commas(n: number): string
	local s = tostring(math.floor(n + 0.5))
	local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
	return (out:gsub("^,", ""))
end

local function altitude(h: number): string
	if h < 1000 then
		return `{math.floor(h)} m`
	end
	return `{string.format("%.1f", h / 1000)} km`
end

local function tonnes(kg: number): string
	return `{string.format("%.1f", kg / 1000)} t`
end

--- Build a model from silhouette specs and photograph it. The icon IS the part.
local function viewOf(parent: Instance, specs: { any }): ViewportFrame?
	if #specs == 0 then
		return nil
	end
	local model = Instance.new("Model")
	for _, spec in specs do
		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.Shape = spec.shape or Enum.PartType.Block
		part.Size = spec.size
		part.CFrame = spec.cframe or CFrame.new(spec.position or Vector3.zero)
		part.Color = spec.color or Color3.fromRGB(200, 200, 200)
		part.Material = spec.material or Enum.Material.SmoothPlastic
		part.TopSurface = Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth
		part.Parent = model
	end
	local view = Hotbar.iconOf(parent, model)
	model:Destroy()
	return view
end

local function signatureOf(asm: any): string
	local bits = {}
	for _, s in ipairs(asm.stages or {}) do
		table.insert(
			bits,
			`{s.engine or "-"}x{s.engineCount or 1}/{s.tank or "-"}/{s.decoupler or "-"}/{s.fins or "-"}/{s.recovery or "-"}`
		)
	end
	table.insert(
		bits,
		`{asm.nose or "-"}/{asm.gnc or "-"}/{asm.payload or "-"}/{asm.rcs and 1 or 0}/{asm.dock and 1 or 0}`
	)
	return table.concat(bits, "|")
end

local function copyAssembly(asm: any): any
	local out = { stages = {}, rcs = asm.rcs == true, dock = asm.dock == true }
	for i, s in ipairs(asm.stages or {}) do
		out.stages[i] = {
			engine = s.engine,
			tank = s.tank,
			decoupler = s.decoupler,
			fins = s.fins,
			recovery = s.recovery,
			engineCount = s.engineCount or 1,
		}
	end
	out.nose = asm.nose
	out.gnc = asm.gnc
	out.payload = asm.payload
	return out
end

local function rebuildIndex()
	byId = {}
	for _, group in latest.catalogue or {} do
		for _, row in group.rows do
			byId[row.id] = row
		end
	end
end

--- Owned parts of a class, in catalogue order (cheapest first).
local function ownedOfClass(class: string): { string }
	local out = {}
	for _, group in latest.catalogue or {} do
		if group.id == "pad" then
			continue
		end
		for _, row in group.rows do
			if row.class == class and row.owned then
				table.insert(out, row.id)
			end
		end
	end
	return out
end

local function labelOf(id: string?): string
	if not id then
		return copy.none
	end
	local part = byId[id]
	return if part then part.label else id
end

-- ---------------------------------------------------------------- the draft

local function commitDraft()
	pendingSig = signatureOf(draft)
	pendingAt = os.clock()
	send("assembly:set", draft)
end

--- Step a slot through the parts the player owns of its class. Optional slots include
--- NONE; required ones do not.
local function cycle(current: string?, class: string, direction: number, allowNone: boolean): string?
	local options = ownedOfClass(class)
	if allowNone then
		table.insert(options, 1, "")
	end
	if #options == 0 then
		return current
	end
	local index = 1
	for i, id in options do
		if id == (current or "") then
			index = i
			break
		end
	end
	index = ((index - 1 + direction) % #options) + 1
	local chosen = options[index]
	return if chosen == "" then nil else chosen
end

-- ---------------------------------------------------------------- warehouse

local function statsLine(row: any): (string, string)
	local class = row.class
	local stats, tags = {}, {}
	if class == "engine" then
		table.insert(stats, `{copy.statThrust} {string.format("%.0f", (row.thrust or 0) / 1000)} kN`)
		table.insert(stats, `{copy.statIsp} {row.isp or 0} s`)
		table.insert(stats, `{copy.statMass} {commas(row.mass or 0)} kg`)
		if row.vacuum then
			table.insert(tags, copy.tagVacuum)
		end
	elseif class == "tank" then
		table.insert(stats, `{copy.statProp} {commas(row.prop or 0)} kg`)
		table.insert(stats, `{copy.statMass} {commas(row.mass or 0)} kg`)
	elseif class == "nose" then
		table.insert(stats, `{copy.statCd} {row.cd or 0}`)
		table.insert(stats, `{copy.statMass} {commas(row.mass or 0)} kg`)
	elseif class == "fin" then
		table.insert(stats, `{copy.statControl} {row.control or 0}`)
		table.insert(stats, `{copy.statMass} {commas(row.mass or 0)} kg`)
		if row.reusable then
			table.insert(tags, copy.tagReusable)
		end
	elseif class == "gnc" then
		table.insert(stats, `{copy.statTurn} {row.turn or 0}`)
		table.insert(stats, `{copy.statMass} {commas(row.mass or 0)} kg`)
	elseif class == "recovery" then
		table.insert(stats, `{copy.statRefund} {math.floor((row.refund or 0) * 100)}%`)
		table.insert(stats, `{copy.statMass} {commas(row.mass or 0)} kg`)
		if row.needs then
			table.insert(tags, copy.tagNeedsGrid)
		end
	elseif row.massLimit then
		table.insert(stats, `{copy.statLimit} {tonnes(row.massLimit)}`)
	else
		table.insert(stats, `{copy.statMass} {commas(row.mass or 0)} kg`)
		if row.needsFairing then
			table.insert(tags, copy.tagNeedsFairing)
		end
		if class == "dock" then
			table.insert(tags, copy.tagNeedsRcs)
		end
	end
	return table.concat(stats, "   ·   "), table.concat(tags, "   ·   ")
end

local function buildWarehouseRow(row: any, order: number): any
	local frame = panel({
		Name = row.id,
		BackgroundColor3 = theme.uiBackground,
		BackgroundTransparency = 0,
		Size = UDim2.new(1, -10, 0, 76),
		LayoutOrder = order,
		Parent = warehouseList,
	})
	local iconHolder = UIKit.create("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(8, 8),
		Size = UDim2.fromOffset(60, 60),
		Parent = frame,
	})
	viewOf(iconHolder, Rocket.icon(row))

	local stats, tags = statsLine(row)
	text({
		Position = UDim2.fromOffset(80, 8),
		Size = UDim2.new(1, -260, 0, 22),
		Font = Enum.Font.GothamBold,
		TextSize = 17,
		Text = row.label,
		Parent = frame,
	})
	text({
		Position = UDim2.fromOffset(80, 31),
		Size = UDim2.new(1, -260, 0, 18),
		TextSize = 13,
		TextColor3 = theme.uiMuted,
		Text = stats,
		Parent = frame,
	})
	text({
		Name = "Tags",
		Position = UDim2.fromOffset(80, 50),
		Size = UDim2.new(1, -260, 0, 18),
		TextSize = 12,
		Font = Enum.Font.GothamBold,
		TextColor3 = theme.accent,
		Text = tags,
		Parent = frame,
	})
	local action = button({
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(150, 46),
		TextSize = 16,
		Text = "",
		Parent = frame,
	}, function()
		if row.massLimit then
			send("pad:upgrade")
		else
			send(`warehouse:buy:{row.id}`)
		end
	end)
	return { frame = frame, action = action }
end

local function updateWarehouseRow(widgets: any, row: any)
	local action = widgets.action
	if row.massLimit then
		-- a pad tier
		if row.current then
			action.Text = copy.yourPad
			action.BackgroundColor3 = theme.uiPanel
			action.TextColor3 = theme.uiMuted
			action.AutoButtonColor = false
		elseif row.owned then
			action.Text = copy.owned
			action.BackgroundColor3 = theme.uiPanel
			action.TextColor3 = theme.uiMuted
			action.AutoButtonColor = false
		elseif row.next then
			action.Text = `{copy.upgradePad}  {money(row.cost or 0)}`
			action.BackgroundColor3 = if row.affordable then theme.uiGood else theme.uiPanel
			action.TextColor3 = if row.affordable then Color3.new(1, 1, 1) else theme.uiMuted
			action.AutoButtonColor = true
		else
			action.Text = copy.padLater
			action.BackgroundColor3 = theme.uiPanel
			action.TextColor3 = theme.uiMuted
			action.AutoButtonColor = false
		end
		return
	end
	if row.owned then
		action.Text = copy.owned
		action.BackgroundColor3 = theme.uiPanel
		action.TextColor3 = theme.uiMuted
		action.AutoButtonColor = false
	else
		action.Text = `{copy.buy}  {money(row.cost or 0)}`
		-- Affordability is shown, never enforced here. The server re-checks it, and a
		-- press on a grey button gets told exactly how much more it needs.
		action.BackgroundColor3 = if row.affordable then theme.uiGood else theme.uiPanel
		action.TextColor3 = if row.affordable then Color3.new(1, 1, 1) else theme.uiMuted
		action.AutoButtonColor = true
	end
end

local function refreshWarehouse()
	if screen ~= "warehouse" or not warehouseList or not latest then
		return
	end
	if warehouseGroupBuilt ~= groupId then
		for id, widgets in warehouseRows do
			widgets.frame:Destroy()
			warehouseRows[id] = nil
		end
		warehouseGroupBuilt = groupId
	end
	for id, groupButton in groupButtons do
		groupButton.BackgroundColor3 = if id == groupId then theme.accent else theme.uiPanel
		groupButton.TextColor3 = if id == groupId then Color3.fromRGB(30, 22, 10) else theme.uiText
	end
	for _, group in latest.catalogue or {} do
		if group.id ~= groupId then
			continue
		end
		for order, row in group.rows do
			local widgets = warehouseRows[row.id]
			if not widgets then
				widgets = buildWarehouseRow(row, order)
				warehouseRows[row.id] = widgets
			end
			updateWarehouseRow(widgets, row)
		end
	end
end

local function buildWarehouse(body: Frame)
	local side = UIKit.create("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromOffset(150, SCREEN_H - 70),
		Parent = body,
	}, { UIKit.list(6) })
	groupButtons = {}
	for order, group in GROUPS do
		groupButtons[group.id] = button({
			Size = UDim2.new(1, -8, 0, 40),
			LayoutOrder = order,
			Text = copy[group.key] or group.id,
			Parent = side,
		}, function()
			groupId = group.id
			refreshWarehouse()
		end)
	end
	warehouseList = UIKit.create("ScrollingFrame", {
		Position = UDim2.fromOffset(160, 0),
		Size = UDim2.new(1, -160, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 6,
		CanvasSize = UDim2.fromOffset(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = body,
	}, { UIKit.list(6) })
	warehouseRows = {}
	warehouseGroupBuilt = nil
	refreshWarehouse()
end

-- ---------------------------------------------------------------- assembly

local function slotRow(parent: Instance, order: number, label: string, value: string, onStep: (number) -> ()): TextLabel
	local row = UIKit.create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 34),
		LayoutOrder = order,
		Parent = parent,
	})
	text({
		Position = UDim2.fromOffset(6, 0),
		Size = UDim2.fromOffset(110, 34),
		TextSize = 13,
		Font = Enum.Font.GothamBold,
		TextColor3 = theme.uiMuted,
		Text = string.upper(label),
		Parent = row,
	})
	button({
		Position = UDim2.fromOffset(118, 3),
		Size = UDim2.fromOffset(30, 28),
		Text = "<",
		Parent = row,
	}, function()
		onStep(-1)
	end)
	local valueLabel = text({
		Position = UDim2.fromOffset(152, 0),
		Size = UDim2.new(1, -196, 0, 34),
		TextSize = 15,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Center,
		Text = value,
		Parent = row,
	})
	button({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -6, 0, 3),
		Size = UDim2.fromOffset(30, 28),
		Text = ">",
		Parent = row,
	}, function()
		onStep(1)
	end)
	return valueLabel
end

local function sectionHeader(parent: Instance, order: number, label: string, extra: TextButton?): Frame
	local row = UIKit.create("Frame", {
		BackgroundColor3 = theme.uiBackground,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 30),
		LayoutOrder = order,
		Parent = parent,
	})
	UIKit.corner(6).Parent = row
	text({
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.new(1, -120, 0, 30),
		TextSize = 14,
		Font = Enum.Font.GothamBlack,
		TextColor3 = theme.accent,
		Text = label,
		Parent = row,
	})
	if extra then
		extra.Parent = row
	end
	return row
end

local function rebuildStack()
	if not stackList or not latest then
		return
	end
	for _, child in stackList:GetChildren() do
		if not child:IsA("UIListLayout") then
			child:Destroy()
		end
	end
	local order = 0
	local function nextOrder(): number
		order += 1
		return order
	end

	-- The top of the rocket first, because the list reads top to bottom like the stack.
	sectionHeader(stackList, nextOrder(), string.upper(copy.nose) .. "  ·  " .. string.upper(copy.guidance))
	slotRow(stackList, nextOrder(), copy.nose, labelOf(draft.nose), function(direction)
		draft.nose = cycle(draft.nose, "nose", direction, true)
		commitDraft()
		rebuildStack()
	end)
	slotRow(stackList, nextOrder(), copy.guidance, labelOf(draft.gnc), function(direction)
		draft.gnc = cycle(draft.gnc, "gnc", direction, false)
		commitDraft()
		rebuildStack()
	end)
	slotRow(stackList, nextOrder(), copy.payload, labelOf(draft.payload), function(direction)
		draft.payload = cycle(draft.payload, "payload", direction, true)
		commitDraft()
		rebuildStack()
	end)
	for _, entry in
		{ { key = "rcs", class = "rcs", label = copy.rcs }, { key = "dock", class = "dock", label = copy.dock } }
	do
		local owned = #ownedOfClass(entry.class) > 0
		local state = if not owned
			then copy.buy .. " → " .. copy.navWarehouse
			else (if draft[entry.key] then copy.on else copy.off)
		slotRow(stackList, nextOrder(), entry.label, state, function()
			if not owned then
				return
			end
			draft[entry.key] = not draft[entry.key]
			commitDraft()
			rebuildStack()
		end)
	end

	local stages = draft.stages
	for i = #stages, 1, -1 do
		local s = stages[i]
		local remove = button({
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -6, 0.5, 0),
			Size = UDim2.fromOffset(96, 24),
			TextSize = 12,
			Text = copy.removeStage,
			BackgroundColor3 = theme.uiPanel,
			TextColor3 = theme.uiMuted,
		}, function()
			table.remove(draft.stages, i)
			commitDraft()
			rebuildStack()
		end)
		sectionHeader(stackList, nextOrder(), `{copy.stage} {i}`, remove)
		for _, slot in STAGE_SLOTS do
			if slot == "fins" and i ~= 1 then
				continue -- only the first stage steers off the pad
			end
			slotRow(stackList, nextOrder(), copy[SLOT_LABEL[slot]], labelOf(s[slot]), function(direction)
				s[slot] = cycle(s[slot], SLOT_CLASS[slot], direction, OPTIONAL_SLOT[slot] == true)
				commitDraft()
				rebuildStack()
			end)
			if slot == "engine" then
				slotRow(stackList, nextOrder(), copy.engineCount, tostring(s.engineCount or 1), function(direction)
					local limit = (latest.limits and latest.limits.maxEngines) or 4
					s.engineCount = math.clamp((s.engineCount or 1) + direction, 1, limit)
					commitDraft()
					rebuildStack()
				end)
			end
		end
	end

	local limitStages = (latest.limits and latest.limits.maxStages) or 4
	local footer = UIKit.create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 40),
		LayoutOrder = nextOrder(),
		Parent = stackList,
	})
	if #stages < limitStages then
		button({
			Position = UDim2.fromOffset(6, 4),
			Size = UDim2.fromOffset(170, 32),
			Text = copy.addStage,
			BackgroundColor3 = theme.uiGood,
			TextColor3 = Color3.new(1, 1, 1),
			Parent = footer,
		}, function()
			local engines = ownedOfClass("engine")
			local tanks = ownedOfClass("tank")
			table.insert(draft.stages, { engine = engines[1], tank = tanks[1], engineCount = 1 })
			commitDraft()
			rebuildStack()
		end)
	end
	button({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -6, 0, 4),
		Size = UDim2.fromOffset(150, 32),
		Text = copy.clear,
		TextColor3 = theme.uiMuted,
		Parent = footer,
	}, function()
		draft = { stages = {}, rcs = false, dock = false }
		send("assembly:clear")
		rebuildStack()
	end)
	assemblySig = signatureOf(draft)
end

local function refreshPreview()
	if not previewHolder then
		return
	end
	local sig = signatureOf(draft)
	if sig == previewSig and previewView then
		return
	end
	previewSig = sig
	if previewView then
		previewView:Destroy()
		previewView = nil
	end
	local specs = Rocket.stack(draft, byId)
	previewView = viewOf(previewHolder, specs)
end

local function refreshProblems()
	if not problemsList or not latest then
		return
	end
	for _, child in problemsList:GetChildren() do
		if not child:IsA("UIListLayout") then
			child:Destroy()
		end
	end
	local problems = latest.problems or {}
	if readyLabel then
		readyLabel.Text = if #problems == 0 then copy.ready else copy.problemsTitle
		readyLabel.TextColor3 = if #problems == 0 then theme.uiGood else theme.uiBad
	end
	for index, problem in problems do
		text({
			Size = UDim2.new(1, 0, 0, 36),
			TextSize = 13,
			TextWrapped = true,
			TextTruncate = Enum.TextTruncate.None,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextColor3 = theme.uiBad,
			Text = `• {problem.text}`,
			LayoutOrder = index,
			Parent = problemsList,
		})
	end
	if miniCard then
		local card = latest.card
		if card then
			miniCard.Text = `{copy.liftoff} {string.format("%.2f", card.twr)} : 1     {copy.deltaV} {commas(
				card.effectiveDV
			)} m/s     {copy.apogee} {altitude(card.apogee or 0)}`
		else
			miniCard.Text = copy.noCard
		end
	end
end

local function buildAssembly(body: Frame)
	stackList = UIKit.create("ScrollingFrame", {
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromScale(0.56, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 6,
		CanvasSize = UDim2.fromOffset(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = body,
	}, { UIKit.list(4) })

	local right = UIKit.create("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.58, 0),
		Size = UDim2.fromScale(0.42, 1),
		Parent = body,
	})
	previewHolder = panel({
		BackgroundColor3 = theme.uiBackground,
		BackgroundTransparency = 0,
		Size = UDim2.new(1, 0, 0, 200),
		Parent = right,
	})
	miniCard = text({
		Position = UDim2.fromOffset(0, 208),
		Size = UDim2.new(1, 0, 0, 36),
		TextSize = 12,
		TextWrapped = true,
		TextTruncate = Enum.TextTruncate.None,
		Font = Enum.Font.GothamBold,
		TextColor3 = theme.uiMuted,
		Text = "",
		Parent = right,
	})
	readyLabel = text({
		Position = UDim2.fromOffset(0, 250),
		Size = UDim2.new(1, 0, 0, 22),
		TextSize = 14,
		Font = Enum.Font.GothamBlack,
		Text = "",
		Parent = right,
	})
	problemsList = UIKit.create("ScrollingFrame", {
		Position = UDim2.fromOffset(0, 276),
		Size = UDim2.new(1, 0, 1, -276),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		CanvasSize = UDim2.fromOffset(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = right,
	}, { UIKit.list(2) })
	previewSig = nil
	rebuildStack()
	refreshPreview()
	refreshProblems()
end

-- ---------------------------------------------------------------- pad card

local function refreshCard()
	if screen ~= "pad" or not cardWidgets or not latest then
		return
	end
	local w = cardWidgets
	local card = latest.card
	local problems = latest.problems or {}
	local pad = latest.pad or {}
	local flying = pad.state == "flying"

	if card then
		local thrust, weight = card.thrust or 0, card.weight or 0
		local top = math.max(thrust, weight, 1)
		w.thrustValue.Text = `{string.format("%.0f", thrust / 1000)} kN`
		w.weightValue.Text = `{string.format("%.0f", weight / 1000)} kN`
		w.thrustFill.Size = UDim2.fromScale(thrust / top, 1)
		w.weightFill.Size = UDim2.fromScale(weight / top, 1)
		local good = (card.twr or 0) > 1.0
		w.thrustFill.BackgroundColor3 = if good then theme.uiGood else theme.uiBad
		w.ratio.Text = `{copy.liftoff}  {string.format("%.2f", card.twr or 0)} : 1`
		w.ratio.TextColor3 = if good then theme.uiGood else theme.uiBad
		w.verdict.Text = card.verdict or ""
		w.verdict.TextColor3 = if (card.twr or 0) <= 1.0
			then theme.uiBad
			elseif (card.twr or 0) < 1.2 or (card.twr or 0) > 3.2 then theme.uiWarn
			else theme.uiGood
		local needs = card.orbitNeeds or latest.orbitDV or 7700
		local effective = card.effectiveDV or 0
		w.dvValue.Text = `{commas(effective)} m/s   ·   {copy.orbitNeeds} {commas(needs)}`
		w.dvFill.Size = UDim2.fromScale(math.clamp(effective / needs, 0, 1), 1)
		w.dvFill.BackgroundColor3 = if effective >= needs then theme.uiGood else theme.accent
		local mass, limit = card.mass or 0, card.padLimit or 1
		w.massValue.Text = `{tonnes(mass)}   ·   {copy.padLimit} {tonnes(limit)}  ({latest.padLabel or ""})`
		w.massFill.Size = UDim2.fromScale(math.clamp(mass / limit, 0, 1), 1)
		w.massFill.BackgroundColor3 = if mass > limit then theme.uiBad else theme.uiGood
		w.apogee.Text = `{copy.apogee}  {if card.orbit then copy.willOrbit else altitude(card.apogee or 0)}`
		w.refurb.Text = `{copy.refurbish}  −{money(latest.refurbish or 0)}`
	else
		for _, key in { "thrustValue", "weightValue", "dvValue", "massValue" } do
			w[key].Text = "—"
		end
		w.thrustFill.Size = UDim2.fromScale(0, 1)
		w.weightFill.Size = UDim2.fromScale(0, 1)
		w.dvFill.Size = UDim2.fromScale(0, 1)
		w.massFill.Size = UDim2.fromScale(0, 1)
		w.ratio.Text = copy.liftoff .. "  —"
		w.ratio.TextColor3 = theme.uiMuted
		w.verdict.Text = copy.noCard
		w.verdict.TextColor3 = theme.uiMuted
		w.apogee.Text = ""
		w.refurb.Text = ""
	end

	for _, child in w.problems:GetChildren() do
		if not child:IsA("UIListLayout") then
			child:Destroy()
		end
	end
	for index, problem in problems do
		text({
			Size = UDim2.new(1, 0, 0, 30),
			TextSize = 13,
			TextWrapped = true,
			TextTruncate = Enum.TextTruncate.None,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextColor3 = theme.uiBad,
			Text = `• {problem.text}`,
			LayoutOrder = index,
			Parent = w.problems,
		})
	end

	-- the two buttons: ROLL OUT while the pad is free and the stack is clean, LAUNCH once
	-- it is standing there. Both are shown, and the one that would not work is grey.
	local ready = latest.ready == true and card ~= nil
	local canRoll = ready and pad.state == "empty"
	local canLaunch = pad.mine == true and pad.state == "rolled"
	w.rollout.BackgroundColor3 = if canRoll then theme.uiGood else theme.uiPanel
	w.rollout.TextColor3 = if canRoll then Color3.new(1, 1, 1) else theme.uiMuted
	w.launch.BackgroundColor3 = if canLaunch then theme.accent else theme.uiPanel
	w.launch.TextColor3 = if canLaunch then Color3.fromRGB(30, 22, 10) else theme.uiMuted
	local status
	if flying then
		status = `{pad.ownerName or ""} {copy.flying}`
	elseif pad.state == "rolled" or pad.state == "rollout" then
		status = if pad.mine then copy.onPad else `{copy.padBusy} — {pad.ownerName or ""}`
	elseif not ready then
		status = copy.fixFirst
	else
		status = ""
	end
	w.status.Text = status
end

local function buildPadCard(body: Frame)
	local w: any = {}
	local left = UIKit.create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(0.6, 1),
		Parent = body,
	})
	local function labelled(y: number, label: string): TextLabel
		text({
			Position = UDim2.fromOffset(0, y),
			Size = UDim2.fromOffset(120, 22),
			TextSize = 13,
			Font = Enum.Font.GothamBold,
			TextColor3 = theme.uiMuted,
			Text = label,
			Parent = left,
		})
		return text({
			Position = UDim2.fromOffset(120, y),
			Size = UDim2.new(1, -120, 0, 22),
			TextSize = 15,
			Font = Enum.Font.GothamBold,
			Text = "",
			Parent = left,
		})
	end
	w.thrustValue = labelled(0, copy.thrust)
	w.thrustFill = bar(left, UDim2.fromOffset(0, 26), UDim.new(1, 0), theme.uiGood)
	w.weightValue = labelled(48, copy.weight)
	w.weightFill = bar(left, UDim2.fromOffset(0, 74), UDim.new(1, 0), theme.uiMuted)
	w.ratio = text({
		Position = UDim2.fromOffset(0, 100),
		Size = UDim2.new(1, 0, 0, 34),
		TextSize = 26,
		Font = Enum.Font.GothamBlack,
		Text = "",
		Parent = left,
	})
	w.verdict = text({
		Position = UDim2.fromOffset(0, 136),
		Size = UDim2.new(1, 0, 0, 40),
		TextSize = 15,
		TextWrapped = true,
		TextTruncate = Enum.TextTruncate.None,
		Font = Enum.Font.GothamBold,
		Text = "",
		Parent = left,
	})
	w.dvValue = labelled(186, copy.deltaV)
	w.dvFill = bar(left, UDim2.fromOffset(0, 212), UDim.new(1, 0), theme.accent)
	w.massValue = labelled(236, copy.mass)
	w.massFill = bar(left, UDim2.fromOffset(0, 262), UDim.new(1, 0), theme.uiGood)
	w.apogee = text({
		Position = UDim2.fromOffset(0, 290),
		Size = UDim2.new(1, 0, 0, 24),
		TextSize = 15,
		Font = Enum.Font.GothamBold,
		TextColor3 = theme.accent,
		Text = "",
		Parent = left,
	})
	w.refurb = text({
		Position = UDim2.fromOffset(0, 316),
		Size = UDim2.new(1, 0, 0, 22),
		TextSize = 13,
		TextColor3 = theme.uiMuted,
		Text = "",
		Parent = left,
	})
	w.problems = UIKit.create("ScrollingFrame", {
		Position = UDim2.fromOffset(0, 346),
		Size = UDim2.new(1, 0, 1, -346),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		CanvasSize = UDim2.fromOffset(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = left,
	}, { UIKit.list(2) })

	local right = UIKit.create("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.64, 0),
		Size = UDim2.fromScale(0.36, 1),
		Parent = body,
	})
	local preview = panel({
		BackgroundColor3 = theme.uiBackground,
		BackgroundTransparency = 0,
		Size = UDim2.new(1, 0, 0, 220),
		Parent = right,
	})
	if latest then
		viewOf(preview, Rocket.stack(latest.assembly or { stages = {} }, byId))
	end
	w.rollout = button({
		Position = UDim2.fromOffset(0, 236),
		Size = UDim2.new(1, 0, 0, 54),
		TextSize = 20,
		Font = Enum.Font.GothamBlack,
		Text = copy.rollout,
		Parent = right,
	}, function()
		send("pad:rollout")
	end)
	w.launch = button({
		Position = UDim2.fromOffset(0, 300),
		Size = UDim2.new(1, 0, 0, 72),
		TextSize = 28,
		Font = Enum.Font.GothamBlack,
		Text = copy.launch,
		Parent = right,
	}, function()
		send("pad:launch")
	end)
	w.status = text({
		Position = UDim2.fromOffset(0, 380),
		Size = UDim2.new(1, 0, 0, 44),
		TextSize = 13,
		TextWrapped = true,
		TextTruncate = Enum.TextTruncate.None,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextColor3 = theme.uiMuted,
		Text = "",
		Parent = right,
	})
	cardWidgets = w
	refreshCard()
end

-- ---------------------------------------------------------------- screens

local function setScreen(name: string)
	if name == screen then
		return
	end
	screen = name
	for _, child in screenBody:GetChildren() do
		child:Destroy()
	end
	warehouseList = nil
	warehouseRows = {}
	stackList = nil
	previewHolder = nil
	previewView = nil
	previewSig = nil
	problemsList = nil
	readyLabel = nil
	miniCard = nil
	cardWidgets = nil
	for id, nav in navButtons do
		nav.BackgroundColor3 = if id == name then theme.accent else theme.uiPanel
		nav.TextColor3 = if id == name then Color3.fromRGB(30, 22, 10) else theme.uiText
	end
	screenPanel.Visible = name ~= "none"
	if name == "none" or not latest then
		return
	end
	if name == "warehouse" then
		screenTitle.Text = copy.warehouseTitle
		buildWarehouse(screenBody)
	elseif name == "assembly" then
		screenTitle.Text = copy.assemblyTitle
		buildAssembly(screenBody)
	elseif name == "pad" then
		screenTitle.Text = copy.padTitle
		buildPadCard(screenBody)
	end
end

local function toggleScreen(name: string)
	setScreen(if screen == name then "none" else name)
end

-- ---------------------------------------------------------------- missions

local tierRows: { [string]: TextLabel } = {}
local missionRows: { [string]: TextLabel } = {}

local function refreshMissions()
	if not latest or not latest.board then
		return
	end
	local board = latest.board
	missionsButton.Text = `{copy.navMissions}\n{board.worldName}  {board.done}/{board.total}`
	for _, entry in board.worlds or {} do
		local row = tierRows[entry.id]
		if not row then
			row = text({
				Size = UDim2.new(1, 0, 0, 22),
				TextSize = 13,
				LayoutOrder = entry.index,
				Text = "",
				Parent = tierList,
			})
			tierRows[entry.id] = row
		end
		local badge = if entry.state == "mastered"
			then copy.tierDone
			elseif entry.state == "open" then copy.tierOpen
			else copy.tierLocked
		row.Text = `{entry.index}.  {entry.name}   —   {badge}`
		row.TextColor3 = if entry.state == "mastered"
			then theme.uiGood
			elseif entry.state == "open" then theme.uiText
			else theme.uiMuted
	end
	for id, row in missionRows do
		local keep = false
		for _, entry in board.list or {} do
			if entry.id == id then
				keep = true
			end
		end
		if not keep then
			row:Destroy()
			missionRows[id] = nil
		end
	end
	for index, entry in board.list or {} do
		local row = missionRows[entry.id]
		if not row then
			row = text({
				Size = UDim2.new(1, 0, 0, 40),
				TextSize = 13,
				RichText = true,
				TextWrapped = true,
				TextTruncate = Enum.TextTruncate.None,
				TextYAlignment = Enum.TextYAlignment.Top,
				LayoutOrder = index,
				Text = "",
				Parent = missionsList,
			})
			missionRows[entry.id] = row
		end
		local hint = if entry.hint then `\n<font color="#{theme.uiMuted:ToHex()}">{entry.hint}</font>` else ""
		row.Text = if entry.done then `<s>{entry.label}</s>` else `{entry.label}{hint}`
		row.TextColor3 = if entry.done then theme.uiMuted else theme.uiText
	end
end

-- ---------------------------------------------------------------- the ribbon

local PHASE_KEY = {
	prelaunch = "phasePrelaunch",
	ascent = "phaseAscent",
	coast = "phaseCoast",
	descent = "phaseDescent",
	recovery = "phaseRecovery",
}

local function tickRibbon()
	if not latest then
		return
	end
	local flight = latest.flight
	local pad = latest.pad or {}
	if not flight or pad.state ~= "flying" then
		ribbon.Visible = false
		return
	end
	ribbon.Visible = true
	local phase = flight.phase
	if phase == "prelaunch" then
		local remaining = math.max(0, (flight.remaining or 0) - (os.clock() - receivedAt))
		ribbonBig.Text = `{copy.countdown}{math.ceil(remaining)}`
		ribbonPhase.Text = copy.phasePrelaunch
		ribbonSub.Text = `{pad.ownerName or ""} {copy.flying}`
		return
	end
	local h = if telemetry then telemetry.h else flight.altitude or 0
	ribbonBig.Text = altitude(h)
	if flight.held then
		ribbonPhase.Text = copy.held
	else
		ribbonPhase.Text = copy[PHASE_KEY[phase or ""] or "phaseAscent"] or ""
	end
	local sub = `{copy.altitude}`
	if flight.stages and flight.stages > 1 then
		sub ..= `   ·   {copy.stage} {math.min(flight.stage or 1, flight.stages)}/{flight.stages}`
	end
	if phase == "descent" or phase == "recovery" then
		sub ..= `   ·   {copy.apogeeReached} {altitude(flight.apogee or 0)}`
	end
	ribbonSub.Text = sub
end

--- The owner's camera rides with the rocket: close at the pad, pulling back as it
--- climbs, and a long shot above the visual ceiling where the altitude reads in km.
local function followRocket()
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local world = workspace:FindFirstChild("World")
	local model = world and world:FindFirstChild("Rocket")
	local primary = model and (model :: Model).PrimaryPart
	if not primary then
		return
	end
	if not following then
		following = true
		camera.CameraType = Enum.CameraType.Scriptable
	end
	local height = (model :: Model):GetAttribute("Height") or 10
	local focus = primary.Position + Vector3.new(0, height * 0.45, 0)
	local h = if telemetry then telemetry.h else 0
	local ceiling = (latest and latest.visualCeiling) or 2000
	local distance = 20 + height * 1.3 + math.min(h, ceiling) * 0.02
	if h > ceiling then
		distance += math.log(1 + (h - ceiling) / 1000) * 35
	end
	local offset = Vector3.new(distance * 0.72, height * 0.3 + distance * 0.22, distance * 0.72)
	local goal = CFrame.lookAt(focus + offset, focus)
	camera.CFrame = camera.CFrame:Lerp(goal, 0.1)
end

local function releaseCamera()
	if not following then
		return
	end
	following = false
	local camera = workspace.CurrentCamera
	if camera then
		camera.CameraType = Enum.CameraType.Custom
	end
end

-- ---------------------------------------------------------------- moments

function BuildHud.toast(message: string, tone: string)
	local color = theme.uiText
	if tone == "good" then
		color = theme.uiGood
	elseif tone == "warn" then
		color = theme.uiWarn
	end
	local item = panel({
		BackgroundColor3 = theme.uiBackground,
		BackgroundTransparency = 0.1,
		Size = UDim2.fromOffset(520, 46),
		Parent = toastHolder,
	}, {
		text({
			Size = UDim2.fromScale(1, 1),
			Font = Enum.Font.GothamBold,
			TextSize = 15,
			Text = message,
			TextColor3 = color,
			TextXAlignment = Enum.TextXAlignment.Center,
		}),
		UIKit.padding(8),
	})
	task.delay(3.4, function()
		local fade = TweenInfo.new(0.5)
		TweenService:Create(item, fade, { BackgroundTransparency = 1 }):Play()
		for _, child in item:GetDescendants() do
			if child:IsA("TextLabel") then
				TweenService:Create(child, fade, { TextTransparency = 1 }):Play()
			end
		end
		task.wait(0.55)
		item:Destroy()
	end)
end

local function fadeFromBlack(seconds: number)
	blackout.BackgroundTransparency = 0
	TweenService:Create(blackout, TweenInfo.new(seconds, Enum.EasingStyle.Sine), { BackgroundTransparency = 1 }):Play()
end

local payoutToken = 0

local function showPayout(payload: any)
	local title = payoutPanel:FindFirstChild("Title") :: TextLabel
	local amount = payoutPanel:FindFirstChild("Amount") :: TextLabel
	local body = payoutPanel:FindFirstChild("Body") :: TextLabel
	if payload.held then
		title.Text = copy.held
		amount.Text = money(0)
		body.Text = copy.heldToast
	else
		title.Text = if payload.docked then copy.dockedReached elseif payload.orbit then copy.orbitReached else copy.paid
		amount.Text = `+{money(payload.total or 0)}`
		local lines = {}
		table.insert(
			lines,
			`{copy.apogeeReached} {altitude(payload.apogee or 0)}   ·   {copy.deltaV} {commas(payload.dv or 0)} m/s`
		)
		table.insert(
			lines,
			if payload.record then copy.newRecord else string.format(copy.repeatFlight, payload.repeatPercent or 0)
		)
		for _, bonus in payload.bonuses or {} do
			table.insert(lines, `{copy.milestone}: {bonus.label}  +{money(bonus.pay or 0)}`)
		end
		body.Text = table.concat(lines, "\n")
	end
	payoutPanel.Visible = true
	payoutToken += 1
	local mine = payoutToken
	task.delay(8, function()
		if payoutToken == mine then
			payoutPanel.Visible = false
		end
	end)
end

function BuildHud.fx(kind: string, payload: any?)
	if kind == "fadeIn" then
		fadeFromBlack(1.4)
	elseif kind == "screen" then
		if typeof(payload) == "table" and typeof(payload.name) == "string" then
			if not (latest and latest.pad and latest.pad.state == "flying" and flightMine) then
				setScreen(payload.name)
			end
		end
	elseif kind == "telemetry" then
		telemetry = payload
	elseif kind == "countdown" then
		telemetry = nil
		setScreen("none")
		missionsOpen = false
		missionsPanel.Visible = false
	elseif kind == "ignition" then
		if flightMine then
			local flash = UIKit.create("Frame", {
				BackgroundColor3 = theme.accent,
				BackgroundTransparency = 0.82,
				Size = UDim2.fromScale(1, 1),
				ZIndex = 2,
				Parent = root,
			})
			TweenService:Create(flash, TweenInfo.new(0.6), { BackgroundTransparency = 1 }):Play()
			task.delay(0.65, function()
				flash:Destroy()
			end)
		end
	elseif kind == "staged" then
		BuildHud.toast(copy.staged, "info")
	elseif kind == "apogee" then
		if typeof(payload) == "table" then
			BuildHud.toast(`{copy.apogeeReached}  {altitude(payload.apogee or 0)}`, "info")
		end
	elseif kind == "orbit" then
		BuildHud.toast(
			if typeof(payload) == "table" and payload.docked then copy.dockedReached else copy.orbitReached,
			"good"
		)
	elseif kind == "payout" then
		if typeof(payload) == "table" then
			showPayout(payload)
		end
	elseif kind == "padClear" then
		telemetry = nil
		flightMine = false
		releaseCamera()
	end
end

-- ---------------------------------------------------------------- state

function BuildHud.setState(state: any)
	latest = state
	receivedAt = os.clock()
	rebuildIndex()
	cashValue.Text = money(state.cash or 0)

	-- The draft follows the server unless a change of ours is still in flight.
	local sig = signatureOf(state.assembly or { stages = {} })
	local ours = pendingSig ~= nil and sig ~= pendingSig and os.clock() - pendingAt < 1.5
	if not ours then
		pendingSig = nil
		draft = copyAssembly(state.assembly or { stages = {} })
	end

	local pad = state.pad or {}
	flightMine = pad.state == "flying" and pad.mine == true

	refreshWarehouse()
	if screen == "assembly" then
		if signatureOf(draft) ~= assemblySig then
			rebuildStack()
		end
		refreshPreview()
		refreshProblems()
	end
	refreshCard()
	refreshMissions()
end

-- ---------------------------------------------------------------- build

function BuildHud.init(): ScreenGui
	local playerGui = player:WaitForChild("PlayerGui")

	gui = UIKit.create("ScreenGui", {
		Name = "BuildHud",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = playerGui,
	})
	-- Everything sits under one root with a UIScale, so a small screen gets the same
	-- layout smaller rather than a layout with pieces off the edge.
	root = UIKit.create("Frame", {
		Name = "Root",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Parent = gui,
	})
	local scale = UIKit.create("UIScale", { Scale = 1, Parent = root })
	local function fit()
		local camera = workspace.CurrentCamera
		if not camera then
			return
		end
		local viewport = camera.ViewportSize
		scale.Scale = math.clamp(math.min(viewport.X / 960, viewport.Y / 640), 0.55, 1)
	end
	fit()
	task.spawn(function()
		while true do
			task.wait(1)
			fit()
		end
	end)

	-- cash ---------------------------------------------------------------
	local cashFrame = panel({
		Position = UDim2.fromOffset(16, 16),
		Size = UDim2.fromOffset(230, 70),
		Parent = root,
	})
	text({
		Position = UDim2.fromOffset(14, 8),
		Size = UDim2.new(1, -24, 0, 16),
		TextSize = 12,
		Font = Enum.Font.GothamBold,
		Text = copy.cashLabel,
		TextColor3 = theme.uiMuted,
		Parent = cashFrame,
	})
	cashValue = text({
		Position = UDim2.fromOffset(14, 24),
		Size = UDim2.new(1, -24, 0, 40),
		TextSize = 30,
		Font = Enum.Font.GothamBlack,
		TextColor3 = theme.uiText,
		Text = money(0),
		Parent = cashFrame,
	})

	-- the altitude ribbon (top centre, only while something flies) ---------
	ribbon = panel({
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 14),
		Size = UDim2.fromOffset(420, 108),
		Visible = false,
		Parent = root,
	})
	ribbonPhase = text({
		Position = UDim2.fromOffset(0, 8),
		Size = UDim2.new(1, 0, 0, 18),
		TextSize = 13,
		Font = Enum.Font.GothamBold,
		TextColor3 = theme.uiMuted,
		TextXAlignment = Enum.TextXAlignment.Center,
		Text = "",
		Parent = ribbon,
	})
	ribbonBig = text({
		Position = UDim2.fromOffset(0, 26),
		Size = UDim2.new(1, 0, 0, 54),
		TextSize = 46,
		Font = Enum.Font.GothamBlack,
		TextColor3 = theme.accent,
		TextXAlignment = Enum.TextXAlignment.Center,
		Text = "0 m",
		Parent = ribbon,
	})
	ribbonSub = text({
		Position = UDim2.fromOffset(0, 82),
		Size = UDim2.new(1, 0, 0, 18),
		TextSize = 12,
		Font = Enum.Font.GothamBold,
		TextColor3 = theme.uiMuted,
		TextXAlignment = Enum.TextXAlignment.Center,
		Text = "",
		Parent = ribbon,
	})

	-- missions (top right) --------------------------------------------------
	missionsButton = button({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -16, 0, 16),
		Size = UDim2.fromOffset(230, 70),
		TextSize = 14,
		Text = copy.navMissions,
		Parent = root,
	}, function()
		missionsOpen = not missionsOpen
		missionsPanel.Visible = missionsOpen
	end)
	missionsPanel = panel({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -16, 0, 94),
		Size = UDim2.fromOffset(360, 420),
		Visible = false,
		ZIndex = 5,
		Parent = root,
	}, { UIKit.padding(14) })
	text({
		Size = UDim2.new(1, 0, 0, 24),
		TextSize = 18,
		Font = Enum.Font.GothamBlack,
		Text = copy.missionsTitle,
		ZIndex = 5,
		Parent = missionsPanel,
	})
	text({
		Position = UDim2.fromOffset(0, 26),
		Size = UDim2.new(1, 0, 0, 40),
		TextSize = 12,
		TextWrapped = true,
		TextTruncate = Enum.TextTruncate.None,
		TextColor3 = theme.uiMuted,
		Text = copy.howToPlay,
		ZIndex = 5,
		Parent = missionsPanel,
	})
	tierList = UIKit.create("Frame", {
		Position = UDim2.fromOffset(0, 70),
		Size = UDim2.new(1, 0, 0, 140),
		BackgroundTransparency = 1,
		ZIndex = 5,
		Parent = missionsPanel,
	}, { UIKit.list(1) })
	missionsList = UIKit.create("Frame", {
		Position = UDim2.fromOffset(0, 218),
		Size = UDim2.new(1, 0, 1, -218),
		BackgroundTransparency = 1,
		ZIndex = 5,
		Parent = missionsPanel,
	}, { UIKit.list(4) })

	-- the screen panel (centre) -----------------------------------------------
	screenPanel = panel({
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(SCREEN_W, SCREEN_H),
		Visible = false,
		ZIndex = 3,
		Parent = root,
	})
	screenTitle = text({
		Position = UDim2.fromOffset(20, 12),
		Size = UDim2.new(1, -120, 0, 30),
		TextSize = 22,
		Font = Enum.Font.GothamBlack,
		Text = "",
		ZIndex = 3,
		Parent = screenPanel,
	})
	button({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -14, 0, 12),
		Size = UDim2.fromOffset(90, 32),
		TextSize = 13,
		Text = copy.close,
		ZIndex = 3,
		Parent = screenPanel,
	}, function()
		setScreen("none")
	end)
	screenBody = UIKit.create("Frame", {
		Position = UDim2.fromOffset(20, 56),
		Size = UDim2.new(1, -40, 1, -70),
		BackgroundTransparency = 1,
		ZIndex = 3,
		Parent = screenPanel,
	})

	-- the nav (bottom centre): three screens, one at a time ------------------
	local nav = UIKit.create("Frame", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -16),
		Size = UDim2.fromOffset(600, 56),
		BackgroundTransparency = 1,
		ZIndex = 4,
		Parent = root,
	}, {
		UIKit.create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	for order, entry in
		{
			{ id = "warehouse", label = copy.navWarehouse },
			{ id = "assembly", label = copy.navAssembly },
			{ id = "pad", label = copy.navPad },
		}
	do
		navButtons[entry.id] = button({
			Size = UDim2.fromOffset(190, 56),
			LayoutOrder = order,
			TextSize = 17,
			Font = Enum.Font.GothamBlack,
			Text = entry.label,
			ZIndex = 4,
			Parent = nav,
		}, function()
			toggleScreen(entry.id)
		end)
	end

	-- toasts ------------------------------------------------------------------
	toastHolder = UIKit.create("Frame", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -84),
		Size = UDim2.fromOffset(520, 220),
		BackgroundTransparency = 1,
		ZIndex = 6,
		Parent = root,
	}, {
		UIKit.create("UIListLayout", {
			Padding = UDim.new(0, 6),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	-- the payout card --------------------------------------------------------
	payoutPanel = panel({
		Name = "Payout",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.42),
		Size = UDim2.fromOffset(460, 250),
		Visible = false,
		ZIndex = 7,
		Parent = root,
	})
	text({
		Name = "Title",
		Position = UDim2.fromOffset(0, 18),
		Size = UDim2.new(1, 0, 0, 26),
		TextSize = 16,
		Font = Enum.Font.GothamBold,
		TextColor3 = theme.uiMuted,
		TextXAlignment = Enum.TextXAlignment.Center,
		Text = "",
		ZIndex = 7,
		Parent = payoutPanel,
	})
	text({
		Name = "Amount",
		Position = UDim2.fromOffset(0, 46),
		Size = UDim2.new(1, 0, 0, 70),
		TextSize = 52,
		Font = Enum.Font.GothamBlack,
		TextColor3 = theme.accent,
		TextXAlignment = Enum.TextXAlignment.Center,
		Text = "",
		ZIndex = 7,
		Parent = payoutPanel,
	})
	text({
		Name = "Body",
		Position = UDim2.fromOffset(20, 122),
		Size = UDim2.new(1, -40, 0, 110),
		TextSize = 14,
		TextWrapped = true,
		TextTruncate = Enum.TextTruncate.None,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextColor3 = theme.uiText,
		Text = "",
		ZIndex = 7,
		Parent = payoutPanel,
	})
	UIKit.create("TextButton", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		ZIndex = 8,
		Parent = payoutPanel,
	}).Activated
		:Connect(function()
			payoutPanel.Visible = false
		end)

	-- blackout (above everything) -------------------------------------------
	blackout = UIKit.create("Frame", {
		Name = "Blackout",
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 9,
		Parent = root,
	})
	task.delay(6, function()
		-- If no fadeIn ever arrives (a slow profile load), do not leave the screen black.
		if blackout.BackgroundTransparency == 0 then
			fadeFromBlack(1)
		end
	end)

	-- keyboard: the three screens, the board, and close --------------------
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed or input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end
		local code = input.KeyCode
		if code == Enum.KeyCode.One then
			toggleScreen("warehouse")
		elseif code == Enum.KeyCode.Two then
			toggleScreen("assembly")
		elseif code == Enum.KeyCode.Three then
			toggleScreen("pad")
		elseif code == Enum.KeyCode.M then
			missionsOpen = not missionsOpen
			missionsPanel.Visible = missionsOpen
		elseif code == Enum.KeyCode.Escape then
			setScreen("none")
		end
	end)

	RunService.RenderStepped:Connect(function()
		tickRibbon()
		if flightMine then
			followRocket()
		elseif following then
			releaseCamera()
		end
	end)

	return gui
end

return BuildHud

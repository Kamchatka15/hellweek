-- OpeningAct — a title card over the black screen at join, from pack data.
--
-- Three registers, from theme.opening:
--   narration  — what is happening. Modest, pale, at the top.
--   voice      — what is said, IN ENGLISH. The big one: blood red, horror face, with
--                drips that run. This is the line the player is meant to read.
--   echo       — the same words in the old tongue, small and dim beneath. It is there
--                to be FELT, not read: nothing in it is needed, and a player who skips
--                straight past it has missed nothing.
-- Any tap/click/key after the first moment skips to the end. The act owns the
-- screen until it is done; the HUD holds its toasts until then.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local UIKit = require(script.Parent.UIKit)

local OpeningAct = {}

export type Spec = {
	narration: { string },
	voice: { string },
	echo: { string }?,
	skipHint: string?,
	narrationColor: Color3?,
	voiceColor: Color3?,
	voiceStroke: Color3?,
	dripColor: Color3?,
	echoColor: Color3?,
}

local SKIP_AFTER = 1.5
local FADE = 0.9

local function label(parent: Instance, props: { [string]: any }): TextLabel
	local defaults = {
		BackgroundTransparency = 1,
		TextScaled = true,
		TextTransparency = 1,
		TextStrokeTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextWrapped = true,
		ZIndex = 12,
		Parent = parent,
	}
	for key, value in props do
		defaults[key] = value
	end
	return UIKit.create("TextLabel", defaults)
end

local function fadeIn(text: TextLabel, strokeTo: number?)
	TweenService:Create(text, TweenInfo.new(FADE, Enum.EasingStyle.Sine), {
		TextTransparency = 0,
		TextStrokeTransparency = strokeTo or 1,
	}):Play()
end

-- Blood that runs off the letters: a few thin drops that grow down from the
-- baseline, then thin out. Pure UI; nothing in the world.
local function drip(holder: Frame, color: Color3, count: number)
	for _ = 1, count do
		local x = 0.12 + math.random() * 0.76
		local width = 3 + math.random(0, 3)
		local length = 18 + math.random(0, 46)
		local drop = UIKit.create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(x, 0.78),
			Size = UDim2.fromOffset(width, 0),
			BackgroundColor3 = color,
			BackgroundTransparency = 0.1,
			BorderSizePixel = 0,
			ZIndex = 13,
			Parent = holder,
		})
		UIKit.corner(width).Parent = drop
		local bead = UIKit.create("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, 2),
			Size = UDim2.fromOffset(width + 3, width + 3),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			ZIndex = 13,
			Parent = drop,
		})
		UIKit.corner(width + 3).Parent = bead
		task.delay(0.2 + math.random() * 0.9, function()
			TweenService:Create(
				drop,
				TweenInfo.new(1.4 + math.random() * 1.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{ Size = UDim2.fromOffset(width, length) }
			):Play()
		end)
	end
end

--- Play the act on top of `gui`. Calls `onDone` exactly once, whether it ran out
--- or was skipped. Returns immediately.
function OpeningAct.play(gui: ScreenGui, spec: Spec, onDone: () -> ())
	local screen = UIKit.create("Frame", {
		Name = "OpeningAct",
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 11,
		Parent = gui,
	})

	local narrationColor = spec.narrationColor or Color3.fromRGB(186, 182, 176)
	local voiceColor = spec.voiceColor or Color3.fromRGB(176, 6, 6)
	local voiceStroke = spec.voiceStroke or Color3.fromRGB(34, 0, 0)
	local dripColor = spec.dripColor or Color3.fromRGB(126, 4, 4)
	local echoColor = spec.echoColor or Color3.fromRGB(104, 74, 74)

	-- Layout, top to bottom: a little narration, then the voice taking the middle of
	-- the screen, then the echo small underneath it.
	local narrationLines: { TextLabel } = {}
	for index, line in spec.narration do
		narrationLines[index] = label(screen, {
			Position = UDim2.fromScale(0.5, 0.1 + (index - 1) * 0.062),
			AnchorPoint = Vector2.new(0.5, 0),
			Size = UDim2.fromScale(0.74, 0.05),
			Font = Enum.Font.GothamMedium,
			Text = line,
			TextColor3 = narrationColor,
		})
	end

	local voiceHolders: { Frame } = {}
	local voiceLines: { TextLabel } = {}
	local voiceTop = 0.29
	local voiceStep = 0.092
	for index, line in spec.voice do
		local holder = UIKit.create("Frame", {
			Position = UDim2.fromScale(0.5, voiceTop + (index - 1) * voiceStep),
			AnchorPoint = Vector2.new(0.5, 0),
			Size = UDim2.fromScale(0.86, 0.082),
			BackgroundTransparency = 1,
			ZIndex = 12,
			Parent = screen,
		})
		voiceHolders[index] = holder
		voiceLines[index] = label(holder, {
			Size = UDim2.fromScale(1, 1),
			Font = Enum.Font.Creepster,
			Text = line,
			TextColor3 = voiceColor,
			TextStrokeColor3 = voiceStroke,
		})
		UIKit.create("UIGradient", {
			Rotation = 90,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
				ColorSequenceKeypoint.new(0.55, Color3.new(1, 1, 1)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(112, 112, 112)),
			}),
			Parent = voiceLines[index],
		})
	end

	local echoLines: { TextLabel } = {}
	local echoTop = voiceTop + #spec.voice * voiceStep + 0.035
	for index, line in spec.echo or {} do
		echoLines[index] = label(screen, {
			Position = UDim2.fromScale(0.5, echoTop + (index - 1) * 0.032),
			AnchorPoint = Vector2.new(0.5, 0),
			Size = UDim2.fromScale(0.5, 0.026),
			Font = Enum.Font.Garamond,
			Text = line,
			TextColor3 = echoColor,
		})
	end

	local hint = label(screen, {
		Position = UDim2.fromScale(0.5, 0.93),
		AnchorPoint = Vector2.new(0.5, 0),
		Size = UDim2.fromScale(0.4, 0.028),
		Font = Enum.Font.GothamMedium,
		Text = spec.skipHint or "TAP TO SKIP",
		TextColor3 = Color3.fromRGB(110, 110, 110),
	})

	local finished = false
	local connection: RBXScriptConnection? = nil

	local function finish()
		if finished then
			return
		end
		finished = true
		if connection then
			connection:Disconnect()
		end
		local out = TweenInfo.new(1.0, Enum.EasingStyle.Sine)
		for _, item in screen:GetDescendants() do
			if item:IsA("TextLabel") then
				TweenService:Create(item, out, { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
			elseif item:IsA("Frame") and item.Name ~= "OpeningAct" then
				TweenService:Create(item, out, { BackgroundTransparency = 1 }):Play()
			end
		end
		task.delay(1.0, function()
			screen:Destroy()
			onDone()
		end)
	end

	-- The timeline. Every beat checks `finished` so a skip stops it cold.
	task.spawn(function()
		local function beat(seconds: number): boolean
			local t = 0
			while t < seconds do
				if finished then
					return false
				end
				t += task.wait(0.05)
			end
			return not finished
		end

		if not beat(0.8) then
			return
		end
		for _, line in narrationLines do
			fadeIn(line)
			if not beat(2.1) then
				return
			end
		end
		if not beat(0.6) then
			return
		end
		for index, line in voiceLines do
			fadeIn(line, 0.25)
			drip(voiceHolders[index], dripColor, 5)
			if not beat(1.5) then
				return
			end
		end
		-- The echo arrives all at once and quietly. It is not a line to work through.
		if not beat(0.5) then
			return
		end
		for _, line in echoLines do
			fadeIn(line)
		end
		if not beat(6) then
			return
		end
		finish()
	end)

	task.delay(SKIP_AFTER, function()
		if finished then
			return
		end
		fadeIn(hint)
		connection = UserInputService.InputBegan:Connect(function(input, processed)
			if processed then
				return
			end
			local kind = input.UserInputType
			if
				kind == Enum.UserInputType.MouseButton1
				or kind == Enum.UserInputType.Touch
				or kind == Enum.UserInputType.Keyboard
				or kind == Enum.UserInputType.Gamepad1
			then
				finish()
			end
		end)
	end)

	local _ = Players
end

return OpeningAct

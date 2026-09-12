-- FloodFx — the two seconds the whole game is judged on.
--
-- The brief is explicit: "If the flood does not read at 200px in 2 seconds, the hook
-- has failed regardless of how the game plays." The coins themselves are server parts;
-- this adds the punctuation so a clip has a beat, not just a spill.
--
-- Grey-box scope: no sound. Audio is Gate 4 and guessing asset IDs produces broken
-- references, which is worse than silence. Named as a gap in the run log.

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local UIKit = require(script.Parent.UIKit)

local FloodFx = {}

local theme = require(game:GetService("ReplicatedStorage"):WaitForChild("Pack").theme)

local gui: ScreenGui
local flash: Frame
local shout: TextLabel
local busy = false

function FloodFx.init(parent: ScreenGui)
	gui = parent

	flash = UIKit.create("Frame", {
		Name = "Flash",
		BackgroundColor3 = theme.accent,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 2,
		Parent = gui,
	})

	shout = UIKit.create("TextLabel", {
		Name = "Shout",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.32),
		Size = UDim2.fromScale(0.5, 0.14),
		Font = Enum.Font.GothamBlack,
		TextScaled = true,
		Text = "PAYOUT!",
		TextColor3 = theme.accent,
		TextStrokeColor3 = Color3.new(0, 0, 0),
		TextStrokeTransparency = 0.1,
		TextTransparency = 1,
		ZIndex = 3,
		Parent = gui,
	})
end

function FloodFx.play(count: number)
	if busy then
		return
	end
	busy = true

	shout.Text = `PAYOUT!  +{count}`
	shout.TextTransparency = 0
	shout.TextStrokeTransparency = 0.1
	shout.Size = UDim2.fromScale(0.35, 0.1)
	flash.BackgroundTransparency = 0.82

	local grow = TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local fade = TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	TweenService:Create(shout, grow, { Size = UDim2.fromScale(0.5, 0.14) }):Play()
	TweenService:Create(flash, fade, { BackgroundTransparency = 1 }):Play()

	task.delay(0.35, function()
		TweenService:Create(shout, fade, { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	end)
	task.delay(1, function()
		busy = false
	end)
end

--- A short, gentle camera nudge. Gentle on purpose: this fires every few seconds in a
--- snack session, and a big shake would be nauseating by minute three.
function FloodFx.nudge()
	local camera = workspace.CurrentCamera
	local character = Players.LocalPlayer.Character
	if not camera or not character then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	local original = humanoid.CameraOffset
	local steps = 6
	task.spawn(function()
		for index = 1, steps do
			local strength = (1 - index / steps) * 0.35
			humanoid.CameraOffset = original
				+ Vector3.new((math.random() - 0.5) * strength, (math.random() - 0.5) * strength, 0)
			task.wait(0.03)
		end
		humanoid.CameraOffset = original
	end)
end

return FloodFx

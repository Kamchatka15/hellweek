--!strict
-- Moves.luau — how a swing FEELS.
--
-- The combat in this game was, until now, entirely invisible: you pressed a button,
-- the server decremented a number, and nothing on your screen moved. That is the
-- fastest way to convince a ten-year-old the button is broken, and he is right — a
-- hit you cannot see did not happen.
--
-- Nothing here is authoritative. The server owns damage, health and death; this file
-- owns the half second after you press the button. It never tells the server anything
-- and it never reads anything it is not given, so a player who tampers with it gets
-- a prettier screen and no advantage whatsoever.
--
-- Three things live here:
--
--   SWING    the arm actually moves, by driving the shoulder Motor6D directly. No
--            uploaded Animation asset, so no human upload gate, which is the same
--            trick CreatureService uses to walk the Herald.
--   KICK     the camera jolts on contact. This is most of what "impact" means; the
--            flash and the number are decoration on top of it.
--   FLIP     a front flip out of a double jump. The one bit of Blox Fruits grammar
--            that matters most: air control that is expressive and costs nothing,
--            so moving around is fun BEFORE the fighting is good.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Moves = {}

local player = Players.LocalPlayer

-- ---------------------------------------------------------------- shared handles

local function characterBits(): (Model?, Humanoid?, BasePart?)
	local character = player.Character
	if not character then
		return nil, nil, nil
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not root or not root:IsA("BasePart") then
		return character, humanoid, nil
	end
	return character, humanoid, root
end

-- ---------------------------------------------------------------- camera kick

local kickAmount = 0
local kickSeed = 0

--- Jolt the camera. `strength` is in degrees at the peak; it decays on its own.
function Moves.kick(strength: number)
	kickAmount = math.max(kickAmount, strength)
	kickSeed += 1
end

-- The kick is applied as a post-camera offset every frame and decays exponentially,
-- so overlapping hits stack into one shove rather than fighting each other.
RunService:BindToRenderStep("HellWeekCameraKick", Enum.RenderPriority.Camera.Value + 1, function(delta: number)
	if kickAmount <= 0.01 then
		kickAmount = 0
		return
	end
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	kickAmount = kickAmount * math.exp(-delta * 9)
	local t = os.clock() * 42 + kickSeed
	local pitch = math.rad(kickAmount) * math.sin(t)
	local yaw = math.rad(kickAmount * 0.6) * math.sin(t * 1.37)
	camera.CFrame = camera.CFrame * CFrame.Angles(pitch, yaw, 0)
end)

-- ---------------------------------------------------------------- the swing

local swinging = false

--- Drive the right shoulder through an overhead arc and back. Works on R6 and R15,
--- which name the joint differently and hang it off different parts, so the motor is
--- found by search rather than by path.
function Moves.swing()
	if swinging then
		return
	end
	local character = player.Character
	if not character then
		return
	end
	local motor: Motor6D? = nil
	for _, d in character:GetDescendants() do
		if d:IsA("Motor6D") and (d.Name == "Right Shoulder" or d.Name == "RightShoulder") then
			motor = d
			break
		end
	end
	if not motor then
		return
	end
	swinging = true
	local base = motor.C0
	task.spawn(function()
		local started = os.clock()
		local length = 0.34
		while true do
			local progress = (os.clock() - started) / length
			if progress >= 1 or motor.Parent == nil then
				break
			end
			-- Up fast, down slow: the wind-up is the read and the follow-through is
			-- the weight. A symmetric arc looks like a wave, not a strike.
			local shape = if progress < 0.35 then progress / 0.35 else 1 - (progress - 0.35) / 0.65
			motor.C0 = base * CFrame.Angles(-math.rad(125) * shape, 0, 0)
			RunService.RenderStepped:Wait()
		end
		if motor.Parent then
			motor.C0 = base
		end
		swinging = false
	end)
end

-- ---------------------------------------------------------------- the flip

local flipping = false
local lastFlip = 0
local FLIP_COOLDOWN = 0.75
local FLIP_TIME = 0.52

--- True if the character is off the ground and therefore allowed a second jump.
local function airborne(humanoid: Humanoid): boolean
	local state = humanoid:GetState()
	return state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping
end

--- A front flip. Called on the SECOND jump press while already in the air.
---
--- The rotation is written straight onto the root every frame rather than handed to
--- a BodyAngularVelocity, because physics-driven spin fights the Humanoid's own
--- balancing and comes out mushy and unpredictable. Position is left entirely alone,
--- so gravity still does its job and the flip never becomes a way to travel.
function Moves.flip(): boolean
	if flipping or os.clock() - lastFlip < FLIP_COOLDOWN then
		return false
	end
	local _, humanoid, root = characterBits()
	if not humanoid or not root or humanoid.Health <= 0 then
		return false
	end
	if not airborne(humanoid) then
		return false
	end

	flipping = true
	lastFlip = os.clock()

	-- A little lift so the flip reads as a move and not a stumble, and so a player
	-- who flips at the top of a jump does not clip the ground halfway round.
	local velocity = root.AssemblyLinearVelocity
	root.AssemblyLinearVelocity = Vector3.new(velocity.X, math.max(velocity.Y, 0) + 26, velocity.Z)

	local wasAutoRotate = humanoid.AutoRotate
	humanoid.AutoRotate = false

	-- Keep the heading we started on; only pitch changes.
	local look = root.CFrame.LookVector
	local yaw = math.atan2(-look.X, -look.Z)

	task.spawn(function()
		local started = os.clock()
		while flipping do
			local progress = (os.clock() - started) / FLIP_TIME
			if progress >= 1 then
				break
			end
			if root.Parent == nil or humanoid.Health <= 0 then
				break
			end
			root.CFrame = CFrame.new(root.Position)
				* CFrame.Angles(0, yaw, 0)
				* CFrame.Angles(-progress * math.pi * 2, 0, 0)
			RunService.RenderStepped:Wait()
		end
		-- Land upright no matter how the loop ended. Leaving a player face-down in
		-- the sand because a flip was interrupted is the bug this guards.
		if root.Parent then
			root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, yaw, 0)
		end
		if humanoid.Parent then
			humanoid.AutoRotate = wasAutoRotate
		end
		flipping = false
	end)
	return true
end

--- Wire the double-jump.
---
--- Roblox has no "second jump" event. `JumpRequest` is the right signal rather than
--- watching `Humanoid.Jump`, because the default control module will not always set
--- that property while you are already off the ground -- which is precisely the
--- moment we care about. JumpRequest fires on every press regardless of state, so
--- the airborne test is ours to make and cannot be quietly swallowed upstream.
function Moves.start()
	UserInputService.JumpRequest:Connect(function()
		local _, humanoid = characterBits()
		if humanoid and airborne(humanoid) then
			Moves.flip()
		end
	end)
	player.CharacterAdded:Connect(function()
		flipping = false
	end)
end

return Moves

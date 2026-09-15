--!strict
-- Compass.luau — a needle that always has an answer to "where now?".
--
-- It reads nothing but the world: the pyramid lays down invisible parts named
-- Route_01_door, Route_02_portal and so on, and the compass sorts them by name and
-- points at the next one you have not stood next to yet. No remote, no server state,
-- no new data to keep in step with the map — move a chamber and the needle follows it.
--
-- Outside the tomb it points at the two things that matter instead: the pyramid by
-- day, and the way home once the sun is down.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local Compass = {}

local GOLD = Color3.fromRGB(212, 168, 62)
local CHAR = Color3.fromRGB(30, 28, 28)
local BONE = Color3.fromRGB(210, 200, 180)
local FIRE = Color3.fromRGB(255, 138, 48)

local REACHED = 22 -- how close counts as "been there"
local NEAR_PYRAMID = 170 -- inside this, the tomb is what you are doing

local function label(name: string): string
	local pretty = {
		door = "THE DOOR",
		portal = "THE PORTAL",
		deep1 = "DOWN",
		deep2 = "DOWN",
		deep3 = "UP",
		bones = "THE BONES",
		sarcophagi = "THE COFFINS",
		wellshaft = "THE WELL",
		columns = "THE COLUMNS",
		embalm = "THE TABLE",
		granary = "THE STORES",
		treasury = "THE GOLD",
		jackal = "THE JACKAL",
		gallery = "THE GALLERY",
		summit = "THE TOP",
		burial = "THE HEART",
	}
	return pretty[name] or string.upper(name)
end

function Compass.init(gui: ScreenGui)
	local holder = Instance.new("Frame")
	holder.Name = "Compass"
	holder.AnchorPoint = Vector2.new(0, 0)
	holder.Position = UDim2.fromOffset(18, 108)
	holder.Size = UDim2.fromOffset(92, 92)
	holder.BackgroundColor3 = CHAR
	holder.BorderSizePixel = 0
	holder.Visible = false
	holder.Parent = gui
	local round = Instance.new("UICorner")
	round.CornerRadius = UDim.new(0.5, 0)
	round.Parent = holder
	local rim = Instance.new("UIStroke")
	rim.Color = GOLD
	rim.Thickness = 2
	rim.Transparency = 0.35
	rim.Parent = holder

	-- The needle: a gold bar with a bone tail, rotated as one.
	local needle = Instance.new("Frame")
	needle.Name = "Needle"
	needle.AnchorPoint = Vector2.new(0.5, 0.5)
	needle.Position = UDim2.fromScale(0.5, 0.5)
	needle.Size = UDim2.fromOffset(8, 58)
	needle.BackgroundTransparency = 1
	needle.Parent = holder
	local head = Instance.new("Frame")
	head.Size = UDim2.fromScale(1, 0.5)
	head.BackgroundColor3 = GOLD
	head.BorderSizePixel = 0
	head.Parent = needle
	local headRound = Instance.new("UICorner")
	headRound.CornerRadius = UDim.new(0.5, 0)
	headRound.Parent = head
	local tail = Instance.new("Frame")
	tail.Position = UDim2.fromScale(0, 0.5)
	tail.Size = UDim2.fromScale(1, 0.5)
	tail.BackgroundColor3 = CHAR
	tail.BorderSizePixel = 0
	tail.Parent = needle
	local tailRound = Instance.new("UICorner")
	tailRound.CornerRadius = UDim.new(0.5, 0)
	tailRound.Parent = tail

	local hub = Instance.new("Frame")
	hub.AnchorPoint = Vector2.new(0.5, 0.5)
	hub.Position = UDim2.fromScale(0.5, 0.5)
	hub.Size = UDim2.fromOffset(12, 12)
	hub.BackgroundColor3 = BONE
	hub.BorderSizePixel = 0
	hub.Parent = holder
	local hubRound = Instance.new("UICorner")
	hubRound.CornerRadius = UDim.new(0.5, 0)
	hubRound.Parent = hub

	local caption = Instance.new("TextLabel")
	caption.AnchorPoint = Vector2.new(0.5, 0)
	caption.Position = UDim2.new(0.5, 0, 1, 6)
	caption.Size = UDim2.fromOffset(150, 30)
	caption.BackgroundTransparency = 1
	caption.Font = Enum.Font.GothamBlack
	caption.TextSize = 13
	caption.TextColor3 = GOLD
	caption.Text = ""
	caption.Parent = holder

	-- Find the route once it exists; the world builds a moment after the client starts.
	local marks: { BasePart } = {}
	local pyramidAt: Vector3? = nil
	local visited: { [number]: boolean } = {}

	local function findRoute()
		local folder = workspace:FindFirstChild("PyramidRoute", true)
		if not folder then
			return
		end
		local found = {}
		for _, p in folder:GetChildren() do
			if p:IsA("BasePart") then
				table.insert(found, p)
			end
		end
		table.sort(found, function(a, b)
			return a.Name < b.Name
		end)
		marks = found
		if #marks > 0 then
			local sum = Vector3.zero
			for _, m in marks do
				sum += m.Position
			end
			pyramidAt = sum / #marks
		end
	end

	findRoute()

	local acc = 0
	RunService.RenderStepped:Connect(function(dt)
		acc += dt
		if #marks == 0 then
			if acc > 1 then
				acc = 0
				findRoute()
			end
			return
		end
		local char = Players.LocalPlayer.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if not root then
			holder.Visible = false
			return
		end
		local here = (root :: BasePart).Position

		-- Anything you have walked up to counts as done, in any order.
		for i, m in marks do
			if not visited[i] and (m.Position - here).Magnitude < REACHED then
				visited[i] = true
			end
		end

		local target: Vector3?, word: string
		local atPyramid = pyramidAt ~= nil and (here - (pyramidAt :: Vector3)).Magnitude < NEAR_PYRAMID
		if atPyramid then
			local nextIndex: number? = nil
			for i = 1, #marks do
				if not visited[i] then
					nextIndex = i
					break
				end
			end
			if nextIndex then
				target = marks[nextIndex].Position
				word = label((marks[nextIndex].Name:gsub("^Route_%d+_", "")))
			else
				target = marks[1].Position
				word = "WAY OUT"
			end
		elseif Lighting.ClockTime < 6.5 or Lighting.ClockTime > 17.5 then
			target = Vector3.zero -- the beacon: at night the camp is the only errand
			word = "CAMP"
		else
			target = marks[1].Position
			word = "PYRAMID"
		end

		local to = (target :: Vector3) - here
		local flat = Vector3.new(to.X, 0, to.Z)
		if flat.Magnitude < 0.1 then
			return
		end
		flat = flat.Unit
		local cam = workspace.CurrentCamera
		local look = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
		local right = Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z)
		if look.Magnitude < 0.01 then
			return
		end
		look, right = look.Unit, right.Unit
		needle.Rotation = math.deg(math.atan2(flat:Dot(right), flat:Dot(look)))
		head.BackgroundColor3 = if word == "CAMP" then FIRE else GOLD
		caption.TextColor3 = head.BackgroundColor3
		caption.Text = ("%s  %d"):format(word, math.floor(to.Magnitude))
		holder.Visible = true
	end)

	return holder
end

return Compass

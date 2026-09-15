--!strict
-- ziggurat.luau — the VisionRework camp: a stone disc with a gold eye, and a stepped
-- obelisk with a small fire on top.
--
-- Replaces the generated needle in `obelisk.luau` when `config.vision` is on. The old
-- file is untouched and comes back by flipping that flag, which is the "hide, do not
-- delete" rule made undoable in source rather than in a Studio folder that the next
-- sync would erase.
--
-- Look target: chunky 2016 Roblox parts. Six colours only. No Neon by day; the gold is
-- Metal, the fire is orange plastic plus particles plus one light. The safe zone IS
-- this disc, so the disc is cut to the beacon's base radius.
--
-- Every spec here is relative to `config.beacon.position`, and the part named
-- `CapFlame` is the one the loop scales with fuel and reads as the beacon's flame.

local STONE = Color3.fromRGB(45, 42, 40) -- charcoal stone
local STONE_DEEP = Color3.fromRGB(38, 36, 34) -- the obelisk, a shade darker than the disc
local GOLD = Color3.fromRGB(212, 168, 62) -- wick gold
local FIRE = Color3.fromRGB(255, 138, 48) -- fire orange

local parts: { any } = {}

local function add(spec: any)
	table.insert(parts, spec)
end

-- ---------------------------------------------------------------- the disc
-- 48 studs across, 1.5 tall, standing on the floor. Radius 24 against a beacon base
-- radius of 25: the stone is the safe zone, give or take a footstep.
local DISC_R = 24
add({
	name = "Disc",
	shape = Enum.PartType.Cylinder,
	size = Vector3.new(1.5, DISC_R * 2, DISC_R * 2),
	cframe = CFrame.new(0, 0.75, 0) * CFrame.Angles(0, 0, math.rad(90)),
	color = STONE,
	material = Enum.Material.Slate,
})

-- Two rings of slabs laid on top so the disc reads as tiled and cracked rather than
-- as one machined puck. Same colour: the seams do the work, not a second tone.
for ring, radius in { 13, 20 } do
	local count = if ring == 1 then 16 else 24
	local arc = 2 * math.pi * radius / count
	for index = 1, count do
		local theta = (index - 1) / count * math.pi * 2 + (if ring == 2 then arc * 0.35 / radius else 0)
		add({
			name = `Slab{ring}_{index}`,
			size = Vector3.new(arc * 0.82, 0.22, if ring == 1 then 3.2 else 2.6),
			cframe = CFrame.new(math.cos(theta) * radius, 1.5 + 0.11, math.sin(theta) * radius)
				* CFrame.Angles(0, -theta, 0),
			color = STONE,
			material = Enum.Material.Slate,
			canCollide = false,
		})
	end
end

-- ---------------------------------------------------------------- the gold eye
-- An almond outline laid into the disc, with the obelisk standing where the pupil
-- would be. Metal, thin, and never Neon while the sun is up. Geometric only: this is
-- an inlay, not writing.
local EYE_W, EYE_H = 40, 22
local EYE_Y = 1.5 + 0.22 + 0.1
for side = -1, 1, 2 do
	local segments = 16
	for index = 1, segments do
		local t0 = (index - 1) / segments
		local t1 = index / segments
		local x0, x1 = (t0 - 0.5) * EYE_W, (t1 - 0.5) * EYE_W
		-- a lens arc: z = side * H/2 * sin(pi t)
		local z0 = side * (EYE_H / 2) * math.sin(math.pi * t0)
		local z1 = side * (EYE_H / 2) * math.sin(math.pi * t1)
		local mid = Vector3.new((x0 + x1) / 2, EYE_Y, (z0 + z1) / 2)
		local run = Vector3.new(x1 - x0, 0, z1 - z0)
		local yaw = -math.atan2(run.Z, run.X)
		add({
			name = `Eye{if side < 0 then "N" else "S"}_{index}`,
			size = Vector3.new(run.Magnitude + 0.3, 0.2, 1.1),
			cframe = CFrame.new(mid) * CFrame.Angles(0, yaw, 0),
			color = GOLD,
			material = Enum.Material.Metal,
			canCollide = false,
		})
	end
end
-- The iris: a thin gold ring hugging the obelisk's foot.
do
	local radius, count = 9.2, 20
	local arc = 2 * math.pi * radius / count
	for index = 1, count do
		local theta = (index - 1) / count * math.pi * 2
		add({
			name = `Iris{index}`,
			size = Vector3.new(arc * 0.9, 0.2, 0.8),
			cframe = CFrame.new(math.cos(theta) * radius, EYE_Y, math.sin(theta) * radius)
				* CFrame.Angles(0, -theta, 0),
			color = GOLD,
			material = Enum.Material.Metal,
			canCollide = false,
		})
	end
end

-- ---------------------------------------------------------------- the obelisk
-- Six terraces, base 14 x 14, 22 tall. A ziggurat, not a needle: it sits low and wide
-- so the fire on top is actually visible from the ground, and it looks like something
-- people built rather than something that grew.
local TERRACES = 6
local BASE_W, TOP_W, HEIGHT = 14, 2.8, 22
local step = HEIGHT / TERRACES
local y = 1.5 + 0.22 -- standing on the slabs
local band = { [2] = true, [4] = true } -- gold on two steps only
local topY = y
for index = 1, TERRACES do
	local t0 = (index - 1) / (TERRACES - 1)
	local w = BASE_W + (TOP_W - BASE_W) * t0
	add({
		name = `Tier{index}`,
		size = Vector3.new(w, step, w),
		cframe = CFrame.new(0, y + step / 2, 0),
		color = STONE_DEEP,
		material = Enum.Material.Slate,
	})
	if band[index] then
		-- A thin square of gold around the top lip of this terrace.
		local lipY = y + step - 0.12
		for _, edge in { { 0, 1 }, { 0, -1 }, { 1, 0 }, { -1, 0 } } do
			local ex, ez = edge[1], edge[2]
			add({
				name = `Band{index}_{ex}_{ez}`,
				size = if ex == 0 then Vector3.new(w + 0.16, 0.15, 0.36) else Vector3.new(0.36, 0.15, w + 0.16),
				cframe = CFrame.new(ex * (w / 2), lipY, ez * (w / 2)),
				color = GOLD,
				material = Enum.Material.Metal,
				canCollide = false,
			})
		end
	end
	y += step
	topY = y
end

-- ---------------------------------------------------------------- the cap fire
-- Small orange parts, one fire emitter, one light. The `CapFlame` part is the one
-- the loop scales with fuel, so it must exist and it must carry that name.
add({
	name = "CapBase",
	size = Vector3.new(2.2, 0.5, 2.2),
	cframe = CFrame.new(0, topY + 0.25, 0),
	color = STONE,
	material = Enum.Material.Slate,
})
for _, corner in { { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } } do
	add({
		name = `Ember{corner[1]}_{corner[2]}`,
		size = Vector3.new(0.5, 0.7, 0.5),
		cframe = CFrame.new(corner[1] * 0.55, topY + 0.85, corner[2] * 0.55),
		color = FIRE,
		material = Enum.Material.SmoothPlastic,
		canCollide = false,
	})
end
add({
	name = "CapFlame",
	shape = Enum.PartType.Ball,
	size = Vector3.new(1.4, 1.6, 1.4),
	cframe = CFrame.new(0, topY + 1.4, 0),
	color = FIRE,
	material = Enum.Material.SmoothPlastic,
	canCollide = false,
	fire = {
		size = 1.6,
		height = 3.2,
		color = FIRE,
		tip = GOLD,
		rate = 26,
		sparkRate = 6,
		-- The cap light per the vision: warm, short, and it throws shadows.
		range = 18,
		brightness = 1.1,
		shadows = true,
	},
})

return parts

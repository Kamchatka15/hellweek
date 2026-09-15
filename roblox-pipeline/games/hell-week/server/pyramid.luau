--!strict
-- pyramid.luau — the Pyramid of the Dry Herald: a walkable tomb standing on the ash
-- flats near the obelisk.
--
-- Shape of the thing:
--   * a hollow stepped shell, 220 studs across and 140 tall, built as rings of slabs
--     so the inside is empty and the outside reads as courses of cut stone
--   * one central stair helix, the spine, running the whole height
--   * a ring corridor on each level, hung off the helix by a single spur
--   * eleven chambers: bones, sarcophagi, a well shaft, columns, an embalming room,
--     a granary, a treasury, a jackal shrine, a gallery, the portal, and the heart
--
-- Every piece — hall, corner, stair, chamber — is emitted as a CLOSED box: floor,
-- ceiling and four walls. Doorways are not authored. Each piece also registers the
-- volume of air inside it, and a final pass deletes any wall segment whose centre
-- falls inside somebody's air. Two pieces that touch therefore open into each other
-- automatically, which is the only reason a tomb this size can be laid out by hand
-- without a hundred hand-placed door gaps to get wrong.
--
-- Colours are the pack's six. Ash is the outer stone, charcoal the inner, and the
-- deep charcoal is the floor; gold is banding and grave goods, bone is bone, fire is
-- fire. Nothing here is Neon except an eye.

local ORIGIN = Vector3.new(63, 0, -237) -- the pyramid's centre, on the ground
local HALF, HEIGHT, COURSES = 110, 140, 26
local COURSE = HEIGHT / COURSES
local STEP_IN = (HALF - 6) / COURSES
local SHELL_T = 10

local W, T, H = 14, 4, 15 -- corridor: inner width, wall thickness, inner height
local RISE, RUN = 1.5, 3 -- one step: 26 degrees, which a humanoid and the nav mesh both accept
local SEG = 10 -- wall segment length: the resolution a doorway can be cut at
local JUNC = W / 2 + T

local ASH = Color3.fromRGB(145, 125, 95)
local CHAR = Color3.fromRGB(45, 42, 40)
local DEEP = Color3.fromRGB(38, 36, 34)
local BONE = Color3.fromRGB(210, 200, 180)
local GOLD = Color3.fromRGB(212, 168, 62)
local FIRE = Color3.fromRGB(255, 138, 48)

-- Cut stone, not brickwork: Brick reads as a modern garden wall under torchlight.
local SLATE, SAND, BRICK = Enum.Material.Slate, Enum.Material.Sand, Enum.Material.Sandstone
local PLASTIC = Enum.Material.SmoothPlastic

-- staged[i] = { spec, carve } — carveable pieces are the ones a doorway may be cut in
local staged: { { spec: any, carve: boolean } } = {}
local air: { { cf: CFrame, size: Vector3 } } = {}
local marks: { { name: string, at: Vector3 } } = {}
-- The centre-line of the route, in the order a player walks it. It exists so the walk
-- can be driven and timed by a machine instead of guessed at. Recording is switched off
-- while the spine is built, because the stair is constructed bottom to top and that is
-- not the order anybody walks it.
local ways: { Vector3 } = {}
local recording = true
local pathLength = 0

local function put(spec: any, carve: boolean?)
	table.insert(staged, { spec = spec, carve = carve == true })
	return spec
end

local function hollow(cf: CFrame, size: Vector3)
	table.insert(air, { cf = cf, size = size })
end

local function way(at: Vector3)
	if not recording then
		return
	end
	if #ways == 0 or (ways[#ways] - at).Magnitude > 3 then
		table.insert(ways, at)
	end
end

local function mark(name: string, cf: CFrame)
	table.insert(marks, { name = name, at = cf.Position })
end

-- ---------------------------------------------------------------- the cursor
-- Position is the middle of the corridor FLOOR; LookVector is the way you walk.
local cur = CFrame.new(0, 4, 112)

local function box(name: string, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material, carve: boolean?)
	return put({
		name = name,
		size = size,
		cframe = cf,
		color = color,
		material = material,
		castShadow = false,
	}, carve)
end

--- A torch bracket on a wall: a stub, a bowl, and a flame. `side` is -1 left, +1 right.
local n = 0
local function torch(cf: CFrame, lit: boolean)
	n += 1
	box(`TorchStem{n}`, Vector3.new(0.6, 0.6, 1.4), cf * CFrame.new(0, 0, -0.7), CHAR, SLATE)
	box(`TorchBowl{n}`, Vector3.new(1.5, 0.9, 1.5), cf * CFrame.new(0, 0.7, -1.5), CHAR, SLATE)
	put({
		name = `TorchFlame{n}`,
		size = Vector3.new(0.9, 0.9, 0.9),
		cframe = cf * CFrame.new(0, 1.5, -1.5),
		color = FIRE,
		material = PLASTIC,
		transparency = 0.25,
		canCollide = false,
		castShadow = false,
		fire = {
			size = 0.9,
			height = 2.2,
			color = FIRE,
			tip = GOLD,
			rate = 11,
			sparkRate = 2,
			range = if lit then 34 else 0.1,
			brightness = if lit then 2.1 else 0,
		},
	})
end

-- ---------------------------------------------------------------- pieces
--- Floor, ceiling and four walls around a rectangular room `across` x `depth` x `height`,
--- centred on `at` with `at`'s LookVector pointing along depth. Walls are segmented so
--- the carve pass can cut doorways in them.
local rooms = 0
local function shellBox(at: CFrame, across: number, depth: number, height: number, floorMat: Enum.Material?)
	rooms += 1
	local id = rooms
	box(
		`Floor{id}`,
		Vector3.new(across + 2 * T, T, depth + 2 * T),
		at * CFrame.new(0, -T / 2, 0),
		DEEP,
		floorMat or SLATE
	)
	box(
		`Ceil{id}`,
		Vector3.new(across + 2 * T, T, depth + 2 * T),
		at * CFrame.new(0, height + T / 2, 0),
		CHAR,
		SLATE,
		true
	)
	-- side walls, segmented along depth
	local steps = math.max(1, math.ceil(depth / SEG))
	local len = depth / steps
	for i = 1, steps do
		local z = -depth / 2 + (i - 0.5) * len
		for _, side in { -1, 1 } do
			box(
				`Wall{id}_{i}_{side}`,
				Vector3.new(T, height, len),
				at * CFrame.new(side * (across / 2 + T / 2), height / 2, z),
				CHAR,
				BRICK,
				true
			)
		end
	end
	-- end walls, segmented across
	local acr = math.max(1, math.ceil(across / SEG))
	local alen = across / acr
	for i = 1, acr do
		local x = -across / 2 + (i - 0.5) * alen
		for _, endz in { -1, 1 } do
			box(
				`End{id}_{i}_{endz}`,
				Vector3.new(alen, height, T),
				at * CFrame.new(x, height / 2, endz * (depth / 2 + T / 2)),
				CHAR,
				BRICK,
				true
			)
		end
	end
	-- the air inside, run a little past both ends so neighbours open into each other
	-- The air that CARVES is only ever a doorway wide. A room that registered its full
	-- width would have its whole end wall deleted by the corridor meeting it, opening it
	-- into the hollow of the pyramid instead of into the corridor.
	hollow(at * CFrame.new(0, height / 2, 0), Vector3.new(math.min(across, W), height, depth + 2.2 * T))
end

local function hall(length: number, torchEvery: number?)
	if length <= 0.01 then
		return
	end
	local at = cur * CFrame.new(0, 0, -length / 2)
	shellBox(at, W, length, H)
	local every = torchEvery or 24
	local count = math.floor(length / every)
	for i = 1, count do
		local z = -length / 2 + i * every
		local side = if i % 2 == 0 then -1 else 1
		torch(at * CFrame.new(side * (W / 2 - 0.2), 6.2, z) * CFrame.Angles(0, side * math.pi / 2, 0), true)
	end
	way(cur.Position)
	cur = cur * CFrame.new(0, 0, -length)
	way(cur.Position)
	pathLength += length
end

local function turn(dir: number)
	cur = cur * CFrame.new(0, 0, -JUNC)
	shellBox(cur, W, W, H)
	-- A junction has to open on every side, not just along the way in. shellBox only
	-- registers air down its own axis, so two turns in a row left a wall standing
	-- between them: the corner of the burial approach was sealed exactly this way.
	hollow(cur * CFrame.new(0, H / 2, 0), Vector3.new(W + 2.2 * T, H, W + 2.2 * T))
	way(cur.Position)
	cur = cur * CFrame.Angles(0, -dir * math.pi / 2, 0) * CFrame.new(0, 0, -JUNC)
	way(cur.Position)
	pathLength += W + 2 * T
end

--- A flight of steps. Each step is its own block; the walls and ceiling climb with it.
local flights = 0
local function flight(steps: number, down: boolean)
	flights += 1
	local id = flights
	local dir = if down then -1 else 1
	-- Open both mouths. A landing box puts its wall 2 studs beyond the first and last
	-- step, and a single step's air reaches only 0.6 studs past itself, so without
	-- these two volumes every staircase in the pyramid is sealed at both ends.
	hollow(cur * CFrame.new(0, H / 2, 4), Vector3.new(W, H, 14))
	for i = 1, steps do
		local y = dir * RISE * i
		local at = cur * CFrame.new(0, y, -(RUN * (i - 1) + RUN / 2))
		put({
			name = `Step{id}_{i}`,
			size = Vector3.new(W + 2 * T, RISE + 2.5, RUN),
			cframe = at * CFrame.new(0, -(RISE + 2.5) / 2, 0),
			color = DEEP,
			material = SLATE,
			canCollide = false,
			castShadow = false,
		})
		box(`StairCeil{id}_{i}`, Vector3.new(W + 2 * T, T, RUN), at * CFrame.new(0, H + T / 2, 0), CHAR, SLATE, true)
		for _, side in { -1, 1 } do
			box(
				`StairWall{id}_{i}_{side}`,
				Vector3.new(T, H + RISE, RUN),
				at * CFrame.new(side * (W / 2 + T / 2), (H + RISE) / 2 - RISE / 2, 0),
				CHAR,
				BRICK,
				true
			)
		end
		hollow(at * CFrame.new(0, H / 2, 0), Vector3.new(W, H + RISE, RUN + 1.2))
		if i == math.ceil(steps / 2) then
			torch(at * CFrame.new(W / 2 - 0.2, 6.2, 0) * CFrame.Angles(0, math.pi / 2, 0), true)
		end
	end
	-- The steps above are scenery. This is the surface underfoot: one slab from the
	-- bottom landing to the top, riding half a rise above the step tops so a player
	-- glides up rather than catching on every nose.
	local a = cur.Position + Vector3.new(0, RISE / 2 - 0.5, 0)
	cur = cur * CFrame.new(0, dir * RISE * steps, -RUN * steps)
	local b = cur.Position + Vector3.new(0, RISE / 2 - 0.5, 0)
	put({
		name = `Ramp{id}`,
		size = Vector3.new(W + 2 * T, 3, (b - a).Magnitude),
		cframe = CFrame.lookAt((a + b) / 2, b),
		color = DEEP,
		material = SLATE,
		transparency = 1,
		castShadow = false,
	})
	hollow(cur * CFrame.new(0, H / 2, -4), Vector3.new(W, H, 14))
	pathLength += RUN * steps
end

-- ---------------------------------------------------------------- grave goods
local rng = Random.new(20260915)
local props = 0
local function nid(): string
	props += 1
	return tostring(props)
end

local function bone(name: string, size: Vector3, cf: CFrame)
	return put({
		name = name,
		size = size,
		cframe = cf,
		color = BONE,
		material = SAND,
		canCollide = false,
		castShadow = false,
	})
end

--- A body on the floor: ribs, a skull, and limbs thrown where they fell.
local function skeleton(cf: CFrame)
	local id = nid()
	bone(`Skull{id}`, Vector3.new(1, 1.1, 1.2), cf * CFrame.new(0, 0.55, -1.9) * CFrame.Angles(0.3, 0, 0))
	bone(`Jaw{id}`, Vector3.new(0.8, 0.3, 0.7), cf * CFrame.new(0, 0.18, -1.4))
	for i = 1, 5 do
		bone(
			`Rib{id}_{i}`,
			Vector3.new(1.7 - i * 0.12, 0.22, 0.28),
			cf * CFrame.new(0, 0.3, -0.8 + i * 0.42) * CFrame.Angles(0, 0, rng:NextNumber(-0.14, 0.14))
		)
	end
	bone(`Spine{id}`, Vector3.new(0.3, 0.22, 2.6), cf * CFrame.new(0, 0.26, 0.2))
	bone(`Hips{id}`, Vector3.new(1.3, 0.3, 0.6), cf * CFrame.new(0, 0.3, 1.5))
	for _, side in { -1, 1 } do
		bone(
			`Arm{id}_{side}`,
			Vector3.new(0.3, 0.3, 2.2),
			cf * CFrame.new(side * 1.0, 0.25, -0.2) * CFrame.Angles(0, side * rng:NextNumber(0.2, 0.7), 0)
		)
		bone(
			`Leg{id}_{side}`,
			Vector3.new(0.36, 0.36, 2.8),
			cf * CFrame.new(side * 0.45, 0.28, 2.9) * CFrame.Angles(0, side * rng:NextNumber(0.05, 0.4), 0)
		)
	end
end

local function bonePile(cf: CFrame, count: number)
	local id = nid()
	for i = 1, count do
		local a = rng:NextNumber(0, math.pi * 2)
		local r = rng:NextNumber(0, 2.6)
		bone(
			`Shard{id}_{i}`,
			Vector3.new(rng:NextNumber(0.2, 0.4), rng:NextNumber(0.2, 0.4), rng:NextNumber(0.9, 2.4)),
			cf
				* CFrame.new(math.cos(a) * r, 0.2 + rng:NextNumber(0, 0.6), math.sin(a) * r)
				* CFrame.Angles(rng:NextNumber(-0.3, 0.3), a, rng:NextNumber(-0.4, 0.4))
		)
	end
	bone(`Skullpile{id}`, Vector3.new(1, 1.1, 1.2), cf * CFrame.new(rng:NextNumber(-1, 1), 0.55, rng:NextNumber(-1, 1)))
end

--- A coffin: a stone chest, a lid, two gold bands and a face at the head.
local function sarcophagus(cf: CFrame, open: boolean)
	local id = nid()
	box(`SarcBase{id}`, Vector3.new(4.4, 3, 9.4), cf * CFrame.new(0, 1.5, 0), CHAR, SLATE)
	box(`SarcRim{id}`, Vector3.new(4.9, 0.5, 9.9), cf * CFrame.new(0, 3.1, 0), DEEP, SLATE)
	if open then
		box(
			`SarcLid{id}`,
			Vector3.new(4.6, 0.9, 9.6),
			cf * CFrame.new(3.4, 0.45, 1.2) * CFrame.Angles(0, rng:NextNumber(-0.3, 0.3), 0.08),
			CHAR,
			SLATE
		)
		bone(`SarcBody{id}`, Vector3.new(2.6, 0.5, 7.4), cf * CFrame.new(0, 3.1, 0))
		bone(`SarcSkull{id}`, Vector3.new(1, 1.1, 1.2), cf * CFrame.new(0, 3.7, -3.2))
	else
		box(`SarcLid{id}`, Vector3.new(4.6, 0.9, 9.6), cf * CFrame.new(0, 3.75, 0), CHAR, SLATE)
		box(`SarcFace{id}`, Vector3.new(2.2, 0.35, 2.6), cf * CFrame.new(0, 4.22, -3), GOLD, Enum.Material.Metal)
		for _, z in { -0.6, 2.2 } do
			box(`SarcBand{id}_{z}`, Vector3.new(4.75, 0.3, 0.7), cf * CFrame.new(0, 4.2, z), GOLD, Enum.Material.Metal)
		end
	end
end

local function urn(cf: CFrame, tall: boolean)
	local id = nid()
	local h = if tall then 3.2 else 2
	box(`UrnBody{id}`, Vector3.new(1.8, h, 1.8), cf * CFrame.new(0, h / 2, 0), ASH, SAND)
	box(`UrnNeck{id}`, Vector3.new(1, 0.6, 1), cf * CFrame.new(0, h + 0.3, 0), ASH, SAND)
	box(`UrnLid{id}`, Vector3.new(1.4, 0.35, 1.4), cf * CFrame.new(0, h + 0.75, 0), GOLD, Enum.Material.Metal)
end

local function column(cf: CFrame, height: number)
	local id = nid()
	box(`ColBase{id}`, Vector3.new(4.6, 0.8, 4.6), cf * CFrame.new(0, 0.4, 0), ASH, SAND)
	local drums = math.max(2, math.floor(height / 5))
	local dh = (height - 2.2) / drums
	for i = 1, drums do
		box(`ColDrum{id}_{i}`, Vector3.new(3.4, dh - 0.16, 3.4), cf * CFrame.new(0, 0.8 + (i - 0.5) * dh, 0), ASH, SAND)
	end
	box(`ColBand{id}`, Vector3.new(3.7, 0.3, 3.7), cf * CFrame.new(0, height - 1.6, 0), GOLD, Enum.Material.Metal)
	box(`ColCap{id}`, Vector3.new(5, 1.4, 5), cf * CFrame.new(0, height - 0.7, 0), ASH, SAND)
end

--- A jackal on a plinth, facing the way `cf` faces. The eyes are the only Neon inside.
local function jackal(cf: CFrame, scale: number)
	local id = nid()
	local s = scale
	box(`JPlinth{id}`, Vector3.new(3.4 * s, 1.2 * s, 5.4 * s), cf * CFrame.new(0, 0.6 * s, 0), DEEP, SLATE)
	box(`JBody{id}`, Vector3.new(2.2 * s, 2.4 * s, 4.6 * s), cf * CFrame.new(0, 2.4 * s, 0), CHAR, SLATE)
	for _, side in { -1, 1 } do
		box(
			`JLeg{id}_{side}`,
			Vector3.new(0.7 * s, 1.6 * s, 0.7 * s),
			cf * CFrame.new(side * 0.7 * s, 2 * s, -1.7 * s),
			CHAR,
			SLATE
		)
	end
	box(`JChest{id}`, Vector3.new(2 * s, 2.8 * s, 1.6 * s), cf * CFrame.new(0, 4 * s, -1.7 * s), CHAR, SLATE)
	box(`JNeck{id}`, Vector3.new(1.3 * s, 2.6 * s, 1.3 * s), cf * CFrame.new(0, 5.8 * s, -1.9 * s), CHAR, SLATE)
	box(`JHead{id}`, Vector3.new(1.4 * s, 1.4 * s, 3 * s), cf * CFrame.new(0, 7.2 * s, -2.6 * s), CHAR, SLATE)
	for _, side in { -1, 1 } do
		box(
			`JEar{id}_{side}`,
			Vector3.new(0.4 * s, 2 * s, 1 * s),
			cf * CFrame.new(side * 0.5 * s, 8.6 * s, -1.9 * s),
			CHAR,
			SLATE
		)
		put({
			name = `JEye{id}_{side}`,
			size = Vector3.new(0.3 * s, 0.3 * s, 0.3 * s),
			cframe = cf * CFrame.new(side * 0.42 * s, 7.5 * s, -3.6 * s),
			color = GOLD,
			material = Enum.Material.Neon,
			canCollide = false,
			castShadow = false,
			light = { color = GOLD, brightness = 0.8, range = 7 },
		})
	end
	box(
		`JCollar{id}`,
		Vector3.new(1.5 * s, 0.5 * s, 1.5 * s),
		cf * CFrame.new(0, 4.6 * s, -1.85 * s),
		GOLD,
		Enum.Material.Metal
	)
end

--- A geometric gold inlay on a wall. Bars only: this is decoration, not writing.
local function relief(cf: CFrame, width: number, height: number)
	local id = nid()
	box(`ReliefPlate{id}`, Vector3.new(width, height, 0.4), cf, DEEP, SLATE)
	local rows = math.max(2, math.floor(height / 2.4))
	for r = 1, rows do
		local y = -height / 2 + (r - 0.5) * (height / rows)
		local bars = rng:NextInteger(2, 4)
		for b = 1, bars do
			local w = width / (bars + 1) * rng:NextNumber(0.5, 0.92)
			local x = -width / 2 + b * (width / (bars + 1))
			box(
				`ReliefBar{id}_{r}_{b}`,
				Vector3.new(w, 0.45, 0.28),
				cf * CFrame.new(x, y, -0.3),
				GOLD,
				Enum.Material.Metal
			)
		end
	end
end

local function brazier(cf: CFrame)
	local id = nid()
	for _, side in { -1, 1 } do
		box(`BrLeg{id}_{side}`, Vector3.new(0.4, 3.2, 0.4), cf * CFrame.new(side * 1, 1.6, 0.5), CHAR, SLATE)
	end
	box(`BrLeg{id}_b`, Vector3.new(0.4, 3.2, 0.4), cf * CFrame.new(0, 1.6, -1), CHAR, SLATE)
	box(`BrBowl{id}`, Vector3.new(3.4, 1.1, 3.4), cf * CFrame.new(0, 3.6, 0), CHAR, SLATE)
	put({
		name = `BrFire{id}`,
		size = Vector3.new(2, 0.8, 2),
		cframe = cf * CFrame.new(0, 4.3, 0),
		color = FIRE,
		material = PLASTIC,
		transparency = 0.3,
		canCollide = false,
		castShadow = false,
		fire = {
			size = 1.5,
			height = 3,
			color = FIRE,
			tip = GOLD,
			rate = 16,
			sparkRate = 4,
			range = 54,
			brightness = 2.4,
		},
	})
end

local function goldPile(cf: CFrame, count: number)
	local id = nid()
	for i = 1, count do
		local a, r = rng:NextNumber(0, math.pi * 2), rng:NextNumber(0, 2.2)
		put({
			name = `Gold{id}_{i}`,
			size = Vector3.new(rng:NextNumber(0.4, 1.1), rng:NextNumber(0.2, 0.5), rng:NextNumber(0.4, 1.1)),
			cframe = cf
				* CFrame.new(math.cos(a) * r, 0.2 + rng:NextNumber(0, 0.5), math.sin(a) * r)
				* CFrame.Angles(0, a, rng:NextNumber(-0.2, 0.2)),
			color = GOLD,
			material = Enum.Material.Metal,
			canCollide = false,
			castShadow = false,
		})
	end
end

local function rubble(cf: CFrame, count: number, spread: number)
	local id = nid()
	for i = 1, count do
		local a, r = rng:NextNumber(0, math.pi * 2), rng:NextNumber(0, spread)
		box(
			`Rubble{id}_{i}`,
			Vector3.new(rng:NextNumber(0.6, 2.2), rng:NextNumber(0.4, 1.2), rng:NextNumber(0.6, 2.2)),
			cf * CFrame.new(math.cos(a) * r, 0.3, math.sin(a) * r) * CFrame.Angles(0, a, 0),
			ASH,
			SAND
		)
	end
end
-- ---------------------------------------------------------------- chambers
--- A room on the route. The shell is the same every time; only the grave goods differ.
local function chamber(kind: string, across: number, depth: number, height: number)
	local at = cur * CFrame.new(0, 0, -depth / 2)
	shellBox(at, across, depth, height, SLATE)
	mark(kind, at)
	local hx, hz = across / 2, depth / 2

	if kind == "portal" then
		for _, side in { -1, 1 } do
			jackal(at * CFrame.new(side * (hx - 5), 0, hz - 7) * CFrame.Angles(0, math.pi, 0), 0.8)
			relief(
				at * CFrame.new(side * (hx - 0.3), height * 0.55, 0) * CFrame.Angles(0, side * math.pi / 2, 0),
				depth - 6,
				height * 0.6
			)
		end
		box(
			"PortalLintel",
			Vector3.new(across, 1.6, 1.2),
			at * CFrame.new(0, height - 1, hz),
			GOLD,
			Enum.Material.Metal
		)
		rubble(at * CFrame.new(0, 0, -hz + 6), 7, hx - 3)
	elseif kind == "bones" then
		for _ = 1, 5 do
			skeleton(
				at
					* CFrame.new(rng:NextNumber(-hx + 5, hx - 5), 0, rng:NextNumber(-hz + 5, hz - 5))
					* CFrame.Angles(0, rng:NextNumber(0, 6.2), 0)
			)
		end
		for _ = 1, 4 do
			bonePile(at * CFrame.new(rng:NextNumber(-hx + 4, hx - 4), 0, rng:NextNumber(-hz + 4, hz - 4)), 9)
		end
		for _, side in { -1, 1 } do
			urn(at * CFrame.new(side * (hx - 3), 0, -hz + 4), false)
			brazier(at * CFrame.new(side * (hx - 4), 0, hz - 5))
		end
	elseif kind == "sarcophagi" then
		for _, x in { -12, 12 } do
			for _, z in { -9, 9 } do
				sarcophagus(at * CFrame.new(x, 0, z), x < 0 and z < 0)
			end
		end
		for _, side in { -1, 1 } do
			brazier(at * CFrame.new(side * (hx - 4), 0, hz - 5))
			relief(
				at * CFrame.new(side * (hx - 0.3), height * 0.55, 0) * CFrame.Angles(0, side * math.pi / 2, 0),
				depth - 8,
				height * 0.5
			)
		end
		bonePile(at * CFrame.new(hx - 6, 0, -hz + 6), 8)
	elseif kind == "wellshaft" then
		-- A square well cut through the floor, ringed with a kerb. The shaft is blind.
		local r = 7
		for _, e in { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
			box(
				`WellKerb{e[1]}_{e[2]}`,
				if e[1] == 0 then Vector3.new(r * 2 + 3, 1.4, 1.5) else Vector3.new(1.5, 1.4, r * 2 + 3),
				at * CFrame.new(e[1] * (r + 0.75), 0.7, e[2] * (r + 0.75)),
				ASH,
				SAND
			)
		end
		for i = 1, 3 do
			box(
				`WellWall{i}`,
				Vector3.new(r * 2 + 2, 6, 1.2),
				at * CFrame.new(0, -3 - (i - 1) * 6, r + 0.6),
				DEEP,
				BRICK
			)
			box(
				`WellWallB{i}`,
				Vector3.new(r * 2 + 2, 6, 1.2),
				at * CFrame.new(0, -3 - (i - 1) * 6, -r - 0.6),
				DEEP,
				BRICK
			)
			box(
				`WellWallL{i}`,
				Vector3.new(1.2, 6, r * 2 + 2),
				at * CFrame.new(-r - 0.6, -3 - (i - 1) * 6, 0),
				DEEP,
				BRICK
			)
			box(
				`WellWallR{i}`,
				Vector3.new(1.2, 6, r * 2 + 2),
				at * CFrame.new(r + 0.6, -3 - (i - 1) * 6, 0),
				DEEP,
				BRICK
			)
		end
		box("WellFloor", Vector3.new(r * 2, 2, r * 2), at * CFrame.new(0, -19, 0), DEEP, SLATE)
		for _, side in { -1, 1 } do
			brazier(at * CFrame.new(side * (hx - 4), 0, 0))
			skeleton(at * CFrame.new(side * (hx - 5), 0, hz - 6) * CFrame.Angles(0, rng:NextNumber(0, 6.2), 0))
		end
	elseif kind == "columns" then
		for row = -1, 1, 2 do
			for i = -1, 1 do
				column(at * CFrame.new(row * (hx * 0.52), 0, i * (hz * 0.55)), height - 1)
			end
		end
		for _, side in { -1, 1 } do
			brazier(at * CFrame.new(side * (hx - 4), 0, 0))
			relief(
				at * CFrame.new(side * (hx - 0.3), height * 0.5, 0) * CFrame.Angles(0, side * math.pi / 2, 0),
				depth - 8,
				height * 0.5
			)
		end
		rubble(at * CFrame.new(0, 0, 0), 9, hx - 6)
		skeleton(at * CFrame.new(-hx + 6, 0, -hz + 7) * CFrame.Angles(0, 1.1, 0))
	elseif kind == "embalm" then
		box("SlabTable", Vector3.new(5, 0.8, 10), at * CFrame.new(0, 3.2, 0), ASH, SAND)
		for _, side in { -1, 1 } do
			for _, z in { -3.5, 3.5 } do
				box(`SlabLeg{side}_{z}`, Vector3.new(0.8, 3.2, 0.8), at * CFrame.new(side * 1.8, 1.6, z), ASH, SAND)
			end
		end
		bone("EmbalmBody", Vector3.new(2.4, 0.5, 7), at * CFrame.new(0, 3.85, 0))
		bone("EmbalmSkull", Vector3.new(1, 1.1, 1.2), at * CFrame.new(0, 4.3, -3.2))
		for i = -2, 2 do
			urn(at * CFrame.new(i * 2.6, 0, -hz + 3.5), i % 2 == 0)
		end
		sarcophagus(at * CFrame.new(hx - 6, 0, hz - 8) * CFrame.Angles(0, math.pi / 2, 0), true)
		brazier(at * CFrame.new(-hx + 4, 0, hz - 5))
	elseif kind == "granary" then
		-- Bins hug the walls. Nothing waist-high stands on the centre line of a room the
		-- route runs straight through, or the way on is a squeeze past a grain store.
		for _, i in { -1, 1 } do
			for j = -1, 1, 2 do
				box(`Bin{i}_{j}`, Vector3.new(6, 7, 6), at * CFrame.new(i * 12, 3.5, j * (hz - 6)), ASH, SAND)
				box(
					`BinLip{i}_{j}`,
					Vector3.new(6.6, 0.6, 6.6),
					at * CFrame.new(i * 12, 7.2, j * (hz - 6)),
					DEEP,
					SLATE
				)
			end
		end
		for _ = 1, 5 do
			urn(at * CFrame.new(rng:NextNumber(-hx + 3, hx - 3), 0, rng:NextNumber(-3, 3)), rng:NextNumber() > 0.5)
		end
		brazier(at * CFrame.new(0, 0, 0))
	elseif kind == "treasury" then
		for _ = 1, 5 do
			goldPile(at * CFrame.new(rng:NextNumber(-hx + 5, hx - 5), 0, rng:NextNumber(-hz + 5, hz - 5)), 16)
		end
		for _, side in { -1, 1 } do
			box(`Chest{side}`, Vector3.new(5, 3.4, 3.4), at * CFrame.new(side * (hx - 5), 1.7, 0), CHAR, SLATE)
			box(
				`ChestBand{side}`,
				Vector3.new(5.3, 0.5, 3.7),
				at * CFrame.new(side * (hx - 5), 3.1, 0),
				GOLD,
				Enum.Material.Metal
			)
			relief(
				at * CFrame.new(side * (hx - 0.3), height * 0.55, 0) * CFrame.Angles(0, side * math.pi / 2, 0),
				depth - 6,
				height * 0.5
			)
			brazier(at * CFrame.new(side * (hx - 5), 0, hz - 5))
		end
		urn(at * CFrame.new(0, 0, -hz + 4), true)
	elseif kind == "jackal" then
		-- Two jackals flanking the way out rather than one blocking it.
		for _, side in { -1, 1 } do
			jackal(at * CFrame.new(side * 11, 0, -hz + 9), 1.3)
		end
		for _, side in { -1, 1 } do
			brazier(at * CFrame.new(side * 13, 0, -hz + 15))
			column(at * CFrame.new(side * (hx - 5), 0, 2), height - 1)
			relief(
				at * CFrame.new(side * (hx - 0.3), height * 0.5, 4) * CFrame.Angles(0, side * math.pi / 2, 0),
				12,
				height * 0.5
			)
		end
		bonePile(at * CFrame.new(0, 0, hz - 8), 11)
		skeleton(at * CFrame.new(4, 0, hz - 10) * CFrame.Angles(0, 2.2, 0))
	elseif kind == "gallery" then
		-- Tall and narrow. The height is the point, so the reliefs climb the walls.
		for _, side in { -1, 1 } do
			for tier = 1, 3 do
				relief(
					at
						* CFrame.new(side * (hx - 0.3), tier * (height / 3.6) + 2, 0)
						* CFrame.Angles(0, side * math.pi / 2, 0),
					depth - 6,
					height / 4.6
				)
			end
			brazier(at * CFrame.new(side * (hx - 3.5), 0, hz - 5))
			brazier(at * CFrame.new(side * (hx - 3.5), 0, -hz + 5))
		end
		box(
			"GalleryBand",
			Vector3.new(across + 0.4, 0.6, depth + 0.4),
			at * CFrame.new(0, height - 2.5, 0),
			GOLD,
			Enum.Material.Metal
		)
	elseif kind == "burial" then
		box("Dais", Vector3.new(24, 1.6, 24), at * CFrame.new(0, 0.8, 0), DEEP, SLATE)
		box("Dais2", Vector3.new(19, 1.6, 19), at * CFrame.new(0, 2.4, 0), DEEP, SLATE)
		sarcophagus(at * CFrame.new(0, 3.2, 0), false)
		for _, sx in { -1, 1 } do
			for _, sz in { -1, 1 } do
				jackal(
					at
						* CFrame.new(sx * 15, 0, sz * 15)
						* CFrame.Angles(0, if sx > 0 then -math.pi / 2 else math.pi / 2, 0),
					1.0
				)
				goldPile(at * CFrame.new(sx * 9, 3.2, sz * 9), 12)
			end
		end
		for i = -1, 1 do
			urn(at * CFrame.new(i * 4, 3.2, -10), true)
		end
		for _, side in { -1, 1 } do
			brazier(at * CFrame.new(side * (hx - 4), 0, 0))
			relief(
				at * CFrame.new(side * (hx - 0.3), height * 0.55, 0) * CFrame.Angles(0, side * math.pi / 2, 0),
				depth - 8,
				height * 0.45
			)
		end
		box(
			"HeartBand",
			Vector3.new(across + 0.4, 0.7, depth + 0.4),
			at * CFrame.new(0, height - 2, 0),
			GOLD,
			Enum.Material.Metal
		)
	end

	way(at.Position)
	cur = cur * CFrame.new(0, 0, -depth)
	way(cur.Position)
	pathLength += depth
end
-- ---------------------------------------------------------------- the route
local AXIS_X, AXIS_Z = -23, 12 -- the entry axis, chosen so the helix rings the centre
local FLIGHT_RUN = RUN * 8 + (W + 2 * T) -- one flight plus its landing

--- Turn whichever way leads away from the pyramid's spine.
local function faceOutward()
	local here = Vector3.new(cur.Position.X, 0, cur.Position.Z)
	local r = (cur * CFrame.Angles(0, -math.pi / 2, 0))
	local l = (cur * CFrame.Angles(0, math.pi / 2, 0))
	local dr = (here + Vector3.new(r.LookVector.X, 0, r.LookVector.Z) * 10).Magnitude
	local dl = (here + Vector3.new(l.LookVector.X, 0, l.LookVector.Z) * 10).Magnitude
	turn(if dr > dl then 1 else -1)
end

local function sideOf(length: number, spec: any?)
	if spec then
		local pre = (length - spec[4]) / 2
		hall(pre)
		chamber(spec[1], spec[2], spec[4], spec[3])
		hall(length - spec[4] - pre)
	else
		hall(length)
	end
end

--- Out from the spine, once around a square ring, and back.
local function spurAndRing(R: number, kinds: { any })
	local landing = cur.Position
	faceOutward()
	local spurFoot = cur.Position -- just past the turn out of the stairwell
	local spur = R - 34
	hall(spur)
	local mouth = cur.Position
	turn(1)
	hall(R - JUNC)
	for s = 1, 3 do
		turn(1)
		sideOf(2 * R - 2 * JUNC, kinds[s])
	end
	turn(1)
	hall(R - JUNC)
	-- Back at the mouth of the spur, and the way home is the way you came. Building a
	-- second corridor here was the old mistake: `turn` steps 11 studs along the old
	-- heading before it rotates, so seven turns do not return to where they started and
	-- the "return" spur ended 35 studs off the stair, a stub going nowhere.
	way(mouth)
	way(spurFoot)
	way(landing)
end

-- The way in: a passage through the masonry, the portal room, then the long walk to
-- the spine. The door sits a little off the middle of the face, as they do.
cur = CFrame.new(AXIS_X, 4, 112)
mark("door", cur)
hall(26)
chamber("portal", 30, 26, 18)
hall(48)
local entry = cur

-- The spine is built ONCE, bottom to top, and walked many times. Twelve flights of six
-- steps is 144 studs of climb in three revolutions of a 36-stud square.
local starts: { CFrame } = {}
cur = CFrame.new(AXIS_X, -92, AXIS_Z)
recording = false
for i = 1, 12 do
	starts[i] = cur
	flight(8, false)
	turn(1)
end
recording = true
local topLanding = cur
cur = entry

-- Walking the spine. The stair is built once but the route uses it four times, so the
-- centre-line has to record the landings actually passed through rather than pretend
-- the player teleported between levels.
local landingAt = 9 -- the entry passage arrives at the ninth landing, y = +4
--- Where a flight tops out, and the middle of the landing box above it. A straight line
--- between two landings cuts through the corner of the stair, so the centre-line has to
--- bend the way the stair does.
local function flightTop(i: number): (Vector3, Vector3)
	local a = starts[i]
	return (a * CFrame.new(0, RISE * 8, -RUN * 8)).Position, (a * CFrame.new(0, RISE * 8, -RUN * 8 - JUNC)).Position
end

local function useSpine(target: number)
	if target > landingAt then
		for i = landingAt, target - 1 do
			way(starts[i].Position)
			local top, corner = flightTop(i)
			way(top)
			way(corner)
		end
	else
		for i = landingAt, target + 1, -1 do
			way(starts[i].Position)
			local top, corner = flightTop(i - 1)
			way(corner)
			way(top)
		end
	end
	way(starts[target].Position)
	pathLength += math.abs(target - landingAt) * FLIGHT_RUN
	landingAt = target
	cur = starts[target]
end

-- L1, the Bone Halls
useSpine(5)
mark("deep1", cur)
spurAndRing(70, {
	{ "bones", 34, 20, 32 },
	{ "sarcophagi", 36, 20, 34 },
	{ "wellshaft", 30, 22, 28 },
})

-- L2, the Hall of Columns
useSpine(1)
mark("deep2", cur)
spurAndRing(70, {
	{ "columns", 44, 26, 44 },
	{ "embalm", 34, 20, 32 },
	{ "granary", 32, 20, 30 },
})

-- L3, the upper halls
useSpine(11)
mark("deep3", cur)
spurAndRing(50, {
	{ "treasury", 34, 22, 32 },
	{ "jackal", 34, 24, 34 },
	{ "gallery", 26, 32, 30 },
})

-- L4, the heart
useSpine(12)
way(topLanding.Position)
cur = topLanding
mark("summit", cur)
faceOutward()
turn(1)
turn(1) -- about face: the chamber is on the spine, not outside it
hall(8)
chamber("burial", 48, 48, 22)

-- ---------------------------------------------------------------- the shell
-- Courses of cut stone, each a ring of four slabs so the inside stays hollow. Only the
-- bottom courses of the entrance face are segmented, because that is the only place a
-- doorway has to be cut.
for i = 1, COURSES do
	local h = HALF - STEP_IN * (i - 1)
	local y = (i - 1) * COURSE
	if h <= SHELL_T + 1 then
		box(`Cap{i}`, Vector3.new(h * 2, COURSE, h * 2), CFrame.new(0, y + COURSE / 2, 0), ASH, SAND)
	else
		local inner = h - SHELL_T
		for _, face in { { 0, 1 }, { 0, -1 }, { 1, 0 }, { -1, 0 } } do
			local fx, fz = face[1], face[2]
			local long = if fx == 0 then h * 2 else inner * 2
			local size = if fx == 0 then Vector3.new(long, COURSE, SHELL_T) else Vector3.new(SHELL_T, COURSE, long)
			local at = CFrame.new(fx * (h - SHELL_T / 2), y + COURSE / 2, fz * (h - SHELL_T / 2))
			if i <= 5 and fz == 1 then
				local n2 = math.ceil(long / 12)
				for k = 1, n2 do
					local off = -long / 2 + (k - 0.5) * (long / n2)
					box(
						`Face{i}_{k}`,
						Vector3.new(long / n2, COURSE, SHELL_T),
						at * CFrame.new(off, 0, 0),
						ASH,
						SAND,
						true
					)
				end
			else
				box(`Course{i}_{fx}_{fz}`, size, at, ASH, SAND)
			end
		end
	end
end

-- The way in from the outside: a stair up the face and two jackals on guard.
for i = 1, 4 do
	box(
		`ApproachStep{i}`,
		Vector3.new(34, 1.4, 4),
		CFrame.new(AXIS_X, 0.7 + (i - 1) * 1.4, HALF + 8 - (i - 1) * 4),
		ASH,
		SAND
	)
end
for _, side in { -1, 1 } do
	jackal(CFrame.new(AXIS_X + side * 20, 0, HALF + 6) * CFrame.Angles(0, math.pi, 0), 1.6)
end
box("DoorLintel", Vector3.new(26, 2.4, 3), CFrame.new(AXIS_X, 20.5, HALF - 1), GOLD, Enum.Material.Metal)
for _, side in { -1, 1 } do
	box(
		`DoorJamb{side}`,
		Vector3.new(3, 20, 3),
		CFrame.new(AXIS_X + side * 12.5, 10, HALF - 1),
		GOLD,
		Enum.Material.Metal
	)
end

-- ---------------------------------------------------------------- carve and emit
-- Delete any wall or ceiling segment standing in somebody's air. This is what turns
-- abutting boxes into a connected tomb: every doorway in the place is cut here.
local bounds = {}
for i, v in air do
	bounds[i] = { cf = v.cf, hx = v.size.X / 2, hy = v.size.Y / 2, hz = v.size.Z / 2, r = v.size.Magnitude / 2 }
end

local parts: { any } = {}
local carved = 0
for _, item in staged do
	local spec = item.spec
	local at: Vector3 = if spec.cframe then spec.cframe.Position else spec.position
	local drop = false
	if item.carve then
		for _, b in bounds do
			if (b.cf.Position - at).Magnitude > b.r then
				continue
			end
			local l = b.cf:PointToObjectSpace(at)
			if math.abs(l.X) <= b.hx and math.abs(l.Y) <= b.hy and math.abs(l.Z) <= b.hz then
				drop = true
				break
			end
		end
	end
	if drop then
		carved += 1
	else
		if spec.cframe then
			spec.cframe = spec.cframe + ORIGIN
		else
			spec.position += ORIGIN
		end
		table.insert(parts, spec)
	end
end

-- The centre-line, as invisible numbered parts. Nothing in the game reads these; they
-- exist so the walkthrough can be driven and timed rather than estimated.
for i, at in ways do
	table.insert(parts, {
		name = string.format("Way_%04d", i),
		size = Vector3.new(1, 1, 1),
		position = at + ORIGIN + Vector3.new(0, 3, 0),
		color = BONE,
		material = PLASTIC,
		transparency = 1,
		canCollide = false,
		castShadow = false,
		group = "PyramidPath",
	})
end

-- Route markers: invisible, named in order, and the only thing the compass reads.
local route: { any } = {}
for i, m in marks do
	local spec = {
		name = string.format("Route_%02d_%s", i, m.name),
		size = Vector3.new(2, 2, 2),
		position = m.at + ORIGIN + Vector3.new(0, 3, 0),
		color = GOLD,
		material = PLASTIC,
		transparency = 1,
		canCollide = false,
		castShadow = false,
		group = "PyramidRoute",
	}
	table.insert(parts, spec)
	table.insert(route, { name = m.name, position = m.at + ORIGIN })
end

return {
	origin = ORIGIN,
	half = HALF,
	height = HEIGHT,
	door = Vector3.new(AXIS_X, 4, HALF + 6) + ORIGIN,
	-- the square the spine descends through, so the world floor can be opened for it
	opening = { ORIGIN.X - 34, ORIGIN.Z - 34, ORIGIN.X + 34, ORIGIN.Z + 34 },
	parts = parts,
	route = route,
	stats = {
		parts = #parts,
		carved = carved,
		air = #air,
		pathLength = math.floor(pathLength),
		chambers = #marks,
		waypoints = #ways,
	},
}

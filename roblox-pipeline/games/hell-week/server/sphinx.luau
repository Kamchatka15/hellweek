--!strict
-- sphinx.luau — the Sphinx, and the five levels of tunnel maze cut into the rock below it.
--
-- It stands on the far side of the obelisk from the pyramid, a recumbent lion with a
-- pharaoh's head, facing the camp. The way in is between its paws.
--
-- The maze is generated, not drawn. Each level is a 9x9 grid of cells; a randomised
-- depth-first search carves a spanning tree through them, which guarantees every cell
-- is reachable. Then it is BRAIDED: every dead end has one more wall knocked out, and a
-- further slice of walls is removed at random. A braided maze has loops instead of
-- cul-de-sacs, so you can be thoroughly lost without ever walking into a corner and
-- having to retrace — which is the difference between a maze that is fun and one that
-- is a chore.
--
-- The geometry is placed FROM that graph rather than alongside it: rock goes wherever
-- the graph says there is no tunnel, so the built maze cannot disagree with the maze
-- that was generated. Nothing is carved and nothing is hand-placed.
--
-- Note: the grave goods here are a leaner copy of the ones in pyramid.luau. Both packs
-- want a shared tomb-props module; that refactor is worth doing once the second tomb
-- has settled.

-- Across the obelisk from the pyramid, and far enough out that the paws are ~170 studs
-- from the camp. The lion is 250 studs long and lies with its face toward the obelisk,
-- so the origin has to sit well beyond where you want the front of it to be.
local ORIGIN = Vector3.new(-30, 0, 430)

-- The grid. P is the cell pitch, W the tunnel width, so the rock between tunnels is
-- P - W thick. H is headroom, T the thickness of floor and ceiling slabs.
local N = 9
local P, W, H, T = 36, 18, 18, 4
local ROCK = P - W
local LEVELS = 5
local DROP = 42 -- studs between one level's floor and the next
local FLOOR1 = -26 -- y of the first level's floor
local RUN = 3 -- tread depth of the scenery steps laid on the ramps

local ASH = Color3.fromRGB(145, 125, 95)
local CHAR = Color3.fromRGB(45, 42, 40)
local DEEP = Color3.fromRGB(38, 36, 34)
local BONE = Color3.fromRGB(210, 200, 180)
local GOLD = Color3.fromRGB(212, 168, 62)
local FIRE = Color3.fromRGB(255, 138, 48)

local SLATE, SAND = Enum.Material.Slate, Enum.Material.Sand
local STONE = Enum.Material.Sandstone
local PLASTIC = Enum.Material.SmoothPlastic
local GLASS = Enum.Material.Glass

local parts: { any } = {}
local marks: { { name: string, at: Vector3 } } = {}
local rng = Random.new(19260915)
local uid = 0

local function nid(): string
	uid += 1
	return tostring(uid)
end

local function put(spec: any): any
	spec.group = spec.group or "Sphinx"
	if spec.cframe then
		spec.cframe = spec.cframe + ORIGIN
	else
		spec.position += ORIGIN
	end
	table.insert(parts, spec)
	return spec
end

local function box(name: string, size: Vector3, at: Vector3, color: Color3, material: Enum.Material, opts: any?)
	local spec: any = {
		name = name,
		size = size,
		position = at,
		color = color,
		material = material,
		castShadow = false,
	}
	if opts then
		for k, v in opts do
			spec[k] = v
		end
	end
	return put(spec)
end

local function slab(name: string, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material, opts: any?)
	local spec: any = {
		name = name,
		size = size,
		cframe = cf,
		color = color,
		material = material,
		castShadow = false,
	}
	if opts then
		for k, v in opts do
			spec[k] = v
		end
	end
	return put(spec)
end

-- ---------------------------------------------------------------- cell geometry
local function cx(i: number): number
	return (i - (N + 1) / 2) * P
end
--- x of the grid line on the low side of cell `i` (k = 0..N counts the lines).
local function line(k: number): number
	return cx(1) - P / 2 + k * P
end
local function floorY(level: number): number
	return FLOOR1 - (level - 1) * DROP
end

-- ---------------------------------------------------------------- the maze
type Cell = { [number]: boolean }
-- directions: 1 = -z, 2 = +x, 3 = +z, 4 = -x
local DIR = { { 0, -1 }, { 1, 0 }, { 0, 1 }, { -1, 0 } }
local BACK = { 3, 4, 1, 2 }

local function inGrid(i: number, j: number): boolean
	return i >= 1 and i <= N and j >= 1 and j <= N
end

--- The spanning tree: a randomised depth-first search, which reaches every cell.
local function carve(r: Random): any
	local open: any = {}
	local seen: any = {}
	for i = 1, N do
		open[i], seen[i] = {}, {}
		for j = 1, N do
			open[i][j] = { false, false, false, false }
			seen[i][j] = false
		end
	end
	local stack = { { r:NextInteger(1, N), r:NextInteger(1, N) } }
	seen[stack[1][1]][stack[1][2]] = true
	while #stack > 0 do
		local top = stack[#stack]
		local i, j = top[1], top[2]
		local choices = {}
		for d = 1, 4 do
			local ni, nj = i + DIR[d][1], j + DIR[d][2]
			if inGrid(ni, nj) and not seen[ni][nj] then
				table.insert(choices, d)
			end
		end
		if #choices == 0 then
			table.remove(stack)
		else
			local d = choices[r:NextInteger(1, #choices)]
			local ni, nj = i + DIR[d][1], j + DIR[d][2]
			open[i][j][d] = true
			open[ni][nj][BACK[d]] = true
			seen[ni][nj] = true
			table.insert(stack, { ni, nj })
		end
	end
	return open
end

--- Braiding is what makes the maze worth walking: every dead end gets a second way out,
--- and a further slice of walls comes down, so there are loops rather than cul-de-sacs.
--- `locked` names walls that must stay exactly as they are — the sides of the inclined
--- shafts, which have to be solid rock from one level to the next.
local function braid(open: any, locked: any, r: Random)
	local function ways(i: number, j: number): number
		local n = 0
		for d = 1, 4 do
			if open[i][j][d] then
				n += 1
			end
		end
		return n
	end
	for i = 1, N do
		for j = 1, N do
			if ways(i, j) <= 1 then
				local shut = {}
				for d = 1, 4 do
					local ni, nj = i + DIR[d][1], j + DIR[d][2]
					if inGrid(ni, nj) and not open[i][j][d] and not locked[i][j][d] then
						table.insert(shut, d)
					end
				end
				if #shut > 0 then
					table.sort(shut, function(a, b)
						local ai, aj = i + DIR[a][1], j + DIR[a][2]
						local bi, bj = i + DIR[b][1], j + DIR[b][2]
						return ways(ai, aj) > ways(bi, bj)
					end)
					local d = shut[1]
					local ni, nj = i + DIR[d][1], j + DIR[d][2]
					open[i][j][d] = true
					open[ni][nj][BACK[d]] = true
				end
			end
		end
	end
	for i = 1, N do
		for j = 1, N do
			for d = 1, 2 do
				local ni, nj = i + DIR[d][1], j + DIR[d][2]
				if inGrid(ni, nj) and not open[i][j][d] and not locked[i][j][d] and r:NextNumber() < 0.16 then
					open[i][j][d] = true
					open[ni][nj][BACK[d]] = true
				end
			end
		end
	end
end

-- ---------------------------------------------------------------- grave goods
local function bone(name: string, size: Vector3, cf: CFrame)
	return slab(name, size, cf, BONE, SAND, { canCollide = false })
end

local function skeleton(cf: CFrame)
	local id = nid()
	bone(`Skull{id}`, Vector3.new(1, 1.1, 1.2), cf * CFrame.new(0, 0.55, -1.9))
	for i = 1, 5 do
		bone(`Rib{id}_{i}`, Vector3.new(1.7 - i * 0.12, 0.22, 0.28), cf * CFrame.new(0, 0.3, -0.8 + i * 0.42))
	end
	bone(`Spine{id}`, Vector3.new(0.3, 0.22, 2.6), cf * CFrame.new(0, 0.26, 0.2))
	bone(`Hips{id}`, Vector3.new(1.3, 0.3, 0.6), cf * CFrame.new(0, 0.3, 1.5))
	for _, side in { -1, 1 } do
		bone(
			`Arm{id}_{side}`,
			Vector3.new(0.3, 0.3, 2.2),
			cf * CFrame.new(side * 1, 0.25, -0.2) * CFrame.Angles(0, side * 0.5, 0)
		)
		bone(`Leg{id}_{side}`, Vector3.new(0.36, 0.36, 2.8), cf * CFrame.new(side * 0.45, 0.28, 2.9))
	end
end

local function bonePile(cf: CFrame, count: number)
	local id = nid()
	for i = 1, count do
		local a, r = rng:NextNumber(0, math.pi * 2), rng:NextNumber(0, 2.4)
		bone(
			`Shard{id}_{i}`,
			Vector3.new(rng:NextNumber(0.2, 0.4), rng:NextNumber(0.2, 0.4), rng:NextNumber(0.9, 2.2)),
			cf * CFrame.new(math.cos(a) * r, 0.2, math.sin(a) * r) * CFrame.Angles(0, a, 0)
		)
	end
end

--- A coffin. `open` shows the occupant; otherwise it wears a gold mask and two bands.
local function coffin(cf: CFrame, open: boolean)
	local id = nid()
	slab(`SarcBase{id}`, Vector3.new(4.4, 3, 9.4), cf * CFrame.new(0, 1.5, 0), CHAR, SLATE)
	slab(`SarcRim{id}`, Vector3.new(4.9, 0.5, 9.9), cf * CFrame.new(0, 3.1, 0), DEEP, SLATE)
	if open then
		slab(
			`SarcLid{id}`,
			Vector3.new(4.6, 0.9, 9.6),
			cf * CFrame.new(3.6, 0.45, 1.2) * CFrame.Angles(0, 0.2, 0.08),
			CHAR,
			SLATE
		)
		bone(`SarcBody{id}`, Vector3.new(2.6, 0.5, 7.4), cf * CFrame.new(0, 3.1, 0))
		bone(`SarcSkull{id}`, Vector3.new(1, 1.1, 1.2), cf * CFrame.new(0, 3.7, -3.2))
	else
		slab(`SarcLid{id}`, Vector3.new(4.6, 0.9, 9.6), cf * CFrame.new(0, 3.75, 0), CHAR, SLATE)
		slab(`SarcFace{id}`, Vector3.new(2.2, 0.35, 2.6), cf * CFrame.new(0, 4.22, -3), GOLD, Enum.Material.Metal)
		for _, z in { -0.6, 2.2 } do
			slab(`SarcBand{id}_{z}`, Vector3.new(4.75, 0.3, 0.7), cf * CFrame.new(0, 4.2, z), GOLD, Enum.Material.Metal)
		end
	end
end

local function urn(cf: CFrame)
	local id = nid()
	slab(`UrnBody{id}`, Vector3.new(1.8, 2.6, 1.8), cf * CFrame.new(0, 1.3, 0), ASH, SAND)
	slab(`UrnLid{id}`, Vector3.new(1.4, 0.35, 1.4), cf * CFrame.new(0, 2.8, 0), GOLD, Enum.Material.Metal)
end

local function column(cf: CFrame, height: number)
	local id = nid()
	slab(`ColBase{id}`, Vector3.new(5, 0.9, 5), cf * CFrame.new(0, 0.45, 0), ASH, SAND)
	slab(`ColShaft{id}`, Vector3.new(3.6, height - 2.4, 3.6), cf * CFrame.new(0, height / 2, 0), ASH, SAND)
	slab(`ColBand{id}`, Vector3.new(3.9, 0.3, 3.9), cf * CFrame.new(0, height - 1.8, 0), GOLD, Enum.Material.Metal)
	slab(`ColCap{id}`, Vector3.new(5.4, 1.5, 5.4), cf * CFrame.new(0, height - 0.75, 0), ASH, SAND)
end

--- A wall torch. `cf` sits on the wall face, looking into the tunnel.
local function torch(cf: CFrame)
	local id = nid()
	slab(`TorchStem{id}`, Vector3.new(0.6, 0.6, 1.4), cf * CFrame.new(0, 0, -0.7), CHAR, SLATE, { canCollide = false })
	slab(
		`TorchBowl{id}`,
		Vector3.new(1.5, 0.9, 1.5),
		cf * CFrame.new(0, 0.7, -1.5),
		CHAR,
		SLATE,
		{ canCollide = false }
	)
	slab(`TorchFlame{id}`, Vector3.new(0.9, 0.9, 0.9), cf * CFrame.new(0, 1.5, -1.5), FIRE, PLASTIC, {
		transparency = 0.25,
		canCollide = false,
		fire = {
			size = 0.9,
			height = 2.2,
			color = FIRE,
			tip = GOLD,
			rate = 11,
			sparkRate = 2,
			range = 32,
			brightness = 2,
		},
	})
end

local function brazier(cf: CFrame)
	local id = nid()
	for _, o in { { 1, 0.5 }, { -1, 0.5 }, { 0, -1 } } do
		slab(
			`BrLeg{id}_{o[1]}_{o[2]}`,
			Vector3.new(0.4, 3.2, 0.4),
			cf * CFrame.new(o[1], 1.6, o[2]),
			CHAR,
			SLATE,
			{ canCollide = false }
		)
	end
	slab(`BrBowl{id}`, Vector3.new(3.4, 1.1, 3.4), cf * CFrame.new(0, 3.6, 0), CHAR, SLATE)
	slab(`BrFire{id}`, Vector3.new(2, 0.8, 2), cf * CFrame.new(0, 4.3, 0), FIRE, PLASTIC, {
		transparency = 0.3,
		canCollide = false,
		fire = {
			size = 1.5,
			height = 3,
			color = FIRE,
			tip = GOLD,
			rate = 16,
			sparkRate = 4,
			range = 56,
			brightness = 2.4,
		},
	})
end

local function relief(cf: CFrame, width: number, height: number)
	local id = nid()
	slab(`ReliefPlate{id}`, Vector3.new(width, height, 0.4), cf, DEEP, SLATE, { canCollide = false })
	local rows = math.max(2, math.floor(height / 2.4))
	for r = 1, rows do
		local y = -height / 2 + (r - 0.5) * (height / rows)
		local bars = rng:NextInteger(2, 4)
		for b = 1, bars do
			local bw = width / (bars + 1) * rng:NextNumber(0.5, 0.9)
			slab(
				`ReliefBar{id}_{r}_{b}`,
				Vector3.new(bw, 0.45, 0.28),
				cf * CFrame.new(-width / 2 + b * (width / (bars + 1)), y, -0.3),
				GOLD,
				Enum.Material.Metal,
				{ canCollide = false }
			)
		end
	end
end

--- A mirage: a still sheet of something that looks like water, sunk in a stone kerb.
--- It is glass, not water — there is none down here — so it takes the colour of the
--- lamps and holds a reflection, and the eye fills in the rest.
local function pool(at: Vector3, radius: number)
	local id = nid()
	local r = radius
	-- a pale bed under pale glass: the light has to come back up out of it or the pool
	-- reads as a hole in the floor rather than as standing water
	box(`PoolBed{id}`, Vector3.new(r * 2, 1, r * 2), at + Vector3.new(0, -2.5, 0), BONE, SLATE)
	for _, e in { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
		local ex, ez = e[1], e[2]
		box(
			`PoolKerb{id}_{ex}_{ez}`,
			if ex == 0 then Vector3.new(r * 2 + 4, 1.6, 2) else Vector3.new(2, 1.6, r * 2 + 4),
			at + Vector3.new(ex * (r + 1), 0.2, ez * (r + 1)),
			GOLD,
			Enum.Material.Metal
		)
	end
	-- the surface: mirror-still, faintly lit from beneath
	box(`PoolFace{id}`, Vector3.new(r * 2, 0.4, r * 2), at + Vector3.new(0, -0.6, 0), BONE, GLASS, {
		transparency = 0.2,
		reflectance = 0.55,
		canCollide = false,
		light = { color = Color3.fromRGB(200, 214, 226), brightness = 3, range = 52 },
	})
	-- three still rings, so it reads as a surface rather than a pane of glass
	for k = 1, 3 do
		local rr = r * (0.35 + k * 0.18)
		for _, e in { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
			local ex, ez = e[1], e[2]
			box(
				`PoolRing{id}_{k}_{ex}_{ez}`,
				if ex == 0 then Vector3.new(rr * 2, 0.12, 0.35) else Vector3.new(0.35, 0.12, rr * 2),
				at + Vector3.new(ex * rr, -0.35, ez * rr),
				GOLD,
				Enum.Material.Metal,
				{ canCollide = false, transparency = 0.45 }
			)
		end
	end
end

-- ---------------------------------------------------------------- level layout
-- Low corner of the 3x3 hall on each level, and of the 1x2 inclined shafts that drop
-- from one level to the next. Chosen so no two of them share a cell.
local HALLS = { { 4, 4 }, { 2, 3 }, { 4, 2 }, { 6, 2 }, { 5, 4 } }
-- A shaft is entered at the north end of its top cell, so that cell may never sit on
-- row 1 (the edge of the grid is always rock), and j may not exceed 7.
--
-- Each shaft is one cell wide and THREE long, which puts its slope at 21 degrees. At
-- two cells it was 30, and a humanoid stepping from flat floor onto a slope that steep
-- at a wall junction gets treated as stuck and thrown clear: three of the eight failed
-- that way, always at the mouth. The entry passage is 22 degrees and has always worked.
local SHAFTS = {
	-- Two rules, both learned the hard way. Every shaft sits in rows 2-4 or 5-7, never
	-- reaching row 8. And no two shafts on the same level share a column: one slope
	-- ending where the next begins puts a player onto a ramp where they expected floor,
	-- and they are thrown out at the foot of it.
	{ { 1, 2 }, { 8, 5 } }, -- 1 -> 2
	{ { 6, 5 }, { 7, 2 } }, -- 2 -> 3
	{ { 3, 5 }, { 2, 2 } }, -- 3 -> 4
	{ { 8, 5 }, { 4, 2 } }, -- 4 -> 5
}
local HALL_NAME = { "Hall of the Lion", "Hall of Coffins", "Drowned Hall", "Hall of Columns", "The Deep Hall" }

local function inBlock(i: number, j: number, b: { number }, w: number, h: number): boolean
	return i >= b[1] and i < b[1] + w and j >= b[2] and j < b[2] + h
end

--- Everything a level needs to know about itself.
local function planOf(level: number)
	local plan = {
		hall = HALLS[level],
		down = if level < LEVELS then SHAFTS[level] else nil,
		up = if level > 1 then SHAFTS[level - 1] else nil,
	}
	return plan
end

local function isHall(plan: any, i: number, j: number): boolean
	return inBlock(i, j, plan.hall, 3, 3)
end
local function isShaft(block: any, i: number, j: number): boolean
	if not block then
		return false
	end
	for _, b in block do
		if inBlock(i, j, b, 1, 3) then
			return true
		end
	end
	return false
end

-- ---------------------------------------------------------------- building a level
local function buildLevel(level: number)
	local y = floorY(level)
	local plan = planOf(level)
	local r = Random.new(4100 + level * 31)
	local open = carve(r)
	local locked: any = {}
	for i = 1, N do
		locked[i] = {}
		for j = 1, N do
			locked[i][j] = { false, false, false, false }
		end
	end

	-- The hall is one room, so every wall inside it comes down.
	for i = plan.hall[1], plan.hall[1] + 2 do
		for j = plan.hall[2], plan.hall[2] + 2 do
			for d = 1, 4 do
				local ni, nj = i + DIR[d][1], j + DIR[d][2]
				if isHall(plan, ni, nj) then
					open[i][j][d] = true
				end
			end
		end
	end

	-- A shaft is entered from its north end and left at its south end, so those two
	-- ways in are forced rather than left to the dice.
	--- Stamp an inclined shaft into the graph. Its sides are solid rock, because the
	--- walls of a slope have to run the full height between two levels; if the maze were
	--- allowed to open into them it would be opening onto a drop. One way in at the top,
	--- one way out at the bottom, and nothing through the flanks.
	local function openShaft(blocks: any, atTop: boolean)
		if not blocks then
			return
		end
		local function set(i: number, j: number, d: number, want: boolean)
			local ni, nj = i + DIR[d][1], j + DIR[d][2]
			open[i][j][d] = want
			locked[i][j][d] = true
			if inGrid(ni, nj) then
				open[ni][nj][BACK[d]] = want
				locked[ni][nj][BACK[d]] = true
			end
		end
		for _, b in blocks do
			local i, top, mid, bot = b[1], b[2], b[2] + 1, b[2] + 2
			set(i, top, 3, true) -- the three cells of the slope always join each other
			set(i, mid, 3, true)
			for _, j in { top, mid, bot } do
				set(i, j, 2, false)
				set(i, j, 4, false)
			end
			set(i, top, 1, atTop)
			set(i, bot, 3, not atTop)
		end
	end
	openShaft(plan.down, true)
	openShaft(plan.up, false)
	-- braid last, so the loops are woven around the shafts rather than through them
	braid(open, locked, r)

	-- floors and ceilings, a slab per cell, minus the holes the shafts need
	for i = 1, N do
		for j = 1, N do
			local at = Vector3.new(cx(i), y, cx(j))
			local overShaft = isShaft(plan.down, i, j) -- this level's floor is its slope
			local underShaft = isShaft(plan.up, i, j) -- and the level above comes through
			if not overShaft then
				box(`F{level}_{i}_{j}`, Vector3.new(P, T, P), at + Vector3.new(0, -T / 2, 0), DEEP, SLATE)
			end
			if not underShaft then
				box(`C{level}_{i}_{j}`, Vector3.new(P, T, P), at + Vector3.new(0, H + T / 2, 0), CHAR, SLATE)
			end
		end
	end

	-- rock: a pillar on every grid crossing, and a block in every wall that stayed shut
	for k = 0, N do
		for l = 0, N do
			local skip = false
			-- inside the hall the crossings are gone; it is one room
			if k >= plan.hall[1] and k <= plan.hall[1] + 1 and l >= plan.hall[2] and l <= plan.hall[2] + 1 then
				skip = true
			end
			if not skip then
				box(
					`Pil{level}_{k}_{l}`,
					Vector3.new(ROCK, H, ROCK),
					Vector3.new(line(k), y + H / 2, line(l)),
					ASH,
					STONE
				)
			end
		end
	end
	for i = 1, N do
		for j = 1, N do
			-- +x wall
			if i < N and not open[i][j][2] then
				box(`Wx{level}_{i}_{j}`, Vector3.new(ROCK, H, W), Vector3.new(line(i), y + H / 2, cx(j)), ASH, STONE)
			end
			-- +z wall
			if j < N and not open[i][j][3] then
				box(`Wz{level}_{i}_{j}`, Vector3.new(W, H, ROCK), Vector3.new(cx(i), y + H / 2, line(j)), ASH, STONE)
			end
		end
	end
	-- the outside of the grid is always rock
	for i = 1, N do
		box(`Bn{level}_{i}`, Vector3.new(W, H, ROCK), Vector3.new(cx(i), y + H / 2, line(0)), ASH, STONE)
		box(`Bs{level}_{i}`, Vector3.new(W, H, ROCK), Vector3.new(cx(i), y + H / 2, line(N)), ASH, STONE)
		box(`Bw{level}_{i}`, Vector3.new(ROCK, H, W), Vector3.new(line(0), y + H / 2, cx(i)), ASH, STONE)
		box(`Be{level}_{i}`, Vector3.new(ROCK, H, W), Vector3.new(line(N), y + H / 2, cx(i)), ASH, STONE)
	end

	return plan, open
end

-- ---------------------------------------------------------------- the shafts
--- An inclined tunnel, one cell wide and two long, dropping a whole level. The ramp is
--- the floor; the steps on it are scenery, as they are in the pyramid, because a
--- continuous surface is the difference between walking down and catching on every nose.
local function buildShaft(level: number, b: { number })
	local i, j = b[1], b[2]
	local yTop, yLow = floorY(level), floorY(level + 1)
	local a = Vector3.new(cx(i), yTop - 1.5, line(j - 1))
	-- Stop 8 studs short of the boundary, reaching floor level exactly. Run to the
	-- boundary and the sloping top surface CROSSES the lower floor's top surface, and
	-- the zero-thickness wedge where they meet is what was catching players and
	-- throwing them to the surface - always at the bottom, never on the way down.
	local c = Vector3.new(cx(i), yLow - 1.5, line(j + 2) - 8)
	local span = (c - a).Magnitude
	local mid = (a + c) / 2
	local cf = CFrame.lookAt(mid, c)
	-- Ten studs thick, and exactly the width of the tunnel. An earlier attempt widened it
	-- to tuck under the walls; that put nine studs of walkable surface INSIDE solid rock
	-- on either side, and a character straying onto it was squeezed out and thrown to
	-- the surface. It showed up as roughly one descent in three failing, at random, on
	-- shafts that were otherwise fine.
	slab(`Ramp{level}_{i}_{j}`, Vector3.new(W, 10, span), cf * CFrame.new(0, -3.5, 0), DEEP, SLATE)
	slab(`RampRoof{level}_{i}_{j}`, Vector3.new(W + ROCK, 3, span), cf * CFrame.new(0, H + 3, 0), CHAR, SLATE)
	local steps = math.floor(span / RUN)
	for s = 1, steps - 1 do
		slab(
			`Tread{level}_{i}_{j}_{s}`,
			Vector3.new(W, 0.5, 0.8),
			cf * CFrame.new(0, 1.6, span / 2 - s * RUN),
			CHAR,
			SLATE,
			{ canCollide = false }
		)
	end
	-- the walls of the slope have to reach from the lower floor to the upper ceiling,
	-- because the rock between two levels is otherwise nothing at all
	local h = (yTop + H) - yLow
	for _, side in { -1, 1 } do
		box(
			`ShaftWall{level}_{i}_{j}_{side}`,
			Vector3.new(ROCK, h, P * 3),
			Vector3.new(cx(i) + side * (W + ROCK) / 2, yLow + h / 2, cx(j) + P),
			ASH,
			STONE
		)
	end
	torch(CFrame.new(cx(i) + (W / 2 - 0.2), yTop - 8, cx(j) + P) * CFrame.Angles(0, math.pi / 2, 0))
end

-- ---------------------------------------------------------------- dressing a level
local YAW = function(d: number): number
	return math.atan2(DIR[d][1], DIR[d][2])
end

local function dressLevel(level: number, plan: any, open: any)
	local y = floorY(level)
	local hx, hz = cx(plan.hall[1] + 1), cx(plan.hall[2] + 1)
	local at = Vector3.new(hx, y, hz)
	table.insert(marks, { name = `L{level}_{HALL_NAME[level]}`, at = at + Vector3.new(0, 4, 0) })

	-- the mirage, and what stands around it
	pool(at, 18)
	for _, sx in { -1, 1 } do
		for _, sz in { -1, 1 } do
			column(CFrame.new(at + Vector3.new(sx * 26, 0, sz * 26)), H - 1)
			brazier(CFrame.new(at + Vector3.new(sx * 38, 0, sz * 38)))
		end
	end
	-- coffins along two walls of the hall, clear of the way through
	for k = -1, 1 do
		coffin(CFrame.new(at + Vector3.new(-40, 0, k * 14)), k == 0 and level % 2 == 1)
		coffin(CFrame.new(at + Vector3.new(40, 0, k * 14)), k == 0 and level % 2 == 0)
	end
	for _, sx in { -1, 1 } do
		relief(CFrame.new(at + Vector3.new(sx * 44.5, 9, 0)) * CFrame.Angles(0, sx * math.pi / 2, 0), 40, 10)
	end
	bonePile(CFrame.new(at + Vector3.new(0, 0, 34)), 10)
	skeleton(CFrame.new(at + Vector3.new(-12, 0, 36)))

	-- the tunnels: a torch on roughly every third wall, and the odd find
	for i = 1, N do
		for j = 1, N do
			if isHall(plan, i, j) or isShaft(plan.down, i, j) or isShaft(plan.up, i, j) then
				continue
			end
			local shut = {}
			for d = 1, 4 do
				if not open[i][j][d] then
					table.insert(shut, d)
				end
			end
			if #shut > 0 and rng:NextNumber() < 0.38 then
				local d = shut[rng:NextInteger(1, #shut)]
				torch(
					CFrame.new(cx(i) + DIR[d][1] * (W / 2 - 0.2), y + 7, cx(j) + DIR[d][2] * (W / 2 - 0.2))
						* CFrame.Angles(0, YAW(d), 0)
				)
			end
			-- Anything solid goes against a wall. A coffin parked in the middle of an
			-- 18-stud tunnel is a squeeze, and a maze is hard enough already.
			local wall = if #shut > 0 then shut[rng:NextInteger(1, #shut)] else nil
			local roll = rng:NextNumber()
			if wall and roll < 0.07 then
				local push = Vector3.new(DIR[wall][1], 0, DIR[wall][2]) * 5.5
				coffin(
					CFrame.new(Vector3.new(cx(i), y, cx(j)) + push) * CFrame.Angles(0, YAW(wall) + math.pi / 2, 0),
					roll < 0.025
				)
			elseif roll < 0.12 then
				bonePile(CFrame.new(cx(i) + rng:NextNumber(-4, 4), y, cx(j) + rng:NextNumber(-4, 4)), 7)
			elseif wall and roll < 0.17 then
				urn(CFrame.new(cx(i) + DIR[wall][1] * 6.5, y, cx(j) + DIR[wall][2] * 6.5))
			elseif roll < 0.2 then
				skeleton(CFrame.new(cx(i), y, cx(j)) * CFrame.Angles(0, rng:NextNumber(0, 6.2), 0))
			end
		end
	end
end

-- ---------------------------------------------------------------- the Sphinx
-- A lion lying down with a king's head, facing the obelisk. Local -Z is the way it
-- looks. Nothing here is carved: it is thirty-odd boxes, the way everything in this
-- pack is, and it reads at a distance because the silhouette is right.
local function buildSphinx()
	local function part(name: string, size: Vector3, at: Vector3, color: Color3, material: Enum.Material)
		box(name, size, at, color, material)
	end
	-- The plinth is built in four pieces rather than one, because the way in runs down
	-- through it: a solid slab here buries the top of the entry ramp, which is exactly
	-- what it did the first time.
	for _, side in { -1, 1 } do
		part(`Plinth{side}`, Vector3.new(34, 8, 250), Vector3.new(side * 26, 4, -133), ASH, SAND)
		part(`PlinthLip{side}`, Vector3.new(34, 2, 256), Vector3.new(side * 26, 8.5, -133), DEEP, SLATE)
	end
	part("PlinthFront", Vector3.new(18, 8, 24), Vector3.new(0, 4, -246), ASH, SAND)
	part("PlinthFrontLip", Vector3.new(18, 2, 24), Vector3.new(0, 8.5, -246), DEEP, SLATE)
	part("PlinthBack", Vector3.new(18, 8, 142), Vector3.new(0, 4, -79), ASH, SAND)
	part("PlinthBackLip", Vector3.new(18, 2, 142), Vector3.new(0, 8.5, -79), DEEP, SLATE)
	part("Haunch", Vector3.new(54, 38, 76), Vector3.new(0, 27, -58), ASH, SAND)
	part("Body", Vector3.new(48, 32, 64), Vector3.new(0, 24, -124), ASH, SAND)
	part("Chest", Vector3.new(54, 44, 44), Vector3.new(0, 30, -176), ASH, SAND)
	part("Tail", Vector3.new(6, 6, 46), Vector3.new(26, 13, -34), ASH, SAND)
	part("TailTuft", Vector3.new(8, 8, 8), Vector3.new(26, 13, -12), CHAR, SAND)
	for _, side in { -1, 1 } do
		part(`Foreleg{side}`, Vector3.new(16, 16, 84), Vector3.new(side * 17, 16, -212), ASH, SAND)
		part(`Paw{side}`, Vector3.new(20, 18, 16), Vector3.new(side * 17, 17, -250), ASH, SAND)
		for t = -1, 1 do
			part(`Toe{side}_{t}`, Vector3.new(5, 6, 6), Vector3.new(side * 17 + t * 6, 11, -257), ASH, SAND)
		end
		part(`Shoulder{side}`, Vector3.new(12, 26, 26), Vector3.new(side * 21, 30, -186), ASH, SAND)
	end
	-- neck and head
	part("Neck", Vector3.new(26, 16, 26), Vector3.new(0, 60, -182), ASH, SAND)
	part("Head", Vector3.new(28, 22, 26), Vector3.new(0, 79, -186), ASH, SAND)
	-- the nemes: the striped headcloth, flaring either side of the face
	for _, side in { -1, 1 } do
		part(`Nemes{side}`, Vector3.new(9, 34, 30), Vector3.new(side * 18, 72, -184), GOLD, Enum.Material.Metal)
		for k = 0, 4 do
			part(
				`NemesBand{side}_{k}`,
				Vector3.new(9.6, 3, 30.6),
				Vector3.new(side * 18, 60 + k * 7, -184),
				CHAR,
				SLATE
			)
		end
	end
	part("NemesTop", Vector3.new(34, 7, 30), Vector3.new(0, 93, -184), GOLD, Enum.Material.Metal)
	part("NemesBack", Vector3.new(28, 26, 10), Vector3.new(0, 76, -170), GOLD, Enum.Material.Metal)
	-- the face
	part("Brow", Vector3.new(26, 4, 4), Vector3.new(0, 86, -199), ASH, SAND)
	for _, side in { -1, 1 } do
		part(`EyeWhite{side}`, Vector3.new(6, 4, 2), Vector3.new(side * 7, 82, -199.5), BONE, SAND)
		slab(`EyePupil{side}`, Vector3.new(2.4, 3, 1.4), CFrame.new(side * 7, 82, -200.2), CHAR, SLATE)
	end
	part("Nose", Vector3.new(5, 9, 5), Vector3.new(0, 77, -199.5), ASH, SAND)
	part("Mouth", Vector3.new(13, 3, 3), Vector3.new(0, 71, -199.5), CHAR, SLATE)
	part("Chin", Vector3.new(17, 6, 6), Vector3.new(0, 68, -198.5), ASH, SAND)
	part("Beard", Vector3.new(9, 18, 7), Vector3.new(0, 57, -197), GOLD, Enum.Material.Metal)
	part("Uraeus", Vector3.new(4, 7, 4), Vector3.new(0, 91, -199), GOLD, Enum.Material.Metal)

	-- between the paws: the stele, the jambs, and the way in
	slab("Stele", Vector3.new(20, 26, 2.5), CFrame.new(0, 21, -218), GOLD, Enum.Material.Metal)
	relief(CFrame.new(0, 21, -219.6), 16, 20)
	for _, side in { -1, 1 } do
		part(`Jamb{side}`, Vector3.new(4, 24, 4), Vector3.new(side * 10, 20, -234), GOLD, Enum.Material.Metal)
		brazier(CFrame.new(side * 16, 8, -244))
	end
	part("Lintel", Vector3.new(26, 4, 5), Vector3.new(0, 34, -234), GOLD, Enum.Material.Metal)

	-- The way up onto the plinth. Without this the base is a ten-stud kerb all the way
	-- round and the whole monument is unreachable on foot: you walk up to the paws and
	-- stop dead. A humanoid climbs two studs, not ten.
	do
		local a = Vector3.new(0, -1.5, -286)
		local c = Vector3.new(0, 9.5 - 1.5, -258)
		local span = (c - a).Magnitude
		local cf = CFrame.lookAt((a + c) / 2, c)
		slab("Approach", Vector3.new(W, 3, span), cf, ASH, SAND)
		local steps = math.floor(span / RUN)
		for k = 1, steps - 1 do
			slab(
				`ApproachTread{k}`,
				Vector3.new(W, 0.5, 0.8),
				cf * CFrame.new(0, 1.6, span / 2 - k * RUN),
				DEEP,
				SLATE,
				{
					canCollide = false,
				}
			)
		end
		for _, side in { -1, 1 } do
			slab(
				`ApproachKerb{side}`,
				Vector3.new(2, 2.5, span),
				cf * CFrame.new(side * (W / 2 + 1), 1.2, 0),
				GOLD,
				Enum.Material.Metal
			)
		end
	end
end

--- The descending passage: from between the paws down into the first level of tunnels.
local function buildEntrance()
	-- starts flush with the front of the plinth, so the first step down is a step, not
	-- a drop into a slot
	local a = Vector3.new(0, 8 - 1.5, -234)
	local c = Vector3.new(0, floorY(1) - 1.5, -150)
	local span = (c - a).Magnitude
	local cf = CFrame.lookAt((a + c) / 2, c)
	slab("EntryRamp", Vector3.new(W + ROCK, 3, span), cf, DEEP, SLATE)
	slab("EntryRoof", Vector3.new(W + 2 * ROCK, 3, span), cf * CFrame.new(0, H + 3, 0), CHAR, SLATE)
	local steps = math.floor(span / RUN)
	for s = 1, steps - 1 do
		slab(`EntryTread{s}`, Vector3.new(W, 0.5, 0.8), cf * CFrame.new(0, 1.6, span / 2 - s * RUN), CHAR, SLATE, {
			canCollide = false,
		})
	end
	for _, side in { -1, 1 } do
		slab(
			`EntryWall{side}`,
			Vector3.new(ROCK, H + 8, span),
			cf * CFrame.new(side * (W + ROCK) / 2, (H + 8) / 2 - 1, 0),
			ASH,
			STONE
		)
		torch(CFrame.new(side * (W / 2 - 0.2), -2, -196) * CFrame.Angles(0, side * math.pi / 2, 0))
	end
	table.insert(marks, { name = "Door", at = Vector3.new(0, 9, -232) })
end

-- ---------------------------------------------------------------- build it all
buildSphinx()
buildEntrance()

local cells = 0
for level = 1, LEVELS do
	local plan, open = buildLevel(level)
	if plan.down then
		for _, b in plan.down do
			buildShaft(level, b)
		end
	end
	dressLevel(level, plan, open)
	-- A marker per cell, carrying the four walls it was generated with, so the built
	-- maze can be checked against the maze that was asked for rather than eyeballed.
	for i = 1, N do
		for j = 1, N do
			local code = ""
			for d = 1, 4 do
				code ..= if open[i][j][d] then "1" else "0"
			end
			-- the marker says what kind of cell it is, so a check can skip the shafts:
			-- a ray across a slope hits its roof, which is correct and not a fault
			local kind = if isShaft(plan.down, i, j) or isShaft(plan.up, i, j)
				then "s"
				elseif isHall(plan, i, j) then "h"
				else "m"
			cells += 1
			box(
				`Cell_{level}_{i}_{j}_{code}_{kind}`,
				Vector3.new(1, 1, 1),
				Vector3.new(cx(i), floorY(level) + 4, cx(j)),
				BONE,
				PLASTIC,
				{ transparency = 1, canCollide = false, group = "SphinxCells" }
			)
		end
	end
end

-- the first level's way in has to be a hole in the north wall, not a wall
for idx = #parts, 1, -1 do
	if parts[idx].name == "Bn1_5" then
		table.remove(parts, idx)
	end
end

local route: { any } = {}
for i, m in marks do
	table.insert(parts, {
		name = string.format("SRoute_%02d_%s", i, m.name),
		size = Vector3.new(2, 2, 2),
		position = m.at + ORIGIN,
		color = GOLD,
		material = PLASTIC,
		transparency = 1,
		canCollide = false,
		castShadow = false,
		group = "SphinxRoute",
	})
	table.insert(route, { name = m.name, position = m.at + ORIGIN })
end

return {
	origin = ORIGIN,
	-- big enough to cover the lion as well as the grid, so no desert scrub is left
	-- standing inside the plinth
	half = 280,
	parts = parts,
	route = route,
	stats = { parts = #parts, cells = cells, levels = LEVELS, grid = N },
}

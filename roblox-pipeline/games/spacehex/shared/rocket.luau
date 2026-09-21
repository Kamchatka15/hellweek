-- rocket — the silhouette, as data. Shared: the server stands this on the pad and the
-- client draws the same stack in the assembly preview and in every warehouse icon.
--
-- No prices and no physics live here. It takes part records (thrust, prop, cd, class)
-- and returns primitive part specs, so the rocket changes the moment a part does because
-- the data did. Everything is a plain Part: nothing is uploaded, nothing is moderated.
--
-- Frame: y = 0 is the bottom of the lowest engine bell, +Y is up, the stack is centred
-- on the axis. Every spec carries `stage` (1 = bottom, 0 = the top section) so the loop
-- knows what to drop at separation, and `role` so it knows where the fire goes.
--
-- v1 is hand-built. tools/gen_rocket.py regenerates this file with finer slicing.

local theme = require(script.Parent.theme)

local Rocket = {}

local SCALE = 1.5
local P = theme.rocket

-- ---------------------------------------------------------------- sizes

--- A tank's radius and height in studs, from how much it holds. Bigger tanks get
--- proportionally longer, which is why a real rocket is one enormous tank.
function Rocket.tankSize(part: any): (number, number)
	local prop = (part and part.prop) or 105
	local k = prop / 105
	return math.clamp(0.62 * k ^ 0.27, 0.6, 3.6) * SCALE, math.clamp(2.0 * k ^ 0.37, 2.0, 21) * SCALE
end

--- An engine bell's radius and height, from thrust.
function Rocket.bellSize(part: any): (number, number)
	local thrust = (part and part.thrust) or 9000
	local k = thrust / 9000
	return math.clamp(0.42 * k ^ 0.33, 0.35, 2.4) * SCALE, math.clamp(0.7 * k ^ 0.3, 0.7, 3.4) * SCALE
end

-- ---------------------------------------------------------------- primitives

local function spec(role: string, stage: number, fields: { [string]: any }): any
	fields.role = role
	fields.stage = stage
	fields.canCollide = false
	fields.castShadow = if fields.castShadow == nil then true else fields.castShadow
	return fields
end

--- A cylinder standing on end. Roblox cylinders lie along X, so it is turned upright.
local function upright(role, stage, name, radius, height, x, y, z, color, material)
	return spec(role, stage, {
		name = name,
		shape = Enum.PartType.Cylinder,
		size = Vector3.new(height, radius * 2, radius * 2),
		cframe = CFrame.new(x, y, z) * CFrame.Angles(0, 0, math.rad(90)),
		color = color,
		material = material or Enum.Material.Metal,
	})
end

local function ball(role, stage, name, radius, x, y, z, color, material)
	return spec(role, stage, {
		name = name,
		shape = Enum.PartType.Ball,
		size = Vector3.new(radius * 2, radius * 2, radius * 2),
		cframe = CFrame.new(x, y, z),
		color = color,
		material = material or Enum.Material.Metal,
	})
end

local function block(role, stage, name, size, cframe, color, material)
	return spec(role, stage, {
		name = name,
		shape = Enum.PartType.Block,
		size = size,
		cframe = cframe,
		color = color,
		material = material or Enum.Material.Metal,
	})
end

--- A tapering column: `slices` rings from `r0` at the bottom to `r1` at the top, with a
--- profile exponent so a cone and an ogive come from the same code.
local function taper(out, role, stage, name, r0, r1, height, y0, slices, curve, color, material)
	local sliceH = height / slices
	for i = 1, slices do
		local t = (i - 0.5) / slices
		local r = r0 + (r1 - r0) * (t ^ curve)
		table.insert(
			out,
			upright(role, stage, `{name}{i}`, r, sliceH + 0.02, 0, y0 + (i - 0.5) * sliceH, 0, color, material)
		)
	end
end

local function clusterOffsets(n: number, ring: number): { { number } }
	if n <= 1 then
		return { { 0, 0 } }
	end
	local out = {}
	for i = 1, n do
		local a = (i - 1) / n * math.pi * 2 + (if n == 4 then math.pi / 4 else 0)
		table.insert(out, { math.cos(a) * ring, math.sin(a) * ring })
	end
	return out
end

-- ---------------------------------------------------------------- pieces

--- One engine bell at (x, z) with its foot at y0. Three rings so it reads as a bell;
--- the bottom ring is tagged `bellMouth`, which is where the loop hangs the fire.
local function bell(out, stage, index, radius, height, x, y0, z)
	local tag = `S{stage}Bell{index}`
	local slices = 3
	local sliceH = height * 0.78 / slices
	for i = 1, slices do
		local t = (i - 0.5) / slices
		local r = radius + (radius * 0.55 - radius) * (t ^ 1.4)
		table.insert(
			out,
			upright(
				if i == 1 then "bellMouth" else "bell",
				stage,
				`{tag}_{i}`,
				r,
				sliceH + 0.02,
				x,
				y0 + (i - 0.5) * sliceH,
				z,
				P.bell
			)
		)
	end
	table.insert(
		out,
		upright("throat", stage, `{tag}Throat`, radius * 0.4, height * 0.3, x, y0 + height * 0.85, z, P.dark)
	)
end

local function fins(out, stage, part, radius, y0, tankH)
	if not part then
		return
	end
	local grid = (part.control or 1) > 1.5
	local count = if grid then 4 else 3
	local span = if grid then radius * 0.85 else math.max(radius * 1.1, 0.8 * SCALE)
	local height = if grid then radius * 0.85 else math.max(radius * 2.2, 1.6 * SCALE)
	local thick = (if grid then 0.16 else 0.1) * SCALE
	local y = if grid then y0 + tankH - height * 0.75 else y0 + height * 0.5
	for i = 1, count do
		local a = (i - 1) / count * math.pi * 2 + math.pi / count
		table.insert(
			out,
			block(
				"fin",
				stage,
				`S{stage}Fin{i}`,
				Vector3.new(span, height, thick),
				CFrame.new(0, y, 0) * CFrame.Angles(0, a, 0) * CFrame.new(radius + span / 2 - 0.05, 0, 0),
				P.fin,
				if grid then Enum.Material.DiamondPlate else Enum.Material.Metal
			)
		)
	end
end

local function recovery(out, stage, part, radius, y0, tankH)
	if not part then
		return
	end
	if (part.refund or 0) >= 0.6 then
		-- legs: four struts splayed from the foot of the tank
		local len = math.max(radius * 1.5, 1.2 * SCALE)
		for i = 1, 4 do
			local a = (i - 1) / 4 * math.pi * 2
			table.insert(
				out,
				block(
					"leg",
					stage,
					`S{stage}Leg{i}`,
					Vector3.new(0.18 * SCALE, len, 0.18 * SCALE),
					CFrame.new(0, y0 + len * 0.45, 0)
						* CFrame.Angles(0, a, 0)
						* CFrame.new(radius * 0.95, 0, 0)
						* CFrame.Angles(0, 0, math.rad(-28)),
					P.dark
				)
			)
		end
	else
		-- chutes: a pack strapped to the shoulder of the tank
		table.insert(
			out,
			block(
				"chute",
				stage,
				`S{stage}Chutes`,
				Vector3.new(radius * 0.5, radius * 0.7, radius * 0.5),
				CFrame.new(radius * 0.95, y0 + tankH * 0.8, 0),
				P.dark
			)
		)
	end
end

-- ---------------------------------------------------------------- the stack

--- The whole rocket. `asm` is the assembly table, `byId` maps part id -> part record.
--- Returns the specs and the stack height. Missing parts are skipped, never errors: an
--- assembly with a hole in it still draws, and the hole is visible.
function Rocket.stack(asm: any, byId: { [string]: any }): ({ any }, number)
	local out = {}
	local y = 0
	local topR = 0.6 * SCALE
	local stages = asm.stages or {}

	for i, s in ipairs(stages) do
		local engine = s.engine and byId[s.engine]
		local tank = s.tank and byId[s.tank]
		local n = math.clamp(s.engineCount or 1, 1, 4)
		local tr, th = Rocket.tankSize(tank)
		local br, bh = Rocket.bellSize(engine)
		local ring = 0
		if n > 1 then
			ring = tr * 0.5
			br = math.min(br, tr * (if n == 2 then 0.48 else 0.42))
		else
			br = math.min(br, tr * 0.95)
		end

		if engine then
			for k, offset in clusterOffsets(n, ring) do
				bell(out, i, k, br, bh, offset[1], y, offset[2])
			end
		end
		local tankY = y + (if engine then bh else 0)
		if tank then
			table.insert(out, upright("tank", i, `S{i}Tank`, tr, th, 0, tankY + th / 2, 0, P.body))
			if i == 1 then
				fins(out, i, s.fins and byId[s.fins], tr, tankY, th)
			end
			recovery(out, i, s.recovery and byId[s.recovery], tr, tankY, th)
		end
		y = tankY + (if tank then th else 0)
		if s.decoupler and byId[s.decoupler] and i < #stages then
			local ringH = 0.3 * SCALE
			table.insert(out, upright("decoupler", i, `S{i}Decoupler`, tr * 1.04, ringH, 0, y + ringH / 2, 0, P.dark))
			y += ringH
		end
		topR = tr
	end

	-- the top section: guidance band, service module, payload, nose
	local gnc = asm.gnc and byId[asm.gnc]
	if gnc and (gnc.mass or 0) > 0 then
		local bandH = 0.22 * SCALE
		table.insert(out, upright("gnc", 0, "Guidance", topR * 1.01, bandH, 0, y + bandH / 2, 0, P.dark))
		y += bandH
	end
	local payload = asm.payload and byId[asm.payload]
	local nose = asm.nose and byId[asm.nose]
	local protected = nose and nose.protects
	if payload or asm.rcs or asm.dock then
		local svcR = topR * 0.88
		local svcH = 0.9 * SCALE
		table.insert(out, upright("service", 0, "Service", svcR, svcH, 0, y + svcH / 2, 0, P.body))
		if asm.rcs then
			for i = 1, 4 do
				local a = (i - 1) / 4 * math.pi * 2
				table.insert(
					out,
					block(
						"rcs",
						0,
						`Rcs{i}`,
						Vector3.new(0.3 * SCALE, 0.3 * SCALE, 0.3 * SCALE),
						CFrame.new(0, y + svcH / 2, 0) * CFrame.Angles(0, a, 0) * CFrame.new(svcR, 0, 0),
						P.dark
					)
				)
			end
		end
		y += svcH
		if asm.dock then
			local dockH = 0.2 * SCALE
			table.insert(out, upright("dock", 0, "DockingPort", topR * 0.6, dockH, 0, y + dockH / 2, 0, P.dark))
			y += dockH
		end
		if payload and not protected then
			local side = topR * 0.9
			table.insert(
				out,
				block("payload", 0, "Payload", Vector3.new(side, side, side), CFrame.new(0, y + side / 2, 0), P.payload)
			)
			y += side
		end
	end
	if nose then
		if protected then
			-- a fairing: a wider shell, with the payload riding inside it
			local fr = topR * 1.15
			local shellH = topR * 2.0
			table.insert(
				out,
				upright(
					"nose",
					0,
					"FairingShell",
					fr,
					shellH,
					0,
					y + shellH / 2,
					0,
					P.body,
					Enum.Material.SmoothPlastic
				)
			)
			if payload then
				local side = topR * 0.9
				table.insert(
					out,
					block(
						"payload",
						0,
						"Payload",
						Vector3.new(side, side, side),
						CFrame.new(0, y + side / 2 + 0.1, 0),
						P.payload
					)
				)
			end
			taper(
				out,
				"nose",
				0,
				"Fairing",
				fr,
				0.12 * SCALE,
				topR * 1.7,
				y + shellH,
				6,
				0.55,
				P.body,
				Enum.Material.SmoothPlastic
			)
			y += shellH + topR * 1.7
		elseif (nose.cd or 0.5) >= 0.4 then
			-- blunt: a dome, half buried in the tank top
			table.insert(out, ball("nose", 0, "Cap", topR, 0, y, 0, P.body))
			y += topR
		elseif (nose.cd or 0.5) >= 0.3 then
			taper(out, "nose", 0, "Cone", topR, 0.1 * SCALE, topR * 2.3, y, 6, 1.0, P.body)
			y += topR * 2.3
		else
			taper(out, "nose", 0, "Ogive", topR, 0.1 * SCALE, topR * 3.0, y, 8, 0.55, P.body)
			y += topR * 3.0
		end
	end

	return out, y
end

-- ---------------------------------------------------------------- icons

--- One part on its own, centred at the origin, for a ViewportFrame. The icon IS the part.
function Rocket.icon(part: any): { any }
	local out = {}
	local class = part.class
	if class == "engine" then
		local br, bh = Rocket.bellSize(part)
		bell(out, 1, 1, br, bh, 0, -bh / 2, 0)
	elseif class == "tank" then
		local tr, th = Rocket.tankSize(part)
		table.insert(out, upright("tank", 1, "Tank", tr, th, 0, 0, 0, P.body))
	elseif class == "nose" then
		local r = 1.0 * SCALE
		if part.protects then
			table.insert(
				out,
				upright("nose", 0, "Shell", r * 1.15, r * 2, 0, -r, 0, P.body, Enum.Material.SmoothPlastic)
			)
			taper(out, "nose", 0, "Fairing", r * 1.15, 0.12, r * 1.7, 0, 6, 0.55, P.body, Enum.Material.SmoothPlastic)
		elseif (part.cd or 0.5) >= 0.4 then
			table.insert(out, ball("nose", 0, "Cap", r, 0, 0, 0, P.body))
		elseif (part.cd or 0.5) >= 0.3 then
			taper(out, "nose", 0, "Cone", r, 0.1, r * 2.3, -r, 6, 1.0, P.body)
		else
			taper(out, "nose", 0, "Ogive", r, 0.1, r * 3.0, -r * 1.4, 8, 0.55, P.body)
		end
	elseif class == "fin" then
		local grid = (part.control or 1) > 1.5
		table.insert(
			out,
			block(
				"fin",
				1,
				"Fin",
				Vector3.new(1.6 * SCALE, if grid then 1.6 * SCALE else 2.6 * SCALE, 0.12 * SCALE),
				CFrame.new(0, 0, 0),
				P.fin,
				if grid then Enum.Material.DiamondPlate else Enum.Material.Metal
			)
		)
	elseif class == "gnc" then
		table.insert(out, block("gnc", 0, "Box", Vector3.new(1.4, 0.9, 1.4) * SCALE, CFrame.new(0, 0, 0), P.dark))
		table.insert(
			out,
			block(
				"gnc",
				0,
				"Stripe",
				Vector3.new(1.45, 0.16, 0.3) * SCALE,
				CFrame.new(0, 0.2, 0),
				P.body,
				Enum.Material.Neon
			)
		)
	elseif class == "decoupler" then
		table.insert(out, upright("decoupler", 1, "Ring", 1.2 * SCALE, 0.35 * SCALE, 0, 0, 0, P.dark))
	elseif class == "recovery" then
		if (part.refund or 0) >= 0.6 then
			for i = 1, 4 do
				local a = (i - 1) / 4 * math.pi * 2
				table.insert(
					out,
					block(
						"leg",
						1,
						`Leg{i}`,
						Vector3.new(0.18, 2.2, 0.18) * SCALE,
						CFrame.new(0, 0, 0)
							* CFrame.Angles(0, a, 0)
							* CFrame.new(0.7 * SCALE, 0, 0)
							* CFrame.Angles(0, 0, math.rad(-28)),
						P.dark
					)
				)
			end
		else
			table.insert(
				out,
				block("chute", 1, "Pack", Vector3.new(1.0, 1.4, 1.0) * SCALE, CFrame.new(0, 0, 0), P.dark)
			)
			table.insert(out, ball("chute", 1, "Canopy", 0.8 * SCALE, 0, 1.1 * SCALE, 0, P.body, Enum.Material.Fabric))
		end
	elseif class == "payload" then
		if part.needsFairing then
			table.insert(
				out,
				block("payload", 0, "Bus", Vector3.new(1.0, 1.0, 1.0) * SCALE, CFrame.new(0, 0, 0), P.payload)
			)
			table.insert(
				out,
				block(
					"payload",
					0,
					"PanelA",
					Vector3.new(2.2, 0.08, 0.9) * SCALE,
					CFrame.new(1.4 * SCALE, 0, 0),
					P.dark
				)
			)
			table.insert(
				out,
				block(
					"payload",
					0,
					"PanelB",
					Vector3.new(2.2, 0.08, 0.9) * SCALE,
					CFrame.new(-1.4 * SCALE, 0, 0),
					P.dark
				)
			)
		else
			table.insert(
				out,
				block("payload", 0, "Ballast", Vector3.new(1.2, 1.2, 1.2) * SCALE, CFrame.new(0, 0, 0), P.dark)
			)
		end
	elseif class == "rcs" then
		table.insert(out, block("rcs", 0, "Body", Vector3.new(1.0, 0.7, 1.0) * SCALE, CFrame.new(0, 0, 0), P.body))
		for i = 1, 4 do
			local a = (i - 1) / 4 * math.pi * 2
			table.insert(
				out,
				block(
					"rcs",
					0,
					`Nozzle{i}`,
					Vector3.new(0.3, 0.3, 0.3) * SCALE,
					CFrame.new(0, 0, 0) * CFrame.Angles(0, a, 0) * CFrame.new(0.6 * SCALE, 0, 0),
					P.dark
				)
			)
		end
	elseif class == "dock" then
		table.insert(out, upright("dock", 0, "Port", 1.1 * SCALE, 0.3 * SCALE, 0, 0, 0, P.dark))
		table.insert(out, upright("dock", 0, "Collar", 0.7 * SCALE, 0.5 * SCALE, 0, 0.3 * SCALE, 0, P.body))
	else
		-- a pad tier: a flat hex-ish disc
		table.insert(
			out,
			upright("pad", 0, "Pad", 1.4 * SCALE, 0.25 * SCALE, 0, 0, 0, theme.pad, Enum.Material.DiamondPlate)
		)
	end
	return out
end

return Rocket

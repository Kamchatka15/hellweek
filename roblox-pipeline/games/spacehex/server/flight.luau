-- flight — the physics. Real equations, deterministic, server-side, no Roblox physics
-- and no client input. The client sends "launch"; the server says how it went.
--
-- Two numbers come out, and both are real:
--   apogee  — from a stage-by-stage vertical integration with drag and gravity.
--             This is the score a suborbital player chases.
--   deltaV  — Tsiolkovsky summed over stages, times guidance efficiency, minus losses.
--             This is what actually decides orbit. 7,700 m/s of orbital velocity, after losses, or you are coming back down.

local Flight = {}

Flight.G = 9.80665
Flight.G0 = 9.80665
Flight.RHO0 = 1.225
Flight.SCALE_H = 8500
Flight.AREA = 2.4 -- m^2 reference frontal area
Flight.DT = 1 / 20
Flight.MAX_T = 400
Flight.ORBIT_DV = 7700 -- m/s orbital velocity at ~400 km. Losses are already subtracted.

-- Drawing constants, read by the loop and the HUD and never by the physics. Below the
-- ceiling the rocket climbs at scale; above it the camera tracks a scaled view and the
-- altitude reads in km.
Flight.VISUAL_CEILING = 2000 -- m
Flight.STUDS_PER_M = 1 / 0.28 -- one stud is 0.28 m for the drawn part of the climb

function Flight.density(h)
	return Flight.RHO0 * math.exp(-h / Flight.SCALE_H)
end

-- Isp varies with ambient pressure. A sea-level bell is poor in vacuum-adjacent air and
-- a vacuum bell is poor at sea level. This one line is why upper stages exist.
local function ispAt(engine, h)
	local p = Flight.density(h) / Flight.RHO0 -- 1 at sea level, ~0 in space
	if engine.vacuum then
		return engine.isp * (0.70 + 0.30 * (1 - p))
	end
	return engine.isp * (1.00 + 0.15 * (1 - p))
end

-- Build the stage stack from an assembly. stages[1] is the bottom stage.
function Flight.resolve(asm, lib)
	local byId = {}
	for _, group in pairs(lib) do
		for _, part in ipairs(group) do
			byId[part.id] = part
		end
	end

	local nose = byId[asm.nose]
	local gnc = byId[asm.gnc]
	local payload = asm.payload and byId[asm.payload] or nil
	local rcs = asm.rcs and byId["rcs"] or nil
	local dock = asm.dock and byId["dock_port"] or nil

	local topMass = (nose and nose.mass or 0)
		+ (gnc and gnc.mass or 0)
		+ (payload and payload.mass or 0)
		+ (rcs and rcs.mass or 0)
		+ (dock and dock.mass or 0)

	local stages, control = {}, 0
	for i, s in ipairs(asm.stages) do
		local eng = byId[s.engine]
		local tank = byId[s.tank]
		local dec = s.decoupler and byId[s.decoupler] or nil
		local fin = s.fins and byId[s.fins] or nil
		local rec = s.recovery and byId[s.recovery] or nil
		local n = s.engineCount or 1
		local dry = eng.mass * n
			+ tank.mass
			+ (dec and dec.mass or 0)
			+ (fin and fin.mass or 0)
			+ (rec and rec.mass or 0)
		stages[i] = {
			engine = eng,
			count = n,
			dry = dry,
			prop = tank.prop,
			thrust = eng.thrust * n,
			burnRate = (eng.thrust * n) / (eng.isp * Flight.G0),
			recovery = rec,
		}
		if i == 1 and fin then
			control += fin.control
		end
	end

	local cd = nose and nose.cd or 0.55
	local turn = (gnc and gnc.turn or 0.70) * (0.86 + 0.14 * math.min(control, 2.2) / 2.2)

	local totalMass = topMass
	for _, st in ipairs(stages) do
		totalMass += st.dry + st.prop
	end

	return {
		stages = stages,
		topMass = topMass,
		cd = cd,
		turn = turn,
		control = control,
		totalMass = totalMass,
		hasRcs = rcs ~= nil,
		hasDock = dock ~= nil,
		payload = payload,
		nose = nose,
	}
end

-- Mass still on the vehicle from stage i upward, with `fuel` left in stage i.
local function massFrom(v, i, fuel)
	local m = v.topMass + fuel
	for k = i, #v.stages do
		m += v.stages[k].dry
	end
	for k = i + 1, #v.stages do
		m += v.stages[k].prop
	end
	return m
end

function Flight.simulate(v)
	local s1 = v.stages[1]
	local liftoffTWR = s1.thrust / (v.totalMass * Flight.G)
	if liftoffTWR <= 1.0 then
		return {
			apogee = 0,
			held = true,
			twr = liftoffTWR,
			deltaV = 0,
			effectiveDV = 0,
			seconds = 0,
			orbit = false,
			trace = {},
		}
	end

	-- Tsiolkovsky over the stack, using Isp at a representative altitude per stage.
	local dvTotal, repH = 0, 0
	for i, st in ipairs(v.stages) do
		local m0 = massFrom(v, i, st.prop)
		local mf = massFrom(v, i, 0)
		dvTotal += ispAt(st.engine, repH) * Flight.G0 * math.log(m0 / mf)
		repH = repH + 60000 -- each stage flies higher than the last
	end

	-- Losses. Gravity loss punishes a lazy liftoff; drag loss punishes a blunt nose and
	-- an over-powered one. 1.4 : 1 is the sweet spot, which is the real answer too.
	local gravityLoss = 1450 * math.min(2.2, (1.40 / liftoffTWR) ^ 0.95)
	local dragLoss = 340 * (v.cd / 0.31) * math.min(2.0, math.max(0.6, liftoffTWR / 1.40))
	local effective = dvTotal * v.turn - gravityLoss - dragLoss

	-- Vertical integration for the visible apogee.
	local h, vel, t, apogee = 0, 0, 0, 0
	local stage, fuel = 1, v.stages[1].prop
	local trace = {}
	while t < Flight.MAX_T do
		local st = v.stages[stage]
		local burning = fuel > 0
		local mass = massFrom(v, stage, fuel)
		local thrust = 0
		if burning then
			thrust = st.thrust * (ispAt(st.engine, h) / st.engine.isp)
		end
		local drag = 0.5 * Flight.density(h) * vel * math.abs(vel) * v.cd * Flight.AREA
		vel += ((thrust - drag) / mass - Flight.G) * Flight.DT
		h = math.max(0, h + vel * Flight.DT)
		if burning then
			fuel = math.max(0, fuel - st.burnRate * Flight.DT)
		end
		if fuel <= 0 and stage < #v.stages then
			stage += 1
			fuel = v.stages[stage].prop
		end
		t += Flight.DT
		if h > apogee then
			apogee = h
		end
		if #trace == 0 or t - trace[#trace].t >= 0.25 then
			table.insert(trace, { t = t, h = h, v = vel })
		end
		if h <= 0 and vel < 0 and t > 2 then
			break
		end
	end

	-- Guidance turns vertical speed into horizontal speed, so a well-guided rocket
	-- reaches a LOWER apogee on the way to a higher orbit. That trade is the game.
	apogee = apogee * (0.55 + 0.45 * (1 - v.turn))
	if effective >= Flight.ORBIT_DV then
		apogee = math.max(apogee, 400000)
	end

	return {
		apogee = apogee,
		held = false,
		twr = liftoffTWR,
		deltaV = dvTotal,
		effectiveDV = effective,
		gravityLoss = gravityLoss,
		dragLoss = dragLoss,
		seconds = t,
		orbit = effective >= Flight.ORBIT_DV,
		docked = effective >= Flight.ORBIT_DV and v.hasRcs and v.hasDock,
		trace = trace,
	}
end

-- Fast closed-form evaluation: TWR, staged Tsiolkovsky, losses. No integration.
-- Used by the designer to rank thousands of candidate stacks; the winner then gets the
-- full simulate() so the player sees a real trajectory.
function Flight.quick(v)
	local s1 = v.stages[1]
	local twr = s1.thrust / (v.totalMass * Flight.G)
	if twr <= 1.0 then
		return { held = true, twr = twr, effectiveDV = 0 }
	end
	local dv, repH = 0, 0
	for i, st in ipairs(v.stages) do
		local m0 = massFrom(v, i, st.prop)
		local mf = massFrom(v, i, 0)
		dv += ispAt(st.engine, repH) * Flight.G0 * math.log(m0 / mf)
		repH = repH + 60000
	end
	local gl = 1450 * math.min(2.2, (1.40 / twr) ^ 0.95)
	local dl = 340 * (v.cd / 0.31) * math.min(2.0, math.max(0.6, twr / 1.40))
	return { held = false, twr = twr, deltaV = dv, effectiveDV = dv * v.turn - gl - dl }
end

return Flight

-- assembly — the rules that decide whether what you rolled out to the pad is a rocket
-- or a pile of parts. "Build it properly" has to mean something specific, and it has to
-- FAIL VISIBLY: every rejection below names the part that is wrong, because a player
-- who is told "invalid design" learns nothing and a player who is told "there is no
-- decoupler between stage 1 and stage 2" learns rocketry.
--
-- Nothing here is arbitrary. Each rule is a real constraint:
--   every stage needs an engine and a tank            a stage with no engine is cargo
--   a decoupler between every pair of stages          stages that cannot separate are one stage
--   first-stage TWR > 1.0                             below that the clamps hold and it never moves
--   a nose on top                                     an open stack is a drag brake
--   control authority on stage 1                      no fins and no gimbal is a tumble
--   a fairing to carry a payload through the air      an exposed satellite does not survive max-Q
--   a docking port needs RCS                          you cannot line up on a port without translation
--   total mass within the pad's limit                 the pad is an upgrade too

local Assembly = {}

local function index(lib)
	local byId = {}
	for _, group in pairs(lib) do
		for _, part in ipairs(group) do
			byId[part.id] = part
		end
	end
	return byId
end

-- Returns ok:boolean, problems:{ {part=<id|nil>, text=<what to fix>} }
-- `problems` is written to be shown verbatim on the pad card. Plain sentences only.
function Assembly.check(asm, lib, padLimit)
	local byId = index(lib)
	local out = {}
	local function bad(part, text)
		table.insert(out, { part = part, text = text })
	end

	if not asm.stages or #asm.stages == 0 then
		bad(nil, "There is nothing on the pad. Start with an engine and a tank.")
		return false, out
	end

	for i, s in ipairs(asm.stages) do
		local eng, tank = byId[s.engine], byId[s.tank]
		if not eng then
			bad(nil, `Stage {i} has no engine.`)
		end
		if not tank then
			bad(nil, `Stage {i} has no fuel tank.`)
		end
		if eng and tank and i < #asm.stages and not s.decoupler then
			bad(nil, `Stage {i} cannot separate from stage {i + 1}. It needs a decoupler.`)
		end
		if eng and eng.vacuum and i == 1 then
			bad(eng.id, `{eng.label} is a vacuum engine. It is weak at sea level — put it on an upper stage.`)
		end
		local rec = s.recovery and byId[s.recovery] or nil
		if rec and rec.needs and not (s.fins == rec.needs) then
			bad(rec.id, `{rec.label} needs {byId[rec.needs].label} on the same stage to steer the landing.`)
		end
	end

	if not asm.nose then
		bad(nil, "There is no nose cone. An open stack drags badly.")
	end

	-- Control authority: stage 1 has to be able to hold a heading.
	local fin = asm.stages[1] and asm.stages[1].fins and byId[asm.stages[1].fins] or nil
	if not fin then
		bad(nil, "Stage 1 has no fins. It will tumble off the pad.")
	end

	local payload = asm.payload and byId[asm.payload] or nil
	if payload and payload.needsFairing then
		local nose = byId[asm.nose]
		if not (nose and nose.protects) then
			bad(payload.id, `{payload.label} has to ride inside a Payload Fairing.`)
		end
	end
	if asm.dock and not asm.rcs then
		bad("dock_port", "A Docking Port is useless without an RCS Pack. You cannot line up without thrusters.")
	end

	-- Rule 9: the pad is an upgrade too. Only judged once every stage has an engine and a
	-- tank, so the number is the stack that would actually roll out.
	if padLimit then
		local complete = true
		local mass = 0
		for _, s in ipairs(asm.stages) do
			local eng, tank = byId[s.engine], byId[s.tank]
			if not (eng and tank) then
				complete = false
				break
			end
			mass += eng.mass * (s.engineCount or 1) + tank.mass + tank.prop
			for _, key in { "decoupler", "fins", "recovery" } do
				local part = s[key] and byId[s[key]]
				if part then
					mass += part.mass
				end
			end
		end
		if complete then
			for _, key in { "nose", "gnc", "payload" } do
				local part = asm[key] and byId[asm[key]]
				if part then
					mass += part.mass
				end
			end
			if asm.rcs and byId.rcs then
				mass += byId.rcs.mass
			end
			if asm.dock and byId.dock_port then
				mass += byId.dock_port.mass
			end
			if mass > padLimit then
				bad(
					nil,
					`Too heavy for the pad: {string.format("%.1f", mass / 1000)} t against its {string.format(
						"%.0f",
						padLimit / 1000
					)} t limit. Upgrade the pad or drop some weight.`
				)
			end
		end
	end

	return #out == 0, out
end

-- The pad card. Shown BEFORE the launch, so the failure is predicted rather than
-- discovered — a player who launches a rocket the game already told them would not fly
-- learns nothing from the explosion.
function Assembly.card(flight, result, padLimit)
	local verdict
	if result.twr <= 1.0 then
		verdict = "IT WILL NOT LIFT — thrust is less than weight"
	elseif result.twr < 1.2 then
		verdict = "IT WILL BARELY LIFT — you will lose a lot of speed to gravity"
	elseif result.twr > 3.2 then
		verdict = "OVERPOWERED — you are burning fuel fighting the air"
	else
		verdict = "GOOD LIFT-OFF"
	end
	return {
		thrust = flight.stages[1].thrust,
		weight = flight.totalMass * 9.80665,
		twr = result.twr,
		deltaV = result.deltaV,
		effectiveDV = result.effectiveDV,
		orbitNeeds = 7700,
		mass = flight.totalMass,
		padLimit = padLimit,
		overweight = flight.totalMass > padLimit,
		verdict = verdict,
	}
end

return Assembly

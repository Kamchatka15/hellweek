--!strict
-- boss.luau — The Dry Herald.
--
-- This creature exists to close the biggest hole in the design: **nothing ever
-- attacked the camp.** The stalker is a pane of glass that keeps you in; it never
-- comes for the thing you built. A camp nothing lays siege to is a storage locker.
--
-- So the Herald does not hunt you. It walks to the obelisk, and it drinks the light.
--
-- That single change makes three other things work at once:
--
--   1. IGNORING IT IS THE ONE THING YOU CANNOT DO. Run away and your fire goes out
--      anyway. A threat you can simply avoid is a threat you eventually stop fearing.
--   2. IT BUILDS THE DANGER CURVE. Twelve swings bare-handed, six with a harvest
--      tool. On night three you are not ready, and you know it. That fear is the
--      whole reason the obelisk and the weapon ladder matter.
--   3. IT IS NEVER KILLED, ONLY DRIVEN OFF. It walks away, waits, and comes back.
--      The run never becomes safe, it only becomes quiet, which is worse.
--
-- It is slower than you on purpose. You can always outwalk it. What you cannot do is
-- outwalk it *and* keep your fire lit, and that tension is the fight.

local GOLD = Color3.fromRGB(212, 168, 74)
local GOLD_HOT = Color3.fromRGB(255, 214, 96)
local BONE = Color3.fromRGB(222, 214, 194)
local BONE_DARK = Color3.fromRGB(176, 166, 146)
local LINEN = Color3.fromRGB(198, 186, 158)

--- The blockout. Used when no imported body is present, and it is also the shape the
--- behaviour was tuned against, so it stays as the fallback rather than being deleted
--- the moment a mesh arrives.
---
--- 18 studs against a 6-stud player: three times human height, per the boss grammar.
--- One wrong proportion and one only — the neck, far too long, holding the head
--- higher than it has any business being.
local parts = {
	-- Named to match the imported mesh exactly, so ONE rig spec serves both the mesh
	-- and this primitive fallback. 18 studs against a 6-stud player.
	{
		name = "torso",
		size = Vector3.new(4.2, 6.2, 2.4),
		position = Vector3.new(0, 10.4, 0),
		color = BONE,
		material = Enum.Material.SmoothPlastic,
	},
	{
		name = "left leg",
		size = Vector3.new(1.2, 7.4, 1.6),
		position = Vector3.new(-1.35, 3.7, 0),
		color = BONE_DARK,
		material = Enum.Material.SmoothPlastic,
	},
	{
		name = "right leg",
		size = Vector3.new(1.2, 7.4, 1.6),
		position = Vector3.new(1.35, 3.7, 0),
		color = BONE_DARK,
		material = Enum.Material.SmoothPlastic,
	},
	{
		name = "left arm",
		size = Vector3.new(1, 6.6, 1),
		position = Vector3.new(-2.9, 9.6, 0),
		color = BONE_DARK,
		material = Enum.Material.SmoothPlastic,
	},
	{
		name = "right arm",
		size = Vector3.new(1, 6.6, 1),
		position = Vector3.new(2.9, 9.6, 0),
		color = BONE_DARK,
		material = Enum.Material.SmoothPlastic,
	},
	-- The wrong proportion lives here: the head sits on a neck far too long, holding
	-- it higher than it has any business being. Everything else is plausible.
	{
		name = "head",
		size = Vector3.new(2, 2.4, 3.4),
		position = Vector3.new(0, 15.6, -0.6),
		color = LINEN,
		material = Enum.Material.Fabric,
	},
	-- Straight, not branching. A forest deer has antlers; this has blades.
	{
		name = "horns",
		size = Vector3.new(3.4, 5.6, 0.5),
		position = Vector3.new(0, 18.4, 0.2),
		color = GOLD,
		material = Enum.Material.Metal,
		canCollide = false,
	},
}

return {
	{
		id = "dry_herald",
		label = "The Dry Herald",

		-- Mesh drop-in. When a Model named DryHerald is sitting in the templates
		-- folder it replaces the blockout entirely and the eyes are still built on
		-- top, so the night signature survives either way.
		template = "DryHerald",
		templateYOffset = 0,

		-- Twelve swings bare-handed, six with a harvest tool. On night three you
		-- should look at this thing and know you are not ready.
		health = 12,
		boss = true,
		retreatFor = 60,

		-- Slower than a player on purpose. You can always outwalk it. You cannot
		-- outwalk it and keep your fire lit at the same time.
		speed = 5,
		nightSpeed = 6,
		noticeRadius = 18,
		nightNoticeRadius = 26,
		biteRadius = 7,
		-- One fuel every 4.5 seconds. Across a 45-second night that is ten fuel against
		-- a cap of fifteen, so an unopposed Herald does not quite empty a full beacon
		-- but comes close enough that you cannot pretend it is not happening.
		biteCooldown = 4.5,
		goalRadius = 15,
		wander = 10,
		drops = { wardstone = 1, stone = 2 },

		eyes = {
			-- Local to the head, so the same two numbers work for the imported mesh
			-- and for the primitive blockout.
			attach = "head",
			offsets = { Vector3.new(-0.5, 0.15, -1.35), Vector3.new(0.5, 0.15, -1.35) },
			color = GOLD,
			size = 0.62,
			brightness = 1.1,
			range = 12,
			-- Visible from the far side of the waste. You are meant to see it coming
			-- long before you can do anything about it.
			nightColor = GOLD_HOT,
			nightBrightness = 2.2,
			nightRange = 22,
		},

		-- The rig. Torso is the root and stays anchored; everything else hangs off a
		-- Motor6D and is therefore free to move. Without this nothing animates and it
		-- slides across the sand like a chess piece.
		rig = {
			root = "torso",
			joints = {
				{ part = "head", to = "torso" },
				{ part = "horns", to = "head" },
				{ part = "left arm", to = "torso" },
				{ part = "right arm", to = "torso" },
				{ part = "left leg", to = "torso" },
				{ part = "right leg", to = "torso" },
			},
		},

		-- A slow, long stride. Period 2.2 seconds is deliberately almost twice a human
		-- walk: it never hurries, because it does not need to.
		gait = {
			period = 2.2,
			bob = 0.42,
			idle = 0.22, -- it still sways while standing, so it never reads as a prop
			limbs = {
				{ part = "LegL", axis = "X", amplitude = 19, phase = 0 },
				{ part = "LegR", axis = "X", amplitude = 19, phase = 0.5 },
				{ part = "ArmL", axis = "X", amplitude = 13, phase = 0.5 },
				{ part = "ArmR", axis = "X", amplitude = 13, phase = 0 },
				-- The neck lags the stride, which is what makes a long neck look heavy
				-- rather than stiff.
				{ part = "Neck", axis = "X", amplitude = 4.5, phase = 0.28 },
				{ part = "Head", axis = "X", amplitude = 3, phase = 0.36 },
				{ part = "Shoulders", axis = "Z", amplitude = 2.6, phase = 0.25 },
			},
		},

		parts = parts,
	},
}

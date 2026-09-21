-- parts — the warehouse catalogue. Every number is a real engineering metric and every
-- metric is something the flight sim actually reads. No decorative stats.
--
--  thrust   N      sea-level thrust
--  isp      s      specific impulse. THE efficiency number: dV = isp * g0 * ln(m0/mf)
--  mass     kg     dry mass of the part
--  prop     kg     propellant carried (tanks only)
--  cd       -      drag coefficient the nose/fairing imposes on the stack
--  control  -      steering authority; sums per stage, feeds turn efficiency
--  cost     $
--  class    -      what slot it fills in an assembly

-- stylua: ignore start
return {
	engines = {
		{ id="eng_hopper",  label="RM-1 Hopper",      class="engine", thrust=9000,   isp=178, mass=110,   cost=696000,   tier=1, blurb="A welded garage motor. It will get you off the ground and not much further." },
		{ id="eng_pioneer", label="RM-2 Pioneer",     class="engine", thrust=31000,  isp=238, mass=185,  cost=1704000,  tier=1, blurb="The first engine that is actually efficient. Most first rockets fly on this." },
		{ id="eng_vulcan",  label="V-1 Vulcan",       class="engine", thrust=78000,  isp=268, mass=430,  cost=3960000,  tier=2, blurb="Heavy lifter. Needs a big tank under it or it drinks the stage dry in seconds." },
		{ id="eng_kestrel", label="K-5 Kestrel [VAC]",class="engine", thrust=36000,  isp=322, mass=270,  cost=4980000,  tier=2, vacuum=true, blurb="Vacuum bell. Poor at sea level, superb once the air is gone. Upper stages only." },
		{ id="eng_titan",   label="T-9 Titan",        class="engine", thrust=205000, isp=288, mass=1010, cost=9360000,  tier=3, blurb="The workhorse. Clusters well. This is the engine that reaches the Kármán line." },
		{ id="eng_raptor",  label="RX-4 Raptor",      class="engine", thrust=450000, isp=302, mass=1650, cost=18600000, tier=4, blurb="Full-flow staged combustion. Expensive, thirsty, and the only way to orbit heavy." },
		{ id="eng_nova",    label="N-V Nova [VAC]",   class="engine", thrust=118000, isp=348, mass=640,  cost=23400000, tier=4, vacuum=true, blurb="The best Isp in the warehouse. Put it on the stage that does the orbital insertion." },
	},

	tanks = {
		{ id="tank_micro",  label="Micro Tank",   class="tank", prop=105,   mass=14,   cost=216000,   tier=1 },
		{ id="tank_small",  label="Small Tank",   class="tank", prop=300,   mass=26,   cost=492000,   tier=1 },
		{ id="tank_medium", label="Medium Tank",  class="tank", prop=1250,  mass=82,  cost=1176000,   tier=2 },
		{ id="tank_large",  label="Large Tank",   class="tank", prop=3500,  mass=205,  cost=2940000,  tier=2 },
		{ id="tank_heavy",  label="Heavy Tank",   class="tank", prop=9200,  mass=505,  cost=7560000,  tier=3 },
		{ id="tank_core",   label="Core Tank",    class="tank", prop=23000, mass=1210, cost=17160000, tier=4 },
	},

	aero = {
		{ id="nose_blunt",  label="Blunt Cap",       class="nose", cd=0.42, mass=18,  cost=48000,   tier=1, blurb="Barely a nose cone. It is what you can afford on launch one." },
		{ id="nose_cone",   label="Cone",            class="nose", cd=0.31, mass=32,  cost=156000,  tier=1 },
		{ id="nose_ogive",  label="Ogive Nose",      class="nose", cd=0.22, mass=48,  cost=552000,  tier=2 },
		{ id="fairing",     label="Payload Fairing", class="nose", cd=0.19, mass=125, cost=1620000, tier=3, protects=true, blurb="Required to carry a payload through the atmosphere without losing it." },
		{ id="fins_basic",  label="Tail Fins",       class="fin",  control=1.0, mass=26, cost=108000,  tier=1 },
		{ id="fins_grid",   label="Grid Fins",       class="fin",  control=2.2, mass=72, cost=1008000, tier=3, reusable=true },
	},

	avionics = {
		{ id="gnc_none",    label="Open Loop",       class="gnc", turn=0.70, mass=0,  cost=0,      tier=1, blurb="No guidance. It goes where it is pointed and loses a lot of Δv doing it." },
		{ id="gnc_basic",   label="Basic Guidance",  class="gnc", turn=0.81, mass=42, cost=672000,  tier=1 },
		{ id="gnc_inertial",label="Inertial Unit",   class="gnc", turn=0.89, mass=68, cost=2220000, tier=2 },
		{ id="gnc_full",    label="Full GNC",        class="gnc", turn=0.95, mass=96, cost=5160000, tier=3, blurb="Closed-loop gravity turn. Worth more Δv than most engine upgrades." },
	},

	structure = {
		{ id="dec_light",   label="Light Decoupler", class="decoupler", mass=16,  cost=96000,   tier=1 },
		{ id="dec_heavy",   label="Heavy Decoupler", class="decoupler", mass=62,  cost=324000,  tier=2 },
		{ id="chutes",      label="Recovery Chutes", class="recovery",  mass=92,  cost=864000,  tier=2, refund=0.35 },
		{ id="legs",        label="Landing Legs",    class="recovery",  mass=310, cost=4200000, tier=3, refund=0.65, needs="fins_grid" },
	},

	mission = {
		{ id="pay_ballast", label="Ballast Mass",    class="payload", mass=120, cost=72000,   tier=1, blurb="Dead weight that proves you can lift something. Pays a small bonus." },
		{ id="pay_sat",     label="Smallsat",        class="payload", mass=340, cost=2280000, tier=2, needsFairing=true },
		{ id="rcs",         label="RCS Pack",        class="rcs",     mass=64,  cost=1860000, tier=3, blurb="Translation thrusters. Without these you cannot line up on a docking port." },
		{ id="dock_port",   label="Docking Port",    class="dock",    mass=145, cost=3240000, tier=4, needs="rcs" },
	},

	-- The pad is an upgrade too. It caps the mass you are allowed to roll out.
	pad = {
		{ id="pad_1", label="Concrete Apron",  massLimit=8000,   cost=0 },
		{ id="pad_2", label="Reinforced Pad",  massLimit=28000,  cost=2880000 },
		{ id="pad_3", label="Flame Trench",    massLimit=95000,  cost=13200000 },
		{ id="pad_4", label="Heavy Complex",   massLimit=320000, cost=55200000 },
	},
}
-- stylua: ignore end

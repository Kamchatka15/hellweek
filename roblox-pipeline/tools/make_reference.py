#!/usr/bin/env python3
"""Build docs/HELL_WEEK_REFERENCE.pdf.

The document is the 99 Nights design reference rewritten for Hell Week: same
structure, our systems, our numbers, and the chain that joins them spelled out
rather than implied. Regenerate after tuning config.luau.
"""
from reportlab.lib import colors
from reportlab.lib.enums import TA_LEFT
from reportlab.lib.pagesizes import LETTER
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import inch
from reportlab.platypus import (BaseDocTemplate, Frame, PageTemplate, Paragraph,
                                Spacer, Table, TableStyle, KeepTogether)

CHAR = colors.Color(45 / 255, 42 / 255, 40 / 255)
GOLD = colors.Color(212 / 255, 168 / 255, 62 / 255)
ASH = colors.Color(145 / 255, 125 / 255, 95 / 255)
BONE = colors.Color(238 / 255, 234 / 255, 226 / 255)
INK = colors.Color(26 / 255, 24 / 255, 23 / 255)

S = {}
S["title"] = ParagraphStyle("title", fontName="Helvetica-Bold", fontSize=26, leading=30,
                            textColor=CHAR, spaceAfter=6)
S["sub"] = ParagraphStyle("sub", fontName="Helvetica", fontSize=11.5, leading=15,
                          textColor=ASH, spaceAfter=14)
S["h1"] = ParagraphStyle("h1", fontName="Helvetica-Bold", fontSize=15.5, leading=19,
                         textColor=CHAR, spaceBefore=16, spaceAfter=7)
S["h2"] = ParagraphStyle("h2", fontName="Helvetica-Bold", fontSize=11.6, leading=15,
                         textColor=colors.Color(120 / 255, 96 / 255, 40 / 255),
                         spaceBefore=11, spaceAfter=4)
S["body"] = ParagraphStyle("body", fontName="Helvetica", fontSize=9.6, leading=13.4,
                           textColor=INK, alignment=TA_LEFT, spaceAfter=6)
S["bullet"] = ParagraphStyle("bullet", parent=S["body"], leftIndent=13, bulletIndent=3,
                             spaceAfter=2.5)
S["note"] = ParagraphStyle("note", parent=S["body"], fontName="Helvetica-Oblique",
                           textColor=ASH)
S["cell"] = ParagraphStyle("cell", fontName="Helvetica", fontSize=8.5, leading=11,
                           textColor=INK)
S["cellb"] = ParagraphStyle("cellb", parent=S["cell"], fontName="Helvetica-Bold",
                            textColor=colors.white)
S["code"] = ParagraphStyle("code", fontName="Courier", fontSize=8.2, leading=11.2,
                           textColor=CHAR, leftIndent=10, spaceAfter=7)

story = []


def H1(t):
    story.append(Paragraph(t, S["h1"]))


def H2(t):
    story.append(Paragraph(t, S["h2"]))


def P(t):
    story.append(Paragraph(t, S["body"]))


def NOTE(t):
    story.append(Paragraph(t, S["note"]))


def CODE(lines):
    for ln in lines:
        story.append(Paragraph(ln.replace(" ", "&nbsp;"), S["code"]))


def UL(items):
    for it in items:
        story.append(Paragraph(it, S["bullet"], bulletText="•"))
    story.append(Spacer(1, 5))


def TBL(head, rows, widths):
    data = [[Paragraph(h, S["cellb"]) for h in head]]
    for r in rows:
        data.append([Paragraph(str(c), S["cell"]) for c in r])
    t = Table(data, colWidths=[w * inch for w in widths], repeatRows=1, hAlign="LEFT")
    t.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), CHAR),
        ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, BONE]),
        ("GRID", (0, 0), (-1, -1), 0.4, colors.Color(0.78, 0.76, 0.72)),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("LEFTPADDING", (0, 0), (-1, -1), 5),
        ("RIGHTPADDING", (0, 0), (-1, -1), 5),
        ("TOPPADDING", (0, 0), (-1, -1), 3.5),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 3.5),
    ]))
    story.append(t)
    story.append(Spacer(1, 8))

# ============================================================== front matter
story.append(Paragraph("HELL WEEK", S["title"]))
story.append(Paragraph(
    "Complete Reference and Systems Spec &mdash; the design rules for our game, written in the shape of "
    "the 99 Nights study document and applied to what we actually have.", S["sub"]))
P("This is the working rulebook. It states what the game is, how its parts hold each other up, what is built "
  "today, and what is still a promise. Numbers come straight from <font face='Courier'>games/hell-week/server/"
  "config.luau</font>; regenerate this file after tuning rather than editing the PDF.")
P("Hell Week is not a desert re-skin of 99 Nights. It borrows one true thing &mdash; <b>a clock that sells "
  "safety</b> &mdash; and replaces everything else. Where the reference document said \"steal this\", this "
  "document says what we stole, what we changed, and why.")

H1("The chain")
P("Every system in Hell Week hangs off one sentence, and each link feeds the next. If a feature does not sit "
  "on this chain, it is decoration and should be cut before it is balanced.")
CODE([
    "fuel  ->  flame  ->  safe radius  ->  how far you dare walk",
    "      ->  what you can reach  ->  what you can carry home",
    "      ->  what you can craft  ->  how far you dare walk tomorrow",
])
P("Read it backwards and it still holds: you cannot craft a Brand without stone and water, you cannot carry "
  "both without a sack slot free, you cannot reach the far resources without the ring being wide enough to "
  "run back to, and the ring is only wide because you fed it. <b>The obelisk is the origin of the coordinate "
  "system.</b> Every distance in the game is distance-to-obelisk.")
P("The three things that can break the chain, and therefore the three things to protect in any change:")
UL([
    "<b>Anything that grants safety without fuel.</b> A weapon that kills the night threat, a wall that does "
    "what the ring does, a light that never runs out. The night must stay a ban on space, not a fight.",
    "<b>Anything that grants reach without risk.</b> Fast travel, a map that removes the walk, a chest at "
    "camp holding far-ring loot. Distance is the difficulty curve; shortcuts flatten it.",
    "<b>Anything that makes day one longer than a child's patience.</b> The first day is the tutorial and it "
    "is already 180 seconds. Every new system must be optional on day one.",
])

H1("Part I &mdash; How the game works")

H2("1. Premise")
P("Up to four of you wake in an ash waste at a guttering obelisk. There is a stone disc with a gold eye cut "
  "into it, a flame on the steps, and a horizon you cannot see the end of. Something with amber eyes stands "
  "past the light and watches. The waste holds two tombs &mdash; a pyramid and a sphinx &mdash; that were "
  "here long before you.")
P("There is no spoken plot. The story is the place: the eye in the floor, the dead trees, the coffins, the "
  "bones in the tunnels, a jackal that does not attack on the first night. Written flavour stays on items and "
  "toasts. <b>Nothing in this game is named after anything real or borrowed.</b>")

H2("2. Win, lose, score")
P("There is no points board. Progress is four readings, and they are all the same reading in different "
  "clothes:")
TBL(["Reading", "What it means", "Where it shows"], [
    ["Day number", "The visible score. The week is seven days.", "HUD, top centre"],
    ["Fuel in the obelisk", "How much of the map exists for you right now.", "Fuel bar, gold"],
    ["Trials answered", "0&ndash;7. The long goal; each one is a standing reason to leave camp.",
     "INFO TRIALS n/7"],
    ["What the camp looks like", "Cache, brazier, ward stake, drying rack, salt line. The honest "
     "record of a run.", "The camp itself"],
], [1.1, 3.6, 1.6])
P("<b>Losing:</b> the obelisk going out at night is how runs end. The safe ring collapses to nothing and "
  "whatever is outside comes in. Night one has <font face='Courier'>mercy = true</font>, so an empty obelisk "
  "on the first night does not end the run &mdash; it is the one free lesson.")

H2("3. Controls")
P("Roblox defaults, nothing rebound, nothing exotic. Everything a ten-year-old already knows how to do.")
TBL(["Action", "Input", "Notes"], [
    ["Move / jump", "W A S D, Space", "Shift to sprint"],
    ["Camera", "Right mouse drag, scroll to zoom", "Shift-lock for kiting"],
    ["Use held tool", "Left click", "Strike a node, or light the Brand"],
    ["Pick up", "PICK UP button, or walk onto it", "Button lights gold when something is in range"],
    ["Feed the obelisk", "FEED button, inside the feed radius (10 studs)", "Consumes the whole sack of fuel"],
    ["Inspect", "Point at a thing and press <b>I</b>", "What it is, what it does, what it currently has"],
    ["Hotbar", "1, 2 &mdash; and the SACK slot", "Pickaxe, Dagger, and what you are carrying"],
], [1.5, 2.4, 2.4])
NOTE("The inspect key is deliberate: descriptions do not float over the world taking up screen space. You ask, "
     "and the game answers.")

H2("4. The loop: day, night, obelisk, haze")
P("Four clocks. Everything else hangs off them.")
TBL(["System", "What it does", "Current numbers"], [
    ["Day", "Gather window. The Jackal does not hunt. Chop, mine, press, build, explore.",
     "180s on day 1, then 110 / 100 / 90 / 85 / 80 / 75"],
    ["Night", "The ring is the only safe ground. The Jackal watches on night 1, hunts after.",
     "40s, rising to 75s by day 7"],
    ["Burn", "Fuel the obelisk spends over a night. Rises every day, so standing still loses.",
     "2, 4, 6, 8, 10, 12, 14"],
    ["Warning", "Seconds of notice before dusk. Nothing arrives unannounced.", "12s"],
    ["Fuel &rarr; radius", "The safe ring. This is the map gate and the whole progression axis.",
     "25 base + 8 per fuel, capped 90; fuel cap 15"],
    ["Haze", "Ash fog. Pulls back as you feed. What you can see is what you can safely reach.",
     "Rings at 420 / 620 / 790"],
    ["Leash", "Past this from the obelisk you are put back by the fire.", "820 studs"],
], [1.05, 3.05, 2.2])
P("<b>Night one is a mercy night.</b> The Jackal stands on the line and watches; it does not come. A new "
  "player gets to see what night <i>is</i> before it is a thing that kills them. This is the single most "
  "important tuning number in the game and it is one boolean.")
P("The three-day arc is about eight and three quarter minutes &mdash; one sitting, start to finish. Day one "
  "alone is 180 seconds because a stranger needs room to be bad at the game with no clock on them.")

H2("5. First run &mdash; what you are supposed to do")
H2("Day 1 (180 seconds, no pressure)")
UL([
    "You wake holding a <b>Pickaxe and a Dagger</b>. Not one tool &mdash; two, because the waste has two "
    "things worth taking and you should find that out by already having both answers in hand.",
    "The obelisk starts lit with <b>2 fuel</b>. A small ring, drawn from the first second, so the lesson is "
    "visible: this is safe, out there is not, feeding makes it bigger.",
    "Dagger the cactus, Pickaxe the stone, pick up the ashwood lying around. Feed the ashwood.",
    "Press two cactus into <b>Water</b>. Temper wood with water for <b>Emberwood</b> &mdash; three fuel "
    "instead of one. This is the moment the game stops being about carrying more and starts being about "
    "carrying better.",
    "Build the <b>cache</b> so you stop walking resources home one armful at a time.",
    "Night 1: the Jackal watches. Stay out if you like. Nothing will happen. Look at it.",
])
H2("Days 2&ndash;3")
UL([
    "Burn doubles. A ring that held all night on day 1 gutters on day 2.",
    "Craft a <b>Brand</b> (light you can carry) and a <b>Wardstone</b>. Put down a <b>ward stake</b>.",
    "Scorpions are out in the ring between 78 and 250 studs. Dagger them for <b>Chitin</b> and <b>Venom</b>.",
    "<b>Night 3 is the first siege.</b> The Dry Herald walks in from 210&ndash;260 studs and drinks a fuel "
    "every time it reaches the obelisk. You cannot kill it. You can out-feed it, drive it off with light, "
    "or lose the night.",
])
H2("Days 4&ndash;7 (parked tuning)")
UL([
    "Escalation placeholders only: longer nights, heavier burn. This is the part of the week that is a shape "
    "rather than a design, and it is the honest next job.",
    "The two tombs are the long errands: the pyramid's burial chamber and the sphinx's Deep Hall.",
])

H2("6. Actions and choices")
P("Every minute you are picking one of these. That is the design; if the choice is obvious the system is "
  "broken.")
TBL(["Choice", "If you take it", "What you give up"], [
    ["Feed now vs carry more", "Ring holds tonight", "The trip you were on"],
    ["Ashwood vs Emberwood", "Three times the burn per slot", "Two cactus, a press, and the walk"],
    ["Build the cache vs explore", "Every future trip is cheaper", "Today's daylight"],
    ["Ward stake vs Brand", "A place that is safe without you", "Light you can take with you"],
    ["Go into a tomb", "Coffins, gold, the deep halls", "You are far from the ring at dusk"],
    ["Fight the scorpion vs walk round it", "Chitin, venom, building stock", "Health and time"],
    ["Stay out on a watch night", "A free night of gathering", "Nothing &mdash; night 1 only. Never again."],
], [1.8, 2.5, 2.1])
H2("Atomic actions the code must support")
UL([
    "Strike a node (power) / harvest a kind (Pickaxe &rarr; stone, Dagger &rarr; cactus, Knife &rarr; any)",
    "Pick up, sack insert, sack full refusal, drop",
    "Feed the obelisk &mdash; server reads fuel value per item, never the client",
    "Craft at the obelisk: press, temper, quicken, cut",
    "Place a camp piece (store, light, ward, convert, mark)",
    "Light the Brand, carry it, have it matter to what can see you",
    "Inspect anything",
    "Enter a tomb, descend, come back out",
])

H2("7. Items &mdash; where they come from, what they are for")
P("Nine items. That is the whole economy and it should stay small enough that a child can hold it in their "
  "head. The fuel ladder is the spine: <b>1 &rarr; 3 &rarr; 8</b>.")
TBL(["Item", "Fuel", "Where", "What it is for"], [
    ["Ashwood", "1", "Dead trees, ground, chests", "The starter fuel. Always available, always weak."],
    ["Cactus", "0", "Cactus, Dagger", "Two press into Water. Will not burn."],
    ["Stone", "0", "Rock, Pickaxe", "Building. Wet it for Wardstone."],
    ["Water", "0", "Press 2 cactus", "Tempers wood, wets stone. The key to both ladders."],
    ["Emberwood", "3", "Temper ashwood with water", "Three times the burn in one slot."],
    ["Heartwood", "8", "Quicken emberwood", "The deepest burn. Slow to make, worth the wait."],
    ["Chitin", "0", "Scorpion", "Hard and light. Building."],
    ["Venom", "0", "Scorpion sting", "The obelisk wants it."],
    ["Wardstone", "0", "Wet stone, marked", "The dark will not cross it."],
], [1.0, 0.45, 1.35, 3.6])
P("<b>Why the ladder matters:</b> the sack holds six. A player who only ever carries ashwood has a ceiling of "
  "6 fuel per trip forever. The same six slots of heartwood are 48. The entire mid-game is that realisation, "
  "and it is why burn rises &mdash; to force it.")
H2("Tools")
TBL(["Tool", "Made from", "Does"], [
    ["Pickaxe", "Start with it", "Harvests stone"],
    ["Dagger", "Start with it", "Power 2; harvests cactus"],
    ["Bone Knife", "Craft", "Harvests any resource"],
    ["Club / Spear", "Craft", "Power 3 / power 5. Striking, not harvesting."],
    ["Brand", "Craft", "Carried light. A spotlight you hold."],
    ["Sigil", "Craft", "Ward effect"],
], [1.1, 1.3, 3.9])
NOTE("Tools are composable by data, not by class: a tool with `power` strikes, a tool naming a `kind` "
     "harvests, a tool with an `effect` wards or lights. One table, no subclasses.")

H2("8. Crafting and the camp")
P("Everything is crafted at the obelisk. There is no bench, and there should not be one &mdash; the obelisk "
  "being the only place anything happens is what keeps the camp the centre of the world.")
TBL(["Recipe", "In", "Out", "Why it exists"], [
    ["Press", "2 cactus", "Water", "The gate to both ladders"],
    ["Temper", "Ashwood + water", "Emberwood", "Fuel ladder, step 1"],
    ["Quicken", "Emberwood", "Heartwood", "Fuel ladder, step 2"],
    ["Wardstone", "Stone + water", "Wardstone", "Safety you can place"],
    ["Cut", "Resources", "Knife, Pickaxe, Club, Spear, Sigil", "Reach and damage"],
    ["Brand", "&mdash;", "Brand", "Light you carry"],
], [1.0, 1.35, 1.35, 2.6])
H2("Camp pieces")
TBL(["Piece", "Effect", "What it changes"], [
    ["Cache", "store", "Stop walking every armful home"],
    ["Brazier", "light", "A second safe place that is not the obelisk"],
    ["Ward stake", "ward", "Ground the dark will not cross"],
    ["Drying rack", "convert", "Turns time into fuel value"],
    ["Salt line", "mark", "A drawn boundary"],
], [1.2, 0.9, 4.2])
P("<b>The camp is the reason day 2 is different from day 1</b> rather than the same lap against a bigger "
  "number. This came directly from watching a ten-year-old play the genre leader: he spent his whole first "
  "day building a camp so that later he could go and explore. Build-then-range is the arc.")

H2("9. What is out there")
P("Two populations, and confusing them is how a player wastes a night.")
H2("A. The Jackal &mdash; the night, personified")
P("A tall charcoal figure with a long muzzle, pointed ears and two amber eyes, standing about 9 studs. Built "
  "from primitives; no rig copied from anywhere. It is <b>not a health bar</b>. There is no weapon in the "
  "game that solves it and there must never be one.")
TBL(["Night", "Mode", "Behaviour"], [
    ["1", "watch", "Stands on the line just off the ring and looks at the camp. Does not come."],
    ["2+", "hunt", "Walks toward anyone outside the light."],
], [0.8, 0.9, 4.6])
P("The answers are the ring, the Brand, a ward stake, and your legs. That is the complete list, and the fact "
  "that it is short is the point.")
H2("B. Killable things")
TBL(["Thing", "Where", "Gives", "Role"], [
    ["Scorpion", "Ring 78&ndash;250, from day 1", "Chitin, venom", "The day threat you can choose to fight"],
    ["Magma golem", "Two, opposite sides of the map", "&mdash;", "Moves at your speed, aggros, red eyes at "
     "night. A thing to avoid, not farm."],
    ["Dry Herald", "Siege, from night 3", "&mdash;", "Walks in and drinks your fuel. Boss-shaped, not "
     "boss-statted."],
], [1.0, 1.5, 0.95, 2.9])
P("Population scales: <font face='Courier'>4 + 2 per day, capped 14</font>, spawned between 78 and 250 studs "
  "&mdash; never inside the first ring, because a scorpion at the obelisk on the first morning is a "
  "different and worse game.")
H2("C. The siege")
P("From night 3, every night: the Dry Herald spawns 210&ndash;260 studs out and walks at the obelisk. Each "
  "time it arrives it takes <b>1 fuel</b>. It is the reason a comfortable fuel margin stops being "
  "comfortable, and it is the pressure that makes the camp pieces worth building.")

H2("10. The tombs")
P("Two standing structures, on opposite sides of the obelisk. They are the long errands &mdash; the reason "
  "to want a wider ring rather than just a safer one.")
H2("The Pyramid")
P("220 studs across, 140 tall, hollow, about 245 studs from the obelisk. 2,126 parts.")
UL([
    "One <b>stair helix</b> as the spine, running the full height; three ring corridors hung off it; "
    "eleven chambers.",
    "Portal, Bone Hall, Coffins, the Well, Hall of Columns, Embalming, Stores, Treasury, Jackal Shrine, "
    "Gallery, and the <b>Burial Chamber</b> at the heart.",
    "Walked centre line: <b>3,110 studs over 162 waypoints</b> &mdash; about 3.2 minutes of pure walking "
    "before you stop to look at anything.",
    "A <b>compass</b> reads the tomb's own route markers and points at the next place you have not been. "
    "Outside it points at the pyramid by day and turns fire-orange for CAMP once the sun is down.",
])
H2("The Sphinx")
P("A recumbent lion with a king's head, facing the obelisk from across the camp, paws about 170 studs out. "
  "The way in is between them. 3,783 parts.")
UL([
    "<b>Five levels</b> of tunnel cut through rock, each a 9&times;9 grid of cells.",
    "The maze is <b>generated, not drawn</b>: a randomised depth-first search carves a spanning tree, so "
    "every cell is reachable by construction. Then it is <b>braided</b> &mdash; every dead end gets a second "
    "wall knocked out and a further sixth of walls come down at random.",
    "That braid is the whole difference between a maze that is fun and one that is a chore: <b>loops instead "
    "of cul-de-sacs</b>. 496 open edges, 17,856 studs of tunnel, and only 4 dead ends in 328 maze cells.",
    "Each level has a hall three cells across with a <b>mirage</b> in it &mdash; pale glass in a gold kerb, "
    "lit from beneath. Plus columns, braziers, coffins and reliefs.",
    "Two inclined shafts down from every level, so there is never only one way on.",
])
NOTE("Geometry is placed FROM the maze graph rather than alongside it, so the built maze cannot disagree with "
     "the generated one. Verified: 1,306 edges checked, 0 wrongly blocked, 0 wrongly open.")
H2("Chests")
P("Chests sit by the teepees and roll from one table today. The tier-by-distance idea from the reference is "
  "<b>not built</b> and is the single highest-value thing on the list.")
TBL(["Item", "Chance"], [["Ashwood x2", "100%"], ["Cactus", "80%"], ["Stone", "70%"],
                         ["Water", "35%"], ["Emberwood", "18%"], ["Heartwood", "5%"]], [1.6, 1.0])

H2("11. The waste")
P("One biome today: <b>ashen-waste</b>. Six colours only &mdash; charcoal, ash, bone, gold, fire, night void "
  "&mdash; and chunky parts. Three further biomes are stubbed in data and unbuilt.")
P("The world is a 1,700-stud slab. The haze rings at 420 / 620 / 790 are the map gate, and the leash sits "
  "beyond them at 820. <b>These three numbers must always be larger than the things standing on the map.</b> "
  "They were not, once: the leash was 360 while the pyramid reached 388 and the sphinx 622, so walking into "
  "either tomb picked the player up and put them back at the fire.")

H2("12. Trials")
P("Seven trials are the long goal and the INFO panel counts them. They are our answer to the reference's four "
  "gated rescues: a standing reason to leave the ring that is not just loot.")
P("<b>Status: the counter exists, the trials themselves are thin.</b> This is the biggest design hole in the "
  "game and the place where the reference has the most to teach &mdash; four escorts, gated by fire level, "
  "each one a multiplier that makes the clock honest.")
P("<b>Not built:</b> a trader on a day clock, classes, per-player offers. All three are recommended and all "
  "three are cheap relative to what they add.")

H2("13. Death and the group")
P("Up to four players, one shared camp, one shared obelisk, personal sacks. The failure state is the obelisk "
  "going out, not any one player dying, which is what makes it a co-op game rather than four solo games in a "
  "room.")
P("<b>Not built:</b> downed state, revive, hunger. The reference is emphatic that hunger should be first "
  "class and that revive is what makes co-op co-operative. Both are on the list.")

H2("14. Toasts and state changes")
TBL(["Trigger", "What the player sees", "Systems effect"], [
    ["Match start", "DAY 1, two onboarding lines", "Tutorial by environment"],
    ["Fed", "Cap light pulses +6 range for a second, keeps +2; haze thins 0.15", "Ring grows, map opens"],
    ["12s to dusk", "Night warning", "Time to get home"],
    ["Dusk", "Sky drops to the night rig, gold ring goes Neon", "Jackal enables"],
    ["Obelisk empty at night", "The ring collapses", "Run ends &mdash; except night 1"],
    ["Siege", "The Herald comes", "1 fuel per arrival"],
    ["Inspect", "What it is, does, and currently has", "&mdash;"],
], [1.25, 2.75, 2.1])

H2("15. Solo and team")
UL([
    "<b>Both:</b> fuel ladder before heroics. A Brand before night 2. The cache before the second long trip.",
    "<b>Solo:</b> feed early and often; you have no one to cover a bad guess about the clock.",
    "<b>Team:</b> say who is on obelisk duty at dusk, out loud, every dusk. Split jobs on day 1 &mdash; "
    "cutter, miner, presser, builder. The sack is personal; the fire is not.",
    "<b>Both, during a siege:</b> somebody holds fuel in hand. Losing a fuel to the Herald matters less than "
    "losing the trip you were on.",
])

H1("Part II &mdash; The questions, answered for Hell Week")
TBL(["Question", "Hell Week's answer"], [
    ["Is the map procedural?", "No. Fixed scenery, fixed tombs. The sphinx maze IS generated from a seed, "
     "and it is the only procedural thing in the game. Layout shuffling is a later want, not a need."],
    ["Can the obelisk be moved?", "No, and it never should be. It is the origin of the coordinate system; "
     "every distance in the game is distance-to-obelisk."],
    ["Hunger? Thirst?", "Neither is built. If one ships it is hunger, and only hunger. Water already exists "
     "as a crafting input &mdash; do not also make it a bar."],
    ["Stamina?", "No. Roblox sprint is enough. A meter minigame does not make the night scarier."],
    ["How long is a night?", "40 seconds on night 1, up to 75 by day 7. Day 180 then 110 and down."],
    ["Why seven days?", "One school week, and one sitting. Three days is about 8:45."],
    ["Can the Jackal be killed?", "No. There is no HP, no weapon, no exception. Light and distance are the "
     "entire API. The moment a player can shoot it the game is a different game."],
    ["Do resources respawn?", "Nodes are placed at load, capped at 150. Respawn on a day timer is unbuilt "
     "and needed &mdash; otherwise a long run strips the near ring and never recovers."],
    ["Can teammates take your things?", "Sacks are personal; world piles are shared. Four players is small "
     "enough that this stays social rather than a grief problem."],
    ["What is the first night for?", "Seeing that night exists before learning that it kills. It is the "
     "cheapest, most valuable tuning decision in the game."],
    ["Can you finish without the trials?", "Yes today, because they are thin. Once they carry a multiplier "
     "the answer should become 'yes, but slowly' &mdash; never 'no'."],
    ["What does the HUD hold?", "Day, day/night bar, fuel, PICK UP, FEED, INFO TRIALS, hotbar with sack, "
     "compass near the pyramid. Keep it exactly this short."],
    ["How does the tutorial work?", "There isn't one. Two onboarding lines, a 180-second first day, a lit "
     "obelisk, and two tools in hand."],
    ["Accessibility", "Night is dark on purpose &mdash; but it has been too dark twice, and both times it "
     "was shipped before anyone walked it. Blue-grey moonlight, not black."],
], [1.6, 4.5])

H1("Part III &mdash; Architecture")
H2("What exists")
TBL(["Module", "Owns", "State"], [
    ["ClockService", "Day/night phases, the day table", "Built"],
    ["BeaconService", "Fuel, radius, flame, feed", "Built"],
    ["SurviveLoop", "The run, safe ring, mood, siege, kit, leash", "Built &mdash; and large"],
    ["StalkerService", "The Jackal: watch, hunt, stand-off, silhouette", "Built"],
    ["CreatureService", "Rigs, gait, spawn rings, boss retreat", "Built"],
    ["ToolService", "Composable tools: power, kind, effect, spot", "Built"],
    ["BuildService", "Camp pieces: store, light, ward, convert, mark", "Built"],
    ["PickupService / SackService", "World items, six slots", "Built"],
    ["RecipeService", "Press, temper, quicken, cut", "Built"],
    ["ContentLoader", "Everything in the world from data, floor holes, lighting rigs", "Built"],
    ["ChallengeService", "Trials 0/7", "Counter only"],
    ["VitalService", "Health, hunger, downed, revive", "<b>Missing</b>"],
    ["LootService", "Chest tier by distance and fuel level", "<b>Missing</b>"],
    ["TraderService", "Day-clock visitor, per-player offers", "<b>Missing</b>"],
], [1.6, 3.2, 1.5])
H2("Rules that must not be broken")
UL([
    "<b>The obelisk is the origin.</b> Distance from it is the difficulty curve.",
    "<b>Day gathers, night bans space.</b> Never both at once.",
    "<b>The night threat is not an HP bar.</b> Light is the API.",
    "<b>Fuel is the only thing that changes the map.</b>",
    "<b>Never trust the client.</b> Send an item id; the server reads the fuel value and subtracts from the "
    "sack. No client-set prices, currency or grants; validate and rate-limit every remote.",
    "<b>The engine never names a game.</b> Anything Hell Week-specific lives in <font face='Courier'>games/"
    "hell-week/</font>, not <font face='Courier'>src/core/</font>.",
    "<b>Tune in config, not code.</b> The 8-second test day is why this rule exists.",
])
H2("Build order from here")
P("Ordered by how much each one strengthens the chain, not by how fun it sounds:")
UL([
    "<b>1. Chest tier by distance and fuel level.</b> The single highest-value missing piece. It is what "
    "makes a wider ring worth wanting, and most of the machinery is already there.",
    "<b>2. Node respawn on a day timer.</b> Without it the near ring strips and never recovers.",
    "<b>3. Hunger.</b> One bar. It turns food from flavour into a plan and gives the day a second clock.",
    "<b>4. Downed and revive.</b> What makes four players a team instead of four solos.",
    "<b>5. The seven trials, properly.</b> Gated by fuel level, each a standing errand, each one making the "
    "week shorter. This is the game's biggest hole.",
    "<b>6. A trader on a day clock.</b> Per-player offers, leaves at night. Cheap; makes days feel "
    "different without a new map.",
    "<b>7. Days 4&ndash;7 as design rather than placeholders.</b>",
])
H2("The runtime loop, as it should read")
CODE([
    "while running do",
    "  ClockService.tick()",
    "  if DAY   then gather on, Jackal off",
    "  if DUSK  then warn 12s, snap the night rig, arm the Jackal",
    "  if NIGHT then Jackal hunts anyone outside the ring or a ward",
    "  BeaconService.burn(dt)",
    "  if night >= 3 then Herald walks in, drinks 1 on arrival",
    "  if fuel == 0 and night and not mercy then end the run",
    "  replicate { day, fuel, radius, trials }",
    "end",
])

H1("Part IV &mdash; Exception pass")
P("Read this before handing Part III to anyone, human or agent. These are the places where Hell Week already "
  "departs from the reference on purpose, and the traps we have actually fallen into.")
H2("Where we differ on purpose")
UL([
    "<b>Seven days, not ninety-nine.</b> A school week and a single sitting. The reference's number is a "
    "payout threshold on an endless clock; ours is the whole game.",
    "<b>No bench.</b> Everything is crafted at the obelisk, which keeps the camp the centre of the world.",
    "<b>Nine items, not hundreds.</b> A child should hold the whole economy in their head.",
    "<b>The fuel ladder replaces the fuel table.</b> 1 &rarr; 3 &rarr; 8 by crafting, not by finding rarer "
    "fuel. Carrying better, not carrying more.",
    "<b>Trials, not rescues.</b> No children, no named civilians, no posters. Seven standing errands.",
    "<b>The siege is one creature, not a wave.</b> It drinks fuel rather than fighting you, which keeps the "
    "pressure on the chain rather than on your aim.",
])
H2("Exceptions inside our own rules")
UL([
    "<b>Night 1:</b> the Jackal watches and does not hunt. <font face='Courier'>mercy = true</font> also "
    "means an empty obelisk does not end the run.",
    "<b>Sieges start night 3</b>, not night 1.",
    "<b>Creatures never spawn inside 78 studs.</b>",
    "<b>The Brand is light you carry, and it is the only portable safety.</b> Do not add a second one.",
])
H2("Mistakes we have actually made &mdash; do not repeat them")
UL([
    "<b>Shipping a night nobody walked.</b> Twice. The brief's numbers rendered the world past the disc pure "
    "black and the Jackal invisible; the fix was moonlight in the same hue. <i>Look at it before calling it "
    "done.</i>",
    "<b>An 8-second test day left in Studio</b> while reporting on the art. Test clocks get reverted in the "
    "same breath they are used.",
    "<b>A leash smaller than the map.</b> The boundary was 360 studs while the pyramid reached 388 and the "
    "sphinx 622, so walking into a tomb teleported the player back to the fire. Hours were spent blaming "
    "stair geometry. <i>When something impossible happens, check what the game itself is doing to the "
    "player before re-deriving the geometry.</i>",
    "<b>A world floor with no holes in it</b>, sealing both tombs' descents &mdash; and a verification pass "
    "that filtered raycasts to the tomb's own parts, which made the floor invisible to the test. <i>A test "
    "that excludes the world cannot find a bug in the world.</i>",
    "<b>A monument with no steps.</b> The sphinx's plinth was a ten-stud kerb and a humanoid climbs two, so "
    "the whole thing was unreachable on foot.",
    "<b>Furniture in the doorway.</b> Grain bins, a sarcophagus and a statue on the centre line of rooms the "
    "route runs straight through. Keep a walking lane down the middle of every room.",
])
H2("What an agent will get wrong if you only say \"make it like 99 Nights\"")
UL([
    "It will give the Jackal a health bar.",
    "It will forget night 1 is safe and punish the tutorial.",
    "It will use walls instead of haze to gate the map.",
    "It will add hunger, thirst, six biomes and a boss before the ring works.",
    "It will copy the children, the deer, or the UI, and get the place moderated or mocked.",
])

H1("Appendix &mdash; the numbers as they stand")
CODE([
    "days        180/40/2 (mercy) | 110/45/4 | 100/50/6 | 90/60/8 | 85/65/10 | 80/70/12 | 75/75/14",
    "beacon      start 2, cap 15, radius 25 + 8/fuel capped 90, feed radius 10",
    "cap light   day 18/1.1   night 42/2.8 flicker   feed +6 for 1s, keeps +2 (max +24)",
    "haze        rings 420 / 620 / 790      leash 820      floor 1700 x 1700",
    "siege       first night 3, 1 fuel per arrival, spawns 210-260",
    "creatures   4 + 2/day capped 14, ring 78-250",
    "sack        6 slots      start: Pickaxe, Dagger      warning 12s",
    "fuel        ashwood 1  |  emberwood 3  |  heartwood 8",
    "pyramid     2,126 parts, 11 chambers, 3,110-stud centre line, 162 waypoints",
    "sphinx      3,783 parts, 5 levels, 9x9 grid, 496 open edges, 17,856 studs of tunnel",
])
P("<b>Bottom line.</b> Hell Week is a clock that sells safety. The obelisk is a radius, the night is a ban on "
  "that radius, the map is a reward for feeding the clock, and the trials are what should make the week "
  "honest. If those four sentences are true in the place, we have the game. If only the sand and the jackal "
  "are true, we do not.")

# ============================================================== render
def decorate(canvas, doc):
    canvas.saveState()
    w, h = LETTER
    canvas.setFillColor(CHAR)
    canvas.rect(0, h - 0.62 * inch, w, 0.62 * inch, stroke=0, fill=1)
    canvas.setFillColor(GOLD)
    canvas.setFont("Helvetica-Bold", 8.4)
    canvas.drawString(0.75 * inch, h - 0.40 * inch, "HELL WEEK  ·  COMPLETE REFERENCE")
    canvas.setFillColor(colors.Color(0.72, 0.70, 0.66))
    canvas.setFont("Helvetica", 7.4)
    canvas.drawRightString(w - 0.75 * inch, h - 0.40 * inch,
                           "Generated from config.luau  ·  tools/make_reference.py")
    canvas.setStrokeColor(colors.Color(0.80, 0.78, 0.74))
    canvas.setLineWidth(0.5)
    canvas.line(0.75 * inch, 0.62 * inch, w - 0.75 * inch, 0.62 * inch)
    canvas.setFillColor(ASH)
    canvas.setFont("Helvetica", 7.6)
    canvas.drawString(0.75 * inch, 0.44 * inch,
                      "Original design. No assets, characters or names from any other game.")
    canvas.setFont("Helvetica-Bold", 8.6)
    canvas.setFillColor(CHAR)
    canvas.drawRightString(w - 0.75 * inch, 0.44 * inch, str(doc.page))
    canvas.restoreState()


doc = BaseDocTemplate("docs/HELL_WEEK_REFERENCE.pdf", pagesize=LETTER,
                      leftMargin=0.75 * inch, rightMargin=0.75 * inch,
                      topMargin=0.88 * inch, bottomMargin=0.78 * inch,
                      title="Hell Week - Complete Reference and Systems Spec",
                      author="Hell Week")
doc.addPageTemplates([PageTemplate(id="page", frames=[Frame(
    doc.leftMargin, doc.bottomMargin, doc.width, doc.height, id="f")], onPage=decorate)])
doc.build(story)
print("wrote docs/HELL_WEEK_REFERENCE.pdf")

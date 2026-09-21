local P = require("./parts")
local F = require("./flight")
local byId = {}
for _, g in pairs(P) do for _, p in ipairs(g) do byId[p.id] = p end end

local RATE, EXP, REPEAT = 700000, 0.38, 0.62
local DV_RATE, DV_EXP = 300000, 1.85
local REFURB, REFURB_REC = 0.04, 0.01
local MILE = {
  {h=5000,"5 km",180000},{h=20000,"20 km",420000},{h=50000,"50 km",900000},
  {h=100000,"KARMAN",2200000},{h=250000,"250 km",4500000},
}
local DVM = {{2000,"dV2k",300000},{3500,"dV3.5k",900000},{5000,"dV5k",2400000},
             {6500,"dV6.5k",5000000},{8000,"dV8k",9000000}}
local ORBIT_PAY, DOCK_PAY = 26000000, 60000000

local own = { nose_blunt=true, gnc_none=true }
local ENG={"eng_hopper","eng_pioneer","eng_vulcan","eng_kestrel","eng_titan","eng_raptor","eng_nova"}
local TNK={"tank_micro","tank_small","tank_medium","tank_large","tank_heavy","tank_core"}
local NOSE={"nose_blunt","nose_cone","nose_ogive","fairing"}
local GNC={"gnc_none","gnc_basic","gnc_inertial","gnc_full"}
local FIN={nil,"fins_basic","fins_grid"}
local function has(id) return id==nil or own[id] end

-- Best assembly buildable from OWNED parts, within the pad mass limit.
local function ownedOf(list)
  local o = {}
  for _, id in ipairs(list) do if own[id] then table.insert(o, id) end end
  return o
end

local function best(padLimit, wantDock)
  local b
  local ENGo, TNKo = ownedOf(ENG), ownedOf(TNK)
  local NOSEo, GNCo = ownedOf(NOSE), ownedOf(GNC)
  local FINo = {false}
  for _, id in ipairs({"fins_basic","fins_grid"}) do if own[id] then table.insert(FINo, id) end end
  local function try(asm)
    for _,s in ipairs(asm.stages) do
      if not (has(s.engine) and has(s.tank) and has(s.fins) and has(s.decoupler)) then return end end
    if not (has(asm.nose) and has(asm.gnc)) then return end
    if asm.rcs and not (own.rcs and own.dock_port) then return end
    local v=F.resolve(asm,P); if v.totalMass>padLimit then return end
    local q=F.quick(v); if q.held then return end
    if not b or q.effectiveDV>b.key then b={key=q.effectiveDV,asm=asm} end
  end
  for _,nose in ipairs(NOSEo) do for _,gnc in ipairs(GNCo) do for _,fin in ipairs(FINo) do
  for _,e1 in ipairs(ENGo) do for _,t1 in ipairs(TNKo) do for c1=1,4 do
    local fins = fin or nil
    local s1={engine=e1,tank=t1,engineCount=c1,fins=fins}
    try({stages={s1},nose=nose,gnc=gnc,rcs=wantDock,dock=wantDock})
    for _,e2 in ipairs(ENGo) do for _,t2 in ipairs(TNKo) do
      if not own.dec_light then break end
      local a={engine=e1,tank=t1,engineCount=c1,fins=fins,decoupler="dec_light"}
      try({stages={a,{engine=e2,tank=t2}},nose=nose,gnc=gnc,rcs=wantDock,dock=wantDock})
      for _,t3 in ipairs({TNKo[#TNKo], TNKo[math.max(1,#TNKo-1)]}) do
        for _,e3 in ipairs({own.eng_nova and "eng_nova" or e2, own.eng_kestrel and "eng_kestrel" or e2}) do
          try({stages={a,{engine=e2,tank=t2,decoupler="dec_light"},{engine=e3,tank=t3}},
               nose=nose,gnc=gnc,rcs=wantDock,dock=wantDock})
        end
      end
    end end
  end end end end end end
  return b
end

local function refurb(asm)
  local c=0
  for _,s in ipairs(asm.stages) do
    local base=byId[s.engine].cost*(s.engineCount or 1)+byId[s.tank].cost
    c += base * (s.recovery and REFURB_REC or REFURB)
  end
  return c + byId[asm.nose].cost*REFURB
end

local ALL={}
for _,g in pairs(P) do for _,p in ipairs(g) do if p.cost and p.cost>0 then table.insert(ALL,p) end end end

local cash, launch, bestH, hit, padTier = 1000000, 0, 0, {}, 1
local bestDV
local padLimit = P.pad[1].massLimit
-- seed: you cannot fly without at least one engine and one tank
own.eng_hopper=true; own.tank_micro=true; cash -= byId.eng_hopper.cost+byId.tank_micro.cost
print(string.format("start $1,000,000  |  bought RM-1 Hopper + Micro Tank, $%.2fM left", cash/1e6))
print(string.rep("-",110))
print(string.format("%-3s %-26s %-11s %-9s %-6s %-8s %-9s %-10s %s","#","bought","refurb","apogee","TWR","dV","effDV","earned","cash"))
print(string.rep("-",110))
while launch < 26 do
  launch += 1
  -- buy the single affordable part that most raises achievable effective dV per dollar
  local pick, pickGain
  local cur = best(padLimit, false)
  local curDV = cur and cur.key or -1e9
  local cands, seen = {}, {}
  local sorted = table.clone(ALL)
  table.sort(sorted, function(a,b) return a.cost < b.cost end)
  for _,p in ipairs(sorted) do
    if p.class and not own[p.id] and p.cost <= cash*0.9 and p.class ~= "payload" then
      seen[p.class] = (seen[p.class] or 0) + 1
      if seen[p.class] <= 2 then table.insert(cands, p) end
    end
  end
  for _,p in ipairs(cands) do
    if true then
      own[p.id]=true
      local n=best(padLimit,false)
      own[p.id]=nil
      if n then
        local gain=(n.key-curDV)/p.cost
        if n.key>curDV and (not pick or gain>pickGain) then pick,pickGain=p,gain end
      end
    end
  end
  if (hit.orbit or (bestDV or 0) > 8800) and not own.dock_port then
    if own.rcs and byId.dock_port.cost<=cash then pick=byId.dock_port
    elseif not own.rcs and byId.rcs.cost<=cash then pick=byId.rcs end
  end
  local boughtName="-"
  if pick then own[pick.id]=true; cash-=pick.cost; boughtName=pick.label end
  local wantDock = own.rcs and own.dock_port
  local b = best(padLimit, wantDock) or best(padLimit,false)
  if not b then print("  no flyable rocket") break end
  local rf=refurb(b.asm); cash-=rf
  local r=F.simulate(F.resolve(b.asm,P))
  local rec=r.apogee>bestH or r.effectiveDV>(bestDV or -1e9)
  local altPay=RATE*(r.apogee/1000)^EXP
  local dvPay=r.effectiveDV>0 and DV_RATE*(r.effectiveDV/1000)^DV_EXP or 0
  local pay=math.max(altPay,dvPay)*(rec and 1 or REPEAT)
  local tags={}
  for _,m in ipairs(MILE) do if r.apogee>=m.h and not hit[m[1]] then hit[m[1]]=true;pay+=m[2];table.insert(tags,m[1]) end end
  for _,m in ipairs(DVM) do if r.effectiveDV>=m[1] and not hit[m[2]] then hit[m[2]]=true;pay+=m[3];table.insert(tags,m[2]) end end
  if r.orbit and not hit.orbit then hit.orbit=true;pay+=ORBIT_PAY;table.insert(tags,"*** ORBIT ***") end
  if r.docked and not hit.dock then hit.dock=true;pay+=DOCK_PAY;table.insert(tags,"*** DOCKED ***") end
  cash+=pay; if r.apogee>bestH then bestH=r.apogee end
  if not bestDV or r.effectiveDV>bestDV then bestDV=r.effectiveDV end
  while padTier<#P.pad and cash>P.pad[padTier+1].cost*2.5 do
    padTier+=1;cash-=P.pad[padTier].cost;padLimit=P.pad[padTier].massLimit
    table.insert(tags,"PAD:"..P.pad[padTier].label) end
  print(string.format("%-3d %-26s $%-10s %-9s %-6.2f %-8.0f %-9.0f $%-9s $%-9s %s",
    launch,boughtName:sub(1,26),string.format("%.2fM",rf/1e6),
    r.orbit and "ORBIT" or string.format("%.1f km",r.apogee/1000),
    r.twr,r.deltaV,r.effectiveDV,string.format("%.2fM",pay/1e6),
    string.format("%.2fM",cash/1e6),table.concat(tags," ")))
  if hit.dock then print(string.rep("-",110));print("DOCKED WITH THE STATION on launch "..launch);break end
end

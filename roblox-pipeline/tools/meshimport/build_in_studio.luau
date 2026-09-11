--!strict
-- LM mesh importer — rebuilds a GLB drop as real geometry inside Studio.
--
-- Run via Studio MCP `execute_luau` (Edit mode) after:
--   1. python3 glb2rbx.py <glb> <out.json>
--   2. serve that json on 127.0.0.1:8731
--
-- Builds one MeshPart per UNIQUE geometry (EditableMesh -> CreateMeshPartAsync),
-- then clones it per node. No Roblox asset upload required.
--
-- LIMIT: CreateMeshPartAsync geometry is RUNTIME ONLY. The resulting MeshParts
-- have MeshId = "" and MeshContent SourceType=None, so they do NOT survive a
-- place save. This is a preview/approval tool. For a permanent placement the
-- fbx must be uploaded (Studio 3D Importer, or Open Cloud Assets API) and the
-- returned asset id referenced from the Rojo source.

local ORIGIN = Vector3.new(0, 0, 0) -- where the model's glTF origin lands, in studs
local DATA_URL = "http://127.0.0.1:8731/kiosk.json"

local AssetService = game:GetService("AssetService")
local HttpService = game:GetService("HttpService")

local prevHttp = HttpService.HttpEnabled
HttpService.HttpEnabled = true
local okFetch, raw = pcall(function()
	return HttpService:GetAsync(DATA_URL)
end)
HttpService.HttpEnabled = prevHttp -- always restored
if not okFetch then
	return { error = "fetch failed: " .. tostring(raw) }
end

local doc = HttpService:JSONDecode(raw)

local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local LUT = {}
for i = 1, #B64 do
	LUT[string.byte(B64, i)] = i - 1
end

local function b64(s: string): buffer
	s = string.gsub(s, "=", "")
	local buf = buffer.create(math.floor(#s * 3 / 4))
	local bi, acc, bits = 0, 0, 0
	for i = 1, #s do
		acc = bit32.bor(bit32.lshift(acc, 6), LUT[string.byte(s, i)])
		bits += 6
		if bits >= 8 then
			bits -= 8
			buffer.writeu8(buf, bi, bit32.band(bit32.rshift(acc, bits), 255))
			bi += 1
			acc = bit32.band(acc, bit32.lshift(1, bits) - 1)
		end
	end
	return buf
end

local old = workspace:FindFirstChild(doc.name)
if old then
	old:Destroy()
end

local protos = {}
for gi, g in ipairs(doc.geoms) do
	local pbuf, ibuf = b64(g.p), b64(g.i)
	local ex = Vector3.new(g.ext[1], g.ext[2], g.ext[3])
	local em = AssetService:CreateEditableMesh()
	local vids = table.create(g.v)
	-- positions arrive int16-quantised inside the geometry's own bbox and are
	-- re-centred here, so the MeshPart pivot is the bbox centre
	for v = 0, g.v - 1 do
		local o = v * 6
		local fx = (buffer.readi16(pbuf, o) + 32768) / 65535 - 0.5
		local fy = (buffer.readi16(pbuf, o + 2) + 32768) / 65535 - 0.5
		local fz = (buffer.readi16(pbuf, o + 4) + 32768) / 65535 - 0.5
		vids[v + 1] = em:AddVertex(Vector3.new(fx * ex.X, fy * ex.Y, fz * ex.Z))
	end
	for t = 0, g.t - 1 do
		local o = t * 6
		local a = vids[buffer.readu16(ibuf, o) + 1]
		local b = vids[buffer.readu16(ibuf, o + 2) + 1]
		local c = vids[buffer.readu16(ibuf, o + 4) + 1]
		local fid = em:AddTriangle(a, b, c)
		local pa, pb, pc = em:GetPosition(a), em:GetPosition(b), em:GetPosition(c)
		local n = (pb - pa):Cross(pc - pa)
		if n.Magnitude > 1e-9 then
			local nid = em:AddNormal(n.Unit)
			em:SetFaceNormals(fid, { nid, nid, nid })
		end
	end
	local okMP, mp = pcall(function()
		return AssetService:CreateMeshPartAsync(Content.fromObject(em), {
			CollisionFidelity = Enum.CollisionFidelity.Box,
		})
	end)
	if not okMP then
		return { error = "geom " .. gi .. ": " .. tostring(mp) }
	end
	protos[gi] = mp
end

local MATENUM = {
	Glass = Enum.Material.Glass,
	Neon = Enum.Material.Neon,
	Metal = Enum.Material.Metal,
	Wood = Enum.Material.Wood,
	Slate = Enum.Material.Slate,
	SmoothPlastic = Enum.Material.SmoothPlastic,
}

local model = Instance.new("Model")
model.Name = doc.name
for _, n in ipairs(doc.nodes) do
	local g = doc.geoms[n.g + 1]
	local m = doc.mats[n.m + 1]
	local part = protos[n.g + 1]:Clone()
	part.Name = n.n
	part.Anchored = true
	part.Color = Color3.new(m.c[1], m.c[2], m.c[3])
	part.Material = MATENUM[m.m] or Enum.Material.SmoothPlastic
	part.Transparency = m.tr
	part.CanCollide = (m.m ~= "Neon")
	part.CFrame = CFrame.new(
		ORIGIN.X + n.t[1] + g.mn[1] + g.ext[1] / 2,
		ORIGIN.Y + n.t[2] + g.mn[2] + g.ext[2] / 2,
		ORIGIN.Z + n.t[3] + g.mn[3] + g.ext[3] / 2
	)
	part.Parent = model
end
model.Parent = workspace
model.PrimaryPart = model:FindFirstChild("Kiosk_Body")

for i = 1, #protos do
	protos[i]:Destroy()
end

local _, size = model:GetBoundingBox()
return {
	parts = #model:GetChildren(),
	uniqueMeshes = #doc.geoms,
	sizeStuds = string.format("%.2f x %.2f x %.2f", size.X, size.Y, size.Z),
}

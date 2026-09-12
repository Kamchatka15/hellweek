-- Server bootstrap. Order is deliberate; see the comments.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Core = ServerScriptService:WaitForChild("Core")
local Net = require(ReplicatedStorage:WaitForChild("Shared").Net)

local ContentLoader = require(Core.ContentLoader)
local DataService = require(Core.DataService)
local LoopService = require(Core.LoopService)
local RemoteGuard = require(Core.RemoteGuard)
local StateSync = require(Core.StateSync)

-- 1. Remotes exist before any code can reference one.
Net.build()
RemoteGuard.start()

-- 2. Pack is read and validated before anything depends on its numbers. A bad pack
--    fails loudly here rather than producing a silently wrong game.
local pack = ContentLoader.load()

-- 3. Loop subscribes to DataService.profileLoaded...
LoopService.start(pack)
StateSync.start()

-- 4. ...and only then does DataService start loading profiles. Reversing 3 and 4 means
--    the first player to join in that window gets no offline grant and no opening
--    state push, which is exactly the kind of bug that only shows up under load.
DataService.start()

print(`[boot] {pack.theme.title} ready`)

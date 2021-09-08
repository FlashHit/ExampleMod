class 'ModificationCommon'

local m_Logger = Logger("ModificationCommon", true)

-- here we create a new DC class with the partition & the instance guid
-- so later in RegisterCallbacks we will do :RegisterLoadHandler(self, self.OnWorldPartDataLoaded)
-- and in there we will do the modification
-- we can do it in the file itself as well, if we only need it in that file
local m_MP001_ConquestSmall0_WorldPartData = DC(Guid("09404C9B-E5D6-4135-B7E2-18F7590A3C6B"), Guid("637EAD5F-34ED-490C-BEEC-F2C299CE57D8"))

-- require here some specific files that modificate something
local m_ExampleModification = require "__shared/Modifications/ExampleModification"

-- this gets called from Shared init (in function RegisterCallbacks)
function ModificationCommon:RegisterCallbacks()
	-- this will return the instance that we defined
	m_MP001_ConquestSmall0_WorldPartData:RegisterLoadHandler(self, self.OnWorldPartDataLoaded)

	-- callbacks that are only needed for that file
	m_ExampleModification:RegisterCallbacks()
end

-- this gets called from Shared init (in function DeregisterCallbacks)
function ModificationCommon:DeregisterCallbacks()
	-- deregister all callbacks
	m_MP001_ConquestSmall0_WorldPartData:Deregister()

	-- callbacks that were only needed for that file
	m_ExampleModification:DeregisterCallbacks()
end

function ModificationCommon:OnWorldPartDataLoaded(p_WorldPartData)
	-- the partition.name will give us information about the map
	-- example: "Loaded WorldPartData for Levels/MP_001/CQ_Logic"
	-- but I think partition.name is always lowercased
	m_Logger:Write("Loaded WorldPartData for " .. Asset(p_WorldPartData).name)

	-- the instance is already casted to WorldPartData
	-- and it is already writable

	-- redirect common events to other required modification files here
	m_ExampleModification:OnWorldPartDataLoaded(p_WorldPartData)
end

return ModificationCommon()

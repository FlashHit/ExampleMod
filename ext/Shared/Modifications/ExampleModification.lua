class 'ExampleModification'

local m_Logger = Logger("ExampleModification", true)

-- with this we handle our common registry
local m_RegistryManager = require "__shared/Logic/RegistryManager"

-- simple example for an ebx modification with the DC class
local m_AmmobagFiringData = DC(Guid("0343F80F-06CC-11E0-8BDF-D7443366E28A"), Guid("5B73C5E2-127E-419B-95FB-A69D9F5CAA7B"))
local m_MedkitFiringData = DC(Guid("B54E9BDA-1F2E-11E0-8602-946E2AD98284"), Guid("F379D6B0-4592-4DC2-9186-5863D3D69C85"))

function ExampleModification:RegisterCallbacks()
	-- DC:RegisterLoadHandler(context, callback)
	m_AmmobagFiringData:RegisterLoadHandler(self, self.DisableAutoReplenish)
	m_MedkitFiringData:RegisterLoadHandler(self, self.DisableAutoReplenish)
end

function ExampleModification:DeregisterCallbacks()
	-- DC:Deregister()
	m_AmmobagFiringData:Deregister()
	m_MedkitFiringData:Deregister()
end

-- Disable infinite medkit and ammobag capacity
function ExampleModification:DisableAutoReplenish(p_FiringFunctionData)
	-- p_FiringFunctionData.ammo.autoReplenishMagazine = false
end

-- called from ModificationCommon
function ExampleModification:OnWorldPartDataLoaded(p_WorldPartData)
	-- Here a simple example of what you could do here

	--[[
	-- Creating a new object
	local s_ReferenceObjectData = ReferenceObjectData()
	s_ReferenceObjectData.blueprint = -- some blueprint
	s_ReferenceObjectData.blueprintTransform = -- a transform
	s_ReferenceObjectData.indexInBlueprint = -- an index

	-- getting the registry where we add it
	local s_RegistryContainer = m_RegistryManager:GetRegistry()

	-- that shouldn't happen
	if s_RegistryContainer == nil then
		m_Logger:Error("Registry not found.")
		return
	end

	-- add it to the WorldPartData
	-- again: we don't have to cast it or make it writable. That is done already.
	p_WorldPartData.objects:add(s_ReferenceObjectData)

	-- add it to our common registry as well
	s_RegistryContainer.referenceObjectRegistry:add(s_ReferenceObjectData)
	]]
end

return ExampleModification()

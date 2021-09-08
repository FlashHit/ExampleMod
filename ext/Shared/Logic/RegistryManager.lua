class 'RegistryManager'

-- this is our init
function RegistryManager:OnExtensionLoaded()
	self:InitializeVariables()
end

function RegistryManager:InitializeVariables()
	self:ResetVariables()
end

function RegistryManager:ResetVariables()
	self.m_Registry = nil
end

-- =============================================
-- Events
-- =============================================

function RegistryManager:OnLevelLoadResources(p_MapName, p_GameModeName, p_DedicatedServer)
	self.m_Registry = RegistryContainer()
end

function RegistryManager:OnLevelRegisterEntityResources(p_LevelData)
	ResourceManager:AddRegistry(self.m_Registry, ResourceCompartment.ResourceCompartment_Game)
	self:ResetVariables()
end

-- =============================================
-- Get Methods
-- =============================================

function RegistryManager:GetRegistry()
	return self.m_Registry
end

return RegistryManager()

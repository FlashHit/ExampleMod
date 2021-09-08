class "BundleManager"

local m_Logger = Logger("BundleManager", true)

function BundleManager:OnExtensionLoaded()
	self:InitializeVariables()
end

function BundleManager:InitializeVariables()
	self.m_LevelName = ""
end

function BundleManager:OnLevelLoadResources(p_LevelName, p_GameMode, p_IsDedicatedServer)
	-- we won't do anything if this is the same level
	if self.m_LevelName == p_LevelName then
		m_Logger:Write("Return OnLoadResources, because it is the same level")
		return
	end

	-- update the current level
	self.m_LevelName = p_LevelName

	-- check if we have a mapconfig for this map
	if MapsConfig[p_LevelName:gsub(".*/", "") .. "_" .. p_GameMode] == nil then
		return
	end

	m_Logger:Write("Mounting SuperBundles:")

	for l_Index, l_SuperBundle in pairs(MapsConfig[p_LevelName:gsub(".*/", "") .. "_" .. p_GameMode].SuperBundles) do
		ResourceManager:MountSuperBundle(l_SuperBundle)
		m_Logger:Write(l_Index .. ": " .. l_SuperBundle)
	end
end

function BundleManager:OnResourceManagerLoadBundles	(p_HookCtx, p_Bundles, p_Compartment)
	local s_LevelName = SharedUtils:GetLevelName()

	-- check if this is the main level bundle & if no other bundles are injected already
	if #p_Bundles == 1 and p_Bundles[1] == s_LevelName then
		-- get gamemode & cut level name
		local s_GameMode = SharedUtils:GetCurrentGameMode()
		s_LevelName = s_LevelName:gsub(".*/", "")

		-- check if we have a mapconfig for this map
		if MapsConfig[s_LevelName .. "_" .. s_GameMode] == nil then
			return
		end

		-- this is the bundle we pass
		local s_Bundles = MapsConfig[s_LevelName .. "_" .. s_GameMode].Bundles

		-- lets print everything before again
		m_Logger:Write("Injecting bundles to main level:")
		-- #s_Bundles - 1, because we don't want to print the bundle of the current level
		for l_Index = 1, #s_Bundles - 1 do
			m_Logger:Write(l_Index .. ": " .. s_Bundles[l_Index])
		end

		-- Note: s_Bundles also has to contain the current level name

		p_HookCtx:Pass(s_Bundles, p_Compartment)
	end
end

function BundleManager:OnTerrainLoad(p_HookCtx, p_TerrainAssetName)
	local s_LevelName = SharedUtils:GetLevelName()
	s_LevelName = s_LevelName:gsub(".*/", "")

	-- check if this terrain is from this map, if not prevent it from loading
	if not p_TerrainAssetName:match(s_LevelName:lower()) then
		m_Logger:Write("Preventing terrain load: " .. p_TerrainAssetName)
		p_HookCtx:Return()
	end
end

return BundleManager()

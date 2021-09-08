class 'SharedExampleMod'

-- global configs
-- we don't need to require this anywhere else
-- as they are required for other files as well we want to require the configs first
-- debugconfig is for things like enable/ disable logger etc.
require "__shared/Config/DebugConfig"

-- this table returns all SupportedMaps (not really huge)
require "__shared/SupportedMaps"

-- require a global logger
-- we don't need to require this anywhere else
require "__shared/Utils/Logger"

-- usage of the logger, we create a new class for this file
local m_Logger = Logger("SharedExampleMod", true)
-- if we do m_Logger:Write("Test") it will return now: "[Shared] Test"
-- so we always know where we did the print & we can easily enable/disable prints
-- you can also use :Error, :Warning, :WriteTable

-- most ebx related stuff can be done with this extension
-- it is also global so we don't need to require this anywhere else
require "__shared/Utils/DataContainer"

-- logic stuff
-- RegistryManager, instead of creating multiple registries we create only one registry
local m_RegistryManager = require "__shared/Logic/RegistryManager"

-- we do all modifications in there. at this point we could do it in here, but who know how much stuff we will add
-- and I don't want this to become messy af
local m_ModificationCommon = require "__shared/Modifications/ModificationCommon"

function SharedExampleMod:__init()
	-- we register all events & hooks in Extension:Loaded to make sure everything is loaded
	Events:Subscribe('Extension:Loaded', self, self.OnExtensionLoaded)
	-- Level:LoadResources is an exception, here we will unsubscribe the events & hooks when we load a not supported map
	-- and resubscribe when the map is supported
	Events:Subscribe('Level:LoadResources', self, self.OnLevelLoadResources)
end

-- take this event as our real init
function SharedExampleMod:OnExtensionLoaded()
	self:SubscribeEvents()
	self:InstallHooks()
	self:RegisterCallbacks()

	-- as we said: this is our real init, so we reroute this event to all files, if needed
	m_RegistryManager:OnExtensionLoaded()

	if self:GetIsHotReload() then
		self:OnHotReload()
	end
end

function SharedExampleMod:SubscribeEvents()
	-- use a table so we are able to unsubscribe these events
	self.m_Events = {
		Events:Subscribe('Level:RegisterEntityResources', self, self.OnLevelRegisterEntityResources),
		Events:Subscribe('Level:Destroy', self, self.OnLevelDestroy)
	}
end

function SharedExampleMod:InstallHooks()
	-- use a table so we are able to uninstall these hooks
	self.m_Hooks = {
		Hooks:Install('ResourceManager:LoadBundles', 1, self, self.OnResourceManagerLoadBundles)
	}
end

function SharedExampleMod:UnsubscribeEvents()
	-- unsubscribe all vext events except Extension:Loaded & Level:LoadResources
	for l_Index = 1, #self.m_Events do
		self.m_Events[l_Index]:Unsubscribe()
	end

	-- clear the events table to so we know we have to resubscribe them on the next supported map
	self.m_Events = {}
end

function SharedExampleMod:UninstallHooks()
	-- uninstall all hooks
	for l_Index = 1, #self.m_Hooks do
		self.m_Hooks[l_Index]:Uninstall()
	end

	-- clear the hooks table to so we know we have to reinstall them on the next supported map
	self.m_Hooks = {}
end

function SharedExampleMod:RegisterCallbacks()
	m_ModificationCommon:RegisterCallbacks()
end

function SharedExampleMod:DeregisterCallbacks()
	m_ModificationCommon:DeregisterCallbacks()
end

-- down below we have all events, then all netevents / custom events, then the hooks, and at least some other functions

-- =============================================
-- Events
-- =============================================

-- the event structure is:
-- 0: ExtensionUnloading Event, 1: Level Events (+ Server Events), 2: Update Events, 3: Player Events, 4: GunSway Events
-- server events count as level events, also they are ordered, first comes what gets triggered first.


-- =============================================
	-- Level Events
-- =============================================

function SharedExampleMod:OnLevelLoadResources(p_LevelName, p_GameMode, p_IsDedicatedServer)
	-- check if this map is supported
	-- example of how the map names work:
	-- p_LevelName:gsub(".*/", "") .. "_" .. p_GameMode => "MP_001_ConquestSmall0"
	-- the gsub:(".*/", "") converts "Levels/MP_001/MP_001" to "MP_001"
	if SupportedMaps[p_LevelName:gsub(".*/", "") .. "_" .. p_GameMode] == nil then
		-- this map is not supported, so we deregister all callbacks
		m_Logger:Write("This map is not supported. Unsubscribe everything...")
		self:UnsubscribeEvents()
		self:UninstallHooks()
		self:DeregisterCallbacks()

		-- don't execute any functions that are getting called below, abort rn
		return
	-- this map is supported, but do we still have the callbacks registered?
	elseif #self.m_Events == 0 then
		-- we need to reregister the callback
		m_Logger:Write("This map is supported. Subscribe everything again...")
		self:SubscribeEvents()
		self:InstallHooks()
		self:RegisterCallbacks()
	end

	-- anything below here will only get called if the map is supported
	-- if we need to call it anyways we have to call it before checking anything
	m_RegistryManager:OnLevelLoadResources(p_LevelName, p_GameMode, p_IsDedicatedServer)
end

function SharedExampleMod:OnLevelRegisterEntityResources(p_LevelData)
	m_RegistryManager:OnLevelRegisterEntityResources(p_LevelData)
end

function SharedExampleMod:OnLevelDestroy()
	-- collect the garbage that we collected in this round
	m_Logger:Write("Memory usage before collecting: " .. math.floor(collectgarbage("count")) .. " MB")
	collectgarbage()
	m_Logger:Write("Memory usage after collecting: " .. math.floor(collectgarbage("count")) .. " MB")
end

-- =============================================
-- Hooks
-- =============================================

function SharedExampleMod:OnResourceManagerLoadBundles(p_HookCtx, p_Bundles, p_Compartment)
	m_Logger:Write("Loading Compartment " .. p_Compartment .. " with bundles:")

	for l_Index = 1, #p_Bundles do
		m_Logger:Write(l_Index .. ": " .. p_Bundles[l_Index])
	end

	-- call something like a BundleManager
end

-- =============================================
-- Functions
-- =============================================

function SharedExampleMod:GetIsHotReload()
	if SharedUtils:IsServerModule() then
		-- server check
		if #SharedUtils:GetContentPackages() == 0 then
			return false
		else
			return true
		end
	else
		-- client check
		if SharedUtils:GetLevelName() == "Levels/Web_Loading/Web_Loading" then
			return false
		else
			return true
		end
	end
end

function SharedExampleMod:OnHotReload()
	m_Logger:Write("Hot reload detected.")

	if SharedUtils:GetLevelName() == nil then
		m_Logger:Write("Level not loaded yet.")
		return
	end

	-- at this point we do nothing OnHotReload
end

return SharedExampleMod()

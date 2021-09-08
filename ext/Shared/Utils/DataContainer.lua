-- made by Janssent

class 'DC'

function DC:__init(p_PartitionGuid, p_InstanceGuid)
	if p_PartitionGuid == nil or p_InstanceGuid == nil then
		error("Invalid guids specified")
	end

	self.m_PartitionGuid = p_PartitionGuid
	self.m_InstanceGuid = p_InstanceGuid
	self.m_ContainerCallbacks = {}
end

function DC:GetInstance()
	local s_Instance = ResourceManager:FindInstanceByGuid(self.m_PartitionGuid, self.m_InstanceGuid)

	if s_Instance == nil then
		return nil
	end

	return _G[s_Instance.typeInfo.name](s_Instance)
end

function DC:CallOrRegisterLoadHandler(p_Userdata, p_Callback)
	local s_Instance = self:GetInstance()

	if s_Instance ~= nil then
		if p_Callback == nil then
			p_Userdata(self:_CastedAndWritable(s_Instance))
		else
			p_Callback(p_Userdata, self:_CastedAndWritable(s_Instance))
		end
	else
		self:RegisterLoadHandlerOnce(p_Userdata, p_Callback)
	end
end

function DC:RegisterLoadHandler(p_Userdata, p_Callback)
	self:_RegisterLoadHandlerInternal(false, p_Userdata, p_Callback)
end

function DC:RegisterLoadHandlerOnce(p_Userdata, p_Callback)
	self:_RegisterLoadHandlerInternal(true, p_Userdata, p_Callback)
end

function DC:Deregister()
	for _, l_ContainerCallback in ipairs(self.m_ContainerCallbacks) do
		l_ContainerCallback:Deregister()
	end

	self.m_ContainerCallbacks = {}
end

function DC:_RegisterLoadHandlerInternal(p_Once, p_Userdata, p_Callback)
	local s_Args

	if p_Callback == nil then
		s_Args = { function(p_Instance) p_Userdata(self:_CastedAndWritable(p_Instance)) end }
	else
		s_Args = { p_Userdata, function(p_Userdata, p_Instance) p_Callback(p_Userdata, self:_CastedAndWritable(p_Instance)) end }
	end

	if p_Once then
		local s_ContainerCallback = ResourceManager:RegisterInstanceLoadHandlerOnce(self.m_PartitionGuid, self.m_InstanceGuid, table.unpack(s_Args))
		table.insert(self.m_ContainerCallbacks, s_ContainerCallback)
	else
		local s_ContainerCallback = ResourceManager:RegisterInstanceLoadHandler(self.m_PartitionGuid, self.m_InstanceGuid, table.unpack(s_Args))
		table.insert(self.m_ContainerCallbacks, s_ContainerCallback)
	end
end

function DC:_CastedAndWritable(p_Instance)
	p_Instance = _G[p_Instance.typeInfo.name](p_Instance)
	p_Instance:MakeWritable()
	return p_Instance
end

function DC.static:WaitForInstances(p_Instances, p_Userdata, p_Callback)
	local s_Instances = {}

	for l_Index, l_DC in ipairs(p_Instances) do
		local s_ContainerCallback = ResourceManager:RegisterInstanceLoadHandlerOnce(l_DC.m_PartitionGuid, l_DC.m_InstanceGuid, function(p_Instance)
			s_Instances[l_Index] = p_Instance

			for i = 1, #p_Instances do
				s_Instances[i] = s_Instances[i] or ResourceManager:FindInstanceByGuid(p_Instances[i].m_PartitionGuid, p_Instances[i].m_InstanceGuid)

				if s_Instances[i] == nil then
					return
				end
			end

			if p_Callback == nil then
				p_Userdata(table.unpack(s_Instances))
			else
				p_Callback(p_Userdata, table.unpack(s_Instances))
			end

			self:WaitForInstances(p_Instances, p_Userdata, p_Callback)
		end)

		table.insert(l_DC.m_ContainerCallbacks, s_ContainerCallback)
	end
end

return DC

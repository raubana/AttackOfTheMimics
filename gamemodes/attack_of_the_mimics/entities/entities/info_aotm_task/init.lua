AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function ENT:Initialize()
	self:SetNoDraw(true)
	self:DrawShadow(false)
	self:SetSolid(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	
	self.description = self.description or "TODO"
	self.active = self.active or false
	self.completed = false
end


function ENT:KeyValue(key, value)
	if key == "taskdescription" then
		self.description = value
	end
end


function ENT:AcceptInput(name, activator)
	if name == "MakeActive" then
		if not self.active then
			self.active = true
			AOTM_SERVER_TASK_MANAGER:AddTask(self)
		end
	elseif name == "MarkComplete" then
		if self.active and not self.completed then
			self.completed = true
			AOTM_SERVER_TASK_MANAGER:BroadcastTasks()
			GAMEMODE:CheckGameState()
		end
	end	
end



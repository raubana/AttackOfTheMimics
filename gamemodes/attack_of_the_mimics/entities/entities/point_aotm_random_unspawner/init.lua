AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function ENT:Initialize()
	self:SetNoDraw(true)
	self:DrawShadow(false)
	self:SetSolid(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	
	self.tobeunspawned = self.tobeunspawned or ""
	self.keepspawned = self.keepspawned or 1
	
	self.ran = false
end


function ENT:KeyValue(key,value)
	if key == "tobeunspawned" then
		self.tobeunspawned = value
	elseif key == "keepspawned" then
		self.keepspawned = math.max( tonumber(value), 1, 0)
	end
end


function ENT:AcceptInput( name, activator, caller, data )
	if name == "Run" then
		if self.ran or not self.tobeunspawned then return end
		local ent_list = ents.FindByName(self.tobeunspawned)
		
		for i = 1, math.max(#ent_list-self.keepspawned, 0) do
			local index = math.random(#ent_list)
			local ent = table.remove(ent_list, index)
			SafeRemoveEntity(ent)
		end
		
		self.ran = true
	end
end



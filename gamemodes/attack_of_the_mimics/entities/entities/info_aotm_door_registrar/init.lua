AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function ENT:Initialize()
	self:SetNoDraw(true)
	self:DrawShadow(false)
	self:SetSolid(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	
	self.doors = self.doors or {}
	
	AOTM_SERVER_DOORKEY_MANAGER:AddRegistrar(self)
end


function ENT:AcceptInput(name, activator, caller, data)
	if name == "RegisterDoor" then
		if not self.doors then
			self.doors = {}
		end
	
		local ent_list = ents.FindByName(data)
		
		for i, ent in ipairs(ent_list) do
			if not table.HasValue(self.doors, ent) then
				ent.doorkey_registrar = self
				table.insert(self.doors, ent)
			end
		end
	end	
end



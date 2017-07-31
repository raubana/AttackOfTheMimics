AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	local physobj = self:GetPhysicsObject()
	if IsValid(physobj) then
		physobj:EnableMotion(false)
	end
	self:SetUseType(SIMPLE_USE)
end


function ENT:KeyValue(key, value)
	if key == "model" then
		self:SetModel(value)
	elseif key == "OnPickUp" then
		self:StoreOutput(key, value)
	end
end


function ENT:Use(activator, caller, useType, value)
	if (not IsValid(activator)) or (not activator:IsPlayer()) or (activator:Team() != TEAM_MECHANIC) then return end

	self:TriggerOutput("OnPickUp", activator)
	SafeRemoveEntity(self)
end

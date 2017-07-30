AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function ENT:Initialize()
	self:SetModel( "models/props_silo/camera.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:GetPhysicsObject():EnableMotion(false)
end


function ENT:KeyValue(key,value)
	if key == "cameraid" then
		self:SetCameraID(value)
	elseif key == "fov" then
		self:SetFOV(tonumber(value))
	end
end
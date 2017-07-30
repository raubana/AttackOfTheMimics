AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function ENT:Initialize()
	self:SetModel( "models/props_c17/tv_monitor01.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:GetPhysicsObject():EnableMotion(false)
	
	AOTM_SERVER_CAMERA_MANAGER:AddDisplay(self)
end


function ENT:AssignCamera( camera_name )
	if not camera_name then
		self:SetCamera(nil)
		return
	end

	local matching_ents = ents.FindByName(camera_name)
	if #matching_ents > 0 then
		self:SetCamera(matching_ents[1])
	else
		ErrorNoHalt(tostring(self).." at "..tostring(self:GetPos()).." recieved a bad camera name: "..camera_name)
	end
end


function ENT:KeyValue(key,value)
	if key == "startcamera" then
		self:AssignCamera( value )
	end
end


function ENT:AcceptInput( name, activator, caller, data )
	if name == "AssignCamera" then
		self:AssignCamera( data )
	end
end


function ENT:OnRemove()
	AOTM_SERVER_CAMERA_MANAGER:DeleteDisplay(self)
end
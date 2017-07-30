AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function ENT:Initialize()
	self:SetNoDraw(true)
	self:DrawShadow(false)
	self:SetSolid(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
end


function ENT:AcceptInput(name, activator, caller, data)
	if name == "AppendCredits" then
		hook.Call("AOTM_AppendCredits", nil, string.Explode("~", data))
	end	
end



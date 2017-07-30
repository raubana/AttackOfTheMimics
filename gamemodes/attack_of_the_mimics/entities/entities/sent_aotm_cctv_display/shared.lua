DEFINE_BASECLASS( "base_anim" )

ENT.PrintName		= "AOTM CCTV Display"
ENT.Author			= "raubana"
ENT.Information		= "For people watching."
ENT.Category		= "Other"

ENT.Editable		= false
ENT.Spawnable		= true
ENT.AdminOnly		= true
ENT.RenderGroup		= RENDERGROUP_OPAQUE


function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "Camera")
end
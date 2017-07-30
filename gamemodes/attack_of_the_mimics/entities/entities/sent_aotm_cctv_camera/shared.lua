DEFINE_BASECLASS( "base_anim" )

ENT.PrintName		= "AOTM CCTV Camera"
ENT.Author			= "raubana"
ENT.Information		= "Big brother is watching."
ENT.Category		= "Other"

ENT.Editable		= false
ENT.Spawnable		= true
ENT.AdminOnly		= true
ENT.RenderGroup		= RENDERGROUP_OPAQUE


function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "FOV")
	self:NetworkVar("String", 0, "CameraID")
end
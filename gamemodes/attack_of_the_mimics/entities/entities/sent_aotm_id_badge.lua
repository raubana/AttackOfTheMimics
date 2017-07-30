AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.PrintName		= "AOTM ID Badge"
ENT.Author			= "raubana"
ENT.Information		= "Hello, my name is..."
ENT.Category		= "AOTM"

ENT.Editable		= false
ENT.Spawnable		= false
ENT.AdminOnly		= true
ENT.RenderGroup		= RENDERGROUP_OPAQUE



function ENT:Initialize()
	self:SetModel("models/attack_of_the_mimics/costume/id_badge.mdl")
	
	if CLIENT then
		self.idbadge_texture = AOTM_CLIENT_IDBADGE_MANAGER:CreateIDBadgeTexture()
		self:UpdateRenderTarget(self:GetParent(), self.idbadge_texture)
	end
end


if SERVER then
	function ENT:PinToPlayer( ply )
		local bone_id = ply:LookupBone( "ValveBiped.Bip01_Spine2" )
		
		-- TODO: Do something else if the lookup fails
		
		local bone_pos = ply:GetBonePosition(bone_id)
		local bone_ang = ply:GetBoneMatrix(bone_id):GetAngles()
		
		bone_ang:RotateAroundAxis(bone_ang:Up(), 90)
		bone_ang:RotateAroundAxis(bone_ang:Forward(), 90)
		
		self:SetPos( bone_pos + (bone_ang:Forward() * 10) + (bone_ang:Up() * 7) + (bone_ang:Right() * 3) )
		self:SetAngles( bone_ang + Angle(-15,-15,0) )
		
		self:SetParent( ply, bone_id )
	end
end


if CLIENT then
	function ENT:UpdateRenderTarget()
		AOTM_CLIENT_IDBADGE_MANAGER:UpdateRenderTarget(self:GetParent(), self.idbadge_texture)
	end

	function ENT:OnRemove()
		AOTM_CLIENT_IDBADGE_MANAGER:DeleteIDBadgeTexture(self.idbadge_texture)
	end
	
	local mat_data = {}
	local tempMat = tempMat
	if not tempMat then
		tempMat = CreateMaterial("AOTM_IDBADGE_MAT", "VertexLitGeneric", mat_data)
	end

	function ENT:Draw()
		tempMat:SetTexture("$basetexture", self.idbadge_texture)
		render.MaterialOverride(tempMat)
		self:DrawModel()
		render.MaterialOverride()
	end
end
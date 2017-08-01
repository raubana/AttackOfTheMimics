AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.PrintName		= "AOTM Mimic Body"
ENT.Author			= "raubana"
ENT.Information		= ""
ENT.Category		= "AOTM"

ENT.Editable		= false
ENT.Spawnable		= false
ENT.AdminOnly		= true
ENT.RenderGroup		= RENDERGROUP_OPAQUE



function ENT:Initialize()
	if SERVER then
		self.next_can_mimic = 0
	else
		self:SetRenderBounds(vector_origin, vector_origin, Vector(1,1,1)*100)
		self:SetPredictable(false)
		self.do_not_draw = false
	end
end



function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "Mimic")
end


if SERVER then
	function ENT:UpdateTransmitState()
		return TRANSMIT_ALWAYS
	end


	local MIN_VOLUME = 30000
	local MAX_VOLUME = 250000
	local MIN_DIMENSION = 20
	local MAX_DIMENSION = 100

	function ENT:Mimic( model, skin, do_not_emit_sound )
		if CurTime() < self.next_can_mimic then return end
		
		local do_not_emit_sound = do_not_emit_sound
		if not isbool(do_not_emit_sound) then
			do_not_emit_sound = false
		end
	
		local skin = skin
		if not skin then
			skin = 0
		end
		
		local old_model = self:GetModel()
		local old_skin = self:GetSkin()
		
		if old_model == model then return end
		
		self:SetModel(model)
		self:SetSkin(skin)
		
		local mins = self:OBBMins()
		local maxs = self:OBBMaxs()
		
		local size = maxs - mins
		
		local volume = size.x * size.y * size.z
		
		print(size, volume)
		
		if math.min(size.x, size.y, size.z) >= MIN_DIMENSION and math.max(size.x, size.y, size.z) <= MAX_DIMENSION and volume >= MIN_VOLUME and volume <= MAX_VOLUME then
			if not do_not_emit_sound then
				-- self:EmitSound("attack_of_the_mimics/player/mimic_transform.wav")
			end
			
			self.next_can_mimic = CurTime() + 2.5
		else
			self:SetModel(old_model)
			self:SetSkin(old_skin)
		end
	end
	
	
	function ENT:Think()
		local mimic = self:GetMimic()
		
		if IsValid(mimic) then
			self:SetPos(mimic:GetPos())
		end
	
	
		self:NextThink(CurTime() + 0.25)
		return true
	end
end

if CLIENT then
	function ENT:Draw()
		local mimic = self:GetMimic()
		
		if IsValid(mimic) then
			local ang = mimic:EyeAngles()
			ang.pitch = 0
			self:SetRenderAngles(ang)
			
			local mins = self:OBBMins()
			local maxs = self:OBBMaxs()
			
			local size = maxs - mins
			self:SetRenderOrigin(mimic:GetPos() - Vector(0,0,mins.z))
			
			if self.do_not_draw  then
				-- do nothing
			else
				self:DrawModel()
			end
		else
			self:DrawModel()
		end
	end
end
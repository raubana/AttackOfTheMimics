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


--[[
local BONE_DATA = {
	{
		bone_name = "ValveBiped.Bip01_Head1",
		angle = Angle(-90,-90,0),
		offset = Vector(0,0,-0.9),
		clips = {
			{
				offset = Vector(0,0,0.5),
				normal = Vector(0,0,1)
			}
		}
	},
	
	{
		bone_name = "ValveBiped.Bip01_Spine",
		angle = Angle(0,90,90),
		offset = Vector(0,0,0),
		clips = {
			{
				offset = Vector(0,0,0.5),
				normal = Vector(0,0,-1)
			},
			
			{
				offset = Vector(0,0,-0.5),
				normal = Vector(0,0,1)
			},
			
			{
				offset = Vector(0,0.5,0),
				normal = Vector(0,-1,0)
			},
			
			{
				offset = Vector(0,-0.5,0),
				normal = Vector(0,1,0)
			},
		}
	},
	
	{
		bone_name = "ValveBiped.Bip01_R_Forearm",
		angle = Angle(90,-120,0),
		offset = Vector(0,0.25,0),
		clips = {
			{
				offset = Vector(0,0,0.5),
				normal = Vector(0,0,-1)
			},
			
			{
				offset = Vector(0,0,-0.5),
				normal = Vector(0,0,1)
			},
			
			{
				offset = Vector(0,-0.5,0),
				normal = Vector(0,-1,0)
			},
		}
	},
	
	{
		bone_name = "ValveBiped.Bip01_L_Forearm",
		angle = Angle(90,-60,0),
		offset = Vector(0,-0.5,0),
		clips = {
			{
				offset = Vector(0,0,0.5),
				normal = Vector(0,0,-1)
			},
			
			{
				offset = Vector(0,0,-0.5),
				normal = Vector(0,0,1)
			},
			
			{
				offset = Vector(0,0.5,0),
				normal = Vector(0,1,0)
			},
		}
	},
	
	{
		bone_name = "ValveBiped.Bip01_R_Foot",
		angle = Angle(0,-45,90),
		offset = Vector(0,-0.5,1),
		clips = {
			{
				offset = Vector(0,0,-0.5),
				normal = Vector(0,0,-1)
			},
			
			{
				offset = Vector(0,0,0),
				normal = Vector(0,-1,0)
			},
		}
	},
	
	{
		bone_name = "ValveBiped.Bip01_L_Foot",
		angle = Angle(0,-45,90),
		offset = Vector(0,0.25,1),
		clips = {
			
			{
				offset = Vector(0,0,-0.5),
				normal = Vector(0,0,-1)
			},
			
			{
				offset = Vector(0,0,0),
				normal = Vector(0,1,0)
			},
		}
	}
}
]]


function ENT:Initialize()
	if SERVER then
		self.next_can_mimic = 0
	else
		self:SetRenderBounds(vector_origin-(Vector(1,1,1)*100), vector_origin+(Vector(1,1,1)*100))
		self.do_not_draw = false
		
		--[[
		self.hiding_trans = SMOOTH_TRANS:create(0.2)
		
		self.client_props = {}
		self.client_prop_model = ""
		
		for i = 1, #BONE_DATA do
			local prop = ClientsideModel("models/error.mdl", RENDERGROUP_OPAQUE)
			prop:SetNoDraw(true)
			prop:Spawn()
			
			table.insert(self.client_props, prop)
		end
		]]
	end
end



function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "Mimic")
end


--[[
if CLIENT then
	function ENT:OnRemove()
		for i, prop in ipairs(self.client_props) do
			if IsValid(prop) then
				prop:Remove()
			end
		end
	end
end
]]


if SERVER then
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
		
		-- print(size, volume)
		
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
end


function ENT:Think()
	local mimic = self:GetMimic()
	
	if IsValid(mimic) then
		local ang = mimic:EyeAngles()
		ang.pitch = 0
		
		self:SetAngles(ang)
	
		local mins = self:OBBMins()
		local maxs = self:OBBMaxs()
		
		local size = maxs - mins
		local pos = mimic:GetPos() - Vector(0,0,mins.z)
		self:SetPos(pos)
		
		--[[
		if CLIENT then
			local expected_model = self:GetModel()
			
			if expected_model != self.client_prop_model then
				self.client_prop_model = expected_model
				for i, prop in ipairs(self.client_props) do
					prop:SetModel(expected_model)
				end
			end
			
			local rel_vel = mimic:GetVelocity() - mimic:GetBaseVelocity()
			
			self.hiding_trans:SetDirection( rel_vel:Length() > 90 or not mimic:GetIsHiding() )
			self.hiding_trans:Update()
		end
		]]
	end

	self:NextThink(CurTime() + 0.25)
	-- did not call NextClientThink because this needs to update every frame.
	return true
end


if CLIENT then
	function ENT:Draw()
		local mimic = self:GetMimic()
		
		if IsValid(mimic) then
			if self.do_not_draw then
				-- do nothing
			else
				self:DrawModel()
			
				--[[
				local p = self.hiding_trans:GetPercent()
				
				if p <= 0 then
					self:DrawModel()
				else
					if p < 1 then p = 1-((math.cos(p*math.pi)+1)/2) end
				
					local my_angle = self:GetAngles()
					local my_pos = self:GetPos()
					
					local mins = self:OBBMins()
					local maxs = self:OBBMaxs()
					
					local size = maxs-mins
					
					local true_center = LerpVector(0.5, maxs, mins)
					
					for i, bone_data in ipairs(BONE_DATA) do
						local prop = self.client_props[i]
						
						if IsValid(prop) then
							prop:SetNoDraw(false)
						
							local bone_num = mimic:LookupBone(bone_data.bone_name)
						
							local bone_pos = mimic:GetBonePosition(bone_num)
							local bone_matrix = mimic:GetBoneMatrix(bone_num)
							local bone_angle = bone_matrix:GetAngles()
							
							local new_bone_angle = bone_matrix:GetAngles()
							
							new_bone_angle:RotateAroundAxis(bone_angle:Forward(), bone_data.angle.roll)
							new_bone_angle:RotateAroundAxis(bone_angle:Up(), bone_data.angle.yaw)
							new_bone_angle:RotateAroundAxis(bone_angle:Right(), bone_data.angle.pitch)
							
							-- debugoverlay.Axis(bone_pos, bone_angle, 25, 0.1, true)
							
							local offset = (size * bone_data.offset * 0.5) - true_center
							offset:Rotate(new_bone_angle)
							local new_bone_pos = bone_pos + offset
							
							new_bone_pos = LerpVector(p, my_pos, new_bone_pos)
							new_bone_angle = LerpAngle(p, my_angle, new_bone_angle)
							
							prop:SetRenderOrigin(new_bone_pos)
							prop:SetRenderAngles(new_bone_angle)
							
							local has_clips = tobool(bone_data.clips) and #bone_data.clips > 0
							
							if has_clips then
								for i, clip_data in ipairs(bone_data.clips) do
									local pos = (size * clip_data.offset * 0.5) + true_center
									pos:Rotate(new_bone_angle)
									pos = pos + new_bone_pos
									
									local normal = 1.0 * clip_data.normal
									normal:Rotate(new_bone_angle)
									
									-- debugoverlay.Axis(pos, normal:Angle(), 25, 0.1, true)
									
									render.PushCustomClipPlane(normal, normal:Dot(pos))
								end
							end
							
							render.CullMode(MATERIAL_CULLMODE_CCW)
							prop:DrawModel()
							render.CullMode(MATERIAL_CULLMODE_CW)
							prop:DrawModel()
							render.CullMode(MATERIAL_CULLMODE_CCW)
							
							if has_clips then
								for i = 1, #bone_data.clips do
									render.PopCustomClipPlane()
								end
							end
							
							prop:SetNoDraw(true)
						end
					end
				end
				]]--
			end
		else
			self:DrawModel()
		end
	end
end
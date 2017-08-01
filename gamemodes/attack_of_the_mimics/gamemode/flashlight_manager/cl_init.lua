include("shared.lua")

AOTM_CLIENT_FLASHLIGHT_MANAGER = AOTM_CLIENT_FLASHLIGHT_MANAGER or {}
AOTM_CLIENT_FLASHLIGHT_MANAGER.flashlights = AOTM_CLIENT_FLASHLIGHT_MANAGER.flashlights or {}


hook.Add( "Tick", "AOTM_Tick_FlashlightManager", function()
	local i = #AOTM_CLIENT_FLASHLIGHT_MANAGER.flashlights
	
	while i > 0 do
		local ent = AOTM_CLIENT_FLASHLIGHT_MANAGER.flashlights[i]
		
		if not IsValid(ent) or not ent:GetIsActivated() then
			table.remove(AOTM_CLIENT_FLASHLIGHT_MANAGER.flashlights, i)
			ent.proj_text:Remove()
			ent.proj_text = nil
		end
		
		i = i - 1
	end

	local flashlights = ents.FindByClass("swep_aotm_flashlight")
	
	for i, ent in ipairs(flashlights) do
		if ent:GetIsActivated() and not ent.proj_text then
			table.insert(AOTM_CLIENT_FLASHLIGHT_MANAGER.flashlights, ent)
			
			proj_text = ProjectedTexture()
			proj_text:SetEnableShadows(true)
			proj_text:SetTexture("effects/flashlight001")
			proj_text:SetBrightness(3)
			local fov = 45
			proj_text:SetHorizontalFOV(fov)
			proj_text:SetVerticalFOV(fov)
			proj_text:SetFarZ(2048*0.75)
			proj_text:SetColor(color_white)
			
			ent.proj_text = proj_text
		end
	end
end )


hook.Add( "PreRender", "AOTM_PreRender_FlashlightManager", function()
	for i, ent in ipairs(AOTM_CLIENT_FLASHLIGHT_MANAGER.flashlights) do
		local proj_text = ent.proj_text
		
		if ent.Owner and IsValid(ent.Owner) then
			local ang = ent.Owner:EyeAngles()
			
			proj_text:SetAngles(ang)
			proj_text:SetPos(ent.Owner:EyePos() + (ang:Forward() * 30) - (ang:Up()*3) + (ang:Right()*3))
			proj_text:Update()
			
			local dlight = DynamicLight( ent.Owner:EntIndex() + 1 )
			if ( dlight ) then
				dlight.pos = ent.Owner:EyePos() + (ang:Forward()*25)
				dlight.r = 255
				dlight.g = 255
				dlight.b = 255
				dlight.brightness = 1.0
				dlight.Decay = 1000
				dlight.Size = 64
				dlight.DieTime = CurTime() + 1.0
			end
		else
			proj_text:SetAngles(ent:GetAngles())
			proj_text:SetPos(ent:GetPos())
			proj_text:Update()
		end
	end
end )



print("flashlight manager cl_init")
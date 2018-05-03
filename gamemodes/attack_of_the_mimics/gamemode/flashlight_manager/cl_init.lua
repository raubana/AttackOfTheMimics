include("shared.lua")

AOTM_CLIENT_FLASHLIGHT_MANAGER = AOTM_CLIENT_FLASHLIGHT_MANAGER or {}
AOTM_CLIENT_FLASHLIGHT_MANAGER.flashlights = AOTM_CLIENT_FLASHLIGHT_MANAGER.flashlights or {}


local FOV = 75
local FARZ = 1024*2
local FLASHLIGHT_TEXTURE = "effects/flashlight/soft"


local BRIGHT = 0.5
local FLASHLIGHT_R = 255*BRIGHT
local FLASHLIGHT_G = 238*BRIGHT
local FLASHLIGHT_B = 170*BRIGHT
local BRIGHTNESS = 1


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
			proj_text:SetTexture(FLASHLIGHT_TEXTURE)
			proj_text:SetBrightness(BRIGHTNESS)
			proj_text:SetHorizontalFOV(FOV)
			proj_text:SetVerticalFOV(FOV)
			proj_text:SetFarZ(FARZ)
			proj_text:SetColor(Color(FLASHLIGHT_R,FLASHLIGHT_G,FLASHLIGHT_B))
			
			ent.proj_text = proj_text
		end
	end
end )


local prng = PerlinNoiseGenerator:create()


hook.Add( "PreRender", "AOTM_PreRender_FlashlightManager", function()
	local localplayer = LocalPlayer()
	
	if not IsValid(localplayer) then return end

	for i, ent in ipairs(AOTM_CLIENT_FLASHLIGHT_MANAGER.flashlights) do
		local proj_text = ent.proj_text
		
		if ent.Owner and IsValid(ent.Owner) then
			local t = RealTime()
			local ang = ent.Owner:EyeAngles()
			local pitch_offset = 0
			local yaw_offset = 0
			local roll_offset = 0
			
			if ent.Owner == localplayer then
				ang = 1.0 * localplayer.target_view_angle -- some dependence on the angular velocity dampening :/
			end
			
			local vel = ent.Owner:GetVelocity():Length()
			
			-- shaky hands
			local dist = 0.75
			if vel > 0 and ent.Owner:IsOnGround() then
				dist = dist + math.min(vel / 600, 1)*16
			end
			pitch_offset = pitch_offset + Lerp(prng:GenPerlinNoise(t + localplayer:EntIndex() + 13,10,0.75,3), -1, 1)*dist
			yaw_offset = yaw_offset + Lerp(prng:GenPerlinNoise(t + localplayer:EntIndex() + 37,10,0.75,3), -1, 1)*dist
			roll_offset = roll_offset + Lerp(prng:GenPerlinNoise(t + localplayer:EntIndex() + 71,10,0.75,3), -1, 1)*dist
			
			-- TODO: Make a global running animation system
			-- running animation
			--[[
			local dist = 0.0
			if vel > 0 then
				dist = dist + math.min(vel / 600, 1)*200
			end
			pitch_offset = pitch_offset + Lerp(prng:GenPerlinNoise(t + localplayer:EntIndex() + 13,4,2,2), -1, 1)*dist
			yaw_offset = yaw_offset + Lerp(prng:GenPerlinNoise(t + localplayer:EntIndex() + 37,4,2,2), -1, 1)*dist
			]]
			
			ang.pitch = ang.pitch + pitch_offset
			ang.yaw = ang.yaw + yaw_offset
			ang.roll = ang.roll + roll_offset
			
			proj_text:SetAngles(ang)
			proj_text:SetPos(ent.Owner:EyePos() + (ang:Forward() * 10) - (ang:Up()*3) + (ang:Right()*3))
			proj_text:Update()
		else
			proj_text:SetAngles(ent:GetAngles())
			proj_text:SetPos(ent:GetPos())
			proj_text:Update()
		end
	end
end )



print("flashlight manager cl_init")
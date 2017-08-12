include("shared.lua")

AOTM_CLIENT_FLASHLIGHT_MANAGER = AOTM_CLIENT_FLASHLIGHT_MANAGER or {}
AOTM_CLIENT_FLASHLIGHT_MANAGER.flashlights = AOTM_CLIENT_FLASHLIGHT_MANAGER.flashlights or {}


local FOV = 45
local FARZ = 2048*0.75
local FLASHLIGHT_TEXTURE = "effects/flashlight001"


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
			proj_text:SetBrightness(3)
			proj_text:SetHorizontalFOV(FOV)
			proj_text:SetVerticalFOV(FOV)
			proj_text:SetFarZ(FARZ)
			proj_text:SetColor(Color(255,255,255))
			
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
			local ang = ent.Owner:EyeAngles()
			if ent.Owner == localplayer then
				ang = 1.0 * localplayer.target_view_angle
				
				local dist = 0.75
				
				local t = RealTime()
				
				local pitch_offset = 0
				local yaw_offset = 0
				local roll_offset = 0
				
				pitch_offset = pitch_offset + Lerp(prng:GenPerlinNoise(t + localplayer:EntIndex() + 13,10,0.75,3), -dist, dist)
				yaw_offset = yaw_offset + Lerp(prng:GenPerlinNoise(t + localplayer:EntIndex() + 37,10,0.75,3), -dist, dist)
				roll_offset = roll_offset + Lerp(prng:GenPerlinNoise(t + localplayer:EntIndex() + 71,10,0.75,3), -dist, dist)
				
				ang.pitch = ang.pitch + pitch_offset
				ang.yaw = ang.yaw + yaw_offset
				ang.roll = ang.roll + roll_offset
			end
			
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


--[[
local RT_SIZE = 128
local rt_texture = GetRenderTarget("AOTM_VOL_LIGHT", RT_SIZE, RT_SIZE, false)

local mat_data = {}
mat_data["$basetexture"] = "AOTM_VOL_LIGHT"
mat_data["$additive"] = 1
mat_data["$nocull"] = 1
mat_data["$vertexcolor"] = 1
mat_data["$vertexalpha"] = 1
local vollight_mat = CreateMaterial("AOTM_VOL_LIGHT_MAT", "UnlitGeneric", mat_data)

mat_data = {}
mat_data["$basetexture"] = "color/black"
mat_data["$vertexcolor"] = 1
mat_data["$vertexalpha"] = 1
local black_mat = CreateMaterial("AOTM_VOL_LIGHT_BLACK_MAT", "UnlitGeneric", mat_data)


local mat = Material(FLASHLIGHT_TEXTURE)


local doing_rt_render = false
hook.Add( "PostDrawTranslucentRenderables", "AOTM_PostDrawTranslucentRenderables_FlashlightManager", function(bDrawingDepth, bDrawingSkybox)
	if doing_rt_render then return end
	
	render.SetColorModulation(1.0, 1.0, 1.0)
	render.SetBlend(1.0)
	
	for i, ent in ipairs(AOTM_CLIENT_FLASHLIGHT_MANAGER.flashlights) do
		if ent.Owner and IsValid(ent.Owner) then
			local ang = ent.Owner:EyeAngles()
			local normal = ang:Forward()
			local origin = ent.Owner:EyePos() + (ang:Forward() * 30) - (ang:Up()*3) + (ang:Right()*3)
			local tan = math.tan(math.rad(FOV/2))
			
			doing_rt_render = true
		
			render.PushRenderTarget(rt_texture)
				render.RenderView({
					origin = origin,
					angles = ang,
					aspectratio = 1.0,
					x = 0,
					y = 0,
					w = RT_SIZE,
					h = RT_SIZE,
					fov = FOV,
					drawviewmodel = false,
					dopostprocess = false,
					bloomtone = false
				})
				
				render.Clear(255,0,0,1,false,true)
			render.PopRenderTarget()
			
			doing_rt_render = false
			
			
			local oldW, oldH = ScrW(), ScrH()
			
			render.SetViewPort( 0, 0, RT_SIZE,RT_SIZE )
			render.PushRenderTarget(rt_texture)
				cam.Start2D()
					surface.SetDrawColor(color_black)
					surface.DrawOutlinedRect(0,0,RT_SIZE,RT_SIZE)
				cam.End2D()
			render.PopRenderTarget()
			render.SetViewPort( 0, 0, oldW, oldH )
			
			
			local parts = math.floor(FARZ/25)
			
			for i = 1, parts do
				local p = 1-(i/(parts+1))
				
				local pos = LerpVector( p, origin, origin+(normal*FARZ) )
				local size = 2*(tan*FARZ*p)
				
				render.PushRenderTarget(rt_texture)
					render.SetMaterial(black_mat)
					cam.Start3D( origin, ang, FOV, 0, 0, RT_SIZE, RT_SIZE )
						render.DrawQuadEasy( pos-(normal*2), -normal, size, size, color_white, 180 )
					cam.End3D()
				render.PopRenderTarget()
				
				
				render.SetMaterial(vollight_mat)
				render.DrawQuadEasy( pos, -normal, size, size, color_white, 180 )
				render.CullMode(MATERIAL_CULLMODE_CW)
				render.DrawQuadEasy( pos, -normal, size, size, color_white, 180 )
				render.CullMode(MATERIAL_CULLMODE_CCW)
			end
		else
			-- do nothing
		end
	end
end )
]]



print("flashlight manager cl_init")
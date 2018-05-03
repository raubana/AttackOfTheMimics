include("shared.lua")

AOTM_CLIENT_CAMERA_MANAGER = AOTM_CLIENT_CAMERA_MANAGER or {}
AOTM_CLIENT_CAMERA_MANAGER.rt_list = AOTM_CLIENT_CAMERA_MANAGER.rt_list or {}
AOTM_CLIENT_CAMERA_MANAGER.unused_rt_list = AOTM_CLIENT_CAMERA_MANAGER.unused_rt_list or {}

AOTM_CLIENT_CAMERA_MANAGER.queued_info = AOTM_CLIENT_CAMERA_MANAGER.queued_info or {}

AOTM_CLIENT_CAMERA_MANAGER.updating_render_targets = AOTM_CLIENT_CAMERA_MANAGER.updating_render_targets or false



AOTM_CLIENT_CAMERA_MANAGER.WIDTH = 512
AOTM_CLIENT_CAMERA_MANAGER.HEIGHT = 512



function AOTM_CLIENT_CAMERA_MANAGER:CreateCameraTexture( )
	local texture
	if #self.unused_rt_list > 0 then
		texture = table.remove(self.unused_rt_list)
		print("REUSED TEXTURE: ", texture)
	else
		local name = "AOTM_CCTV_"..tostring(#self.rt_list + #self.unused_rt_list)
		texture = GetRenderTarget(name, self.WIDTH, self.HEIGHT, false)
		print("MADE NEW TEXTURE: ", texture)
	end
	
	table.insert(self.rt_list, texture)
	
	return texture
end


function AOTM_CLIENT_CAMERA_MANAGER:DeleteCameraTexture( texture )
	if table.HasValue(self.rt_list, texture) then
		print("MOVED TEXTURE TO UNUSED LIST:", texture)
		table.RemoveByValue(self.rt_list, texture)
		table.insert(self.unused_rt_list, texture)
	end
end


function AOTM_CLIENT_CAMERA_MANAGER:QueueData( source_ent, texture, origin, angles, fov )
	table.insert(self.queued_info, {source_ent, texture, origin, angles, fov})
end


function AOTM_CLIENT_CAMERA_MANAGER:UpdateRenderTarget( source_ent, texture, origin, angles, fov )
	--[[
	local temp_Texture = GetRenderTarget("AOTM_CCTV_TEMP", AOTM_CLIENT_CAMERA_MANAGER.WIDTH, AOTM_CLIENT_CAMERA_MANAGER.HEIGHT, false)
	local mat_ColorMod = Material( "pp/colour" )
	local old_texture = mat_ColorMod:GetTexture("$fbtexture")
	mat_ColorMod:SetTexture( "$fbtexture", temp_Texture )
	]]
	
	render.PushRenderTarget(texture)
	
	local fov = fov or 45
	
	local nodraw = source_ent:GetNoDraw()
	source_ent:SetNoDraw(true)
	
	local dyn_light = render.ComputeDynamicLighting(origin, angles:Forward())
	local light = render.ComputeLighting(origin, angles:Forward())
	
	light = light - dyn_light
	
	local nightvision = math.min(light.x, light.y, light.z) <= 0.01
	
	local proj_text
	
	if nightvision then
		proj_text = ProjectedTexture()
		proj_text:SetEnableShadows(true)
		proj_text:SetTexture("effects/flashlight001")
		proj_text:SetBrightness(1)
		proj_text:SetColor(HSVToColor(0,0,0.5))
		proj_text:SetHorizontalFOV(fov*1.2)
		proj_text:SetVerticalFOV(fov*1.2)
		proj_text:SetPos(origin-(angles:Up()*5))
		proj_text:SetAngles(angles)
		proj_text:Update()
	end
	
	render.RenderView({
		origin = origin,
		angles = angles,
		aspectratio = 1.0,
		x = 0,
		y = 0,
		w = self.WIDTH,
		h = self.HEIGHT,
		fov = fov,
		drawviewmodel = false,
		dopostprocess = false,
		bloomtone = false
	})
	
	if nightvision then
		proj_text:Remove()
	end
	
	source_ent:SetNoDraw(nodraw)
	
	render.BlurRenderTarget(texture, 1, 1, 1)
	
	--[[
	render.CopyRenderTargetToTexture(temp_Texture)
	
	local contrast = 1.0
	if nightvision then contrast = 4.0 end
	
	local color_mod = {}
	color_mod["$pp_colour_addr"] = 0.0
	color_mod["$pp_colour_addg"] = 0.0
	color_mod["$pp_colour_addb"] = 0.0
	color_mod["$pp_colour_brightness"] = 0.0
	color_mod["$pp_colour_contrast"] = contrast
	color_mod["$pp_colour_colour"] = 0.0
	color_mod["$pp_colour_multr"] = 0.0
	color_mod["$pp_colour_multg"] = 0.0
	color_mod["$pp_colour_multb"] = 0.0
	
	for k, v in pairs(color_mod) do
		mat_ColorMod:SetFloat(k, v)
	end
	
	render.SetMaterial(mat_ColorMod)
	render.DrawScreenQuad()
	]]
	
	render.PopRenderTarget()
	
	-- mat_ColorMod:SetTexture( "$fbtexture", old_texture )
end


hook.Add( "PreRender", "AOTM_PreRender_CameraManager_ClInit", function()
	if not AOTM_CLIENT_CAMERA_MANAGER.updating_render_targets then
		AOTM_CLIENT_CAMERA_MANAGER.updating_render_targets = true
		
		local i = #AOTM_CLIENT_CAMERA_MANAGER.queued_info
	
		while i > 0 do
			local data = table.remove(AOTM_CLIENT_CAMERA_MANAGER.queued_info)
			AOTM_CLIENT_CAMERA_MANAGER:UpdateRenderTarget(data[1], data[2], data[3], data[4], data[5])
			i = i - 1
		end
		
		AOTM_CLIENT_CAMERA_MANAGER.updating_render_targets = false
	else
		return
	end
end )


print("camera manager cl_init")
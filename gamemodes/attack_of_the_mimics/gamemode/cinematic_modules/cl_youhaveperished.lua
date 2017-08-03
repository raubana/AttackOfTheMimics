
local start_time = 0.0


local FONT = FONT
if not FONT then
	FONT = surface.CreateFont( "AOTM_YouHavePerished", {font="Georgia", size=64} )
end


net.Receive( "AOTM_YouHavePerished", function(len, ply)
	print("perished start")
	
	start_time = RealTime()
	
	AOTM_CLIENT_MUSIC_MANAGER:StopAllSongs()
	AOTM_CLIENT_MUSIC_MANAGER:StartSong("attack_of_the_mimics/music/youhaveperished.mp3", 1.0, 1, false)
	
	
	hook.Add( "HUDShouldDraw", "AOTM_HUDShouldDraw_YouHavePerished", function(name)
		return name == "CHudGMod" or name == "CHudChat"
	end )
	
	
	hook.Add( "CalcView", "AOTM_CalcView_YouHavePerished", function(ply, origin, angles, fov, znear, zfar)
		local view = {
			origin = origin,
			angles = angles,
			fov = fov,
			znear = znear,
			zfar = zfar
		}
		
		local t = RealTime() - start_time
		
		view.angles:RotateAroundAxis( view.angles:Up(), Lerp((math.cos(math.pi*2*3*t)+1)/2, -0.5, 0.5) )
		view.angles:RotateAroundAxis( view.angles:Right(), Lerp((math.cos(math.pi*2*5*t)+1)/2, -0.5, 0.5) )
		
		return view
	end )
	
	
	hook.Add( "HUDPaint", "AOTM_HUDPaint_YouHavePerished", function()
		local t = RealTime() - start_time
		
		local p = 0
		
		
		if t < 4 then
			-- do nothing
		elseif t < 7 then
			p = math.Clamp( math.InvLerp(t, 4, 7), 0, 1 )
		elseif t < 10 then
			p = 1.0
		elseif t < 15 then
			p = math.Clamp( math.InvLerp(t, 15, 10), 0, 1 )
		end
		
		if p > 0 then
			local t = "You Have Perished"
		
			surface.SetFont("AOTM_YouHavePerished")
			surface.SetTextColor(Color(0,0,0,255*p))
			
			local w, h = surface.GetTextSize(t)
			surface.SetTextPos((ScrW()-w)/2, (ScrH()-h)/2)
			surface.DrawText(t)
		end
	end )
	
	
	hook.Add( "PreDrawHUD", "AOTM_RenderScreenspaceEffects_YouHavePerished", function()
		if AOTM_CLIENT_CAMERA_MANAGER.updating_render_targets then
			return
		end
	
		local t = RealTime() - start_time
		
		if t < 1.8 then
			local p = t/1.8
			
			DrawSharpen( 10.0, Lerp((math.cos(math.pi*2*12*t)+1)/2, -1, 1))
			
			local color_mod = {}
			color_mod["$pp_colour_addr"] = 0.0
			color_mod["$pp_colour_addg"] = 0.0
			color_mod["$pp_colour_addb"] = 0.0
			color_mod["$pp_colour_brightness"] = Lerp(math.pow(p,16), -0.05, -1.0)
			color_mod["$pp_colour_contrast"] = -10
			color_mod["$pp_colour_colour"] = 0.0
			color_mod["$pp_colour_mulr"] = -10.0
			color_mod["$pp_colour_mulg"] = 0.0
			color_mod["$pp_colour_mulb"] = 0.0
			
			DrawColorModify(color_mod)
		else
			local p = math.Clamp( math.InvLerp(t, 1.8, 20) , 0, 1)
			
			local color_mod = {}
			color_mod["$pp_colour_addr"] = 0.0
			color_mod["$pp_colour_addg"] = 0.0
			color_mod["$pp_colour_addb"] = 0.0
			color_mod["$pp_colour_brightness"] = Lerp(p, 0.33, 0.0)
			color_mod["$pp_colour_contrast"] = Lerp(p, 0.5, 1.0)
			color_mod["$pp_colour_colour"] = Lerp(p, 0.0, 1.0)
			color_mod["$pp_colour_mulr"] = 0.0
			color_mod["$pp_colour_mulg"] = 0.0
			color_mod["$pp_colour_mulb"] = 0.0
			
			DrawColorModify(color_mod)
			
			render.CheapBlur(math.min(ScrW(), ScrH())* 0.25 * 0.5 * (math.pow(1-p,2)))
		end
		
		if t > 1.8 then
			hook.Remove("CalcView", "AOTM_CalcView_YouHavePerished")
		end
		
		if t > 10 then
			hook.Remove("HUDShouldDraw", "AOTM_HUDShouldDraw_YouHavePerished")
		end
		
		if t > 20 then
			hook.Remove("HUDPaint", "AOTM_HUDPaint_YouHavePerished")
			hook.Remove("RenderScreenspaceEffects", "AOTM_RenderScreenspaceEffects_YouHavePerished")
		end
	end )
	
end )


print("cl_youhaveperished ran")
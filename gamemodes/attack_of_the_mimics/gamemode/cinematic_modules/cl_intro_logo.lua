local LOGO_DURATION = 12.0

local matLogo = Material("attack_of_the_mimics/vgui/logos/logo_transition")

local logo_starttime = 0.0


local function calc_padded_screen_size( screen_width, screen_height, padding )
	local screen_ratio = screen_width / screen_height
		
	local padded_screen_height
	local padded_screen_width
	
	if screen_ratio > 1.0 then
		padded_screen_height = screen_height * (1-padding)
		padded_screen_width = screen_width - (screen_height - padded_screen_height)
	else
		padded_screen_width = screen_width * (1-padding)
		padded_screen_height = screen_height - (screen_width - padded_screen_width)
	end
	
	return padded_screen_width, padded_screen_height
end


net.Receive( "AOTM_RunIntroLogo", function(len, ply)
	print("logo start")

	logo_starttime = RealTime()
	
	local localplayer = LocalPlayer()
	if IsValid(localplayer) then
		AOTM_CLIENT_MUSIC_MANAGER:StopAllSongs()
		AOTM_CLIENT_MUSIC_MANAGER:StartSong("attack_of_the_mimics/music/intro_theme.mp3", 0.33, 1, false)
	end
	
	hook.Add( "HUDShouldDraw", "AOTM_HUDShouldDraw_IntroLogo", function(name)
		return name == "CHudGMod" or name == "CHudChat"
	end )
	
	hook.Add( "RenderScreenspaceEffects", "AOTM_RenderScreenspaceEffects_IntroLogo", function()
		if AOTM_CLIENT_CAMERA_MANAGER.updating_render_targets then
			return
		end
	
		local p = (RealTime() - logo_starttime) / LOGO_DURATION
		
		local color_mod = {}
		color_mod["$pp_colour_addr"] = 0.0
		color_mod["$pp_colour_addg"] = 0.0
		color_mod["$pp_colour_addb"] = 0.0
		color_mod["$pp_colour_brightness"] = 0.0
		color_mod["$pp_colour_contrast"] = p
		color_mod["$pp_colour_colour"] = 1.0
		color_mod["$pp_colour_mulr"] = 0.0
		color_mod["$pp_colour_mulg"] = 0.0
		color_mod["$pp_colour_mulb"] = 0.0
		
		DrawColorModify(color_mod)
		
		render.CheapBlur(math.min(ScrW(), ScrH())* 0.25 * 0.5 * (math.pow(1-p,2)))
		
		if p >= 1.0 then
			hook.Remove("HUDShouldDraw", "AOTM_HUDShouldDraw_IntroLogo")
			hook.Remove("RenderScreenspaceEffects", "AOTM_RenderScreenspaceEffects_IntroLogo")
			hook.Remove("HUDPaint", "AOTM_HUDPaint_IntroLogo")
		end
	end )
	

	hook.Add( "HUDPaint", "AOTM_HUDPaint_IntroLogo", function()
		local p = (RealTime() - logo_starttime) / LOGO_DURATION
	
		local scrw = ScrW()
		local scrh = ScrH()
		
		local padded_scrw, padded_scrh = calc_padded_screen_size(scrw, scrh, 0.5)
		
		local screen_ratio = scrw/scrh
		local padded_screen_ratio = padded_scrw/padded_scrh
		
		local r_width = 896
		local r_height = 512
		
		local ratio = r_width/r_height
		
		if padded_screen_ratio < ratio then
			r_height = padded_scrw*(1.0/ratio)
			r_width = r_height * ratio
		else
			-- TODO: Did I do this right?
			r_width = padded_scrh*ratio
			r_height = r_width/ratio
		end
		
		local logo_p = Lerp(1-p, -0.5, 1.25)
		logo_p = math.Clamp(logo_p, 0.01, 0.99)
		
		if logo_p < 0.89 then
		
			matLogo:SetFloat("$alphatestreference", logo_p)
			matLogo:Recompute()
			
			surface.SetDrawColor(color_white)
			surface.SetMaterial(matLogo)
			surface.DrawTexturedRect((scrw-r_width)/2, (scrh-r_height)/2, r_width, r_height)
		end
	end )
	
end )



print("cl_intro_logo ran")